import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmClockScreen extends StatefulWidget {
  const AlarmClockScreen({Key? key}) : super(key: key);

  @override
  _AlarmClockScreenState createState() => _AlarmClockScreenState();
}

class _AlarmClockScreenState extends State<AlarmClockScreen> {
  TimeOfDay? _selectedTime;
  DateTime? _alarmTime;
  Timer? _timer;
  String _currentTime = '';
  bool _isAlarmSet = false;
  bool _isAlarmRinging = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _alarmMessage;
  final TextEditingController _messageController = TextEditingController();

  // Voice control
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _voiceText = '';
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _updateCurrentTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCurrentTime();
      _checkAlarm();
    });
    _initSpeech();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Khởi tạo speech recognition
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
    setState(() {});
  }

  // Bắt đầu lắng nghe giọng nói
  void _startListening() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cần cấp quyền microphone để sử dụng giọng nói'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chức năng nhận dạng giọng nói không khả dụng'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _voiceText = result.recognizedWords.toLowerCase();
        });
        if (result.finalResult) {
          _processVoiceCommand(_voiceText);
        }
      },
      localeId: 'vi_VN',
    );

    setState(() {
      _isListening = true;
    });
  }

  // Dừng lắng nghe
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Xử lý lệnh giọng nói
  void _processVoiceCommand(String command) {
    print('Voice command: $command');

    // Hủy báo thức trước khi xử lý lệnh mới
    if (command.contains('hủy') || command.contains('tắt báo thức')) {
      if (_isAlarmSet) {
        _cancelAlarm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy báo thức theo lệnh giọng nói'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return;
    }

    // Đặt/Hẹn báo thức - hỗ trợ nhiều format
    // "đặt báo thức 7 giờ", "hẹn báo thức 14 giờ 30", "báo thức 7:30"
    bool isSetAlarmCommand =
        command.contains('đặt') ||
        command.contains('hẹn') ||
        command.contains('báo thức');

    // Pattern 1: "X giờ Y phút" hoặc "X giờ Y"
    final timeRegex1 = RegExp(r'(\d+)\s*giờ\s*(\d*)\s*phút?');
    final match1 = timeRegex1.firstMatch(command);

    // Pattern 2: "X:Y" (format 7:30)
    final timeRegex2 = RegExp(r'(\d+):(\d+)');
    final match2 = timeRegex2.firstMatch(command);

    int? hour;
    int? minute;

    if (match1 != null) {
      hour = int.parse(match1.group(1)!);
      minute = match1.group(2)!.isNotEmpty ? int.parse(match1.group(2)!) : 0;
    } else if (match2 != null) {
      hour = int.parse(match2.group(1)!);
      minute = int.parse(match2.group(2)!);
    }

    if (hour != null &&
        minute != null &&
        hour >= 0 &&
        hour <= 23 &&
        minute >= 0 &&
        minute <= 59) {
      setState(() {
        _selectedTime = TimeOfDay(hour: hour!, minute: minute!);
      });

      // Tự động kích hoạt báo thức nếu có từ khóa đặt/hẹn
      if (isSetAlarmCommand) {
        _setAlarm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã hẹn báo thức ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Chỉ hiển thị thời gian, yêu cầu xác nhận
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã chọn ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}. Nhấn "Đặt báo thức" để kích hoạt',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Kích hoạt',
              textColor: Colors.white,
              onPressed: _setAlarm,
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Không nhận diện được lệnh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Không nhận diện được lệnh.\nThử nói: "Hẹn báo thức 7 giờ 30" hoặc "Đặt báo thức 14:30"',
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _updateCurrentTime() {
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  void _checkAlarm() {
    if (_isAlarmSet && _alarmTime != null && !_isAlarmRinging) {
      final now = DateTime.now();
      if (now.hour == _alarmTime!.hour && now.minute == _alarmTime!.minute) {
        _triggerAlarm();
      }
    }
  }

  Future<void> _triggerAlarm() async {
    setState(() {
      _isAlarmRinging = true;
    });

    // Phát âm thanh báo thức (sử dụng âm thanh mặc định từ assets)
    try {
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      // Nếu không có file âm thanh, sử dụng URL
      try {
        await _audioPlayer.play(
          UrlSource('https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3'),
        );
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      } catch (e) {
        print('Error playing sound: $e');
      }
    }

    // Hiển thị dialog báo thức
    if (mounted) {
      _showAlarmDialog();
    }
  }

  void _showAlarmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.alarm, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('BÁO THỨC!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _alarmMessage ?? 'Đã đến giờ báo thức!',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('HH:mm').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _stopAlarm,
            icon: const Icon(Icons.stop),
            label: const Text('Tắt báo thức'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _stopAlarm() {
    _audioPlayer.stop();
    setState(() {
      _isAlarmRinging = false;
      _isAlarmSet = false;
      _alarmTime = null;
      _selectedTime = null;
      _alarmMessage = null;
    });
    Navigator.of(context).pop();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _setAlarm() {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn giờ báo thức!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      final now = DateTime.now();
      _alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Nếu thời gian đã qua, đặt cho ngày mai
      if (_alarmTime!.isBefore(now)) {
        _alarmTime = _alarmTime!.add(const Duration(days: 1));
      }

      _isAlarmSet = true;
      _alarmMessage = _messageController.text.isEmpty
          ? null
          : _messageController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Báo thức đã được đặt vào ${_selectedTime!.format(context)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelAlarm() {
    setState(() {
      _isAlarmSet = false;
      _alarmTime = null;
      _selectedTime = null;
      _alarmMessage = null;
      _messageController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã hủy báo thức'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đồng hồ báo thức'),
        backgroundColor: Colors.purple,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Hiển thị đồng hồ hiện tại
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Thời gian hiện tại',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Nút điều khiển bằng giọng nói
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [Colors.red.shade300, Colors.red.shade500]
                        : [Colors.green.shade300, Colors.green.shade500],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.green)
                          .withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isListening
                              ? 'Đang nghe...'
                              : 'Điều khiển bằng giọng nói',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_voiceText.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '"$_voiceText"',
                          style: const TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _isListening
                          ? _stopListening
                          : _startListening,
                      icon: Icon(_isListening ? Icons.stop : Icons.mic),
                      label: Text(
                        _isListening ? 'Dừng lắng nghe' : 'Nhấn để nói',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _isListening
                            ? Colors.red
                            : Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ví dụ: "Đặt báo thức 7 giờ 30" hoặc "Hủy báo thức"',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Phần đặt báo thức
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.alarm_add, color: Colors.purple.shade700),
                        const SizedBox(width: 10),
                        const Text(
                          'Đặt báo thức',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Hiển thị thời gian đã chọn
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _selectedTime == null
                                ? 'Chưa chọn giờ'
                                : _selectedTime!.format(context),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _selectedTime == null
                                  ? Colors.grey
                                  : Colors.purple.shade700,
                            ),
                          ),
                          if (_isAlarmSet) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Báo thức đang hoạt động',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Ô nhập tin nhắn báo thức
                    TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Tin nhắn báo thức (tùy chọn)',
                        hintText: 'Nhập tin nhắn nhắc nhở...',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.message,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    // Nút chọn giờ
                    ElevatedButton.icon(
                      onPressed: _isAlarmSet ? null : _selectTime,
                      icon: const Icon(Icons.schedule, size: 24),
                      label: const Text(
                        'Chọn giờ báo thức',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Nút đặt hoặc hủy báo thức
                    if (!_isAlarmSet)
                      ElevatedButton.icon(
                        onPressed: _setAlarm,
                        icon: const Icon(Icons.alarm_on, size: 24),
                        label: const Text(
                          'Đặt báo thức',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _cancelAlarm,
                        icon: const Icon(Icons.alarm_off, size: 24),
                        label: const Text(
                          'Hủy báo thức',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Hướng dẫn
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Hướng dẫn sử dụng:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '1. Nhấn "Chọn giờ báo thức" để chọn thời gian\n'
                      '2. Nhập tin nhắn nhắc nhở (tùy chọn)\n'
                      '3. Nhấn "Đặt báo thức" để kích hoạt\n'
                      '4. Báo thức sẽ kêu với âm thanh khi đến giờ\n'
                      '5. Nhấn "Tắt báo thức" trong dialog để dừng',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

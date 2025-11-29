import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({Key? key}) : super(key: key);

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  List<String> _laps = [];

  // Voice control
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _voiceText = '';
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speechToText.stop();
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
  void _stopListeningVoice() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Xử lý lệnh giọng nói
  void _processVoiceCommand(String command) {
    print('Voice command: $command');

    // Bắt đầu
    if (command.contains('bắt đầu') ||
        command.contains('start') ||
        command.contains('chạy') ||
        command.contains('khởi động')) {
      if (!_stopwatch.isRunning) {
        _startStopwatch();
        _showFeedback('Đã bắt đầu bấm giờ');
      }
      return;
    }

    // Tạm dừng / Dừng
    if (command.contains('dừng') ||
        command.contains('tạm dừng') ||
        command.contains('stop') ||
        command.contains('pause')) {
      if (_stopwatch.isRunning) {
        _stopStopwatch();
        _showFeedback('Đã tạm dừng');
      }
      return;
    }

    // Ghi vòng
    if (command.contains('vòng') ||
        command.contains('lap') ||
        command.contains('ghi')) {
      if (_stopwatch.isRunning) {
        _recordLap();
        _showFeedback('Đã ghi vòng ${_laps.length}');
      } else {
        _showFeedback('Cần bắt đầu đồng hồ trước', isError: true);
      }
      return;
    }

    // Reset / Đặt lại
    if (command.contains('reset') ||
        command.contains('đặt lại') ||
        command.contains('xóa') ||
        command.contains('làm mới')) {
      _resetStopwatch();
      _showFeedback('Đã đặt lại đồng hồ');
      return;
    }

    // Không nhận diện được
    _showFeedback('Không nhận diện được lệnh', isError: true);
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.orange : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startStopwatch() {
    setState(() {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        setState(() {});
      });
    });
  }

  void _stopStopwatch() {
    setState(() {
      _stopwatch.stop();
      _timer?.cancel();
    });
  }

  void _resetStopwatch() {
    setState(() {
      _stopwatch.reset();
      _timer?.cancel();
      _laps.clear();
    });
  }

  void _recordLap() {
    if (_stopwatch.isRunning) {
      setState(() {
        String lapTime = _formatTime(_stopwatch.elapsed);
        _laps.insert(0, 'Vòng ${_laps.length + 1}: $lapTime');
      });
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = (duration.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds.$milliseconds';
    } else {
      return '$minutes:$seconds.$milliseconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayTime = _formatTime(_stopwatch.elapsed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đồng hồ bấm giờ'),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              // Hiển thị đồng hồ bấm giờ
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _stopwatch.isRunning ? Icons.timer : Icons.timer_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      displayTime,
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Nút điều khiển bằng giọng nói
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [Colors.red.shade300, Colors.red.shade500]
                        : [Colors.teal.shade300, Colors.teal.shade500],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.teal)
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
                          ? _stopListeningVoice
                          : _startListening,
                      icon: Icon(_isListening ? Icons.stop : Icons.mic),
                      label: Text(
                        _isListening ? 'Dừng lắng nghe' : 'Nhấn để nói',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _isListening
                            ? Colors.red
                            : Colors.teal,
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
                      'Nói: "Bắt đầu", "Dừng", "Vòng", "Đặt lại"',
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
              // Các nút điều khiển
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Nút Start/Stop
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _stopwatch.isRunning
                              ? Colors.orange.shade700
                              : Colors.green.shade600,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_stopwatch.isRunning
                                          ? Colors.orange
                                          : Colors.green)
                                      .withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _stopwatch.isRunning
                              ? _stopStopwatch
                              : _startStopwatch,
                          icon: Icon(
                            _stopwatch.isRunning
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _stopwatch.isRunning ? 'Tạm dừng' : 'Bắt đầu',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _stopwatch.isRunning
                              ? Colors.orange.shade700
                              : Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                  // Nút Lap
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _stopwatch.isRunning ? _recordLap : null,
                          icon: const Icon(
                            Icons.flag,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Vòng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                  // Nút Reset
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _resetStopwatch,
                          icon: const Icon(
                            Icons.refresh,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Đặt lại',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Danh sách các vòng
              if (_laps.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.list_alt, color: Colors.teal.shade700),
                      const SizedBox(width: 10),
                      Text(
                        'Danh sách vòng (${_laps.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _laps.clear();
                          });
                        },
                        icon: Icon(
                          Icons.clear_all,
                          color: Colors.teal.shade700,
                        ),
                        tooltip: 'Xóa tất cả',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _laps.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade300),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_laps.length - index}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          _laps[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.access_time,
                          color: Colors.teal.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.timelapse,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Chưa có vòng nào được ghi lại',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nhấn nút "Vòng" để ghi lại thời gian',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
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
                      '• Nhấn "Bắt đầu" để bắt đầu đếm thời gian\n'
                      '• Nhấn "Tạm dừng" để dừng tạm thời\n'
                      '• Nhấn "Vòng" để ghi lại thời gian hiện tại\n'
                      '• Nhấn "Đặt lại" để reset về 0\n'
                      '• Độ chính xác: 1/100 giây',
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

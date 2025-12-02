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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Đồng hồ bấm giờ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Hiển thị đồng hồ bấm giờ
                Container(
                  padding: const EdgeInsets.all(35),
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
                        _stopwatch.isRunning
                            ? Icons.timer
                            : Icons.timer_outlined,
                        size: 50,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        displayTime,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Các nút điều khiển
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Nút Start/Stop
                    _buildControlButton(
                      icon: _stopwatch.isRunning
                          ? Icons.pause
                          : Icons.play_arrow,
                      label: _stopwatch.isRunning ? 'Dừng' : 'Bắt đầu',
                      color: _stopwatch.isRunning
                          ? Colors.orange.shade600
                          : Colors.green.shade600,
                      onPressed: _stopwatch.isRunning
                          ? _stopStopwatch
                          : _startStopwatch,
                    ),
                    // Nút Lap
                    _buildControlButton(
                      icon: Icons.flag,
                      label: 'Vòng',
                      color: Colors.blue.shade600,
                      onPressed: _stopwatch.isRunning ? _recordLap : null,
                    ),
                    // Nút Reset
                    _buildControlButton(
                      icon: Icons.refresh,
                      label: 'Đặt lại',
                      color: Colors.red.shade600,
                      onPressed: _resetStopwatch,
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // Nút điều khiển bằng giọng nói
                Container(
                  padding: const EdgeInsets.all(12),
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
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isListening
                                ? 'Đang nghe...'
                                : 'Điều khiển giọng nói',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (_voiceText.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '"$_voiceText"',
                            style: const TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _isListening
                            ? _stopListeningVoice
                            : _startListening,
                        icon: Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          size: 20,
                        ),
                        label: Text(
                          _isListening ? 'Dừng' : 'Nhấn để nói',
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _isListening
                              ? Colors.red
                              : Colors.teal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lệnh: "Bắt đầu", "Dừng", "Vòng", "Đặt lại"',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Danh sách các vòng
                if (_laps.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          color: Colors.teal.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Danh sách vòng (${_laps.length})',
                          style: TextStyle(
                            fontSize: 16,
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
                            size: 20,
                          ),
                          tooltip: 'Xóa tất cả',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 32,
                            height: 32,
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
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            _laps[index],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(
                            Icons.access_time,
                            color: Colors.teal.shade400,
                            size: 18,
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.timelapse,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có vòng nào',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Nhấn "Vòng" để ghi lại',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final bool isDisabled = onPressed == null;
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey.shade300 : color,
            shape: BoxShape.circle,
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              size: 32,
              color: isDisabled ? Colors.grey.shade500 : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDisabled ? Colors.grey.shade500 : color,
          ),
        ),
      ],
    );
  }
}

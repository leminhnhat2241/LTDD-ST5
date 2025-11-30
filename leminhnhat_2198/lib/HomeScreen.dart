import 'package:flutter/material.dart';
import 'TemperatureConverterScreen.dart';
import 'UnitConverterScreen.dart';
import 'YouTubePlayerScreen.dart';
import 'AlarmClockScreen.dart';
import 'StopwatchScreen.dart';
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // Thêm thư viện speech_to_text
import 'package:permission_handler/permission_handler.dart'; // Thêm thư viện permission_handler

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _startListening() async {
    await _requestMicrophonePermission();

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${error.errorMsg}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords.toLowerCase();
          });
          _processVoiceCommand(_recognizedText);
        },
        localeId: 'vi_VN',
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể khởi động nhận diện giọng nói'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _processVoiceCommand(String command) {
    // Chuyển đổi nhiệt độ
    if (command.contains('nhiệt độ') ||
        command.contains('chuyển đổi nhiệt') ||
        command.contains('độ c') ||
        command.contains('độ f')) {
      _stopListening();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TemperatureConverterScreen()),
      );
      return;
    }

    // Chuyển đổi đơn vị
    if (command.contains('đơn vị') ||
        command.contains('chuyển đổi đơn') ||
        command.contains('mét') ||
        command.contains('feet') ||
        command.contains('kilômét')) {
      _stopListening();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UnitConverterScreen()),
      );
      return;
    }

    // YouTube
    if (command.contains('youtube') ||
        command.contains('video') ||
        command.contains('xem video')) {
      _stopListening();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const YouTubePlayerScreen()),
      );
      return;
    }

    // Báo thức
    if (command.contains('báo thức') ||
        command.contains('đồng hồ báo') ||
        command.contains('alarm') ||
        command.contains('báo giờ')) {
      _stopListening();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AlarmClockScreen()),
      );
      return;
    }

    // Bấm giờ / Stopwatch
    if (command.contains('bấm giờ') ||
        command.contains('đồng hồ bấm') ||
        command.contains('stopwatch') ||
        command.contains('đo thời gian')) {
      _stopListening();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StopwatchScreen()),
      );
      return;
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng dụng chuyển đổi'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            tooltip: _isListening ? 'Đang nghe...' : 'Điều khiển giọng nói',
            onPressed: _isListening ? _stopListening : _startListening,
            color: _isListening ? Colors.red : Colors.white,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Hiển thị trạng thái nhận diện giọng nói
              if (_isListening)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic, color: Colors.red, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đang nghe...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            if (_recognizedText.isNotEmpty)
                              Text(
                                _recognizedText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isListening) const SizedBox(height: 20),
              const Text(
                'Chọn chức năng chuyển đổi:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Hướng dẫn voice control
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.mic,
                          size: 20,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Điều khiển giọng nói:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• "Nhiệt độ" - Chuyển đổi nhiệt độ\n'
                      '• "Đơn vị" - Chuyển đổi đơn vị đo\n'
                      '• "YouTube" hoặc "Video" - Xem video\n'
                      '• "Báo thức" - Đồng hồ báo thức\n'
                      '• "Bấm giờ" - Đồng hồ bấm giờ',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Nút chuyển đổi nhiệt độ
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TemperatureConverterScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.thermostat, size: 28),
                label: const Text(
                  'Chuyển đổi nhiệt độ',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 16),
              // Nút chuyển đổi đơn vị đo
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UnitConverterScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.straighten, size: 28),
                label: const Text(
                  'Chuyển đổi đơn vị đo',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 16),
              // Nút xem video YouTube
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const YouTubePlayerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_filled, size: 28),
                label: const Text(
                  'Xem video YouTube',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 16),
              // Nút đồng hồ báo thức
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlarmClockScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.alarm, size: 28),
                label: const Text(
                  'Đồng hồ báo thức',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 16),
              // Nút đồng hồ bấm giờ
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StopwatchScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.timer, size: 28),
                label: const Text(
                  'Đồng hồ bấm giờ',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 40),
              // Hiển thị ảnh từ Internet với xử lý lỗi
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGQr4vSTzTPnM6JMqYxvsP9xS8wSvjcw8kMw&s',
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Không có kết nối Internet',
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

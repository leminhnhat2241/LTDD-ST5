import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leminhnhat_2198/RealtimeTranslateScreen.dart';
import 'package:leminhnhat_2198/ImageTranslateOverlayScreen.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  bool _isTranslating = false;
  bool _isListening = false;
  bool _isRecognizing = false;

  late stt.SpeechToText _speech;
  final ImagePicker _imagePicker = ImagePicker();

  TranslateLanguage _sourceLanguage = TranslateLanguage.vietnamese;
  TranslateLanguage _targetLanguage = TranslateLanguage.english;

  OnDeviceTranslator? _translator;

  final Map<TranslateLanguage, String> _languageNames = {
    TranslateLanguage.vietnamese: 'Tiếng Việt',
    TranslateLanguage.english: 'English',
    TranslateLanguage.chinese: '中文',
    TranslateLanguage.japanese: '日本語',
    TranslateLanguage.korean: '한국어',
    TranslateLanguage.french: 'Français',
    TranslateLanguage.german: 'Deutsch',
    TranslateLanguage.spanish: 'Español',
    TranslateLanguage.thai: 'ไทย',
  };

  final Map<TranslateLanguage, String> _localeIds = {
    TranslateLanguage.vietnamese: 'vi_VN',
    TranslateLanguage.english: 'en_US',
    TranslateLanguage.chinese: 'zh_CN',
    TranslateLanguage.japanese: 'ja_JP',
    TranslateLanguage.korean: 'ko_KR',
    TranslateLanguage.french: 'fr_FR',
    TranslateLanguage.german: 'de_DE',
    TranslateLanguage.spanish: 'es_ES',
    TranslateLanguage.thai: 'th_TH',
  };

  @override
  void initState() {
    super.initState();
    _initTranslator();
    _initSpeech();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    await _speech.initialize();
  }

  void _initTranslator() async {
    _translator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    );
  }

  Future<void> _startListening() async {
    // Kiểm tra quyền microphone
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cần cấp quyền microphone để sử dụng chức năng này',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
          if (mounted) {
            String errorMessage = 'Lỗi nhận dạng giọng nói';

            // Xử lý các loại lỗi cụ thể
            if (error.errorMsg.contains('network')) {
              errorMessage =
                  'Không có kết nối Internet.\nVui lòng kiểm tra kết nối mạng.';
            } else if (error.errorMsg.contains('no-speech')) {
              errorMessage = 'Không phát hiện giọng nói.\nVui lòng thử lại.';
            } else if (error.errorMsg.contains('audio')) {
              errorMessage =
                  'Lỗi microphone.\nVui lòng kiểm tra quyền truy cập.';
            } else if (error.errorMsg.contains('not-allowed')) {
              errorMessage =
                  'Quyền microphone bị từ chối.\nVui lòng cấp quyền trong cài đặt.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Đóng',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);

        String localeId = _localeIds[_sourceLanguage] ?? 'vi_VN';

        _speech.listen(
          onResult: (result) {
            setState(() {
              _textController.text = result.recognizedWords;
            });
          },
          localeId: localeId,
          listenMode: stt.ListenMode.confirmation,
        );
      } else {
        // Speech recognition không khả dụng
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nhận dạng giọng nói không khả dụng.\nVui lòng kiểm tra kết nối Internet.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _pickImageAndRecognize(ImageSource source) async {
    try {
      setState(() => _isRecognizing = true);

      final XFile? image = await _imagePicker.pickImage(source: source);

      if (image == null) {
        setState(() => _isRecognizing = false);
        return;
      }

      setState(() => _isRecognizing = false);

      // Navigate to image overlay screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageTranslateOverlayScreen(
              imagePath: image.path,
              sourceLanguage: _sourceLanguage,
              targetLanguage: _targetLanguage,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isRecognizing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn nguồn ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImageAndRecognize(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImageAndRecognize(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _translate() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản cần dịch')),
      );
      return;
    }

    setState(() {
      _isTranslating = true;
      _translatedText = '';
    });

    try {
      // Đóng translator cũ
      await _translator?.close();

      // Tạo translator mới với ngôn ngữ hiện tại
      _translator = OnDeviceTranslator(
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );

      final result = await _translator!.translateText(_textController.text);

      setState(() {
        _translatedText = result;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi dịch: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      // Swap text
      final tempText = _textController.text;
      _textController.text = _translatedText;
      _translatedText = tempText;
    });
  }

  @override
  void dispose() {
    _translator?.close();
    _textController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Translate',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: 'Dịch Realtime',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RealtimeTranslateScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Language selector card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildLanguageDropdown(
                          value: _sourceLanguage,
                          onChanged: (value) {
                            setState(() {
                              _sourceLanguage = value!;
                              _translatedText = '';
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _swapLanguages,
                        icon: const Icon(Icons.swap_horiz, size: 32),
                        color: Colors.blue.shade700,
                      ),
                      Expanded(
                        child: _buildLanguageDropdown(
                          value: _targetLanguage,
                          onChanged: (value) {
                            setState(() {
                              _targetLanguage = value!;
                              _translatedText = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Input text card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Văn bản gốc',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const Spacer(),
                          // Nút camera
                          IconButton(
                            onPressed: _showImageSourceDialog,
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.blue.shade700,
                              size: 28,
                            ),
                            tooltip: 'Chụp ảnh để nhận dạng',
                          ),
                          // Nút microphone
                          IconButton(
                            onPressed: _startListening,
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening
                                  ? Colors.red
                                  : Colors.blue.shade700,
                              size: 28,
                            ),
                            tooltip: _isListening
                                ? 'Đang nghe...'
                                : 'Nhấn để nói',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _textController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Nhập văn bản cần dịch...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blue.shade700,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.blue.shade50,
                        ),
                      ),
                      // Listening indicator
                      if (_isListening)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mic, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Đang nghe...',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Recognizing indicator
                      if (_isRecognizing)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Đang nhận dạng...',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Translate button
              ElevatedButton(
                onPressed: _isTranslating ? null : _translate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isTranslating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.translate, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Dịch',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              // Translation result card
              if (_translatedText.isNotEmpty)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kết quả dịch',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: SelectableText(
                            _translatedText,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required TranslateLanguage value,
    required ValueChanged<TranslateLanguage?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TranslateLanguage>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
          items: _languageNames.entries.map((entry) {
            return DropdownMenuItem<TranslateLanguage>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

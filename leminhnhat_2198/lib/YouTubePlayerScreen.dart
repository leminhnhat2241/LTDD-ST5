import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show IFrameElement;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

class YouTubePlayerScreen extends StatefulWidget {
  const YouTubePlayerScreen({Key? key}) : super(key: key);

  @override
  _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? _errorMessage;
  bool _isPlayerReady = false;
  String? _currentVideoId;
  String _iframeViewType = '';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Register iframe view for web
      _iframeViewType =
          'youtube-player-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String? _extractVideoId(String url) {
    // Xử lý các định dạng URL YouTube khác nhau
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([^&]+)'),
      RegExp(r'youtu\.be/([^?]+)'),
      RegExp(r'youtube\.com/embed/([^?]+)'),
      RegExp(r'youtube\.com/v/([^?]+)'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  void _loadVideo() {
    setState(() {
      _errorMessage = null;

      if (_urlController.text.isEmpty) {
        _errorMessage = 'Vui lòng nhập link YouTube';
        return;
      }

      // Extract video ID from URL
      final videoId = _extractVideoId(_urlController.text);

      if (videoId == null) {
        _errorMessage =
            'Link YouTube không hợp lệ.\nVí dụ: https://www.youtube.com/watch?v=VIDEO_ID';
        return;
      }

      _currentVideoId = videoId;

      if (kIsWeb) {
        // Register iframe for web platform
        _iframeViewType =
            'youtube-player-${DateTime.now().millisecondsSinceEpoch}';
        ui_web.platformViewRegistry.registerViewFactory(_iframeViewType, (
          int viewId,
        ) {
          final iframe = html.IFrameElement()
            ..src = 'https://www.youtube.com/embed/$videoId?autoplay=1'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';
          return iframe;
        });
      }

      _isPlayerReady = true;
    });
  }

  void _clearVideo() {
    setState(() {
      _urlController.clear();
      _errorMessage = null;
      _isPlayerReady = false;
      _currentVideoId = null;
    });
  }

  Future<void> _openInYouTube() async {
    if (_currentVideoId != null) {
      final url = Uri.parse('https://www.youtube.com/watch?v=$_currentVideoId');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở YouTube'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem video YouTube'),
        backgroundColor: Colors.red,
        elevation: 4,
        actions: [
          if (_isPlayerReady)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Mở trong YouTube',
              onPressed: _openInYouTube,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Nhập link YouTube:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://www.youtube.com/watch?v=...',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  prefixIcon: const Icon(Icons.link, color: Colors.red),
                  errorText: _errorMessage,
                  suffixIcon: _urlController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _urlController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    if (_errorMessage != null) {
                      _errorMessage = null;
                    }
                  });
                },
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadVideo,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text(
                        'Phát video',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (_isPlayerReady) ...[
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _clearVideo,
                      icon: const Icon(Icons.stop),
                      label: const Text('Dừng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 30),
              if (_isPlayerReady && _currentVideoId != null)
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? HtmlElementView(viewType: _iframeViewType)
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.video_library,
                                  size: 80,
                                  color: Colors.white54,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Video player chỉ hỗ trợ trên Web',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: _openInYouTube,
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Mở trong YouTube'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                )
              else
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Nhập link và nhấn "Phát video"\nđể xem video YouTube',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Hướng dẫn:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '1. Copy link video từ YouTube\n'
                      '2. Dán link vào ô nhập liệu\n'
                      '3. Nhấn "Phát video" để xem\n'
                      '4. Nhấn icon ⤴ để mở trong app YouTube',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[900],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Định dạng link hỗ trợ:\n'
                      '• youtube.com/watch?v=VIDEO_ID\n'
                      '• youtu.be/VIDEO_ID\n'
                      '• youtube.com/embed/VIDEO_ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
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

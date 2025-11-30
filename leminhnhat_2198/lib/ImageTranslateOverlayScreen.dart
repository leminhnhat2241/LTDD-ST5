import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class ImageTranslateOverlayScreen extends StatefulWidget {
  final String imagePath;
  final TranslateLanguage sourceLanguage;
  final TranslateLanguage targetLanguage;

  const ImageTranslateOverlayScreen({
    super.key,
    required this.imagePath,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  State<ImageTranslateOverlayScreen> createState() =>
      _ImageTranslateOverlayScreenState();
}

class TextBlockTranslation {
  final Rect boundingBox;
  final String originalText;
  final String translatedText;

  TextBlockTranslation({
    required this.boundingBox,
    required this.originalText,
    required this.translatedText,
  });
}

class _ImageTranslateOverlayScreenState
    extends State<ImageTranslateOverlayScreen> {
  bool _isProcessing = true;
  OnDeviceTranslator? _translator;
  ui.Image? _image;
  List<TextBlockTranslation> _textBlocks = [];
  Size _imageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      // Load image to get dimensions
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _image = frame.image;
      _imageSize = Size(_image!.width.toDouble(), _image!.height.toDouble());

      // Step 1: Recognize text blocks from image
      final InputImage inputImage = InputImage.fromFilePath(widget.imagePath);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();

      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      await textRecognizer.close();

      if (recognizedText.blocks.isEmpty) {
        setState(() {
          _isProcessing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy văn bản trong ảnh'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Step 2: Translate each text block
      _translator = OnDeviceTranslator(
        sourceLanguage: widget.sourceLanguage,
        targetLanguage: widget.targetLanguage,
      );

      List<TextBlockTranslation> translations = [];

      for (var block in recognizedText.blocks) {
        try {
          final translated = await _translator!.translateText(block.text);
          translations.add(
            TextBlockTranslation(
              boundingBox: block.boundingBox,
              originalText: block.text,
              translatedText: translated,
            ),
          );
        } catch (e) {
          debugPrint('Error translating block: $e');
        }
      }

      setState(() {
        _textBlocks = translations;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
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

  @override
  void dispose() {
    _translator?.close();
    super.dispose();
  }

  String get _recognizedText =>
      _textBlocks.map((b) => b.originalText).join('\n');
  String get _translatedText =>
      _textBlocks.map((b) => b.translatedText).join('\n');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Dịch từ Ảnh',
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
      ),
      body: _isProcessing
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Đang nhận dạng và dịch...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                // Background image
                Center(
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),

                // Translated text overlays at exact positions
                if (_textBlocks.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: TranslationOverlayPainter(
                          textBlocks: _textBlocks,
                          imageSize: _imageSize,
                          containerSize: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}

class TranslationOverlayPainter extends CustomPainter {
  final List<TextBlockTranslation> textBlocks;
  final Size imageSize;
  final Size containerSize;

  TranslationOverlayPainter({
    required this.textBlocks,
    required this.imageSize,
    required this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale to fit image in container
    final double scaleX = containerSize.width / imageSize.width;
    final double scaleY = containerSize.height / imageSize.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate offset to center image
    final double scaledWidth = imageSize.width * scale;
    final double scaledHeight = imageSize.height * scale;
    final double offsetX = (containerSize.width - scaledWidth) / 2;
    final double offsetY = (containerSize.height - scaledHeight) / 2;

    for (var block in textBlocks) {
      // Scale and position the bounding box
      final rect = Rect.fromLTWH(
        offsetX + block.boundingBox.left * scale,
        offsetY + block.boundingBox.top * scale,
        block.boundingBox.width * scale,
        block.boundingBox.height * scale,
      );

      // Draw semi-transparent background over original text
      final bgPaint = Paint()
        ..color = Colors.black.withOpacity(0.85)
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, bgPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.greenAccent.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect, borderPaint);

      // Draw translated text
      final textPainter = TextPainter(
        text: TextSpan(
          text: block.translatedText,
          style: TextStyle(
            color: Colors.white,
            fontSize: _calculateFontSize(rect.height),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 3),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 10,
      );

      textPainter.layout(maxWidth: rect.width - 8);

      // Center text vertically in the box
      final textOffset = Offset(
        rect.left + 4,
        rect.top + (rect.height - textPainter.height) / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  double _calculateFontSize(double boxHeight) {
    // Dynamic font size based on box height
    if (boxHeight < 30) return 10;
    if (boxHeight < 50) return 12;
    if (boxHeight < 80) return 14;
    if (boxHeight < 120) return 16;
    return 18;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

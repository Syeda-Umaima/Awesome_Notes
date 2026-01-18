// lib/widgets/voice_input_dialog.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceInputDialog extends StatefulWidget {
  final Function(String) onTextRecognized;

  const VoiceInputDialog({
    super.key,
    required this.onTextRecognized,
  });

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  String _statusMessage = 'Initializing...';
  List<stt.LocaleName> _locales = [];
  String? _selectedLocaleId;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initSpeech();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      setState(() {
        _statusMessage = 'Microphone permission denied';
      });
      return;
    }

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (mounted) {
            setState(() {
              if (status == 'listening') {
                _statusMessage = 'Listening...';
                _isListening = true;
              } else if (status == 'notListening') {
                _statusMessage = 'Tap mic to speak';
                _isListening = false;
              } else if (status == 'done') {
                _statusMessage = 'Processing...';
              }
            });
          }
        },
        onError: (error) {
          debugPrint('Speech error: ${error.errorMsg}');
          if (mounted) {
            setState(() {
              _statusMessage = 'Error: ${error.errorMsg}';
              _isListening = false;
            });
          }
        },
        debugLogging: true,
      );

      if (_isInitialized) {
        // Get available locales
        _locales = await _speech.locales();
        final systemLocale = await _speech.systemLocale();
        _selectedLocaleId = systemLocale?.localeId ?? 'en_US';

        setState(() {
          _statusMessage = 'Tap the microphone to start';
        });
      } else {
        setState(() {
          _statusMessage = 'Speech recognition not available';
        });
      }
    } catch (e) {
      debugPrint('Speech init error: $e');
      setState(() {
        _statusMessage = 'Failed to initialize: $e';
      });
    }
  }

  void _startListening() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    setState(() {
      _recognizedText = '';
      _confidence = 0.0;
    });

    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: _selectedLocaleId,
      onSoundLevelChange: (level) {
        // Could use this for visual feedback
      },
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _statusMessage = 'Tap mic to speak again';
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
      if (result.hasConfidenceRating && result.confidence > 0) {
        _confidence = result.confidence;
      }
    });
  }

  void _insertText() {
    if (_recognizedText.trim().isNotEmpty) {
      widget.onTextRecognized(_recognizedText.trim());
      Navigator.pop(context);
    }
  }

  void _clearText() {
    setState(() {
      _recognizedText = '';
      _confidence = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.mic, color: Colors.red.shade400),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Voice Input',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Mic button with pulse animation
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: _isListening ? 100 * _pulseAnimation.value : 100,
                  height: _isListening ? 100 * _pulseAnimation.value : 100,
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.red : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: Colors.red.withAlpha(77),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 50,
                    color: _isListening ? Colors.white : Colors.grey.shade600,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Status message
          Text(
            _statusMessage,
            style: TextStyle(
              color: _isListening ? Colors.red : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Confidence indicator
          if (_confidence > 0)
            Text(
              'Confidence: ${(_confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          const SizedBox(height: 20),

          // Recognized text area
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isListening ? Colors.red.shade200 : Colors.grey.shade300,
              ),
            ),
            child: SingleChildScrollView(
              child: Text(
                _recognizedText.isEmpty
                    ? 'Your speech will appear here...'
                    : _recognizedText,
                style: TextStyle(
                  fontSize: 16,
                  color: _recognizedText.isEmpty
                      ? Colors.grey.shade400
                      : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _recognizedText.isEmpty ? null : _clearText,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _recognizedText.isEmpty ? null : _insertText,
                  icon: const Icon(Icons.check),
                  label: const Text('Insert Text'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC39E18),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Language selector
          if (_locales.isNotEmpty)
            ExpansionTile(
              title: const Text(
                'Language Settings',
                style: TextStyle(fontSize: 14),
              ),
              tilePadding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: _locales.length,
                    itemBuilder: (context, index) {
                      final locale = _locales[index];
                      return RadioListTile<String>(
                        title: Text(
                          locale.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: locale.localeId,
                        groupValue: _selectedLocaleId,
                        onChanged: (value) {
                          setState(() {
                            _selectedLocaleId = value;
                          });
                        },
                        dense: true,
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

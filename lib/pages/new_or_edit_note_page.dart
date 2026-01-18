// lib/pages/new_or_edit_note_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../change_notifiers/new_note_controller.dart';
import '../change_notifiers/notes_provider.dart';
import '../core/constants.dart';
import '../core/dialogs.dart';
import '../models/note_model.dart';
import '../services/notification_service.dart';
import '../widgets/ai_features_sheet.dart';
import '../widgets/note_back_button.dart';
import '../widgets/note_color_picker.dart';
import '../widgets/note_icon_button_outlined.dart';
import '../widgets/note_metadata.dart';
import '../widgets/note_toolbar.dart';

class NewOrEditNotePage extends StatefulWidget {
  const NewOrEditNotePage({required this.isNewNote, super.key});

  final bool isNewNote;

  @override
  State<NewOrEditNotePage> createState() => _NewOrEditNotePageState();
}

class _NewOrEditNotePageState extends State<NewOrEditNotePage> {
  late final NewNoteController newNoteController;
  late final TextEditingController titleController;
  late final quill.QuillController quillController;
  late final FocusNode focusNode;
  late final ScrollController scrollController;

  final ImagePicker _picker = ImagePicker();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // Image handling
  String? imagePath;
  Uint8List? webImageBytes;

  // New feature state
  int _selectedColorIndex = 0;
  DateTime? _reminderDateTime;

  @override
  @override
void initState() {
  super.initState();

  newNoteController = context.read<NewNoteController>();
  titleController = TextEditingController(text: newNoteController.title);

  final note = newNoteController.noteModel;
  if (!widget.isNewNote && note != null && note.imagePath != null) {
    try {
      if (kIsWeb || note.imagePath!.length > 200) {
        // Base64 encoded (web)
        webImageBytes = base64Decode(note.imagePath!);
        imagePath = null;
      } else {
        // Local file path
        imagePath = note.imagePath;
        webImageBytes = null;
      }
    } catch (e) {
      debugPrint('Error loading saved image: $e');
    }
  }

  quillController = quill.QuillController.basic()
    ..addListener(() {
      newNoteController.content = quillController.document;
    });

  focusNode = FocusNode();
  scrollController = ScrollController();
  _speech = stt.SpeechToText();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (widget.isNewNote) {
      focusNode.requestFocus();
      newNoteController.readOnly = false;
    } else {
      newNoteController.readOnly = true;
      quillController.document = newNoteController.content;
    }
  });
}

  @override
  void dispose() {
    titleController.dispose();
    quillController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  // 🖼️ Pick and insert image
  Future<void> pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) return;

      if (kIsWeb) {
        webImageBytes = await picked.readAsBytes();
        setState(() => imagePath = null);
      } else {
        setState(() {
          imagePath = picked.path;
          webImageBytes = null;
        });
      }

      _addImageToEditor();
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _addImageToEditor() async {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      int index = quillController.selection.baseOffset;
      if (index < 0 || index > quillController.document.length) {
        index = quillController.document.length;
      }

      // Insert a simple placeholder text for image
      quillController.document.insert(index, '\n[Image attached]\n');

      quillController.updateSelection(
        TextSelection.collapsed(offset: index + 18),
        quill.ChangeSource.local,
      );

      focusNode.requestFocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Image added to note')),
        );
      }
    });
  }

  // 🎤 Voice input
  Future<void> _toggleVoiceInput() async {
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onStatus: (status) => debugPrint('Speech status: $status'),
          onError: (error) {
            debugPrint('Speech error: $error');
            if (mounted) {
              setState(() => _isListening = false);
            }
          },
        );

        if (!available) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Voice Input Unavailable'),
                content: const Text(
                  'Speech recognition is not available on this device/emulator.\n\n'
                  'To test voice input:\n'
                  '• Use a physical Android/iOS device\n'
                  '• Ensure microphone permissions are granted\n'
                  '• Check device settings for speech recognition',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          return;
        }

        setState(() => _isListening = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎙 Listening... Speak now!')),
          );
        }

        _speech.listen(
          onResult: (result) {
            final text = result.recognizedWords.trim();
            if (text.isNotEmpty) {
              final index = quillController.selection.baseOffset >= 0
                  ? quillController.selection.baseOffset
                  : quillController.document.length;

              quillController.document.insert(index, "$text ");
              quillController.updateSelection(
                TextSelection.collapsed(offset: index + text.length + 1),
                quill.ChangeSource.local,
              );
            }
          },
        );
      } catch (e) {
        debugPrint('Speech initialization error: $e');
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Voice Input Error'),
              content: Text(
                'Speech recognition not available on this device.\n\n'
                'Error: $e\n\n'
                'Please test on a physical device.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🛑 Stopped listening')),
        );
      }
    }
  }

  // 🤖 Show AI Features Bottom Sheet
  void _showAIFeatures() {
    final content = quillController.document.toPlainText().trim();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIFeaturesSheet(
        title: titleController.text,
        content: content,
        onSummaryGenerated: (summary) {
          // Insert summary at cursor position
          final index = quillController.selection.baseOffset >= 0
              ? quillController.selection.baseOffset
              : quillController.document.length;
          quillController.document.insert(index, '\n\n📝 Summary:\n$summary\n');
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('✅ Summary added to note')),
          );
        },
        onTagsSuggested: (tags) {
          // Clear existing tags and add new ones
          while (newNoteController.tags.isNotEmpty) {
            newNoteController.removeTag(0);
          }
          for (final tag in tags) {
            newNoteController.addTag(tag);
          }
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(content: Text('✅ Tags applied: ${tags.join(", ")}')),
          );
        },
        onTitleSuggested: (title) {
          titleController.text = title;
          newNoteController.title = title;
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('✅ Title updated')),
          );
        },
      ),
    );
  }

  // 🎨 Show Color Picker
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteColorPicker(
        selectedColorIndex: _selectedColorIndex,
        onColorSelected: (index) {
          setState(() {
            _selectedColorIndex = index;
          });
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('✅ Note color changed')),
          );
        },
      ),
    );
  }

  // ⏰ Show Reminder Picker
  void _showReminderPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ReminderPickerDialog(
          initialDateTime: _reminderDateTime,
        ),
      ),
    ).then((selectedDateTime) {
      if (!mounted) return;
      if (selectedDateTime != null && selectedDateTime is DateTime) {
        setState(() {
          _reminderDateTime = selectedDateTime;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⏰ Reminder set for ${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} at ${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
            ),
          ),
        );
      }
    });
  }

  // Build feature button widget
  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💾 Save note properly to Hive
  Future<void> _saveNote() async {
  try {
    final noteBox = Hive.box<NoteModel>('notesbox');
    final plainText = quillController.document.toPlainText().trim();
    final voiceText = _isListening ? plainText : null;

    String? storedImagePath;
    if (kIsWeb && webImageBytes != null) {
      storedImagePath = base64Encode(webImageBytes!);
    } else if (!kIsWeb && imagePath != null) {
      storedImagePath = imagePath;
    }

    NoteModel hiveNote;
    if (widget.isNewNote) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      hiveNote = NoteModel(
        title: titleController.text.trim().isEmpty ? null : titleController.text.trim(),
        description: plainText.isEmpty ? null : plainText,
        contentJson: jsonEncode(quillController.document.toDelta().toJson()),
        dateCreated: DateTime.now().microsecondsSinceEpoch,
        dateModified: DateTime.now().microsecondsSinceEpoch,
        imagePath: storedImagePath,
        voiceText: voiceText,
        tags: newNoteController.tags,
        userId: currentUserId,
      );
      await noteBox.add(hiveNote);
    } else {
      hiveNote = newNoteController.noteModel!;
      hiveNote
        ..title = titleController.text.trim().isEmpty ? null : titleController.text.trim()
        ..description = plainText.isEmpty ? null : plainText
        ..contentJson = jsonEncode(quillController.document.toDelta().toJson())
        ..dateModified = DateTime.now().microsecondsSinceEpoch
        ..imagePath = storedImagePath
        ..voiceText = voiceText
        ..tags = newNoteController.tags;
      await hiveNote.save();
    }

    if (mounted) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final userNotes = noteBox.values
          .where((note) => note.userId == currentUserId)
          .toList();
      context.read<NotesProvider>().setNotes(userNotes);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Note saved successfully!')),
      );
    }
  } catch (e) {
    debugPrint('❌ Error saving to Hive: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error saving note: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (!newNoteController.canSaveNote) {
          Navigator.pop(context);
          return;
        }

        showConfirmationDialog(
          context: context,
          title: 'Do you want to save the note?',
        ).then((shouldSave) {
          if (!context.mounted) return;

          if (shouldSave == true) {
            _saveNote();
          }

          Navigator.pop(context);
        });
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const NoteBackButton(),
          title: Text(widget.isNewNote ? 'New Note' : 'Edit Note'),
          actions: [
            Selector<NewNoteController, bool>(
              selector: (context, c) => c.readOnly,
              builder: (context, readOnly, child) => NoteIconButtonOutlined(
                icon: readOnly
                    ? FontAwesomeIcons.pen
                    : FontAwesomeIcons.bookOpen,
                onPressed: () {
                  newNoteController.readOnly = !readOnly;
                  if (newNoteController.readOnly) {
                    FocusScope.of(context).unfocus();
                  } else {
                    focusNode.requestFocus();
                  }
                },
              ),
            ),
            Selector<NewNoteController, bool>(
              selector: (_, c) => c.canSaveNote,
              builder: (context, canSaveNote, child) => NoteIconButtonOutlined(
                icon: FontAwesomeIcons.check,
                onPressed: canSaveNote
                    ? () async {
                        await _saveNote();
                        if (context.mounted) Navigator.pop(context);
                      }
                    : null,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Title Field
              Selector<NewNoteController, bool>(
                selector: (context, c) => c.readOnly,
                builder: (context, readOnly, child) => TextField(
                  controller: titleController,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title here',
                    hintStyle: TextStyle(color: gray300),
                    border: InputBorder.none,
                  ),
                  canRequestFocus: !readOnly,
                  onChanged: (val) => newNoteController.title = val,
                ),
              ),

              NoteMetadata(note: newNoteController.noteModel),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(color: gray500, thickness: 2),
              ),

              // ✅ Image Preview
              if (kIsWeb && webImageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: double.infinity,
                      ),
                      child: Image.memory(
                        webImageBytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
              else if (imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: double.infinity,
                      ),
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

              // Quill Editor
              Expanded(
                child: Selector<NewNoteController, bool>(
                  selector: (_, c) => c.readOnly,
                  builder: (_, readOnly, _) => Column(
                    children: [
                      Expanded(
                        child: quill.QuillEditor(
                          controller: quillController,
                          focusNode: focusNode,
                          scrollController: scrollController,
                        ),
                      ),

                      if (!readOnly)
                        Column(
                          children: [
                            NoteToolbar(controller: quillController),
                            const SizedBox(height: 10),
                            // Enhanced Feature Toolbar
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // 🎤 Voice Input
                                  _buildFeatureButton(
                                    icon: _isListening ? Icons.mic : Icons.mic_none_outlined,
                                    label: 'Voice',
                                    color: _isListening ? Colors.red : Colors.grey.shade700,
                                    onTap: _toggleVoiceInput,
                                  ),
                                  // 🖼️ Add Image
                                  _buildFeatureButton(
                                    icon: Icons.image_outlined,
                                    label: 'Image',
                                    color: Colors.grey.shade700,
                                    onTap: pickImage,
                                  ),
                                  // 🤖 AI Features
                                  _buildFeatureButton(
                                    icon: Icons.auto_awesome,
                                    label: 'AI',
                                    color: const Color(0xFFC39E18),
                                    onTap: _showAIFeatures,
                                  ),
                                  // 🎨 Color Picker
                                  _buildFeatureButton(
                                    icon: Icons.palette_outlined,
                                    label: 'Color',
                                    color: NoteColorPicker.getColor(_selectedColorIndex) == Colors.white
                                        ? Colors.grey.shade700
                                        : NoteColorPicker.getColor(_selectedColorIndex),
                                    onTap: _showColorPicker,
                                  ),
                                  // ⏰ Reminder
                                  _buildFeatureButton(
                                    icon: _reminderDateTime != null
                                        ? Icons.alarm_on
                                        : Icons.alarm_add_outlined,
                                    label: 'Remind',
                                    color: _reminderDateTime != null
                                        ? Colors.green
                                        : Colors.grey.shade700,
                                    onTap: _showReminderPicker,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
}
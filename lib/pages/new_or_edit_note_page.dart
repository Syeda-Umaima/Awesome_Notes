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

import '../change_notifiers/new_note_controller.dart';
import '../core/constants.dart';
import '../core/dialogs.dart';
import '../models/note_model.dart';
import '../widgets/note_back_button.dart';
import '../widgets/note_icon_button_outlined.dart';
import '../widgets/note_metadata.dart';

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

  @override
  void initState() {
    super.initState();

    newNoteController = context.read<NewNoteController>();
    titleController = TextEditingController(text: newNoteController.title);

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
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
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
  }

  Future<void> _addImageToEditor() async {
    Uint8List imageBytes;

    if (kIsWeb && webImageBytes != null) {
      imageBytes = webImageBytes!;
    } else if (!kIsWeb && imagePath != null) {
      imageBytes = await File(imagePath!).readAsBytes();
    } else {
      return;
    }

    final String base64Image = base64Encode(imageBytes);
    final String imageUrl = 'data:image/png;base64,$base64Image';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      int index = quillController.selection.baseOffset;
      if (index < 0 || index > quillController.document.length) {
        index = quillController.document.length;
      }

      quillController.replaceText(
        index,
        0,
        quill.BlockEmbed.image(imageUrl),
        TextSelection.collapsed(offset: index + 1),
      );

      focusNode.requestFocus();
    });
  }

  // 🎤 Voice input
  Future<void> _toggleVoiceInput() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );

      if (available) {
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ Speech recognition not available')),
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

  // 💾 Save note
  void _saveNote() {
    newNoteController.saveNote(context);

    try {
      final noteBox = Hive.box<NoteModel>('notesBox');
      final plainText = quillController.document.toPlainText().trim();
      final voiceText = _isListening ? plainText : null;

      final hiveNote = NoteModel(
        title: titleController.text.trim().isEmpty
            ? null
            : titleController.text.trim(),
        description: plainText.isEmpty ? null : plainText,
        imagePath: imagePath,
        voiceText: voiceText,
        createdAt: DateTime.now(),
      );

      noteBox.add(hiveNote).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Note saved locally & to cloud!')),
          );
        }
      }).catchError((e) {
        debugPrint('Error saving to Hive: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⚠️ Saved to cloud but local backup failed: $e')),
          );
        }
      });
    } catch (e) {
      debugPrint('Error preparing to save to Hive: $e');
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
                icon: readOnly ? FontAwesomeIcons.pen : FontAwesomeIcons.bookOpen,
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
                    ? () {
                        _saveNote();
                        Navigator.pop(context);
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

              NoteMetadata(note: newNoteController.note),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(color: gray500, thickness: 2),
              ),

              if (kIsWeb && webImageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.memory(
                    webImageBytes!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else if (imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.file(
                    File(imagePath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              Expanded(
                child: Selector<NewNoteController, bool>(
                  selector: (context, c) => c.readOnly,
                  builder: (context, readOnly, child) {
                    return Column(
                      children: [
                        Expanded(
                          child: quill.QuillEditor(
                            controller: quillController,
                            scrollController: scrollController,
                            focusNode: focusNode,
                          ),
                        ),

                        if (!readOnly)
                          Column(
                            children: [
                              Container(
                                color: Colors.grey[200],
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      quill.QuillToolbarToggleStyleButton(
                                        attribute: quill.Attribute.bold,
                                        controller: quillController,
                                      ),
                                      quill.QuillToolbarToggleStyleButton(
                                        attribute: quill.Attribute.italic,
                                        controller: quillController,
                                      ),
                                      quill.QuillToolbarToggleStyleButton(
                                        attribute: quill.Attribute.underline,
                                        controller: quillController,
                                      ),
                                      quill.QuillToolbarToggleStyleButton(
                                        attribute: quill.Attribute.strikeThrough,
                                        controller: quillController,
                                      ),
                                      const VerticalDivider(),
                                      quill.QuillToolbarToggleStyleButton(
                                        attribute: quill.Attribute.ul,
                                        controller: quillController,
                                      ),
                                      quill.QuillToolbarToggleStyleButton(
                                        attribute: quill.Attribute.ol,
                                        controller: quillController,
                                      ),
                                      const VerticalDivider(),
                                      quill.QuillToolbarClearFormatButton(
                                        controller: quillController,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _isListening
                                          ? Icons.mic
                                          : Icons.mic_none_outlined,
                                      color:
                                          _isListening ? Colors.red : Colors.grey,
                                    ),
                                    tooltip: _isListening
                                        ? 'Stop Recording'
                                        : 'Start Voice Input',
                                    onPressed: _toggleVoiceInput,
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.image_outlined,
                                      color: Colors.grey,
                                    ),
                                    tooltip: 'Add Image',
                                    onPressed: pickImage,
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
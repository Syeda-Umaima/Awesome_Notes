import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
import '../widgets/voice_input_dialog.dart';

/// Screen for creating new notes or editing existing ones
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
  String? imagePath;
  Uint8List? webImageBytes;
  int _selectedColorIndex = 0;
  DateTime? _reminderDateTime;

  @override
  void initState() {
    super.initState();

    newNoteController = context.read<NewNoteController>();
    titleController = TextEditingController(text: newNoteController.title);

    // Load existing image if editing a note
    final note = newNoteController.noteModel;
    if (!widget.isNewNote && note != null && note.imagePath != null) {
      try {
        if (kIsWeb || note.imagePath!.length > 200) {
          webImageBytes = base64Decode(note.imagePath!);
          imagePath = null;
        } else {
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
    super.dispose();
  }

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

      quillController.document.insert(index, '\n[Image attached]\n');

      quillController.updateSelection(
        TextSelection.collapsed(offset: index + 18),
        quill.ChangeSource.local,
      );

      focusNode.requestFocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image added to note')),
        );
      }
    });
  }

  void _showVoiceInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceInputDialog(
        onTextRecognized: (text) {
          final index = quillController.selection.baseOffset >= 0
              ? quillController.selection.baseOffset
              : quillController.document.length - 1;

          final safeIndex = index.clamp(0, quillController.document.length - 1);
          quillController.document.insert(safeIndex, '$text ');
          quillController.updateSelection(
            TextSelection.collapsed(offset: safeIndex + text.length + 1),
            quill.ChangeSource.local,
          );

          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('Voice text inserted')),
          );
        },
      ),
    );
  }

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
          final index = quillController.selection.baseOffset >= 0
              ? quillController.selection.baseOffset
              : quillController.document.length;
          quillController.document.insert(index, '\n\nSummary:\n$summary\n');
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('Summary added to note')),
          );
        },
        onTagsSuggested: (tags) {
          while (newNoteController.tags.isNotEmpty) {
            newNoteController.removeTag(0);
          }
          for (final tag in tags) {
            newNoteController.addTag(tag);
          }
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(content: Text('Tags applied: ${tags.join(", ")}')),
          );
        },
        onTitleSuggested: (title) {
          titleController.text = title;
          newNoteController.title = title;
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('Title updated')),
          );
        },
      ),
    );
  }

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
            const SnackBar(content: Text('Note color changed')),
          );
        },
      ),
    );
  }

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
              'Reminder set for ${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} at ${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
            ),
          ),
        );
      }
    });
  }

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

  Future<void> _saveNote() async {
    try {
      final noteBox = Hive.box<NoteModel>('notesbox');
      final plainText = quillController.document.toPlainText().trim();

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
          const SnackBar(content: Text('Note saved successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error saving to Hive: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
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

              // Image preview
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
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFeatureButton(
                                    icon: Icons.mic_none_outlined,
                                    label: 'Voice',
                                    color: Colors.grey.shade700,
                                    onTap: _showVoiceInput,
                                  ),
                                  _buildFeatureButton(
                                    icon: Icons.image_outlined,
                                    label: 'Image',
                                    color: Colors.grey.shade700,
                                    onTap: pickImage,
                                  ),
                                  _buildFeatureButton(
                                    icon: Icons.auto_awesome,
                                    label: 'AI',
                                    color: const Color(0xFFC39E18),
                                    onTap: _showAIFeatures,
                                  ),
                                  _buildFeatureButton(
                                    icon: Icons.palette_outlined,
                                    label: 'Color',
                                    color: NoteColorPicker.getColor(_selectedColorIndex) == Colors.white
                                        ? Colors.grey.shade700
                                        : NoteColorPicker.getColor(_selectedColorIndex),
                                    onTap: _showColorPicker,
                                  ),
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

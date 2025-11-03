// lib/change_notifiers/new_note_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import '../models/note_model.dart';
import 'notes_provider.dart';

class NewNoteController extends ChangeNotifier {
  NoteModel? _noteModel;
  set noteModel(NoteModel? value) {
    _noteModel = value;
    _title = value?.title ?? '';
    _content = value?.contentJson != null
        ? Document.fromJson(jsonDecode(value!.contentJson!))
        : Document();
    _tags.clear();
    _tags.addAll(value?.tags ?? []);
    notifyListeners();
  }

  NoteModel? get noteModel => _noteModel;

  bool _readOnly = false;
  set readOnly(bool value) {
    _readOnly = value;
    notifyListeners();
  }

  bool get readOnly => _readOnly;

  String _title = '';
  set title(String value) {
    _title = value;
    notifyListeners();
  }

  String get title => _title.trim();

  Document _content = Document();
  set content(Document value) {
    _content = value;
    notifyListeners();
  }

  Document get content => _content;

  final List<String> _tags = [];
  List<String> get tags => [..._tags];

  void addTag(String tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void removeTag(int index) {
    _tags.removeAt(index);
    notifyListeners();
  }

  void updateTag(String tag, int index) {
    _tags[index] = tag;
    notifyListeners();
  }

  bool get isNewNote => _noteModel == null;

  bool get canSaveNote {
    final String? newTitle = title.isNotEmpty ? title : null;
    final String newContentStr = content.toPlainText().trim();
    final String? newContentJson = newContentStr.isNotEmpty ? jsonEncode(content.toDelta().toJson()) : null;
    bool canSave = newTitle != null || newContentJson != null || _tags.isNotEmpty;

    if (!isNewNote) {
      canSave &= newTitle != _noteModel!.title ||
          newContentJson != _noteModel!.contentJson ||
          !listEquals(_tags, _noteModel!.tags);
    }

    return canSave;
  }

  void saveNote(BuildContext context) {
    final String? newTitle = title.isNotEmpty ? title : null;
    final String newContentStr = content.toPlainText().trim();
    final String? newContentJson = newContentStr.isNotEmpty ? jsonEncode(content.toDelta().toJson()) : null;
    final int now = DateTime.now().microsecondsSinceEpoch;

    final NoteModel noteModel = NoteModel(
      title: newTitle,
      description: newContentStr.isNotEmpty ? newContentStr : null,
      contentJson: newContentJson,
      dateCreated: isNewNote ? now : _noteModel!.dateCreated,
      dateModified: now,
      tags: tags,
    );

    final notesProvider = context.read<NotesProvider>();
    isNewNote ? notesProvider.addNote(noteModel) : notesProvider.updateNote(noteModel);
  }
}
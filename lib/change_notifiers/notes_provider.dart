// lib/change_notifiers/notes_provider.dart
import 'package:flutter/material.dart';
import '../enums/order_option.dart';
import '../models/note_model.dart';

class NotesProvider extends ChangeNotifier {
  final List<NoteModel> _notes = [];

  List<NoteModel> get notes {
    final term = _searchTerm.toLowerCase().trim();
    final filtered = _searchTerm.isEmpty
        ? _notes
        : _notes.where((note) {
            final title = (note.title ?? '').toLowerCase();
            final content = (note.description ?? note.voiceText ?? '').toLowerCase();
            return title.contains(term) || content.contains(term);
          }).toList();

    filtered.sort((a, b) {
      final int aDate = _orderBy == OrderOption.dateModified
          ? (a.dateModified ?? a.dateCreated ?? 0)
          : (a.dateCreated ?? 0);
      final int bDate = _orderBy == OrderOption.dateModified
          ? (b.dateModified ?? b.dateCreated ?? 0)
          : (b.dateCreated ?? 0);
      return _isDescending ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
    });

    return filtered;
  }

  String _searchTerm = '';
  String get searchTerm => _searchTerm;
  set searchTerm(String value) {
    _searchTerm = value;
    notifyListeners();
  }

  bool _isGrid = true;
  bool get isGrid => _isGrid;
  set isGrid(bool value) {
    _isGrid = value;
    notifyListeners();
  }

  OrderOption _orderBy = OrderOption.dateModified;
  OrderOption get orderBy => _orderBy;
  set orderBy(OrderOption value) {
    _orderBy = value;
    notifyListeners();
  }

  bool _isDescending = true;
  bool get isDescending => _isDescending;
  set isDescending(bool value) {
    _isDescending = value;
    notifyListeners();
  }

  void setNotes(List<NoteModel> hiveNotes) {
    _notes
      ..clear()
      ..addAll(hiveNotes);
    notifyListeners();
  }

  void addNote(NoteModel note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void removeNote(NoteModel note) {
    _notes.remove(note);
    notifyListeners();
  }

  void updateNote(NoteModel updated) {
    final idx = _notes.indexWhere((n) => n.key == updated.key);
    if (idx != -1) {
      _notes[idx] = updated;
      notifyListeners();
    }
  }
}
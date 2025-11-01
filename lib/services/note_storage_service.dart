import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NoteStorageService {
  static const _boxName = 'notesBox';
  Box<NoteModel> get _box => Hive.box<NoteModel>(_boxName);

  Future<void> addNote(NoteModel note) async => await _box.add(note);

  List<NoteModel> getAllNotes() => _box.values.toList();

  Future<void> updateNoteAt(int index, NoteModel note) async =>
      await _box.putAt(index, note);

  Future<void> deleteNoteAt(int index) async =>
      await _box.deleteAt(index);
}

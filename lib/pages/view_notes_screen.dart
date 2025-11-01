import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

class ViewNotesScreen extends StatelessWidget {
  const ViewNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<NoteModel>('notesBox');

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<NoteModel> notes, _) {
          if (notes.isEmpty) {
            return const Center(child: Text('No notes found.'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes.getAt(index);
              return ListTile(
                title: Text(note?.title ?? 'Untitled'),
                subtitle: Text(note?.description ?? note?.voiceText ?? ''),
                leading: note?.imagePath != null
                    ? Image.file(File(note!.imagePath!), width: 50, fit: BoxFit.cover)
                    : const Icon(Icons.note),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => notes.deleteAt(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

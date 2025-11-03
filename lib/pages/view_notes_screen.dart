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
            return const Center(
              child: Text(
                'No notes found.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Sort notes by creation date (newest first)
          final sortedNotes = notes.values.toList()
            ..sort((a, b) =>
                (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: sortedNotes.length,
            itemBuilder: (context, index) {
              final note = sortedNotes[index];
              final noteIndex = notes.values.toList().indexOf(note);
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    note.title ?? 'Untitled',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    note.description ?? note.voiceText ?? 'No content',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: note.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(note.imagePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 50);
                            },
                          ),
                        )
                      : const Icon(Icons.note, size: 50),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Note?'),
                          content: const Text(
                              'Are you sure you want to delete this note?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        notes.deleteAt(noteIndex);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

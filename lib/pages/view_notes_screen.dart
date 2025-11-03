// lib/pages/view_notes_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../change_notifiers/notes_provider.dart';
import '../models/note_model.dart';

class ViewNotesScreen extends StatelessWidget {
  const ViewNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<NoteModel>('notesbox');

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

          final sortedNotes = notes.values.toList()
            ..sort((a, b) => (b.dateCreated ?? 0)
                .compareTo(a.dateCreated ?? 0));

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: sortedNotes.length,
            itemBuilder: (context, index) {
              final note = sortedNotes[index];
              final noteIndex = notes.values.toList().indexOf(note);

              Widget imageWidget;
              if (note.imagePath != null && note.imagePath!.isNotEmpty) {
                try {
                  if (kIsWeb || note.imagePath!.length > 200) {
                    final Uint8List bytes = base64Decode(note.imagePath!);
                    imageWidget = Image.memory(
                      bytes,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 50),
                    );
                  } else {
                    final file = File(note.imagePath!);
                    imageWidget = file.existsSync()
                        ? Image.file(
                            file,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 50),
                          )
                        : const Icon(Icons.broken_image, size: 50);
                  }
                } catch (_) {
                  imageWidget = const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  );
                }
              } else {
                imageWidget = const Icon(Icons.note, size: 50);
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageWidget,
                  ),
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
                        await notes.deleteAt(noteIndex);
                        context.read<NotesProvider>().removeNote(note);
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
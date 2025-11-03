import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
          print('🧠 Loaded notes count: ${notes.length}');
          if (notes.isEmpty) {
            return const Center(child: Text('No notes found.'));
          }

          final sorted = notes.values.toList()
            ..sort((a, b) =>
                (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: sorted.length,
            itemBuilder: (context, i) {
              final note = sorted[i];
              final idx = notes.values.toList().indexOf(note);

              Widget img;
              if (note.imagePath != null && note.imagePath!.isNotEmpty) {
                try {
                  if (kIsWeb || note.imagePath!.length > 200) {
                    img = Image.memory(
                      base64Decode(note.imagePath!),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    );
                  } else {
                    final file = File(note.imagePath!);
                    img = file.existsSync()
                        ? Image.file(file, width: 60, height: 60, fit: BoxFit.cover)
                        : const Icon(Icons.broken_image, size: 50);
                  }
                } catch (_) {
                  img = const Icon(Icons.broken_image, size: 50);
                }
              } else {
                img = const Icon(Icons.note, size: 50);
              }

              return Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: img,
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
                    onPressed: () => notes.deleteAt(idx),
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

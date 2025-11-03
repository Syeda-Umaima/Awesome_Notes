// lib/widgets/note_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../change_notifiers/new_note_controller.dart';
import '../change_notifiers/notes_provider.dart';
import '../core/constants.dart';
import '../core/dialogs.dart';
import '../core/utils.dart';
import '../models/note_model.dart';
import 'note_tag.dart';
import '../pages/new_or_edit_note_page.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.note,
    required this.isInGrid,
    super.key,
  });

  final NoteModel note;
  final bool isInGrid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (context) => NewNoteController()..noteModel = note,
              child: const NewOrEditNotePage(isNewNote: false),
            ),
          ),
        );
      },
      onLongPress: () async {
        final bool? shouldDelete = await showConfirmationDialog(
          context: context,
          title: 'Do you want to delete this note?',
        );

        if (shouldDelete == true && context.mounted) {
          context.read<NotesProvider>().removeNote(note);
          await Hive.box<NoteModel>('notesbox').delete(note.key);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: white,
          border: Border.all(color: black),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: black,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.title != null) ...[
              Text(
                note.title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: isInGrid ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            if (note.description != null || note.voiceText != null) ...[
              Flexible(
                child: Text(
                  note.description ?? note.voiceText ?? 'No content',
                  style: const TextStyle(fontSize: 14),
                  maxLines: isInGrid ? 4 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (note.tags != null && note.tags!.isNotEmpty) ...[
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: note.tags!
                    .map((tag) => NoteTag(label: tag))
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              toShortDate(note.dateModified ?? note.dateCreated ?? DateTime.now().microsecondsSinceEpoch),
              style: const TextStyle(
                fontSize: 12,
                color: gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../change_notifiers/new_note_controller.dart';
import '../change_notifiers/notes_provider.dart';
import '../core/constants.dart';
import '../core/dialogs.dart';
import '../core/utils.dart';
import '../models/note.dart';
import 'note_tag.dart';
import '../pages/new_or_edit_note_page.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.note,
    required this.isInGrid,
    super.key,
  });

  final Note note;
  final bool isInGrid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => NewNoteController()..note = note,
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
          context.read<NotesProvider>().deleteNote(note);
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
            if (note.content != null) ...[
              Text(
                note.content!,
                style: const TextStyle(fontSize: 14),
                maxLines: isInGrid ? 4 : 2,
                overflow: TextOverflow.ellipsis,
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
              toShortDate(note.dateModified),
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

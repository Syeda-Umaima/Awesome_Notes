// lib/pages/main_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../change_notifiers/new_note_controller.dart';
import '../change_notifiers/notes_provider.dart';
import '../core/dialogs.dart';
import '../models/note_model.dart';
import '../services/auth_service.dart';
import '../widgets/no_notes.dart';
import '../widgets/note_fab.dart';
import '../widgets/note_grid.dart';
import '../widgets/note_icon_button_outlined.dart';
import '../widgets/notes_list.dart';
import '../widgets/search_field.dart';
import '../widgets/view_options.dart';
import 'new_or_edit_note_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotesProvider>();
      final box = Hive.box<NoteModel>('notesbox');
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      // Filter notes to only show current user's notes
      final hiveNotes = box.values
          .where((note) => note.userId == currentUserId)
          .toList()
        ..sort((a, b) => (b.dateCreated ?? 0)
            .compareTo(a.dateCreated ?? 0));
      provider.setNotes(hiveNotes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome Notes'),
        actions: [
          NoteIconButtonOutlined(
            icon: FontAwesomeIcons.rightFromBracket,
            onPressed: () async {
              final shouldLogout = await showConfirmationDialog(
                    context: context,
                    title: 'Do you want to sign out of the app?',
                  ) ??
                  false;
              if (shouldLogout) AuthService.logout();
            },
          ),
        ],
      ),
      floatingActionButton: NoteFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) => NewNoteController(),
                child: const NewOrEditNotePage(isNewNote: true),
              ),
            ),
          );
        },
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          final List<NoteModel> notes = notesProvider.notes;

          final filtered = notesProvider.searchTerm.isEmpty
              ? notes
              : notes
                  .where((n) =>
                      (n.title ?? '')
                          .toLowerCase()
                          .contains(notesProvider.searchTerm.toLowerCase()) ||
                      (n.description ?? n.voiceText ?? '')
                          .toLowerCase()
                          .contains(notesProvider.searchTerm.toLowerCase()))
                  .toList();

          return filtered.isEmpty && notesProvider.searchTerm.isEmpty
              ? const NoNotes()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SearchField(),
                      if (filtered.isNotEmpty) ...[
                        const ViewOptions(),
                        Expanded(
                          child: notesProvider.isGrid
                              ? NotesGrid(notes: filtered)
                              : NotesList(notes: filtered),
                        ),
                      ] else
                        const Expanded(
                          child: Center(
                            child: Text(
                              'No notes found for your search query!',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
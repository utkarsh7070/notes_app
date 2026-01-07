import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/Auth/presentation/screens/widgets/note_empty_view.dart';
import 'package:notes_app/Auth/presentation/screens/widgets/note_list_view.dart';
import 'package:notes_app/Auth/presentation/screens/widgets/notes_error_view.dart';
import 'package:notes_app/Auth/presentation/screens/widgets/notes_loading_view.dart';

import '../../provider/notes_provider.dart';
import '../../view_model/notes/notes_state.dart';

class NotesBody extends ConsumerWidget {
  final String userId;
  final NotesState notesState;

  const NotesBody({super.key, required this.userId, required this.notesState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (notesState) {
      NotesLoading() => const NotesLoadingView(),
      NotesError(:final message) => NotesErrorView(
        message: message,
        userId: userId,
      ),
      NotesLoaded(:final notes) =>
        notes.isEmpty
            ? const NotesEmptyView()
            : NotesListView(notes: notes, userId: userId),
      _ => const SizedBox.shrink(),
    };
  }
}

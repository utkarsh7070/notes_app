import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:searchable_listview/searchable_listview.dart';

import '../../../domain/entities/note_entity.dart';
import '../../provider/notes_provider.dart';
import 'note_card.dart';

class NotesListView extends ConsumerWidget {
  final List<NoteEntity> notes;
  final String userId;

  const NotesListView({super.key, required this.notes, required this.userId});

  void _showMessage(BuildContext context, String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No notes found',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchableList<NoteEntity>(
      key: ValueKey(
        'notes_list_${notes.length}_${notes.map((n) => n.id).join(",")}',
      ),
      initialList: notes,
      searchFieldPadding: const EdgeInsets.all(16),
      emptyWidget: _buildSearchEmptyState(),
      filter: (query) => notes
          .where(
            (note) =>
                note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList(),
      itemBuilder: (item) => NoteCard(
        key: ValueKey(
          'note_${item.id}_${item.updatedAt.millisecondsSinceEpoch}',
        ),
        note: item,
        onTap: () {
          context.pushNamed('note-detail-screen', extra: item);
        },
        onDelete: () async {
          await ref
              .read(notesViewModelProvider(userId).notifier)
              .deleteNote(userId: item.userId, noteId: item.id);

          if (context.mounted) {
            _showMessage(context, 'Note deleted', false);
          }
        },
      ),
      inputDecoration: InputDecoration(
        labelText: 'Search Notes',
        hintText: 'Search by title or content...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      searchTextController: TextEditingController(),
      cursorColor: Theme.of(context).primaryColor,
    );
  }
}

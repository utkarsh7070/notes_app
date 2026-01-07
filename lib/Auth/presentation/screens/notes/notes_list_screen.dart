import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:searchable_listview/searchable_listview.dart';
import '../../../domain/entities/note_entity.dart';
import '../../provider/auth_provider.dart';
import '../../provider/notes_provider.dart';
import '../../view_model/notes/notes_state.dart';
import '../widgets/note_card.dart';
import 'note_detail_screen.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateStreamProvider);
    final userId = authState.value?.uid ?? '';

    if (kDebugMode) {
      print('[NotesListScreen] Building with userId: $userId');
    }

    final notesState = userId.isNotEmpty
        ? ref.watch(notesViewModelProvider(userId))
        : const NotesInitial();

    if (kDebugMode) {
      print('[NotesListScreen Current state: ${notesState.toString()}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: _buildBody(context, ref, notesState, userId),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          context.pushNamed('note-detail-screen',extra: null);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      WidgetRef ref,
      NotesState state,
      String userId,
      ) {
    if (state is NotesLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading notes...'),
          ],
        ),
      );
    }

    if (state is NotesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Refresh by rebuilding the provider
                ref.invalidate(notesViewModelProvider(userId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is NotesLoaded) {
      final notes = state.notes;
      print('[NotesListScreen] Displaying ${notes.length} notes');

      if (notes.isEmpty) {
        return _buildEmptyState();
      }

      return SearchableList<NoteEntity>(
        key: ValueKey('notes_list_${notes.length}_${notes.map((n) => n.id).join(",")}'),
        initialList: notes,
        searchFieldPadding: EdgeInsets.all(16),
        filter: (query) {
          final filtered = notes
              .where((note) =>
          note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase()))
              .toList();
          print('[NotesListScreen] Filtered to ${filtered.length} notes for query: "$query"');
          return filtered;
        },
        emptyWidget: _buildSearchEmptyState(),
        itemBuilder: (item) {
          print('[NotesListScreen] Building note card');
          return NoteCard(
            key: ValueKey('note_${item.id}_${item.updatedAt.millisecondsSinceEpoch}'),
            note: item,
            onTap: () async {
              context.pushNamed('note-detail-screen',extra: item);
            },
            onDelete: () async {
              await ref
                  .read(notesViewModelProvider(userId).notifier)
                  .deleteNote(userId: item.userId, noteId: item.id);
              if (context.mounted) {
                _showMessage(context, 'Note deleted', false);
              }
            },
          );
        },
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

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first note',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ref.read(authViewModelProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
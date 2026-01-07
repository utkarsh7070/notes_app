import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../provider/auth_provider.dart';
import '../../provider/notes_provider.dart';
import '../../view_model/notes/notes_state.dart';
import '../widgets/notes_body.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});


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
      body: NotesBody(
        userId: userId,
        notesState: notesState,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          context.pushNamed('note-detail-screen',extra: null);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
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
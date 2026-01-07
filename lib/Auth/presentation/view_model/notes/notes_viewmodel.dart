import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/Auth/domain/usecases/notes/get_note_usecase.dart';
import '../../../domain/entities/note_entity.dart';
import '../../../domain/usecases/notes/create_note_usecase.dart';
import '../../../domain/usecases/notes/delete_note_usecase.dart';
import '../../../domain/usecases/notes/update_note_usecase.dart';
import 'notes_state.dart';

class NotesViewModel extends StateNotifier<NotesState> {
  final GetNotesUseCase getNotesUseCase;
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final String userId;

  StreamSubscription? _notesSubscription;

  NotesViewModel({
    required this.getNotesUseCase,
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.userId,
  }) : super(const NotesInitial()) {
    _loadNotes();
  }

  void _loadNotes() {
    if (kDebugMode) {
      print('[NotesViewModel] Loading notes for userId: $userId');
    }
    state = const NotesLoading();

    _notesSubscription?.cancel();

    _notesSubscription = getNotesUseCase(GetNoteParams(userId: userId)).listen(
      (result) {
        result.fold(
          (failure) {
            if (kDebugMode) {
              print('[NotesViewModel] Error: ${failure.message}');
            }
            state = NotesError(failure.message);
          },
          (notes) {
            if (kDebugMode) {
              print(
                '[NotesViewModel] Received ${notes.length} notes from stream',
              );
            }

            final currentState = state;
            final searchQuery = currentState is NotesLoaded
                ? currentState.searchQuery
                : '';

            state = NotesLoaded(notes: notes, searchQuery: searchQuery);
            if (kDebugMode) {
              print(
                '[NotesViewModel] State updated to NotesLoaded with ${notes.length} notes',
              );
            }
          },
        );
      },
      onError: (error) {
        if (kDebugMode) {
          print('[NotesViewModel] Stream error: $error');
        }
        state = NotesError(error.toString());
      },
    );
  }

  Future<void> createNote(String title, String content) async {
    if (kDebugMode) {
      print('[NotesViewModel] Creating note: $title');
    }

    final result = await createNoteUseCase(
      CreateNoteParams(title: title, content: content, userId: userId),
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[NotesViewModel] Create failed: ${failure.message}');
        }
      },
      (_) {
        if (kDebugMode) {
          print('[NotesViewModel] Note created successfully');
        }
      },
    );
  }

  Future<void> updateNote(NoteEntity note, String title, String content) async {
    if (kDebugMode) {
      print('[NotesViewModel] Updating note ${note.id}: $title');
    }

    final result = await updateNoteUseCase(
      UpdateNoteParams(note: note, title: title, content: content),
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[NotesViewModel] Update failed: ${failure.message}');
        }
      },
      (_) {
        if (kDebugMode) {
          print('[NotesViewModel] Note updated successfully');
        }
      },
    );
  }

  Future<void> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    if (kDebugMode) {
      print('[NotesViewModel] Deleting note $noteId');
    }

    final result = await deleteNoteUseCase(
      DeleteNoteParams(noteId: noteId, userId: userId),
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[NotesViewModel] Delete failed: ${failure.message}');
        }
      },
      (_) {
        if (kDebugMode) {
          print('[NotesViewModel] Note deleted successfully');
        }
      },
    );
  }

  void updateSearchQuery(String query) {
    if (kDebugMode) {
      print('[NotesViewModel] Search query updated: $query');
    }
    if (state is NotesLoaded) {
      final currentNotes = (state as NotesLoaded).notes;
      state = NotesLoaded(notes: currentNotes, searchQuery: query);
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('[NotesViewModel] Disposing...');
    }
    _notesSubscription?.cancel();
    super.dispose();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/Auth/domain/usecases/notes/get_note_usecase.dart';
import '../../data/datasource/note_remote_ds.dart';
import '../../data/repositories/note_repository_imp.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecases/notes/create_note_usecase.dart';
import '../../domain/usecases/notes/delete_note_usecase.dart';
import '../../domain/usecases/notes/update_note_usecase.dart';
import '../view_model/notes/notes_state.dart';
import '../view_model/notes/notes_viewmodel.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final notesRemoteDataSourceProvider = Provider<NotesRemoteDataSource>((ref) {
  return NotesRemoteDataSourceImpl(firestore: ref.watch(firestoreProvider));
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl(
    remoteDataSource: ref.watch(notesRemoteDataSourceProvider),
  );
});

final getNotesUseCaseProvider = Provider.autoDispose<GetNotesUseCase>((ref) {
  return GetNotesUseCase(ref.watch(notesRepositoryProvider));
});

final createNoteUseCaseProvider = Provider.autoDispose<CreateNoteUseCase>((
  ref,
) {
  return CreateNoteUseCase(ref.watch(notesRepositoryProvider));
});

final updateNoteUseCaseProvider = Provider.autoDispose<UpdateNoteUseCase>((
  ref,
) {
  return UpdateNoteUseCase(ref.watch(notesRepositoryProvider));
});

final deleteNoteUseCaseProvider = Provider.autoDispose<DeleteNoteUseCase>((
  ref,
) {
  return DeleteNoteUseCase(ref.watch(notesRepositoryProvider));
});

final notesViewModelProvider = StateNotifierProvider.family
    .autoDispose<NotesViewModel, NotesState, String>((ref, userId) {
      return NotesViewModel(
        getNotesUseCase: ref.watch(getNotesUseCaseProvider),
        createNoteUseCase: ref.watch(createNoteUseCaseProvider),
        updateNoteUseCase: ref.watch(updateNoteUseCaseProvider),
        deleteNoteUseCase: ref.watch(deleteNoteUseCaseProvider),
        userId: userId,
      );
    });

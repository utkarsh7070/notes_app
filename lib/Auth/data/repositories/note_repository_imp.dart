import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../core/error/exception.dart';
import '../../../core/error/failure.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasource/note_remote_ds.dart';
import '../model/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<NoteEntity>>> getNotesStream(String userId) {
    try {
      return remoteDataSource
          .getNotesStream(userId)
          .map(
            (notes) => Right<Failure, List<NoteEntity>>(
              notes.map((note) => note.toEntity()).toList(),
            ),
          );
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> createNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      await remoteDataSource.createNote(noteModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateNote(NoteEntity note) async {
    if (kDebugMode) {
      print("note repository");
    }
    try {
      final noteModel = NoteModel.fromEntity(note);
      await remoteDataSource.updateNote(noteModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String userId, String noteId) async {
    try {
      await remoteDataSource.deleteNote(userId, noteId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NoteEntity>> getNoteById(String noteId) async {
    try {
      final note = await remoteDataSource.getNoteById(noteId);
      return Right(note.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

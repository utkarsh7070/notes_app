import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../entities/note_entity.dart';

abstract class NotesRepository {
  Stream<Either<Failure, List<NoteEntity>>> getNotesStream(String userId);

  Future<Either<Failure, void>> createNote(NoteEntity note);

  Future<Either<Failure, void>> updateNote(NoteEntity note);

  Future<Either<Failure, void>> deleteNote(String userId, String noteId);

  Future<Either<Failure, NoteEntity>> getNoteById(String noteId);
}

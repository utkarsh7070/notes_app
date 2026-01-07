import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../entities/note_entity.dart';
import '../../repositories/notes_repository.dart';

class UpdateNoteUseCase implements UseCase<void, UpdateNoteParams> {
  final NotesRepository repository;

  UpdateNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateNoteParams params) async {
    if (params.title.trim().isEmpty) {
      return Left(ValidationFailure('Title cannot be empty'));
    }
    if (params.content.trim().isEmpty) {
      return Left(ValidationFailure('Content cannot be empty'));
    }

    final now = DateTime.now();
    final note = NoteEntity(
      id: params.note.id,
      title: params.title.trim(),
      content: params.content.trim(),
      userId: params.note.userId,
      createdAt: params.note.createdAt,
      updatedAt: now,
    );

    return await repository.updateNote(note);
  }
}

class UpdateNoteParams extends Equatable {
  final String title;
  final String content;
  final NoteEntity note;

  const UpdateNoteParams({
    required this.title,
    required this.content,
    required this.note,
  });

  @override
  List<Object> get props => [title, content, note];
}

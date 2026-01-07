import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../entities/note_entity.dart';
import '../../repositories/notes_repository.dart';

class CreateNoteUseCase implements UseCase<void, CreateNoteParams> {
  final NotesRepository repository;

  CreateNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateNoteParams params) async {
    if (params.title.trim().isEmpty) {
      return Left(ValidationFailure('Title cannot be empty'));
    }
    if (params.content.trim().isEmpty) {
      return Left(ValidationFailure('Content cannot be empty'));
    }

    final now = DateTime.now();
    final note = NoteEntity(
      id: '',
      title: params.title.trim(),
      content: params.content.trim(),
      userId: params.userId,
      createdAt: now,
      updatedAt: now,
    );

    return await repository.createNote(note);
  }
}

class CreateNoteParams extends Equatable {
  final String title;
  final String content;
  final String userId;

  const CreateNoteParams({
    required this.title,
    required this.content,
    required this.userId,
  });

  @override
  List<Object> get props => [title, content, userId];
}

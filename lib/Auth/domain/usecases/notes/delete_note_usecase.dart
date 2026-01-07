import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../repositories/notes_repository.dart';

class DeleteNoteUseCase implements UseCase<void, DeleteNoteParams> {
  final NotesRepository repository;

  DeleteNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) async {
    if (params.noteId.isEmpty) {
      return Left(ValidationFailure('Note ID cannot be empty'));
    }
    return await repository.deleteNote(params.userId, params.noteId);
  }
}

class DeleteNoteParams extends Equatable {
  final String noteId;
  final String userId;

  const DeleteNoteParams({required this.noteId, required this.userId});

  @override
  List<Object> get props => [noteId];
}

import 'dart:async';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/usecases/usecase.dart';
import '../../entities/note_entity.dart';
import '../../repositories/notes_repository.dart';

class GetNotesUseCase implements StreamUseCase<void, GetNoteParams> {
  final NotesRepository repository;

  GetNotesUseCase(this.repository);

  @override
  Stream<Either<Failure, List<NoteEntity>>> call(GetNoteParams getNoteParams) {
    return repository.getNotesStream(getNoteParams.userId);
  }
}

class GetNoteParams extends Equatable {
  final String userId;

  const GetNoteParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

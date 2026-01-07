import 'package:equatable/equatable.dart';
import '../../../domain/entities/note_entity.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {
  const NotesInitial();

  @override
  String toString() => 'NotesInitial()';
}

class NotesLoading extends NotesState {
  const NotesLoading();

  @override
  String toString() => 'NotesLoading()';
}

class NotesLoaded extends NotesState {
  final List<NoteEntity> notes;
  final String searchQuery;

  const NotesLoaded({required this.notes, this.searchQuery = ''});

  List<NoteEntity> get filteredNotes {
    if (searchQuery.isEmpty) return notes;
    return notes
        .where(
          (note) =>
              note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              note.content.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  List<Object?> get props => [notes, searchQuery];

  NotesLoaded copyWith({List<NoteEntity>? notes, String? searchQuery}) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  String toString() =>
      'NotesLoaded(notes: ${notes.length}, searchQuery: "$searchQuery")';
}

class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'NotesError(message: $message)';
}

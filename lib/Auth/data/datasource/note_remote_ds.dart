import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:notes_app/Auth/data/model/note_model.dart';
import 'package:notes_app/core/error/exception.dart';

abstract class NotesRemoteDataSource {
  Stream<List<NoteModel>> getNotesStream(String userId);

  Future<void> createNote(NoteModel note);

  Future<void> updateNote(NoteModel note);

  Future<void> deleteNote(String userId,String noteId);

  Future<NoteModel> getNoteById(String noteId);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _notesCollection = 'notes';

  NotesRemoteDataSourceImpl({required this.firestore});

  CollectionReference _getNotesCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('notes');
  }

  @override
  Stream<List<NoteModel>> getNotesStream(String userId) {
    // print(user?.uid);
    return _getNotesCollection(
      userId,
    ).orderBy('updatedAt', descending: true).snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return NoteModel.fromJson(doc);
      }).toList();
    });
  }

  @override
  Future<void> createNote(NoteModel note) async {
    try {
      await _getNotesCollection(note.userId).add(note.toJson());
      if (kDebugMode) {
        print('create note');
      }
    } catch (e) {
      throw ServerException('Failed to create note: $e');
    }
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    if (kDebugMode) {
      print("print update note ${note.userId},${note.id}");
    }
    try {
      await _getNotesCollection(note.userId)
          .doc(note.id)
          .update(note.toJson());
    } catch (e) {
      throw ServerException('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String userId,String noteId) async {
    try {
      await firestore.collection(_notesCollection).doc(noteId).delete();
      print(noteId);
      await _getNotesCollection(userId).doc(noteId).delete();
    } catch (e) {
      throw ServerException('Failed to delete note: $e');
    }
  }

  @override
  Future<NoteModel> getNoteById(String noteId) async {
    try {
      final doc = await firestore
          .collection(_notesCollection)
          .doc(noteId)
          .get();

      if (!doc.exists) {
        throw const ServerException('Note not found');
      }

      return NoteModel.fromJson(doc);
    } catch (e) {
      throw ServerException('Failed to get note: $e');
    }
  }
}

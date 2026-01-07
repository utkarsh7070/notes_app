import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/note_entity.dart';
import '../../provider/auth_provider.dart';
import '../../provider/notes_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final NoteEntity? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.note == null;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final authState = ref.read(authStateStreamProvider);
    final userId = authState.value?.uid ?? '';

    if (userId.isEmpty) {
      _showMessage('User not authenticated', true);
      setState(() {
        _isSaving = false;
      });
      return;
    }

    try {
      if (widget.note == null) {
        print('[NoteDetailScreen] Creating note: ${_titleController.text}');
        await ref.read(notesViewModelProvider(userId).notifier).createNote(
          _titleController.text.trim(),
          _contentController.text.trim(),
        );

        if (mounted) {
          print('[NoteDetailScreen] Note created, popping screen');
          context.pop();
        }
      } else {
        print('[NoteDetailScreen] Updating note: ${_titleController.text}');
        await ref.read(notesViewModelProvider(userId).notifier).updateNote(
          widget.note!,
          _titleController.text.trim(),
          _contentController.text.trim(),
        );

        if (mounted) {
          print('[NoteDetailScreen] Note updated, popping screen');
          context.pop();
        }
      }
    } catch (e) {
      print('[NoteDetailScreen] Error: $e');
      _showMessage('Failed to save note: $e', true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        centerTitle: true,
        actions: [
          if( widget.note != null)
            Visibility(
              replacement: TextButton(onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              }, child: Text('Cancel')),
              visible: widget.note != null && !_isEditing,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Visibility(
                replacement: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                    Text(_titleController.text),
                  ],
                ),
                visible: _isEditing,
                child: CustomTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Enter note title',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Visibility(
                replacement: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Content',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                    Text(_contentController.text),
                  ],
                ),
                visible: _isEditing,
                child: CustomTextField(
                  controller: _contentController,
                  label: 'Content',
                  hint: 'Enter note content',
                  maxLines: 15,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              if (_isEditing)
                CustomButton(
                  text: widget.note == null ? 'Create Note' : 'Update Note',
                  onPressed: _isSaving ? () {} : _handleSave,
                  isLoading: _isSaving,
                ),
              if (!_isEditing && widget.note != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created: ${_formatDate(widget.note!.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Updated: ${_formatDate(widget.note!.updatedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
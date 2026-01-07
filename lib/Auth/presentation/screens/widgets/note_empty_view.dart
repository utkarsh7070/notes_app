import 'package:flutter/material.dart';

class NotesEmptyView extends StatelessWidget {
  const NotesEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No notes yet',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

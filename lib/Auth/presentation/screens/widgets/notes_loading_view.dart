import 'package:flutter/material.dart';

class NotesLoadingView extends StatelessWidget {
  const NotesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading notes...'),
        ],
      ),
    );
  }
}

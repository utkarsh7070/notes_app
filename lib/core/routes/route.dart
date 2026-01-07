import 'package:go_router/go_router.dart';
import 'package:notes_app/Auth/presentation/screens/auth/signup_screen.dart';

import '../../Auth/domain/entities/note_entity.dart';
import '../../Auth/presentation/screens/auth/login_screen.dart';
import '../../Auth/presentation/screens/notes/note_detail_screen.dart';
import '../../Auth/presentation/screens/notes/notes_list_screen.dart';
import '../../app.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth-wrapper',
    routes: [
      GoRoute(
        path: '/auth-wrapper',
        name: 'auth-wrapper',
        builder: (context, state) => const AuthWrapper(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/note-list-screen',
        name: 'note-list-screen',
        builder: (context, state) => const NotesListScreen(),
      ),
      GoRoute(
        path: '/note-detail-screen',
        name: 'note-detail-screen',

        builder: (context, state) {
          final note = state.extra as NoteEntity?;
          return NoteDetailScreen(note: note);
        },
      ),
    ],
  );
}

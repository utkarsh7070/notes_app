import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';
import 'auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;

  AuthViewModel({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
  }) : super(const AuthInitial());

  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();

    final result = await signInUseCase(
      SignInParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = const AuthSuccess('Signed in successfully'),
    );
  }

  Future<void> signUp(String email, String password) async {
    state = const AuthLoading();

    final result = await signUpUseCase(
      SignUpParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = const AuthSuccess('Account created successfully'),
    );
  }

  Future<void> signOut() async {
    state = const AuthLoading();

    final result = await signOutUseCase(const NoParams());

    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthSuccess('Signed out successfully'),
    );
  }

  void resetState() {
    state = const AuthInitial();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => user != null;
  bool get isUnauthenticated => user == null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
  }

  void _initializeAuth() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        final user = AppUser(
          id: session.user.id,
          name: session.user.userMetadata?['full_name'] ?? 
                session.user.userMetadata?['name'] ?? 
                session.user.email?.split('@').first ?? 'User',
          email: session.user.email ?? '',
          createdAt: DateTime.parse(session.user.createdAt),
        );
        
        state = state.copyWith(
          user: user,
          isLoading: false,
          errorMessage: null,
        );
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AuthState();
      }
    });
    
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final user = AppUser(
        id: session.user.id,
        name: session.user.userMetadata?['full_name'] ?? 
              session.user.userMetadata?['name'] ?? 
              session.user.email?.split('@').first ?? 'User',
        email: session.user.email ?? '',
        createdAt: DateTime.parse(session.user.createdAt),
      );
      
      state = state.copyWith(user: user);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      if (name.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Name is required',
        );
        return false;
      }

      if (email.trim().isEmpty || !email.contains('@')) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please enter a valid email address',
        );
        return false;
      }

      if (password.length < 6) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Password must be at least 6 characters',
        );
        return false;
      }

      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': name.trim(),
        },
      );

      if (response.user != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Registration failed. Please try again.',
        );
        return false;
      }
    } catch (e) {
      String errorMessage = 'Registration failed. Please try again.';

      if (e.toString().contains('User already registered')) {
        errorMessage = 'An account with this email already exists.';
      } else if (e.toString().contains('Invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.toString().contains('Password should be at least')) {
        errorMessage = 'Password must be at least 6 characters long.';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Basic validation
      if (email.trim().isEmpty || !email.contains('@')) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please enter a valid email address',
        );
        return false;
      }

      if (password.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please enter your password',
        );
        return false;
      }

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Login failed. Please check your credentials.',
        );
        return false;
      }
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Please check your email and click the confirmation link.';
      } else if (e.toString().contains('Too many requests')) {
        errorMessage = 'Too many login attempts. Please try again later.';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.redirectUrl,
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google sign-in failed. Please try again.',
      );
      return false;
    }
  }


  void logout() {
    Supabase.instance.client.auth.signOut();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

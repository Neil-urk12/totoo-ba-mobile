import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? user,
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
  AuthNotifier() : super(const AuthState());

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await Future.delayed(const Duration(seconds: 1));

      // Simulate validation
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

      if (password.length < 8) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Password must be at least 8 characters',
        );
        return false;
      }

      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Password must contain at least one uppercase letter',
        );
        return false;
      }

      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Password must contain at least one special character',
        );
        return false;
      }

      // Create user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        user: user,
        isLoading: false,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed. Please try again.',
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

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Simulate validation
      if (email.trim().isEmpty || !email.contains('@')) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please enter a valid email address',
        );
        return false;
      }

      if (password.length < 8) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Password must be at least 8 characters',
        );
        return false;
      }

      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Password must contain at least one uppercase letter',
        );
        return false;
      }

      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Password must contain at least one special character',
        );
        return false;
      }

      // For demo purposes, create a mock user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Demo User',
        email: email.trim(),
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        user: user,
        isLoading: false,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed. Please try again.',
      );
      return false;
    }
  }

  void logout() {
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

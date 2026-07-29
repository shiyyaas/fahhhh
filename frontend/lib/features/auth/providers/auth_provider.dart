import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_state.dart';
import '../models/current_user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mock_auth_repository.dart';

part 'auth_provider.g.dart';

// Maintain the existing global SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError("sharedPreferencesProvider must be overridden in main.dart");
});

// Code generated AuthRepository provider
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return MockAuthRepository();
}

// Code generated AuthNotifier provider using Riverpod Generator annotations
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final cachedUserJson = prefs.getString('cached_user_profile');
    if (cachedUserJson != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(cachedUserJson);
        final user = CurrentUser.fromJson(userMap);
        return Authenticated(user);
      } catch (e) {
        // Clear corrupt data
        prefs.remove('cached_user_profile');
      }
    }
    return const Unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const Authenticating();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(email, password);

      // Cache user session in SharedPreferences
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('cached_user_profile', jsonEncode(user.toJson()));

      state = Authenticated(user);
    } catch (e) {
      state = AuthenticationFailed(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove('cached_user_profile');
    state = const Unauthenticated();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final currentState = state;
    if (currentState is Authenticated) {
      final updatedUser = currentState.user.copyWith(
        name: name,
        email: email,
        phone: phone,
      );

      // Cache user session in SharedPreferences
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('cached_user_profile', jsonEncode(updatedUser.toJson()));

      state = Authenticated(updatedUser);
    }
  }
}

// Keep a backward-compatible authProvider so existing files don't break
final authProvider = StateProvider<AuthState>((ref) {
  // Watch the modern code-generated AuthNotifier
  final state = ref.watch(authNotifierProvider);
  return state;
});

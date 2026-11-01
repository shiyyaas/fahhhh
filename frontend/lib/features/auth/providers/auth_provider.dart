import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_state.dart';
import '../models/current_user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../repositories/auth_repository.dart';
import '../repositories/network_auth_repository.dart';

part 'auth_provider.g.dart';

// Maintain the existing global SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError("sharedPreferencesProvider must be overridden in main.dart");
});

// Code generated AuthRepository provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return NetworkAuthRepository(
    apiClient: ref.watch(apiClientProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
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
    await prefs.remove('auth_token');
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

      // Optionally sync to backend if user id is available
      final userId = updatedUser.id;
      if (userId != null && userId.isNotEmpty) {
        try {
          final apiClient = ref.read(apiClientProvider);
          if (updatedUser.role.name == 'student') {
            await apiClient.put(
              ApiEndpoints.student(userId),
              data: {
                'studentName': name,
                'email': email,
                'phoneNo': phone,
              },
            );
          } else {
            await apiClient.put(
              ApiEndpoints.teacher(userId),
              data: {
                'teacherName': name,
                'email': email,
                'phoneNo': phone,
              },
            );
          }
        } catch (_) {
          // Graceful fallback if offline
        }
      }

      state = Authenticated(updatedUser);
    }
  }

  Future<String?> uploadAvatar(XFile imageFile) async {
    final currentState = state;
    if (currentState is! Authenticated) return null;

    try {
      final apiClient = ref.read(apiClientProvider);
      final user = currentState.user;

      final bytes = await imageFile.readAsBytes();
      final formData = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name,
        ),
        'userId': user.id ?? '',
        'email': user.email,
        'role': user.role.name,
      });

      final response = await apiClient.post(
        ApiEndpoints.uploadAvatar,
        data: formData,
      );

      final data = response.data;
      if (data is Map && data['success'] == true) {
        final avatarRelative = data['avatarUrl'] as String;
        final fullAvatarUrl = ApiEndpoints.resolveUrl(avatarRelative);

        final updatedUser = user.copyWith(imageUrl: fullAvatarUrl);
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setString('cached_user_profile', jsonEncode(updatedUser.toJson()));
        state = Authenticated(updatedUser);
        return fullAvatarUrl;
      }
    } catch (e) {
      // Return null on upload failure
    }
    return null;
  }
}

// Keep a backward-compatible authProvider so existing files don't break
final authProvider = StateProvider<AuthState>((ref) {
  // Watch the modern code-generated AuthNotifier
  final state = ref.watch(authNotifierProvider);
  return state;
});

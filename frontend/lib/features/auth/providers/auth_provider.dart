import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_state.dart';
import '../models/user_role.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final authProvider = StateProvider<AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final token = prefs.getString("auth_token");
  final roleStr = prefs.getString("user_role");
  if (token != null && roleStr != null) {
    UserRole role;
    switch (roleStr) {
      case "TEACHER":
        role = UserRole.teacher;
        break;
      case "HOD":
        role = UserRole.hod;
        break;
      default:
        role = UserRole.student;
    }
    return AuthState(
      isLoggedIn: true,
      role: role,
    );
  }
  return const AuthState(
    isLoggedIn: false,
    role: UserRole.student,
  );
});

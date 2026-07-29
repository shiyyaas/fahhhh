import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Simulate short network delay
    await Future.delayed(const Duration(milliseconds: 500));

    String roleString = "STUDENT";
    final lowercaseEmail = email.toLowerCase();
    if (lowercaseEmail.contains("hod")) {
      roleString = "HOD";
    } else if (lowercaseEmail.contains("teacher")) {
      roleString = "TEACHER";
    }

    // Persist login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", "mock_token_abc123");
    await prefs.setString("user_email", email);
    await prefs.setString("user_role", roleString);

    return {
      "token": "mock_token_abc123",
      "user": {
        "email": email,
        "role": roleString,
      },
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_email");
    await prefs.remove("user_role");
  }
}

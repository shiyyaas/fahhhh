import 'user_role.dart';

class AuthState {

  final bool isLoggedIn;
  final UserRole role;

  const AuthState({
    required this.isLoggedIn,
    required this.role,
  });

}
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state.dart';
import '../models/user_role.dart';

final authProvider =
    StateProvider<AuthState>((ref) {

  return const AuthState(
    isLoggedIn: false,
    role: UserRole.student,
  );

});
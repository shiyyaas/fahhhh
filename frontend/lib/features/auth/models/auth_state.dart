import '../models/current_user.dart';
import '../models/user_role.dart';

sealed class AuthState {
  const AuthState();

  bool get isLoggedIn => this is Authenticated;

  UserRole get role {
    final self = this;
    if (self is Authenticated) {
      return self.user.role;
    }
    return UserRole.student;
  }

  CurrentUser? get user {
    final self = this;
    if (self is Authenticated) {
      return self.user;
    }
    return null;
  }
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Authenticating extends AuthState {
  const Authenticating();
}

class Authenticated extends AuthState {
  @override
  final CurrentUser user;
  const Authenticated(this.user);
}

class AuthenticationFailed extends AuthState {
  final String message;
  const AuthenticationFailed(this.message);
}

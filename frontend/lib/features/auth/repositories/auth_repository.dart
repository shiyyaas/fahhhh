import '../models/current_user.dart';

abstract class AuthRepository {
  Future<CurrentUser> login(String email, String password);
}

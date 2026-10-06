import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/current_user.dart';
import '../models/user_role.dart';
import 'auth_repository.dart';

class NetworkAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  NetworkAuthRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  })  : _apiClient = apiClient,
        _prefs = prefs;

  @override
  Future<CurrentUser> login(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty) {
      throw Exception("Email cannot be empty");
    }
    if (trimmedPassword.isEmpty) {
      throw Exception("Password cannot be empty");
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': trimmedEmail,
          'password': trimmedPassword,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      final token = data['token'] as String?;
      if (token != null) {
        await _prefs.setString('auth_token', token);
      }

      final userMap = data['user'] as Map<String, dynamic>;
      final rawRole = (userMap['role'] as String? ?? 'STUDENT').toUpperCase();

      final UserRole role;
      final bool isHOD;
      if (rawRole == 'HOD') {
        role = UserRole.teacher;
        isHOD = true;
      } else if (rawRole == 'TEACHER') {
        role = UserRole.teacher;
        isHOD = false;
      } else {
        role = UserRole.student;
        isHOD = false;
      }

      final currentUser = CurrentUser(
        id: userMap['id'] as String? ?? userMap['_id'] as String?,
        name: userMap['name'] as String? ?? 'User',
        email: userMap['email'] as String? ?? trimmedEmail,
        role: role,
        isHOD: isHOD,
        departmentId: userMap['department'] as String? ?? 'Department of Computer Science',
        designation: isHOD ? 'Head Of Department' : (role == UserRole.teacher ? 'Assistant Professor' : null),
        phone: userMap['phone'] as String? ?? '',
        imageUrl: role == UserRole.student ? 'assets/images/student.png' : 'assets/images/profile.png',
      );

      return currentUser;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final resData = e.response!.data as Map;
        final msg = resData['message'] ?? 'Network authentication failed';
        throw Exception(msg);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server at ${ApiEndpoints.baseUrl}. Ensure backend is running.');
      }
      throw Exception(e.message ?? 'Unknown connection error');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }
}

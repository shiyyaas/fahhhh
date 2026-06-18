import 'package:dio/dio.dart';

class AuthService {

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:5000/api",
    ),
  );

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

    final response = await dio.post(
      "/auth/login",
      data: {
        "email": email,
        "password": password,
      },
    );

    return response.data;
  }
}
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Mark single student attendance
  Future<bool> markAttendance({
    required String studentId,
    required String subjectId,
    required String teacherId,
    required String batchId,
    required String status, // 'Present' or 'Absent'
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.markAttendance,
        data: {
          'student': studentId,
          'subject': subjectId,
          'teacher': teacherId,
          'batch': batchId,
          'status': status,
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('[AttendanceRepository] markAttendance error: $e');
      return false;
    }
  }

  /// Mark bulk attendance for a list of students
  Future<void> markBulkAttendance({
    required List<Map<String, dynamic>> records,
  }) async {
    for (final record in records) {
      try {
        await _apiClient.dio.post(
          ApiEndpoints.markAttendance,
          data: record,
        );
      } catch (e) {
        debugPrint('[AttendanceRepository] markBulkAttendance item error: $e');
      }
    }
  }

  /// Get attendance percentage for a student
  Future<Map<String, dynamic>?> getAttendancePercentage(String studentId) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.attendancePercentage(studentId));
      if (response.data['success'] == true) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('[AttendanceRepository] getAttendancePercentage error: $e');
      return null;
    }
  }

  /// Get student attendance list
  Future<List<dynamic>> getStudentAttendance(String studentId) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.studentAttendance(studentId));
      if (response.data['success'] == true) {
        return (response.data['attendance'] as List?) ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('[AttendanceRepository] getStudentAttendance error: $e');
      return [];
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../repositories/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AttendanceRepository(apiClient: apiClient);
});

final studentAttendancePercentageProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, studentId) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getAttendancePercentage(studentId);
});

final studentAttendanceHistoryProvider = FutureProvider.family<List<dynamic>, String>((ref, studentId) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getStudentAttendance(studentId);
});

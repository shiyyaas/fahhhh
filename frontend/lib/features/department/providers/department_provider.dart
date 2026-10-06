import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/department_class.dart';
import '../models/department_teacher.dart';
import '../models/department_student.dart';
import '../models/department_subject.dart';
import '../repositories/department_repository.dart';

final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DepartmentRepository(apiClient: apiClient);
});

final departmentClassesProvider = FutureProvider<List<DepartmentClass>>((ref) async {
  final repo = ref.watch(departmentRepositoryProvider);
  return repo.getClasses();
});

final departmentTeachersProvider = FutureProvider<List<DepartmentTeacher>>((ref) async {
  final repo = ref.watch(departmentRepositoryProvider);
  return repo.getTeachers();
});

final departmentStudentsProvider = FutureProvider.family<List<DepartmentStudent>, String?>((ref, batchId) async {
  final repo = ref.watch(departmentRepositoryProvider);
  return repo.getStudents(batchId: batchId);
});

final departmentSubjectsProvider = FutureProvider<List<DepartmentSubject>>((ref) async {
  final repo = ref.watch(departmentRepositoryProvider);
  return repo.getSubjects();
});

final hodDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(departmentRepositoryProvider);
  return repo.getHodDashboard();
});

final defaultersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(departmentRepositoryProvider);
  return repo.getDefaulters();
});

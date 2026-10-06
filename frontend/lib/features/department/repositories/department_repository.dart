import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/department_class.dart';
import '../models/department_teacher.dart';
import '../models/department_student.dart';
import '../models/department_subject.dart';

class DepartmentRepository {
  final ApiClient _apiClient;

  DepartmentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<DepartmentClass>> getClasses() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.batches);
      if (response.data is Map && response.data['success'] == true) {
        final list = response.data['batches'] as List<dynamic>? ?? [];
        if (list.isNotEmpty) {
          return list.map((item) => DepartmentClass.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {
      // Graceful fallback to mock data on offline/network errors
    }
    return mockDepartmentClasses;
  }

  Future<List<DepartmentTeacher>> getTeachers() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teachers);
      if (response.data is Map && response.data['success'] == true) {
        final list = response.data['teachers'] as List<dynamic>? ?? [];
        if (list.isNotEmpty) {
          return list.map((item) => DepartmentTeacher.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {
      // Graceful fallback to mock data on offline/network errors
    }
    return mockDepartmentTeachers;
  }

  Future<List<DepartmentStudent>> getStudents({String? batchId}) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.students);
      if (response.data is Map && response.data['success'] == true) {
        final list = response.data['students'] as List<dynamic>? ?? [];
        if (list.isNotEmpty) {
          var students = list.map((item) => DepartmentStudent.fromJson(item as Map<String, dynamic>)).toList();
          if (batchId != null && batchId.isNotEmpty) {
            students = students.where((s) => s.batchId == batchId || (s.batchName ?? '').toLowerCase() == batchId.toLowerCase()).toList();
          }
          return students;
        }
      }
    } catch (_) {
      // Graceful fallback to mock data on offline/network errors
    }
    return mockDepartmentStudents;
  }

  Future<List<DepartmentSubject>> getSubjects() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.subjects);
      if (response.data is Map && response.data['success'] == true) {
        final list = response.data['subjects'] as List<dynamic>? ?? [];
        if (list.isNotEmpty) {
          return list.map((item) => DepartmentSubject.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {
      // Graceful fallback to mock data on offline/network errors
    }
    return mockDepartmentSubjects;
  }

  Future<DepartmentTeacher> createTeacher({
    required String teacherName,
    required String employeeId,
    required String email,
    required String phoneNo,
    List<String>? departments,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.teachers,
      data: {
        'teacherName': teacherName,
        'employeeId': employeeId,
        'email': email,
        'phoneNo': phoneNo,
        'departments': departments ?? [],
      },
    );
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data['teacher'] != null) {
      return DepartmentTeacher.fromJson(data['teacher'] as Map<String, dynamic>);
    }
    throw Exception(data['message'] ?? 'Failed to create teacher');
  }

  Future<void> deleteTeacher(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.teacher(id));
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete teacher');
    }
  }

  Future<DepartmentStudent> createStudent({
    required String studentName,
    required String registerNo,
    required String email,
    required String phoneNo,
    required String aadhaarNo,
    required String batchId,
    String? apaarId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.students,
      data: {
        'studentName': studentName,
        'registerNo': registerNo,
        'email': email,
        'phoneNo': phoneNo,
        'aadhaarNo': aadhaarNo,
        'batchId': batchId,
        'apaarId': apaarId ?? '',
      },
    );
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data['student'] != null) {
      return DepartmentStudent.fromJson(data['student'] as Map<String, dynamic>);
    }
    throw Exception(data['message'] ?? 'Failed to create student');
  }

  Future<void> deleteStudent(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.student(id));
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete student');
    }
  }

  Future<DepartmentSubject> createSubject({
    required String subjectName,
    required String subjectCode,
    required int semester,
    int credits = 4,
    List<String>? departments,
    List<String>? teachers,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.subjects,
      data: {
        'subjectName': subjectName,
        'subjectCode': subjectCode,
        'semester': semester,
        'credits': credits,
        'departments': departments ?? [],
        'teachers': teachers ?? [],
      },
    );
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data['subject'] != null) {
      return DepartmentSubject.fromJson(data['subject'] as Map<String, dynamic>);
    }
    throw Exception(data['message'] ?? 'Failed to create subject');
  }

  Future<void> deleteSubject(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.subject(id));
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete subject');
    }
  }

  Future<void> promoteBatch(String batchId) async {
    final response = await _apiClient.put(ApiEndpoints.promoteBatch(batchId));
    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to promote batch');
    }
  }

  Future<Map<String, dynamic>> getHodDashboard() async {
    final response = await _apiClient.get(ApiEndpoints.hodDashboard);
    if (response.data is Map && response.data['success'] == true) {
      return (response.data['dashboard'] as Map<String, dynamic>?) ?? {};
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> getDefaulters() async {
    final response = await _apiClient.get(ApiEndpoints.defaulters);
    if (response.data is Map && response.data['success'] == true) {
      final list = response.data['defaulters'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }
}

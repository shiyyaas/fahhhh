import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    } catch (_) {
      // In web or environments where dart:io Platform is unavailable
    }
    return 'http://localhost:5000/api';
  }

  // Auth
  static const String login = '/auth/login';

  // Dashboard
  static const String hodDashboard = '/dashboard/hod';
  static String teacherDashboard(String id) => '/dashboard/teacher/$id';
  static String studentDashboard(String id) => '/dashboard/student/$id';

  // Batches
  static const String batches = '/batches';
  static String promoteBatch(String id) => '/batches/$id/promote';

  // Teachers
  static const String teachers = '/teachers';
  static String teacher(String id) => '/teachers/$id';

  // Students
  static const String students = '/students';
  static String student(String id) => '/students/$id';

  // Subjects
  static const String subjects = '/subjects';
  static String subject(String id) => '/subjects/$id';

  // Departments
  static const String departments = '/departments';
  static String department(String id) => '/departments/$id';

  // Timetable
  static const String timetable = '/timetable';
  static String batchTimetable(String id) => '/timetable/batch/$id';
  static String teacherTimetable(String id) => '/timetable/teacher/$id';
  static String deleteTimetable(String id) => '/timetable/$id';

  // Attendance
  static const String markAttendance = '/attendance/mark';
  static String studentAttendance(String id) => '/attendance/student/$id';
  static String batchAttendance(String id) => '/attendance/batch/$id';
  static String subjectAttendance(String id) => '/attendance/subject/$id';
  static String attendancePercentage(String id) => '/attendance/percentage/$id';
  static const String defaulters = '/attendance/defaulters';

  // Reports
  static String studentReport(String id) => '/reports/student/$id';
  static String batchReport(String id) => '/reports/batch/$id';
  static String subjectReport(String id) => '/reports/subject/$id';
  static String studentReportPdf(String id) => '/reports/student/$id/pdf';
  static String batchMonthlyPdf(String id) => '/reports/batch/$id/monthly-pdf';
  static String batchMonthlyPreview(String id) => '/reports/batch/$id/monthly-preview';

  // Leaves
  static const String leaves = '/leaves';
  static String recommendLeave(String id) => '/leaves/$id/recommend';
  static String approveLeave(String id) => '/leaves/$id/approve';
  static String rejectLeave(String id) => '/leaves/$id/reject';

  // Notifications
  static const String notifications = '/notifications';
  static String userNotifications(String userId) => '/notifications/$userId';
  static String markNotificationRead(String id) => '/notifications/$id/read';
}

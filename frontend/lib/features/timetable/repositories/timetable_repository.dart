import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/timetable_slot.dart';
import '../../home/widgets/status_badge.dart';

/// Maps a backend day-name string to a 1–6 integer (Mon=1 … Sat=6).
int _dayNameToInt(String day) {
  const map = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
  };
  return map[day] ?? 1;
}

/// Parses "HH:mm" (e.g. "09:30") to [TimeOfDay].
TimeOfDay _parseTime(String time) {
  final parts = time.split(':');
  if (parts.length < 2) return const TimeOfDay(hour: 9, minute: 0);
  return TimeOfDay(
    hour: int.tryParse(parts[0]) ?? 9,
    minute: int.tryParse(parts[1]) ?? 0,
  );
}

/// Converts a backend timetable JSON entry to [TimetableSlot].
TimetableSlot _slotFromJson(Map<String, dynamic> json) {
  final subjectObj = json['subject'];
  final teacherObj = json['teacher'];
  final batchObj = json['batch'];

  final subjectId = subjectObj is Map ? (subjectObj['_id'] as String? ?? '') : (subjectObj as String? ?? '');
  final subjectName = subjectObj is Map
      ? (subjectObj['subjectName'] as String? ?? 'Subject')
      : 'Subject';
  final teacherName = teacherObj is Map
      ? (teacherObj['teacherName'] as String? ?? 'Teacher')
      : 'Teacher';
  final batchName = batchObj is Map
      ? (batchObj['batchName'] as String? ?? 'Class')
      : 'Class';

  final teacherId = teacherObj is Map ? (teacherObj['_id'] as String? ?? '') : (teacherObj as String? ?? '');
  final batchId = batchObj is Map ? (batchObj['_id'] as String? ?? '') : (batchObj as String? ?? '');

  final day = json['day'] as String? ?? 'Monday';
  final startTimeStr = json['startTime'] as String? ?? '09:30';
  final endTimeStr = json['endTime'] as String? ?? '10:30';

  return TimetableSlot(
    id: json['_id'] as String? ?? subjectId,
    dayOfWeek: _dayNameToInt(day),
    startTime: _parseTime(startTimeStr),
    endTime: _parseTime(endTimeStr),
    subjectName: subjectName,
    teacherName: teacherName,
    classId: batchName,
    status: AttendanceStatus.pending,
    studentStatus: AttendanceStatus.pending,
    studentAttendance: const {},
    subjectId: subjectId,
    teacherId: teacherId,
    batchId: batchId,
  );
}

class TimetableRepository {
  final ApiClient _apiClient;

  TimetableRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetches timetable for a batch (HOD/Student perspective).
  /// Falls back to an empty list on error.
  Future<List<TimetableSlot>> getBatchTimetable(String batchId) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.batchTimetable(batchId));
      final data = response.data;
      if (data is Map && data['success'] == true) {
        final raw = data['timetable'] as List? ?? [];
        return raw
            .whereType<Map<String, dynamic>>()
            .map(_slotFromJson)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[TimetableRepository] getBatchTimetable error: $e');
      return [];
    }
  }

  /// Fetches timetable for a teacher (Teacher perspective).
  /// Falls back to an empty list on error.
  Future<List<TimetableSlot>> getTeacherTimetable(String teacherId) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.teacherTimetable(teacherId));
      final data = response.data;
      if (data is Map && data['success'] == true) {
        final raw = data['timetable'] as List? ?? [];
        return raw
            .whereType<Map<String, dynamic>>()
            .map(_slotFromJson)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[TimetableRepository] getTeacherTimetable error: $e');
      return [];
    }
  }

  /// Fetches all timetable entries (General / HOD perspective).
  Future<List<TimetableSlot>> getAllTimetable() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.timetable);
      final data = response.data;
      if (data is Map && data['success'] == true) {
        final raw = data['timetable'] as List? ?? [];
        return raw
            .whereType<Map<String, dynamic>>()
            .map(_slotFromJson)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[TimetableRepository] getAllTimetable error: $e');
      return [];
    }
  }
}


import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/timetable_slot.dart';
import '../../home/widgets/status_badge.dart';

/// Converts backend day names into integers.
/// Monday = 1 ... Saturday = 6.
int _dayNameToInt(String day) {
  const days = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
  };

  final result = days[day];

  if (result == null) {
    throw FormatException('Invalid timetable day: $day');
  }

  return result;
}

/// Converts integer day values into backend day names.
String _dayIntToName(int day) {
  const days = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
  };

  final result = days[day];

  if (result == null) {
    throw FormatException('Invalid day number: $day');
  }

  return result;
}

/// Parses HH:mm into TimeOfDay.
TimeOfDay _parseTime(String time) {
  final parts = time.split(':');

  if (parts.length != 2) {
    throw FormatException('Invalid time format: $time');
  }

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);

  if (hour == null ||
      minute == null ||
      hour < 0 ||
      hour > 23 ||
      minute < 0 ||
      minute > 59) {
    throw FormatException('Invalid time: $time');
  }

  return TimeOfDay(hour: hour, minute: minute);
}

/// Converts TimeOfDay into HH:mm.
String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}

/// Safely extracts an ID from a populated MongoDB reference
/// or an unpopulated ObjectId string.
String _extractId(dynamic value) {
  if (value is Map) {
    return value['_id']?.toString() ?? '';
  }

  return value?.toString() ?? '';
}

/// Converts backend timetable JSON into TimetableSlot.
TimetableSlot _slotFromJson(Map<String, dynamic> json) {
  final subjectObj = json['subject'];
  final teacherObj = json['teacher'];
  final batchObj = json['batch'];

  final subjectId = _extractId(subjectObj);
  final teacherId = _extractId(teacherObj);
  final batchId = _extractId(batchObj);

  final subjectName = subjectObj is Map
      ? subjectObj['subjectName']?.toString() ?? 'Subject'
      : 'Subject';

  final teacherName = teacherObj is Map
      ? teacherObj['teacherName']?.toString() ?? 'Teacher'
      : 'Teacher';

  final batchName = batchObj is Map
      ? batchObj['batchName']?.toString() ?? 'Class'
      : 'Class';

  final id = json['_id']?.toString();

  if (id == null || id.isEmpty) {
    throw const FormatException(
      'Timetable entry is missing its MongoDB ID',
    );
  }

  return TimetableSlot(
    id: id,
    dayOfWeek: _dayNameToInt(
      json['day']?.toString() ?? '',
    ),
    startTime: _parseTime(
      json['startTime']?.toString() ?? '',
    ),
    endTime: _parseTime(
      json['endTime']?.toString() ?? '',
    ),
    subjectName: subjectName,
    teacherName: teacherName,
    classId: batchName,
    roomNo: json['roomNo']?.toString() ?? '',
    status: AttendanceStatus.pending,
    studentStatus: AttendanceStatus.pending,
    studentAttendance: const {},
    subjectId: subjectId,
    teacherId: teacherId,
    batchId: batchId,
  );
}

/// Converts a JSON response into a timetable slot.
TimetableSlot _slotFromResponse(dynamic responseData) {
  if (responseData is! Map) {
    throw const FormatException('Invalid server response');
  }

  if (responseData['success'] != true ||
      responseData['timetable'] is! Map) {
    throw Exception(
      responseData['message']?.toString() ??
          'Timetable operation failed',
    );
  }

  return _slotFromJson(
    Map<String, dynamic>.from(responseData['timetable'] as Map),
  );
}

/// Converts a JSON list into timetable slots.
List<TimetableSlot> _slotsFromResponse(dynamic responseData) {
  if (responseData is! Map ||
      responseData['success'] != true) {
    throw Exception(
      responseData is Map
          ? responseData['message']?.toString() ??
              'Unable to fetch timetable'
          : 'Invalid server response',
    );
  }

  final raw = responseData['timetable'];

  if (raw is! List) {
    throw const FormatException(
      'Invalid timetable list from server',
    );
  }

  return raw.map((item) {
    if (item is! Map) {
      throw const FormatException(
        'Invalid timetable entry',
      );
    }

    return _slotFromJson(
      Map<String, dynamic>.from(item),
    );
  }).toList();
}

class TimetableRepository {
  final ApiClient _apiClient;

  TimetableRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Builds the request body for create and update.
  Map<String, dynamic> _slotToJson(TimetableSlot slot) {
    if (slot.batchId == null || slot.batchId!.isEmpty) {
      throw ArgumentError('Batch ID is required');
    }

    if (slot.subjectId == null || slot.subjectId!.isEmpty) {
      throw ArgumentError('Subject ID is required');
    }

    if (slot.teacherId == null || slot.teacherId!.isEmpty) {
      throw ArgumentError('Teacher ID is required');
    }

    if (slot.roomNo.trim().isEmpty) {
      throw ArgumentError('Room number is required');
    }

    return {
      'batch': slot.batchId,
      'subject': slot.subjectId,
      'teacher': slot.teacherId,
      'day': _dayIntToName(slot.dayOfWeek),
      'startTime': _formatTime(slot.startTime),
      'endTime': _formatTime(slot.endTime),
      'roomNo': slot.roomNo.trim(),
    };
  }

  /// GET: Fetch all timetable entries.
  Future<List<TimetableSlot>> getAllTimetable() async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.timetable,
    );

    return _slotsFromResponse(response.data);
  }

  /// GET: Fetch timetable for a batch.
  Future<List<TimetableSlot>> getBatchTimetable(
    String batchId,
  ) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.batchTimetable(batchId),
    );

    return _slotsFromResponse(response.data);
  }

  /// GET: Fetch timetable for a teacher.
  Future<List<TimetableSlot>> getTeacherTimetable(
    String teacherId,
  ) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.teacherTimetable(teacherId),
    );

    return _slotsFromResponse(response.data);
  }

  /// POST: Create a timetable entry.
  Future<TimetableSlot> createTimetable(
    TimetableSlot slot,
  ) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.timetable,
      data: _slotToJson(slot),
    );

    return _slotFromResponse(response.data);
  }

  /// PATCH: Update an existing timetable entry.
  Future<TimetableSlot> updateTimetable(
    TimetableSlot slot,
  ) async {
    if (slot.id.isEmpty) {
      throw ArgumentError('Timetable ID is required');
    }

    final response = await _apiClient.dio.patch(
      ApiEndpoints.updateTimetable(slot.id),
      data: _slotToJson(slot),
    );

    return _slotFromResponse(response.data);
  }

  /// DELETE: Delete a timetable entry.
  Future<void> deleteTimetable(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Timetable ID is required');
    }

    final response = await _apiClient.dio.delete(
      ApiEndpoints.deleteTimetable(id),
    );

    final data = response.data;

    if (data is! Map || data['success'] != true) {
      throw Exception(
        data is Map
            ? data['message']?.toString() ??
                'Unable to delete timetable'
            : 'Invalid server response',
      );
    }
  }
}

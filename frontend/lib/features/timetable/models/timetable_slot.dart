import 'package:flutter/material.dart';
import '../../home/widgets/status_badge.dart';

class TimetableSlot {
  final String id;
  final int dayOfWeek; // 1 = Mon, 2 = Tue, 3 = Wed, 4 = Thu, 5 = Fri, 6 = Sat, 7 = Sun
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String subjectName;
  final String teacherName;
  final String classId; // e.g. "S2 BCA"
  final AttendanceStatus status; // Teacher status: recorded, missed, recordNow, pending
  final AttendanceStatus studentStatus; // Student status for the logged-in student: present, absent, late, ongoing, pending
  final Map<String, AttendanceStatus> studentAttendance; // rollNumber -> status (for detailed marking)

  const TimetableSlot({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.teacherName,
    required this.classId,
    this.status = AttendanceStatus.pending,
    this.studentStatus = AttendanceStatus.pending,
    this.studentAttendance = const {},
  });

  TimetableSlot copyWith({
    String? id,
    int? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? subjectName,
    String? teacherName,
    String? classId,
    AttendanceStatus? status,
    AttendanceStatus? studentStatus,
    Map<String, AttendanceStatus>? studentAttendance,
  }) {
    return TimetableSlot(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
      classId: classId ?? this.classId,
      status: status ?? this.status,
      studentStatus: studentStatus ?? this.studentStatus,
      studentAttendance: studentAttendance ?? this.studentAttendance,
    );
  }
}

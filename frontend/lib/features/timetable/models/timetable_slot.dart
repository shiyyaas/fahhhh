
import 'package:flutter/material.dart';
import '../../home/widgets/status_badge.dart';

class TimetableSlot {
  final String id;

  // Timetable information
  final int dayOfWeek; // 1 = Mon, 2 = Tue, 3 = Wed, 4 = Thu, 5 = Fri, 6 = Sat
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String roomNo;

  // Subject, teacher and batch information
  final String subjectName;
  final String teacherName;
  final String classId; // e.g. "S2 BCA"

  // Attendance information
  final AttendanceStatus status;
  final AttendanceStatus studentStatus;
  final Map<String, AttendanceStatus> studentAttendance;

  // Backend MongoDB references
  final String? subjectId;
  final String? teacherId;
  final String? batchId;

  const TimetableSlot({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.teacherName,
    required this.classId,
    this.roomNo = '',
    this.status = AttendanceStatus.pending,
    this.studentStatus = AttendanceStatus.pending,
    this.studentAttendance = const {},
    this.subjectId,
    this.teacherId,
    this.batchId,
  });

  TimetableSlot copyWith({
    String? id,
    int? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? subjectName,
    String? teacherName,
    String? classId,
    String? roomNo,
    AttendanceStatus? status,
    AttendanceStatus? studentStatus,
    Map<String, AttendanceStatus>? studentAttendance,
    String? subjectId,
    String? teacherId,
    String? batchId,
  }) {
    return TimetableSlot(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
      classId: classId ?? this.classId,
      roomNo: roomNo ?? this.roomNo,
      status: status ?? this.status,
      studentStatus: studentStatus ?? this.studentStatus,
      studentAttendance:
          studentAttendance ?? this.studentAttendance,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      batchId: batchId ?? this.batchId,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../home/widgets/status_badge.dart';
import '../models/timetable_slot.dart';

part 'timetable_provider.g.dart';

// Reactive local selected date state provider
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void selectDate(DateTime date) {
    state = date;
  }
}

// Student mock model
class Student {
  final String rollNumber;
  final String name;

  const Student({required this.rollNumber, required this.name});
}

// Static mock students
const List<Student> s2BcaStudents = [
  Student(rollNumber: "21/BCA/01", name: "Abel Joseph"),
  Student(rollNumber: "21/BCA/02", name: "Adithya K"),
  Student(rollNumber: "21/BCA/03", name: "Ananthu Prasad"),
  Student(rollNumber: "21/BCA/04", name: "Shiyas ps"), // Logged-in student
  Student(rollNumber: "21/BCA/05", name: "Sidharth S"),
  Student(rollNumber: "21/BCA/06", name: "Sneha Sunil"),
  Student(rollNumber: "21/BCA/07", name: "Sreehari S"),
  Student(rollNumber: "21/BCA/08", name: "Vinayak S"),
];

const List<Student> s4BcaStudents = [
  Student(rollNumber: "23/BCA/01", name: "Albin Tom"),
  Student(rollNumber: "23/BCA/02", name: "Fathima R"),
  Student(rollNumber: "23/BCA/03", name: "Gokul Krishna"),
];

const List<Student> s6BcaStudents = [
  Student(rollNumber: "22/BCA/01", name: "Deepak Dev"),
  Student(rollNumber: "22/BCA/02", name: "Kiran Das"),
];

const List<Student> s8BcaStudents = [
  Student(rollNumber: "20/BCA/01", name: "Nidhin Chandran"),
  Student(rollNumber: "20/BCA/02", name: "Pranav M"),
];

List<Student> getStudentsForClass(String classId) {
  if (classId.contains("S2")) return s2BcaStudents;
  if (classId.contains("S4")) return s4BcaStudents;
  if (classId.contains("S6")) return s6BcaStudents;
  return s8BcaStudents;
}

@riverpod
class TimetableNotifier extends _$TimetableNotifier {
  @override
  List<TimetableSlot> build() {
    // Generate initial timetable schedule slots
    final List<TimetableSlot> initialSlots = [];

    // We populate Monday to Friday (1 to 5)
    for (int day = 1; day <= 5; day++) {
      // Period 1: 09:30 - 10:30
      initialSlots.add(TimetableSlot(
        id: "slot_${day}_1_s2",
        dayOfWeek: day,
        startTime: const TimeOfDay(hour: 9, minute: 30),
        endTime: const TimeOfDay(hour: 10, minute: 30),
        subjectName: day == 1 ? "Software Engineering" : (day == 2 ? "Computer Networks" : "Microprocessors"),
        teacherName: day == 1 ? "Ms Sheethal" : "Rijina",
        classId: "S2 BCA",
        status: AttendanceStatus.recordNow,
        studentStatus: AttendanceStatus.pending,
        studentAttendance: _initDefaultAttendance("S2 BCA"),
      ));

      initialSlots.add(TimetableSlot(
        id: "slot_${day}_1_s4",
        dayOfWeek: day,
        startTime: const TimeOfDay(hour: 9, minute: 30),
        endTime: const TimeOfDay(hour: 10, minute: 30),
        subjectName: "Database Systems",
        teacherName: "Anu",
        classId: "S4 BCA",
        status: AttendanceStatus.pending,
        studentStatus: AttendanceStatus.pending,
        studentAttendance: _initDefaultAttendance("S4 BCA"),
      ));

      // Period 2: 10:30 - 11:30
      initialSlots.add(TimetableSlot(
        id: "slot_${day}_2_s2",
        dayOfWeek: day,
        startTime: const TimeOfDay(hour: 10, minute: 30),
        endTime: const TimeOfDay(hour: 11, minute: 30),
        subjectName: day % 2 == 0 ? "Software Engineering" : "Mathematics",
        teacherName: day % 2 == 0 ? "Ms Sheethal" : "Anju",
        classId: "S2 BCA",
        status: AttendanceStatus.pending,
        studentStatus: AttendanceStatus.pending,
        studentAttendance: _initDefaultAttendance("S2 BCA"),
      ));

      initialSlots.add(TimetableSlot(
        id: "slot_${day}_2_s4",
        dayOfWeek: day,
        startTime: const TimeOfDay(hour: 10, minute: 30),
        endTime: const TimeOfDay(hour: 11, minute: 30),
        subjectName: "Operating Systems",
        teacherName: "Ms Sheethal",
        classId: "S4 BCA",
        status: AttendanceStatus.pending,
        studentStatus: AttendanceStatus.pending,
        studentAttendance: _initDefaultAttendance("S4 BCA"),
      ));

      // Period 3: 11:30 - 12:30
      initialSlots.add(TimetableSlot(
        id: "slot_${day}_3_s2",
        dayOfWeek: day,
        startTime: const TimeOfDay(hour: 11, minute: 30),
        endTime: const TimeOfDay(hour: 12, minute: 30),
        subjectName: "Python Programming",
        teacherName: "Rijina",
        classId: "S2 BCA",
        status: AttendanceStatus.pending,
        studentStatus: AttendanceStatus.pending,
        studentAttendance: _initDefaultAttendance("S2 BCA"),
      ));

      initialSlots.add(TimetableSlot(
        id: "slot_${day}_3_s6",
        dayOfWeek: day,
        startTime: const TimeOfDay(hour: 11, minute: 30),
        endTime: const TimeOfDay(hour: 12, minute: 30),
        subjectName: "Artificial Intelligence",
        teacherName: "Sheetal",
        classId: "S6 BCA",
        status: AttendanceStatus.pending,
        studentStatus: AttendanceStatus.pending,
        studentAttendance: _initDefaultAttendance("S6 BCA"),
      ));

      // Period 4: 13:30 - 14:30
      initialSlots.add(TimetableSlot(
        id: "slot_${day}_4_s2",
        dayOfWeek: day,
        startTime: const TimeOfDay(hour: 13, minute: 30),
        endTime: const TimeOfDay(hour: 14, minute: 30),
        subjectName: "Web Technologies",
        teacherName: "Anu",
        classId: "S2 BCA",
        status: AttendanceStatus.pending,
        studentStatus: AttendanceStatus.pending,
        studentAttendance: _initDefaultAttendance("S2 BCA"),
      ));

      initialSlots.add(TimetableSlot(
        id: "slot_${day}_4_s8",
        dayOfWeek: day,
        startTime: const TimeOfDay(hour: 13, minute: 30),
        endTime: const TimeOfDay(hour: 14, minute: 30),
        subjectName: "Cloud Computing",
        teacherName: "Anju",
        classId: "S8 BCA",
        status: AttendanceStatus.pending,
        studentStatus: AttendanceStatus.pending,
        studentAttendance: _initDefaultAttendance("S8 BCA"),
      ));

      // Period 5: 14:30 - 15:30
      initialSlots.add(TimetableSlot(
        id: "slot_${day}_5_s2",
        dayOfWeek: day,
        startTime: const TimeOfDay(hour: 14, minute: 30),
        endTime: const TimeOfDay(hour: 15, minute: 30),
        subjectName: "Environmental Studies",
        teacherName: "Anju",
        classId: "S2 BCA",
        status: AttendanceStatus.pending,
        studentStatus: AttendanceStatus.pending,
        studentAttendance: _initDefaultAttendance("S2 BCA"),
      ));

      initialSlots.add(TimetableSlot(
        id: "slot_${day}_5_s8",
        dayOfWeek: day,
        startTime: const TimeOfDay(hour: 14, minute: 30),
        endTime: const TimeOfDay(hour: 15, minute: 30),
        subjectName: "Cyber Security",
        teacherName: "Sheetal",
        classId: "S8 BCA",
        status: AttendanceStatus.pending,
        studentStatus: AttendanceStatus.pending,
        studentAttendance: _initDefaultAttendance("S8 BCA"),
      ));
    }

    return initialSlots;
  }

  Map<String, AttendanceStatus> _initDefaultAttendance(String classId) {
    final Map<String, AttendanceStatus> attendance = {};
    final students = getStudentsForClass(classId);
    for (var student in students) {
      attendance[student.rollNumber] = AttendanceStatus.pending;
    }
    return attendance;
  }

  void updateSlot(TimetableSlot updatedSlot) {
    state = [
      for (final slot in state)
        if (slot.id == updatedSlot.id) updatedSlot else slot
    ];
  }

  void saveAttendance(String slotId, Map<String, AttendanceStatus> attendance) {
    state = [
      for (final slot in state)
        if (slot.id == slotId)
          slot.copyWith(
            status: AttendanceStatus.recorded,
            studentStatus: attendance["21/BCA/04"] ?? slot.studentStatus,
            studentAttendance: attendance,
          )
        else
          slot
    ];
  }

  void resetAll() {
    ref.invalidateSelf();
  }
}

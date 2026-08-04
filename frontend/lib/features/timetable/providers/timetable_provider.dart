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

// Standard Available Subjects by Semester
const Map<String, List<String>> semesterSubjects = {
  "S2": ["DS", "OS", "Web Dev", "C", "English", "Malayalam"],
  "S4": ["Lab", "Maths", "Data Science", "AI", "Python", "Software Engineering"],
  "S6": ["Digital Marketing", "Disaster Management", "Neural Network", "Computer Networks", "Image Processing", "NLP"],
  "S8": ["Android", "Flutter", "Java", "Cybersecurity", "English", "Malayalam"],
};

// Teacher Assignments for Mock Data
const Map<String, String> subjectTeachers = {
  // S2
  "DS": "Anju miss",
  "OS": "Ms Sheethal",
  "Web Dev": "Anu miss",
  "C": "Rijina miss",
  "English": "Deepa miss",
  "Malayalam": "Manju miss",
  // S4
  "Lab": "Rijina miss",
  "Maths": "Anju miss",
  "Data Science": "Sheetal miss",
  "AI": "Anu miss",
  "Python": "Anju miss",
  "Software Engineering": "Ms Sheethal",
  // S6
  "Digital Marketing": "Anu miss",
  "Disaster Management": "Manju miss",
  "Neural Network": "Sheetal miss",
  "Computer Networks": "Rijina miss",
  "Image Processing": "Anju miss",
  "NLP": "Deepa miss",
  // S8
  "Android": "Rijina miss",
  "Flutter": "Anju miss",
  "Java": "Anu miss",
  "Cybersecurity": "Sheetal miss",
};

@riverpod
class TimetableNotifier extends _$TimetableNotifier {
  @override
  List<TimetableSlot> build() {
    final List<TimetableSlot> initialSlots = [];
    final List<String> classes = ["S2 BCA", "S4 BCA", "S6 BCA", "S8 BCA"];

    // Populate Mon to Fri (1 to 5) for all classes
    for (final classId in classes) {
      final semKey = classId.substring(0, 2); // "S2", "S4", etc.
      final subjects = semesterSubjects[semKey] ?? [];

      for (int day = 1; day <= 5; day++) {
        for (int period = 1; period <= 5; period++) {
          // Determinstic subject index selection to rotate the 6 subjects nicely across 25 periods
          final subjectIndex = (day * 2 + period) % subjects.length;
          final subject = subjects[subjectIndex];
          final teacher = subjectTeachers[subject] ?? "Anju miss";

          // Period schedule timings
          final startHours = [9, 10, 11, 13, 14];
          final startMinutes = [30, 30, 30, 30, 30];
          final endHours = [10, 11, 12, 14, 15];
          final endMinutes = [30, 30, 30, 30, 30];

          initialSlots.add(TimetableSlot(
            id: "slot_${classId.replaceAll(' ', '_')}_${day}_$period",
            dayOfWeek: day,
            startTime: TimeOfDay(hour: startHours[period - 1], minute: startMinutes[period - 1]),
            endTime: TimeOfDay(hour: endHours[period - 1], minute: endMinutes[period - 1]),
            subjectName: subject,
            teacherName: teacher,
            classId: classId,
            status: period == 1 && day == 1 ? AttendanceStatus.recordNow : AttendanceStatus.pending,
            studentStatus: AttendanceStatus.pending,
            studentAttendance: _initDefaultAttendance(classId),
          ));
        }
      }
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

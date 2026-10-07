/// Attendance status for a student's date-wise subject record.
enum StudentAttendanceStatus { present, absent, late }

/// Date-wise attendance entry for a student's subject detail view.
class StudentSubjectRecord {
  final String dateStr; // e.g. "Jan 10 | Monday"
  final StudentAttendanceStatus status;

  const StudentSubjectRecord({
    required this.dateStr,
    required this.status,
  });
}

// Fallback mock date-wise attendance records commented out - live backend data is used instead.
// const List<StudentSubjectRecord> mockStudentSubjectRecords = [ ... ];

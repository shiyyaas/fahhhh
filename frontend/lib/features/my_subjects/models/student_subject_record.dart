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

/// Mock date-wise attendance records for demo.
const List<StudentSubjectRecord> mockStudentSubjectRecords = [
  StudentSubjectRecord(
    dateStr: "Jan 15 | Thursday",
    status: StudentAttendanceStatus.present,
  ),
  StudentSubjectRecord(
    dateStr: "Jan 14 | Wednesday",
    status: StudentAttendanceStatus.absent,
  ),
  StudentSubjectRecord(
    dateStr: "Jan 13 | Tuesday",
    status: StudentAttendanceStatus.present,
  ),
  StudentSubjectRecord(
    dateStr: "Jan 12 | Monday",
    status: StudentAttendanceStatus.late,
  ),
  StudentSubjectRecord(
    dateStr: "Jan 09 | Friday",
    status: StudentAttendanceStatus.present,
  ),
  StudentSubjectRecord(
    dateStr: "Jan 08 | Thursday",
    status: StudentAttendanceStatus.absent,
  ),
  StudentSubjectRecord(
    dateStr: "Jan 07 | Wednesday",
    status: StudentAttendanceStatus.present,
  ),
  StudentSubjectRecord(
    dateStr: "Jan 06 | Tuesday",
    status: StudentAttendanceStatus.late,
  ),
  StudentSubjectRecord(
    dateStr: "Jan 05 | Monday",
    status: StudentAttendanceStatus.present,
  ),
];

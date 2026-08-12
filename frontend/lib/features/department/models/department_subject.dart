/// A subject row shown in the Department CLASS - subjects list.
class DepartmentSubject {
  final String name;
  final String teacher;
  final int attendancePercent;

  const DepartmentSubject({
    required this.name,
    required this.teacher,
    required this.attendancePercent,
  });
}
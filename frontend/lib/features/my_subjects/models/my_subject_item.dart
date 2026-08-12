/// A subject row shown in the teacher's My Subjects list.
class MySubjectItem {
  final String name;
  final String classes;
  final int attendancePercent;

  const MySubjectItem({
    required this.name,
    required this.classes,
    required this.attendancePercent,
  });
}
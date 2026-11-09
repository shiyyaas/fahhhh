/// A subject row shown in the teacher's My Subjects list.
class MySubjectItem {
  final String? id;
  final String name;
  final String classes;
  final int attendancePercent;

  const MySubjectItem({
    this.id,
    required this.name,
    required this.classes,
    required this.attendancePercent,
  });
}
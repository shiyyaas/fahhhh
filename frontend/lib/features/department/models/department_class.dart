/// A class entry shown in the Department - Classes list.
class DepartmentClass {
  final String name;
  final String classTeacher;
  final int attendancePercent;

  const DepartmentClass({
    required this.name,
    required this.classTeacher,
    required this.attendancePercent,
  });
}

/// Mock classes for the department overview.
/// Replaced by repository data once the backend is wired.
const List<DepartmentClass> mockDepartmentClasses = [
  DepartmentClass(name: "S2 BCA", classTeacher: "Sheetal miss", attendancePercent: 65),
  DepartmentClass(name: "S4 BCA", classTeacher: "Anu Varghese", attendancePercent: 95),
  DepartmentClass(name: "S6 BCA", classTeacher: "Rijina NM", attendancePercent: 95),
  DepartmentClass(name: "S8 BCA", classTeacher: "Anu Varghese", attendancePercent: 95),
];

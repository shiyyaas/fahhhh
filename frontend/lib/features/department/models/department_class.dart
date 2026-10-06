/// A class entry shown in the Department - Classes list.
class DepartmentClass {
  final String? id;
  final String name;
  final String classTeacher;
  final int attendancePercent;
  final int? currentSemester;
  final int? startYear;
  final int? endYear;

  const DepartmentClass({
    this.id,
    required this.name,
    required this.classTeacher,
    required this.attendancePercent,
    this.currentSemester,
    this.startYear,
    this.endYear,
  });

  factory DepartmentClass.fromJson(Map<String, dynamic> json) {
    return DepartmentClass(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['batchName'] as String? ?? json['name'] as String? ?? '',
      classTeacher: json['classTeacher'] as String? ?? 'Class Teacher',
      attendancePercent: (json['attendancePercent'] as num?)?.toInt() ?? 85,
      currentSemester: json['currentSemester'] as int?,
      startYear: json['startYear'] as int?,
      endYear: json['endYear'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchName': name,
      'classTeacher': classTeacher,
      'attendancePercent': attendancePercent,
      'currentSemester': currentSemester,
      'startYear': startYear,
      'endYear': endYear,
    };
  }
}

/// Fallback mock classes for the department overview when offline/unseeded.
const List<DepartmentClass> mockDepartmentClasses = [
  DepartmentClass(name: "S2 BCA", classTeacher: "Sheetal miss", attendancePercent: 65),
  DepartmentClass(name: "S4 BCA", classTeacher: "Anu Varghese", attendancePercent: 95),
  DepartmentClass(name: "S6 BCA", classTeacher: "Rijina NM", attendancePercent: 95),
  DepartmentClass(name: "S8 BCA", classTeacher: "Anu Varghese", attendancePercent: 95),
];

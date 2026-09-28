/// A student entry shown in the Department - Students list.
class DepartmentStudent {
  final String name;
  final String rollNumber;
  final String? imageUrl;

  const DepartmentStudent({
    required this.name,
    required this.rollNumber,
    this.imageUrl,
  });
}

/// Mock students for the department overview.
/// Replaced by repository data once the backend is wired.
const List<DepartmentStudent> mockDepartmentStudents = [
  DepartmentStudent(name: "Alice Johnson", rollNumber: "S2023001"),
  DepartmentStudent(name: "Bob Smith", rollNumber: "S2023002"),
  DepartmentStudent(name: "Carol Davis", rollNumber: "S2023003"),
  DepartmentStudent(name: "David Wilson", rollNumber: "S2023004"),
  DepartmentStudent(name: "Emma Brown", rollNumber: "S2023005"),
  DepartmentStudent(name: "Frank Miller", rollNumber: "S2023006"),
  DepartmentStudent(name: "Grace Lee", rollNumber: "S2023007"),
  DepartmentStudent(name: "Henry Taylor", rollNumber: "S2023008"),
  DepartmentStudent(name: "Isabella Clark", rollNumber: "S2023009"),
  DepartmentStudent(name: "Jack Anderson", rollNumber: "S2023010"),
];
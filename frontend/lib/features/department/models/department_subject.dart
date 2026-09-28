/// A subject entry shown in the Department - Subjects list.
class DepartmentSubject {
  final String name;
  final String teacher;
  final String rollNumber;
  final int attendancePercent;

  const DepartmentSubject({
    required this.name,
    required this.teacher,
    required this.rollNumber,
    required this.attendancePercent,
  });
}

/// Mock subjects for the department overview.
/// Replaced by repository data once the backend is wired.
const List<DepartmentSubject> mockDepartmentSubjects = [
  DepartmentSubject(name: "Software Engineering", teacher: "Sheetal miss", rollNumber: "S2023001", attendancePercent: 95),
  DepartmentSubject(name: "Data Science", teacher: "Anu Varghese", rollNumber: "S2023002", attendancePercent: 82),
  DepartmentSubject(name: "Computer Networks", teacher: "Rijina NM", rollNumber: "S2023003", attendancePercent: 90),
  DepartmentSubject(name: "AI", teacher: "Priya S", rollNumber: "S2023004", attendancePercent: 65),
  DepartmentSubject(name: "Digital Marketing", teacher: "Rahul Menon", rollNumber: "S2023005", attendancePercent: 88),
  DepartmentSubject(name: "Image Processing", teacher: "Lakshmi N", rollNumber: "S2023006", attendancePercent: 74),
  DepartmentSubject(name: "Cybersecurity", teacher: "Arun Das", rollNumber: "S2023007", attendancePercent: 95),
  DepartmentSubject(name: "Maths", teacher: "Deepa R", rollNumber: "S2023008", attendancePercent: 78),
  DepartmentSubject(name: "NLP", teacher: "Fathima Beevi", rollNumber: "S2023009", attendancePercent: 85),
  DepartmentSubject(name: "Flutter", teacher: "Vishnu P", rollNumber: "S2023010", attendancePercent: 70),
];
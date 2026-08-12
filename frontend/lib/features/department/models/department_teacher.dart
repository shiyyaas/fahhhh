/// A teacher entry shown in the Department - Teachers list.
class DepartmentTeacher {
  final String name;
  final String subject;
  final String? imageUrl;

  const DepartmentTeacher({
    required this.name,
    required this.subject,
    this.imageUrl,
  });
}

/// Mock teachers for the department overview.
/// Replaced by repository data once the backend is wired.
const List<DepartmentTeacher> mockDepartmentTeachers = [
  DepartmentTeacher(name: "Sheetal miss", subject: "Software Engineering"),
  DepartmentTeacher(name: "Anu Varghese", subject: "Data Science"),
  DepartmentTeacher(name: "Rijina NM", subject: "Computer Networks"),
  DepartmentTeacher(name: "Priya S", subject: "AI"),
  DepartmentTeacher(name: "Rahul Menon", subject: "Digital Marketing"),
  DepartmentTeacher(name: "Lakshmi N", subject: "Image Processing"),
  DepartmentTeacher(name: "Arun Das", subject: "Cybersecurity"),
  DepartmentTeacher(name: "Deepa R", subject: "Maths"),
  DepartmentTeacher(name: "Fathima Beevi", subject: "NLP"),
  DepartmentTeacher(name: "Vishnu P", subject: "Flutter"),
  DepartmentTeacher(name: "Saranya K", subject: "Android"),
];

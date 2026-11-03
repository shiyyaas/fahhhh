
/// A teacher entry shown in the Department - Teachers list.
class DepartmentTeacher {
  final String? id;
  final String name;
  final String subject;
  final List<String> subjects;
  final String? employeeId;
  final String? email;
  final String? phoneNo;
  final String? imageUrl;

  const DepartmentTeacher({
    this.id,
    required this.name,
    required this.subject,
    this.subjects = const [],
    this.employeeId,
    this.email,
    this.phoneNo,
    this.imageUrl,
  });

  factory DepartmentTeacher.fromJson(Map<String, dynamic> json) {
    // Read assigned subjects from the backend.
    final List<String> subjectsList = [];

    if (json['subjects'] is List) {
      for (final item in json['subjects']) {
        String subjectName = '';

        if (item is Map) {
          subjectName = item['subjectName']?.toString() ?? '';
        } else {
          subjectName = item.toString();
        }

        if (subjectName.isNotEmpty) {
          subjectsList.add(subjectName);
        }
      }
    }

    // Backward compatibility with the old subject field.
    final oldSubject = json['subject'];

    if (subjectsList.isEmpty &&
        oldSubject is String &&
        oldSubject.isNotEmpty) {
      subjectsList.add(oldSubject);
    }

    final String subjectText = subjectsList.isNotEmpty
        ? subjectsList.join(', ')
        : 'No subjects assigned';

    return DepartmentTeacher(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['teacherName']?.toString() ??
          json['name']?.toString() ??
          '',
      subject: subjectText,
      subjects: subjectsList,
      employeeId: json['employeeId']?.toString(),
      email: json['email']?.toString(),
      phoneNo: json['phoneNo']?.toString(),
      imageUrl: json['imageUrl']?.toString() ??
          json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherName': name,
      'subject': subject,
      'subjects': subjects,
      'employeeId': employeeId,
      'email': email,
      'phoneNo': phoneNo,
      'imageUrl': imageUrl,
    };
  }
}


// Fallback mock teachers commented out - backend data is used instead.
// const List<DepartmentTeacher> mockDepartmentTeachers = [
//   DepartmentTeacher(name: "Sheetal miss", subject: "Software Engineering"),
//   DepartmentTeacher(name: "Anu Varghese", subject: "Data Science"),
//   DepartmentTeacher(name: "Rijina NM", subject: "Computer Networks"),
//   DepartmentTeacher(name: "Priya S", subject: "AI"),
//   DepartmentTeacher(name: "Rahul Menon", subject: "Digital Marketing"),
//   DepartmentTeacher(name: "Lakshmi N", subject: "Image Processing"),
//   DepartmentTeacher(name: "Arun Das", subject: "Cybersecurity"),
//   DepartmentTeacher(name: "Deepa R", subject: "Maths"),
//   DepartmentTeacher(name: "Fathima Beevi", subject: "NLP"),
//   DepartmentTeacher(name: "Vishnu P", subject: "Flutter"),
//   DepartmentTeacher(name: "Saranya K", subject: "Android"),
// ];

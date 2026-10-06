/// A teacher entry shown in the Department - Teachers list.
class DepartmentTeacher {
  final String? id;
  final String name;
  final String subject;
  final String? employeeId;
  final String? email;
  final String? phoneNo;
  final String? imageUrl;

  const DepartmentTeacher({
    this.id,
    required this.name,
    required this.subject,
    this.employeeId,
    this.email,
    this.phoneNo,
    this.imageUrl,
  });

  factory DepartmentTeacher.fromJson(Map<String, dynamic> json) {
    // Subject might be derived or defaults
    String subjectName = 'Faculty';
    if (json['subject'] != null) {
      subjectName = json['subject'] as String;
    } else if (json['departments'] is List && (json['departments'] as List).isNotEmpty) {
      final dept = (json['departments'] as List).first;
      if (dept is Map && dept['departmentName'] != null) {
        subjectName = dept['departmentName'] as String;
      }
    }

    return DepartmentTeacher(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['teacherName'] as String? ?? json['name'] as String? ?? '',
      subject: subjectName,
      employeeId: json['employeeId'] as String?,
      email: json['email'] as String?,
      phoneNo: json['phoneNo'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherName': name,
      'subject': subject,
      'employeeId': employeeId,
      'email': email,
      'phoneNo': phoneNo,
      'imageUrl': imageUrl,
    };
  }
}

/// Fallback mock teachers for the department overview when offline/unseeded.
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

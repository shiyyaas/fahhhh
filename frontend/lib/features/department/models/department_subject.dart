/// A subject entry shown in the Department - Subjects list.
class DepartmentSubject {
  final String? id;
  final String name;
  final String teacher;
  final String rollNumber;
  final int attendancePercent;
  final String? subjectCode;
  final int? semester;
  final int? credits;

  const DepartmentSubject({
    this.id,
    required this.name,
    required this.teacher,
    required this.rollNumber,
    required this.attendancePercent,
    this.subjectCode,
    this.semester,
    this.credits,
  });

  factory DepartmentSubject.fromJson(Map<String, dynamic> json) {
    String teacherName = 'Faculty';
    if (json['teachers'] is List && (json['teachers'] as List).isNotEmpty) {
      final t = (json['teachers'] as List).first;
      if (t is Map && t['teacherName'] != null) {
        teacherName = t['teacherName'] as String;
      } else if (t is String) {
        teacherName = t;
      }
    } else if (json['teacher'] != null) {
      teacherName = json['teacher'] as String;
    }

    return DepartmentSubject(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['subjectName'] as String? ?? json['name'] as String? ?? '',
      teacher: teacherName,
      rollNumber: json['subjectCode'] as String? ?? json['rollNumber'] as String? ?? '',
      attendancePercent: (json['attendancePercent'] as num?)?.toInt() ?? 85,
      subjectCode: json['subjectCode'] as String?,
      semester: json['semester'] as int?,
      credits: json['credits'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectName': name,
      'subjectCode': rollNumber,
      'teacher': teacher,
      'attendancePercent': attendancePercent,
      'semester': semester,
      'credits': credits,
    };
  }
}

// Fallback mock subjects commented out - backend data is used instead.
// const List<DepartmentSubject> mockDepartmentSubjects = [
//   DepartmentSubject(name: "Software Engineering", teacher: "Sheetal miss", rollNumber: "S2023001", attendancePercent: 95),
//   DepartmentSubject(name: "Data Science", teacher: "Anu Varghese", rollNumber: "S2023002", attendancePercent: 82),
//   DepartmentSubject(name: "Computer Networks", teacher: "Rijina NM", rollNumber: "S2023003", attendancePercent: 90),
//   DepartmentSubject(name: "AI", teacher: "Priya S", rollNumber: "S2023004", attendancePercent: 65),
//   DepartmentSubject(name: "Digital Marketing", teacher: "Rahul Menon", rollNumber: "S2023005", attendancePercent: 88),
//   DepartmentSubject(name: "Image Processing", teacher: "Lakshmi N", rollNumber: "S2023006", attendancePercent: 74),
//   DepartmentSubject(name: "Cybersecurity", teacher: "Arun Das", rollNumber: "S2023007", attendancePercent: 95),
//   DepartmentSubject(name: "Maths", teacher: "Deepa R", rollNumber: "S2023008", attendancePercent: 78),
//   DepartmentSubject(name: "NLP", teacher: "Fathima Beevi", rollNumber: "S2023009", attendancePercent: 85),
//   DepartmentSubject(name: "Flutter", teacher: "Vishnu P", rollNumber: "S2023010", attendancePercent: 70),
// ];
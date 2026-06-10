import '../../auth/models/user_role.dart';

class TeacherModel {

  final String name;
  final String email;
  final String phone;
  final String department;
  final String designation;
  final String ? imageUrl;

  final UserRole role;

  final bool isHod;
  final bool isClassTeacher;
  final String? classTeacherOf;

  TeacherModel({

    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.designation,
    required this.imageUrl,

    required this.role,

    required this.isHod,
    required this.isClassTeacher,
    this.classTeacherOf,
    
  });

}
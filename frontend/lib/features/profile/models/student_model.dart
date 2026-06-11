import '../../auth/models/user_role.dart';

class StudentModel {

  final String name;
  final String email;
  final String phone;

  final String department;
  final String className;

  final String? imageUrl;

  final UserRole role;

  StudentModel({

    required this.name,
    required this.email,
    required this.phone,

    required this.department,
    required this.className,

    this.imageUrl,

    required this.role,

  });

}
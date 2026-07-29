import 'user_role.dart';

class CurrentUser {
  final String email;
  final String name;
  final UserRole role;

  // Overlapping Boolean Flags for Teachers:
  final bool isClassTeacher;
  final String? assignedClassId;
  final bool isHOD;
  final String? departmentId;

  const CurrentUser({
    required this.email,
    required this.name,
    required this.role,
    this.isClassTeacher = false,
    this.assignedClassId,
    this.isHOD = false,
    this.departmentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'isClassTeacher': isClassTeacher,
      'assignedClassId': assignedClassId,
      'isHOD': isHOD,
      'departmentId': departmentId,
    };
  }

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.byName(json['role'] as String),
      isClassTeacher: json['isClassTeacher'] as bool? ?? false,
      assignedClassId: json['assignedClassId'] as String?,
      isHOD: json['isHOD'] as bool? ?? false,
      departmentId: json['departmentId'] as String?,
    );
  }
}

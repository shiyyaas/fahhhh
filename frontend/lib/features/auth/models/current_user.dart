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

  // Additional fields for Unified Model:
  final String phone;
  final String? imageUrl;
  final String? rollNumber;
  final String? semester;
  final String? className;
  final String? designation;
  final List<String>? activeSubjects;

  const CurrentUser({
    required this.email,
    required this.name,
    required this.role,
    this.isClassTeacher = false,
    this.assignedClassId,
    this.isHOD = false,
    this.departmentId,
    this.phone = "",
    this.imageUrl,
    this.rollNumber,
    this.semester,
    this.className,
    this.designation,
    this.activeSubjects,
  });

  CurrentUser copyWith({
    String? email,
    String? name,
    UserRole? role,
    bool? isClassTeacher,
    String? assignedClassId,
    bool? isHOD,
    String? departmentId,
    String? phone,
    String? imageUrl,
    String? rollNumber,
    String? semester,
    String? className,
    String? designation,
    List<String>? activeSubjects,
  }) {
    return CurrentUser(
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isClassTeacher: isClassTeacher ?? this.isClassTeacher,
      assignedClassId: assignedClassId ?? this.assignedClassId,
      isHOD: isHOD ?? this.isHOD,
      departmentId: departmentId ?? this.departmentId,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      rollNumber: rollNumber ?? this.rollNumber,
      semester: semester ?? this.semester,
      className: className ?? this.className,
      designation: designation ?? this.designation,
      activeSubjects: activeSubjects ?? this.activeSubjects,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'isClassTeacher': isClassTeacher,
      'assignedClassId': assignedClassId,
      'isHOD': isHOD,
      'departmentId': departmentId,
      'phone': phone,
      'imageUrl': imageUrl,
      'rollNumber': rollNumber,
      'semester': semester,
      'className': className,
      'designation': designation,
      'activeSubjects': activeSubjects,
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
      phone: json['phone'] as String? ?? "",
      imageUrl: json['imageUrl'] as String?,
      rollNumber: json['rollNumber'] as String?,
      semester: json['semester'] as String?,
      className: json['className'] as String?,
      designation: json['designation'] as String?,
      activeSubjects: (json['activeSubjects'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }
}

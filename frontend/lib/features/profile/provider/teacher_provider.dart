import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/teacher_model.dart';
import '../../auth/models/user_role.dart';

final teacherProvider = Provider<TeacherModel>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (user != null && user.role == UserRole.teacher) {
    return TeacherModel(
      name: user.name,
      email: user.email,
      phone: "8796543231",
      department: user.departmentId ?? "Department of Computer Science",
      designation: user.isHOD ? "Head Of Department" : "Assistant Professor",
      imageUrl: 'assets/images/profile.png',
      role: UserRole.teacher,
      isHod: user.isHOD,
      isClassTeacher: user.isClassTeacher,
      classTeacherOf: user.assignedClassId,
    );
  }

  // Graceful fallback dummy profile
  return TeacherModel(
    name: "Ms Sheethal",
    email: "sheetal@mescas.org",
    phone: "8796543231",
    department: "Department of Computer Science",
    designation: "Assistant Professor",
    imageUrl: 'assets/images/profile.png',
    role: UserRole.teacher,
    isHod: true,
    isClassTeacher: true,
    classTeacherOf: "S2 BCA",
  );
});

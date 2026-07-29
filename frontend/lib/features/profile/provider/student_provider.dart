import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/student_model.dart';
import '../../auth/models/user_role.dart';

final studentProvider = Provider<StudentModel>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (user != null && user.role == UserRole.student) {
    return StudentModel(
      name: user.name,
      email: user.email,
      phone: "6235223761",
      department: "Department of Computer Science",
      className: "S2 BCA",
      imageUrl: "assets/images/student.png",
      role: UserRole.student,
    );
  }

  // Graceful fallback dummy profile
  return StudentModel(
    name: "Shiyas ps",
    email: "shiyas@mescas.org",
    phone: "6235223761",
    department: "Department of Computer Science",
    className: "S2 BCA",
    imageUrl: "assets/images/student.png",
    role: UserRole.student,
  );
});

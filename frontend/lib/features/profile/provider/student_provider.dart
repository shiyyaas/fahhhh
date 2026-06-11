import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student_model.dart';
import '../../auth/models/user_role.dart';

final studentProvider =
    Provider<StudentModel>((ref) {

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
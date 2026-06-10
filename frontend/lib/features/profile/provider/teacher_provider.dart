import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/teacher_model.dart';
import '../../auth/models/user_role.dart';

final teacherProvider =
    Provider<TeacherModel>((ref) {

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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student_model.dart';

final studentProvider =
    Provider<StudentModel>((ref) {

  return StudentModel(
    name: "Ms Sheethal",
    email: "sheetal@mescas.org",
    phone: "8796543231",
    department: "Department of Computer Science",
    className: "S2 BCA",
  );

});
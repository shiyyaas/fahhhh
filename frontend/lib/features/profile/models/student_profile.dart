
/// Student profile details shown when a student card is tapped.
class StudentProfile {
  final String name;
  final String rollNumber;
  final String className;
  final String email;
  final String phone;
  final String parentContact;
  final String? semester;
  final String? imageUrl;

  const StudentProfile({
    required this.name,
    required this.rollNumber,
    required this.className,
    required this.email,
    required this.phone,
    required this.parentContact,
    this.semester,
    this.imageUrl,
  });
}

/// Build a profile for a mock student.
StudentProfile buildStudentProfile({
  required String name,
  required String rollNumber,
  required String className,
  String? semester,
  String? imageUrl,
}) {
  final emailBase = name
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');

  final code =
      rollNumber.codeUnits.fold<int>(7, (acc, c) => acc + c) % 9000 + 1000;

  return StudentProfile(
    name: name,
    rollNumber: rollNumber,
    className: className,
    email: '$emailBase@mescas.org',
    phone: '62$code',
    parentContact: '75$code',
    semester: semester,
    imageUrl: imageUrl,
  );
}

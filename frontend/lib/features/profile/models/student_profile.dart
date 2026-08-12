/// Student profile details shown when a student card is tapped.
class StudentProfile {
  final String name;
  final String rollNumber;
  final String className;
  final String email;
  final String phone;
  final String parentContact;

  const StudentProfile({
    required this.name,
    required this.rollNumber,
    required this.className,
    required this.email,
    required this.phone,
    required this.parentContact,
  });
}

/// Build a profile for a mock student. Contact details are deterministic
/// (mock until backend) — email derived from name, phone/parent from roll.
StudentProfile buildStudentProfile({
  required String name,
  required String rollNumber,
  required String className,
}) {
  final emailBase = name
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');

  // Deterministic phone-ish numbers from the roll number digits.
  final code = rollNumber.codeUnits.fold<int>(7, (acc, c) => acc + c) % 9000 + 1000;

  return StudentProfile(
    name: name,
    rollNumber: rollNumber,
    className: className,
    email: '$emailBase@mescas.org',
    phone: '62$code',
    parentContact: '75$code',
  );
}

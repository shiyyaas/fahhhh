import 'package:flutter_test/flutter_test.dart';
import 'package:fahhhh/features/auth/repositories/mock_auth_repository.dart';
import 'package:fahhhh/features/auth/models/user_role.dart';

void main() {
  group('MockAuthRepository Tests', () {
    final repository = MockAuthRepository();

    test('Student Profile validation and mapping', () async {
      final user = await repository.login('student@mescas.org', 'password123');
      expect(user.role, UserRole.student);
      expect(user.email, 'student@mescas.org');
      expect(user.name, 'shiyas ps');
      expect(user.isHOD, false);
      expect(user.isClassTeacher, false);
      expect(user.className, 'S2 BCA');
    });

    test('Pure Teacher Profile validation and mapping', () async {
      final user = await repository.login('sheetal@mescas.org', 'password123');
      expect(user.role, UserRole.teacher);
      expect(user.email, 'sheetal@mescas.org');
      expect(user.name, 'sheetal');
      expect(user.isHOD, false);
      expect(user.isClassTeacher, false);
      expect(user.assignedClassId, 'No CLASS');
    });

    test('Class Teacher Profile validation and mapping', () async {
      final user = await repository.login('classteacher@mescas.org', 'password123');
      expect(user.role, UserRole.teacher);
      expect(user.email, 'classteacher@mescas.org');
      expect(user.name, 'Rijina');
      expect(user.isClassTeacher, true);
      expect(user.isHOD, false);
      expect(user.assignedClassId, 'S2 BCA');
    });

    test('HOD Profile validation and mapping', () async {
      final user = await repository.login('hod@mescas.org', 'password123');
      expect(user.role, UserRole.teacher);
      expect(user.email, 'hod@mescas.org');
      expect(user.isClassTeacher, false);
      expect(user.isHOD, true);
      expect(user.departmentId, 'Computer science');
    });

    test('Validation failure on empty email', () {
      expect(
        () => repository.login('', 'password123'),
        throwsA(isA<Exception>()),
      );
    });

    test('Validation failure on invalid email format', () {
      expect(
        () => repository.login('invalid_email', 'password123'),
        throwsA(isA<Exception>()),
      );
    });

    test('Validation failure on too short password', () {
      expect(
        () => repository.login('student@mescas.org', '123'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

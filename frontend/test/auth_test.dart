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
      expect(user.name, 'Shiyas ps');
      expect(user.isHOD, false);
      expect(user.isClassTeacher, false);
    });

    test('Pure Teacher Profile validation and mapping', () async {
      final user = await repository.login('teacher@mescas.org', 'password123');
      expect(user.role, UserRole.teacher);
      expect(user.email, 'teacher@mescas.org');
      expect(user.name, 'Pure Teacher');
      expect(user.isHOD, false);
      expect(user.isClassTeacher, false);
    });

    test('Class Teacher Profile validation and mapping', () async {
      final user = await repository.login('classteacher@mescas.org', 'password123');
      expect(user.role, UserRole.teacher);
      expect(user.email, 'classteacher@mescas.org');
      expect(user.isClassTeacher, true);
      expect(user.isHOD, false);
      expect(user.assignedClassId, 'S2 BCA');
    });

    test('HOD + Class Teacher Profile validation and mapping', () async {
      final user = await repository.login('sheetal@mescas.org', 'password123');
      expect(user.role, UserRole.teacher);
      expect(user.email, 'sheetal@mescas.org');
      expect(user.isClassTeacher, true);
      expect(user.isHOD, true);
      expect(user.assignedClassId, 'S2 BCA');
      expect(user.departmentId, 'Department of Computer Science');
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

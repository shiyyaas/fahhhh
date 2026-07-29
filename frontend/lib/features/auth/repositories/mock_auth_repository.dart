import 'dart:async';
import '../models/current_user.dart';
import '../models/user_role.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<CurrentUser> login(String email, String password) async {
    // Simulate short network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty) {
      throw Exception("Email cannot be empty");
    }
    if (!trimmedEmail.contains('@')) {
      throw Exception("Invalid email address format");
    }
    if (trimmedPassword.isEmpty) {
      throw Exception("Password cannot be empty");
    }
    if (trimmedPassword.length < 4) {
      throw Exception("Password must be at least 4 characters");
    }

    // 1. Student Profile (base role: student, flags false)
    if (trimmedEmail == "student@mescas.org" || trimmedEmail == "shiyas@mescas.org") {
      return const CurrentUser(
        email: "student@mescas.org",
        name: "Shiyas ps",
        role: UserRole.student,
      );
    }

    // 2. Pure Teacher Profile (base role: teacher, flags false)
    if (trimmedEmail == "teacher@mescas.org") {
      return const CurrentUser(
        email: "teacher@mescas.org",
        name: "Pure Teacher",
        role: UserRole.teacher,
      );
    }

    // 3. Class Teacher Profile (base role: teacher, isClassTeacher: true, isHOD: false)
    if (trimmedEmail == "classteacher@mescas.org") {
      return const CurrentUser(
        email: "classteacher@mescas.org",
        name: "Class Teacher",
        role: UserRole.teacher,
        isClassTeacher: true,
        assignedClassId: "S2 BCA",
        isHOD: false,
      );
    }

    // 4. HOD + Class Teacher Profile (base role: teacher, isClassTeacher: true, isHOD: true)
    if (trimmedEmail == "sheetal@mescas.org" || trimmedEmail == "hodteacher@mescas.org") {
      return const CurrentUser(
        email: "sheetal@mescas.org",
        name: "Ms Sheethal",
        role: UserRole.teacher,
        isClassTeacher: true,
        assignedClassId: "S2 BCA",
        isHOD: true,
        departmentId: "Department of Computer Science",
      );
    }

    // Default dynamic profile mapping if they typed other email/password combinations
    final lower = trimmedEmail.toLowerCase();
    if (lower.contains("hod")) {
      return CurrentUser(
        email: trimmedEmail,
        name: "Dynamic HOD Teacher",
        role: UserRole.teacher,
        isClassTeacher: true,
        assignedClassId: "S2 BCA",
        isHOD: true,
        departmentId: "Department of Computer Science",
      );
    } else if (lower.contains("class")) {
      return CurrentUser(
        email: trimmedEmail,
        name: "Dynamic Class Teacher",
        role: UserRole.teacher,
        isClassTeacher: true,
        assignedClassId: "S2 BCA",
        isHOD: false,
      );
    } else if (lower.contains("teacher")) {
      return CurrentUser(
        email: trimmedEmail,
        name: "Dynamic Pure Teacher",
        role: UserRole.teacher,
        isClassTeacher: false,
        isHOD: false,
      );
    } else {
      return CurrentUser(
        email: trimmedEmail,
        name: "Dynamic Student",
        role: UserRole.student,
      );
    }
  }
}

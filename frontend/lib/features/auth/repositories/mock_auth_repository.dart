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
        phone: "6235223761",
        imageUrl: "assets/images/student.png",
        rollNumber: "21/BCA/04",
        semester: "2",
        className: "S2 BCA",
        departmentId: "Department of Computer Science",
      );
    }

    // 2. Pure Teacher Profile (base role: teacher, flags false)
    if (trimmedEmail == "teacher@mescas.org") {
      return const CurrentUser(
        email: "teacher@mescas.org",
        name: "Pure Teacher",
        role: UserRole.teacher,
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Assistant Professor",
        departmentId: "Department of Computer Science",
        activeSubjects: ["Computer Networks", "Software Engineering"],
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
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Assistant Professor",
        departmentId: "Department of Computer Science",
        activeSubjects: ["Computer Networks", "Software Engineering"],
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
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Head Of Department",
        activeSubjects: ["Computer Networks", "Software Engineering"],
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
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Head Of Department",
        activeSubjects: ["Computer Networks", "Software Engineering"],
      );
    } else if (lower.contains("class")) {
      return CurrentUser(
        email: trimmedEmail,
        name: "Dynamic Class Teacher",
        role: UserRole.teacher,
        isClassTeacher: true,
        assignedClassId: "S2 BCA",
        isHOD: false,
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Assistant Professor",
        departmentId: "Department of Computer Science",
        activeSubjects: ["Computer Networks", "Software Engineering"],
      );
    } else if (lower.contains("teacher")) {
      return CurrentUser(
        email: trimmedEmail,
        name: "Dynamic Pure Teacher",
        role: UserRole.teacher,
        isClassTeacher: false,
        isHOD: false,
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Assistant Professor",
        departmentId: "Department of Computer Science",
        activeSubjects: ["Computer Networks", "Software Engineering"],
      );
    } else {
      return CurrentUser(
        email: trimmedEmail,
        name: "Dynamic Student",
        role: UserRole.student,
        phone: "6235223761",
        imageUrl: "assets/images/student.png",
        rollNumber: "21/BCA/04",
        semester: "2",
        className: "S2 BCA",
        departmentId: "Department of Computer Science",
      );
    }
  }
}

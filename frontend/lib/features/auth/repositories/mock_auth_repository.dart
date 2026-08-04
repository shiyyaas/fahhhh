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
        name: "shiyas ps",
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
    if (trimmedEmail == "teacher@mescas.org" || trimmedEmail == "sheetal@mescas.org") {
      return const CurrentUser(
        email: "sheetal@mescas.org",
        name: "sheetal",
        role: UserRole.teacher,
        isClassTeacher: false,
        assignedClassId: "No CLASS",
        className: "No CLASS",
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Assistant Professor",
        departmentId: "Department of Computer Science",
        activeSubjects: ["Computer Networks", "Software Engineering"],
      );
    }

    // 3. Class Teacher Profile (base role: teacher, isClassTeacher: true, isHOD: false)
    if (trimmedEmail == "classteacher@mescas.org" || trimmedEmail == "rijina@mescas.org") {
      return const CurrentUser(
        email: "classteacher@mescas.org",
        name: "Rijina",
        role: UserRole.teacher,
        isClassTeacher: true,
        assignedClassId: "S2 BCA",
        className: "S2 BCA",
        isHOD: false,
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Assistant Professor",
        departmentId: "Department of Computer Science",
        activeSubjects: ["Computer Networks", "Software Engineering"],
      );
    }

    // 4. HOD Profile (base role: teacher, isClassTeacher: false, isHOD: true)
    if (trimmedEmail == "hodteacher@mescas.org" || trimmedEmail == "hod@mescas.org" || trimmedEmail == "anu@mescas.org") {
      return const CurrentUser(
        email: "hod@mescas.org",
        name: "Anu varghese",
        role: UserRole.teacher,
        isClassTeacher: false,
        isHOD: true,
        departmentId: "Computer science",
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Head Of Department",
        activeSubjects: ["Computer Networks", "Software Engineering"],
      );
    }

    // Default dynamic profile mapping if they typed other email/password combinations
    final lower = trimmedEmail.toLowerCase();
    if (lower.contains("hod") || lower.contains("anu")) {
      return CurrentUser(
        email: trimmedEmail,
        name: "Anu varghese",
        role: UserRole.teacher,
        isClassTeacher: false,
        isHOD: true,
        departmentId: "Computer science",
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Head Of Department",
        activeSubjects: ["Computer Networks", "Software Engineering"],
      );
    } else if (lower.contains("class") || lower.contains("rijina")) {
      return CurrentUser(
        email: trimmedEmail,
        name: "Rijina",
        role: UserRole.teacher,
        isClassTeacher: true,
        assignedClassId: "S2 BCA",
        className: "S2 BCA",
        isHOD: false,
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Assistant Professor",
        departmentId: "Department of Computer Science",
        activeSubjects: ["Computer Networks", "Software Engineering"],
      );
    } else if (lower.contains("teacher") || lower.contains("sheetal")) {
      return CurrentUser(
        email: trimmedEmail,
        name: "sheetal",
        role: UserRole.teacher,
        isClassTeacher: false,
        assignedClassId: "No CLASS",
        className: "No CLASS",
        phone: "8796543231",
        imageUrl: "assets/images/profile.png",
        designation: "Assistant Professor",
        departmentId: "Department of Computer Science",
        activeSubjects: ["Computer Networks", "Software Engineering"],
      );
    } else {
      return CurrentUser(
        email: trimmedEmail,
        name: "shiyas ps",
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

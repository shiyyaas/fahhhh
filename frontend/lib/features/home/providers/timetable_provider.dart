import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/status_badge.dart';

final timetableProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'subjectName': 'Software Engineering',
      'secondaryText': 'S2BCA',
      'status': AttendanceStatus.recorded,
      'startTime': const TimeOfDay(
        hour: 9,
        minute: 30,
      ),
      'endTime': const TimeOfDay(
        hour: 10,
        minute: 15,
      ),
      'profileImage': 'assets/images/profile.png',
    },
  ];
});

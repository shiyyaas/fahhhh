//widgets
import 'package:fahhhh/widgets/home/date_btn.dart';
import 'package:fahhhh/widgets/home/header_section.dart';
import 'package:fahhhh/widgets/home/week_calendar.dart';
import 'package:fahhhh/widgets/home/timetable_card.dart';
import 'package:fahhhh/widgets/home/status_badge.dart'; //For timetable_card.dart

import 'package:flutter/material.dart';

class Home extends StatefulWidget {

  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> timetable = [
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 5),

            const HeaderSection(),

            WeekCalendar(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),

            const SizedBox(height: 25),

            DateBtn(selectedDate: selectedDate),

            Expanded(
              child: ListView.builder(
                itemCount: timetable.length,
                itemBuilder: (context, index) {
                final item = timetable[index];
                return TimetableCard(
                  // profileImage: item['profileImage'],
                  subjectName: item['subjectName'],
                  secondaryText: item['secondaryText'],
                  status: item['status'],
                  startTime: item['startTime'],
                  endTime: item['endTime'],
                );
                },
                ),
              ),
          ],
        ),
      ),
    );

  }

}
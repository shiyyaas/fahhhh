//widgets
import 'package:fahhhh/features/home/widgets/date_btn.dart';
import 'package:fahhhh/features/home/widgets/header_section.dart';
import 'package:fahhhh/features/home/widgets/week_calendar.dart';
import 'package:fahhhh/features/home/widgets/timetable_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../providers/timetable_provider.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final timetable = ref.watch(timetableProvider);

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
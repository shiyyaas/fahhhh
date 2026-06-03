import 'package:fahhhh/widgets/home/header_section.dart';
import 'package:fahhhh/widgets/home/week_calendar.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {

  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 5),
            
            const HeaderSection(),

            const SizedBox(height: 3),

            WeekCalendar(
              selectedDate: selectedDate,
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),

          ],
        ),
      ),
    );

  }

}
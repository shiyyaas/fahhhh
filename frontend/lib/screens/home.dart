import 'package:fahhhh/widgets/header_section.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Column(

          children: [

            const HeaderSection(),

          ],

        ),

      ),

    );

  }

}
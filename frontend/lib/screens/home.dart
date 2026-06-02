import 'package:fahhhh/widgets/header_section.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {

  const Home({super.key});

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
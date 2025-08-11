import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/app/config/routes/app_routes.dart';
import 'package:with_calendar/app/feature/select_mode/view/button_area.dart';
import 'package:with_calendar/app/feature/select_mode/view/show_invite_bottom_sheet.dart';

class SelectModeScreen extends StatelessWidget {
  const SelectModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 이미지
            Image.asset(
              'assets/images/img_calendar.png',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 24),

            // With Calendar 텍스트



            const Expanded(child: ButtonArea())
          ],
        ),
      ),
    );
  }
}

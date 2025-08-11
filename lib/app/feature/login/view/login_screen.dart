import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/app/config/routes/app_routes.dart';

import '../../../config/constant/ui/gradient_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 52),

            // 가족 이미지
            Center(
              child: Image.asset(
                'assets/images/img_family.png',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 30),

            // 타이틀
            const GradientText(
              "With Calendar",
              style: TextStyle(
                fontSize: 58,
                fontWeight: FontWeight.bold,
              ),
              gradient: LinearGradient(
                colors: [
                  Color(0xFFDE496E), // 시작 색상
                  Color(0xFFFF6E91), // 끝 색상
                ],
              ),
            ),

            const SizedBox(height: 1),

            // 서브 텍스트
            const Text(
              "Your family's moments, beautifully organized",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // 카카오 로그인 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () {
                  context.go(Routes.terms);
                  // TODO: 카카오 로그인 동작 추가
                },
                child: Image.asset(
                  'assets/images/ic_kakao_btn2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const Spacer(),

            // 하단 텍스트
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                "By continuing, you agree to our terms of service and privacy policy",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/app/config/routes/app_routes.dart';
import 'package:with_calendar/app/feature/calendar/view/calendar_screen.dart';
import 'package:with_calendar/app/feature/familiy/view/family_screen.dart';
import 'package:with_calendar/app/feature/home/view/home_screen.dart';
import 'package:with_calendar/app/feature/settings/view/settings_screen.dart';
import 'package:with_calendar/app/feature/terms/view/terms_check_tile.dart';

import '../../bottom_navigation_bar/view/bottom_navigation_screen.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool chkTerms = false;
  bool chkPrivacy = false;
  bool chkMarketing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          // 전체를 수직 가운데로
          child: SingleChildScrollView(
            // 혹시 작은 화면에서 스크롤 필요할 경우
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 위젯 크기에 맞춤
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  const Text(
                    "약관 동의",
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6E91),
                      fontFamily: 'Signika',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 필수 약관
                  TermsCheckTile(
                    value: chkTerms,
                    required: true,
                    text: "서비스 이용약관 동의",
                    onChanged: (val) {
                      setState(() => chkTerms = val ?? false);
                    },
                  ),

                  TermsCheckTile(
                    value: chkPrivacy,
                    required: true,
                    text: "개인정보 처리방침 동의",
                    onChanged: (val) {
                      setState(() => chkPrivacy = val ?? false);
                    },
                  ),

                  TermsCheckTile(
                    value: chkMarketing,
                    text: "마케팅 정보 수신 동의",
                    onChanged: (val) {
                      setState(() => chkMarketing = val ?? false);
                    },
                  ),

                  const SizedBox(height: 32),

                  // 계속하기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: (chkTerms && chkPrivacy)
                          ? () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BottomNavBar(
                                    pages: const [
                                      HomeScreen(),
                                      FamilyScreen(),
                                      CalendarScreen(),
                                      SettingsScreen()
                                    ])));
                      }
                          : null,
                      child: Container(
                        height: 52, // 고정 높이
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: (chkTerms && chkPrivacy)
                              ? const LinearGradient(
                            colors: [
                              Color(0xFFDE496E),
                              Color(0xFFFF6E91)
                            ],
                          )
                              : null,
                          color: (chkTerms && chkPrivacy)
                              ? null
                              : Colors.grey.shade400,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "계속하기",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

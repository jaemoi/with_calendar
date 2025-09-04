// routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/app/feature/calendar/view/calendar_screen.dart';
import 'package:with_calendar/app/feature/schedule_detail/view/schedule_detail_screen.dart';
import 'package:with_calendar/app/feature/settings/view/settings_screen.dart';

import '../../feature/bottom_navigation_bar/view/bottom_navigation_screen.dart';
import '../../feature/chat/view/chat_screen.dart';
import '../../feature/familiy/view/family_screen.dart';
import '../../feature/home/view/home_screen.dart';
import '../../feature/login/view/login_screen.dart';
import '../../feature/schedule_upsert/view/schedule_upsert_screen.dart';
import '../../feature/select_mode/view/select_mode_screen.dart';
import '../../feature/terms/view/terms_screen.dart';

class Routes {
  // ✅ 전역 루트 네비게이터 키 (쉘 위로 띄울 때 사용)
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static const login = '/login';
  static const terms = '/terms';
  static const selectMode = '/select-mode';
  static const createSchedule = '/schedule/new';
  static const scheduleDetail = '/schedule/:id';
  static const editSchedule = '/schedule/:id/edit';

  // 탭 루트 경로(쉘 내부)
  static const home = '/home';
  static const family = '/family';
  static const calendar = '/calendar';
  static const settings = '/settings';

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: login,
    routes: [
      // 인증/온보딩은 쉘 밖
      GoRoute(path: login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: terms, builder: (_, __) => const TermsScreen()),
      GoRoute(path: selectMode, builder: (_, __) => const SelectModeScreen()),
      GoRoute(
          path: createSchedule,
          builder: (context, state) {
            final extra = state.extra;
            DateTime? initialDate;
            if (extra is DateTime) {
              initialDate = DateTime(extra.year, extra.month, extra.day);
            }
            return ScheduleUpsertScreen(initialDate: initialDate);
          }),
      GoRoute(
          path: editSchedule,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const Scaffold(body: Center(child: Text('잘못된 일정 ID')));
            }
            return ScheduleUpsertScreen(scheduleId: id);
          }),
      GoRoute(
        path: scheduleDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) {
            return const Scaffold(body: Center(child: Text('잘못된 일정 ID')));
          }
          return FutureBuilder<Schedule?>(
            future: ScheduleRepository.instance.getById(id),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              final s = snap.data;
              if (s == null) {
                return const Scaffold(
                    body: Center(child: Text('일정을 찾을 수 없어요.')));
              }
              return ScheduleDetailScreen(schedule: s);
            },
          );
        },
      ),

      // 바텀 네비가 항상 보이는 메인 쉘
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: home, builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: family,
                builder: (_, __) => const FamilyScreen(),
                routes: [
                  GoRoute(
                      path: 'chat',
                      name: 'familyChat',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (_, __) => const ChatScreen())
                ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: calendar, builder: (_, __) => const CalendarScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: settings, builder: (_, __) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
  );
}

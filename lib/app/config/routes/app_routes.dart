// routes.dart
import 'package:go_router/go_router.dart';
import 'package:with_calendar/app/feature/calendar/view/calendar_screen.dart';
import 'package:with_calendar/app/feature/settings/view/settings_screen.dart';
import '../../feature/bottom_navigation_bar/view/bottom_navigation_screen.dart';
import '../../feature/familiy/view/family_screen.dart';
import '../../feature/home/view/home_screen.dart';
import '../../feature/login/view/login_screen.dart';
import '../../feature/select_mode/view/select_mode_screen.dart';
import '../../feature/terms/view/terms_screen.dart';

class Routes {
  static const login = '/login';
  static const terms = '/terms';
  static const selectMode = '/select-mode';

  // 탭 루트 경로(쉘 내부)
  static const home = '/home';
  static const family = '/family';
  static const calendar = '/calendar';
  static const settings = '/settings';

  static final router = GoRouter(
    initialLocation: login,
    routes: [
      // 인증/온보딩은 쉘 밖
      GoRoute(path: login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: terms, builder: (_, __) => const TermsScreen()),
      GoRoute(path: selectMode, builder: (_, __) => const SelectModeScreen()),

      // 바텀 네비가 항상 보이는 메인 쉘
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: home, builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: family, builder: (_, __) => const FamilyScreen()),
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

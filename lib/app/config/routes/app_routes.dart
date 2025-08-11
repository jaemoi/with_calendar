

import 'package:go_router/go_router.dart';
import 'package:with_calendar/app/feature/calendar/view/calendar_screen.dart';
import 'package:with_calendar/app/feature/settings/view/settings_screen.dart';

import '../../feature/familiy/view/family_screen.dart';
import '../../feature/home/view/home_screen.dart';
import '../../feature/login/view/login_screen.dart';
import '../../feature/select_mode/view/select_mode_screen.dart';
import '../../feature/terms/view/terms_screen.dart';

class Routes{
  static const login = '/login';
  static const terms = '/terms';
  static const selectMode = '/select-mode';
  static const home = '/home';
  static const family = '/family';
  static const calendar = '/calendar';
  static const settings = '/settings';


  static final router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: terms,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: selectMode,
        builder: (context, state) => const SelectModeScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: family,
        builder: (context, state) => const FamilyScreen(),
      ),
      GoRoute(
        path: calendar,
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
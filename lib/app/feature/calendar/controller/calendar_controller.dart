import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view/calendar_screen.dart';

final calendarControllerProvider =
AsyncNotifierProvider<CalendarController, Map<DateTime, List<DayBadge>>>(
  CalendarController.new,
);

class CalendarController extends AsyncNotifier<Map<DateTime, List<DayBadge>>> {
  @override
  Future<Map<DateTime, List<DayBadge>>> build() async {
    final jsonString = await rootBundle.loadString('assets/solarterms/solarterms_2020_2035.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final year = int.parse(json.keys.first);
    final entries = json['$year'] as Map<String, dynamic>;

    final result = <DateTime, List<DayBadge>>{};
    for (final entry in entries.entries) {
      final parts = entry.key.split('-'); // MM-DD
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final date = DateTime(year, month, day);

      result[date] = [DayBadge(entry.value, _color(entry.value))];
    }

    return result;
  }

  Color _color(String label) {
    return const Color(0xFF4DB6AC); // 기본 절기색 (Teal 계열)
  }
}

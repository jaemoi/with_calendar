// 1) 일정 모델(화면 파일 상단 or 별도 파일)
import 'dart:ui';

import '../../schedule_detail/view/schedule_detail_screen.dart';

class ScheduleEvent {
  final int id;
  final String title;
  final DateTime start;
  final DateTime end;
  final List<String> categories;
  final List<Participant> participants;
  final String? note;

  final Color color;

  const ScheduleEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.categories = const [],
    this.participants = const [],
    this.note,
    this.color = const Color(0xFFDE496E),
  });

  // Schedule -> ScheduleEvent 변환
  factory ScheduleEvent.fromSchedule(Schedule s,
      {Color color = const Color(0xFFDE496E)}) {
    return ScheduleEvent(
      id: s.id,
      title: s.title,
      start: s.start,
      end: s.end,
      categories: s.categories,
      participants: s.participants,
      note: s.note,
      color: color,
    );
  }
}

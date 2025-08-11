// 1) 일정 모델(화면 파일 상단 or 별도 파일)
import 'dart:ui';

class ScheduleEvent {
  final DateTime start;
  final DateTime end;
  final String title;
  final Color color;

  const ScheduleEvent({
    required this.start,
    required this.end,
    required this.title,
    required this.color,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controller/calendar_controller.dart';

class DayBadge {
  final String label;
  final Color color;

  const DayBadge(this.label, this.color);
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  // YearPicker 범위
  final DateTime _firstYear = DateTime(1950, 1, 1);
  final DateTime _lastYear  = DateTime(DateTime.now().year + 10, 12, 31);

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(calendarControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('With Calendar'),
        actions: [
          TextButton.icon(
            onPressed: _openYearPicker,
            icon: const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.black),
            label: Text('${_focused.year}년',style: const TextStyle(color: Colors.black),),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onPrimary),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('에러: $e')),
        data: (eventsByDay) {
          final selectedBadges = _selected == null
              ? []
              : eventsByDay[DateTime(
                      _selected!.year, _selected!.month, _selected!.day)] ??
                  [];

          return Column(
            children: [
              TableCalendar<DayBadge>(
                firstDay: DateTime.utc(1950, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focused,
                calendarFormat: _format,
                onFormatChanged: (f) => setState(() => _format = f),
                selectedDayPredicate: (d) => isSameDay(_selected, d),
                onDaySelected: (sel, foc) => setState(() {
                  _selected = sel;
                  _focused = foc;
                }),
                onPageChanged: (foc) => setState(() {
                  _focused = foc;
                }),
                eventLoader: (day) =>
                    eventsByDay[DateTime(day.year, day.month, day.day)] ?? [],
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: true,
                  isTodayHighlighted: true,
                  todayDecoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFFDE496E), width: 1.4),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFFDE496E),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(fontWeight: FontWeight.w800),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    final text =
                        ['일', '월', '화', '수', '목', '금', '토'][day.weekday % 7];
                    final isSun = day.weekday == DateTime.sunday;
                    final isSat = day.weekday == DateTime.saturday;

                    return Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isSun
                              ? const Color(0xFFE53935) // 빨강
                              : isSat
                                  ? const Color(0xFF1E88E5) // 파랑
                                  : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                  defaultBuilder: _day,
                  outsideBuilder: (ctx, day, foc) =>
                      _day(ctx, day, foc, outside: true),
                  todayBuilder: (ctx, day, foc) =>
                      _day(ctx, day, foc, isToday: true),
                  selectedBuilder: (ctx, day, foc) =>
                      _day(ctx, day, foc, isSelected: true),
                  markerBuilder: _markerBuilder,
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 12),
              if (_selected != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 항상 좌측 정렬 날짜 표시
                        Text(
                          '${_selected!.year}-${_selected!.month.toString().padLeft(2, '0')}-${_selected!.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),

                        // 절기 정보 또는 비어있음 표시
                        if (selectedBadges.isNotEmpty)
                          ...selectedBadges.map((e) => _badgeLine(e.label, dotColor: e.color))
                        else
                          _badgeLine('일정이 없습니다.')
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _badgeLine(String label, {Color? dotColor}) {
    return Row(
      children: [
        if (dotColor != null) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        Text(label, style: const TextStyle(fontSize: 15)),
      ],
    );
  }

  Widget _day(BuildContext context, DateTime day, DateTime focused,
      {bool isToday = false, bool isSelected = false, bool outside = false}) {
    final isSun = day.weekday == DateTime.sunday;
    final isSat = day.weekday == DateTime.saturday;

    Color textColor = const Color(0xFF111111);
    if (isSun) textColor = const Color(0xFFE53935);
    if (isSat) textColor = const Color(0xFF1E88E5);
    if (outside) textColor = textColor.withOpacity(0.35);

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(6),
      decoration: isSelected
          ? const BoxDecoration(
              color: Color(0xFFDE496E),
              shape: BoxShape.circle,
            )
          : null,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: isSelected ? Colors.white : textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget? _markerBuilder(
      BuildContext context, DateTime day, List<dynamic> events) {
    if (events.isEmpty) return null;
    final list = events.take(3).cast<DayBadge>().toList();

    return Positioned(
      bottom: 6,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: list
            .map((e) => Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: e.color,
                    shape: BoxShape.circle,
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _openYearPicker() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SizedBox(
          height: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text('연도 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              Expanded(
                child: YearPicker(
                  firstDate: _firstYear,
                  lastDate: _lastYear,
                  selectedDate: DateTime(_focused.year, 1, 1),
                  onChanged: (date) {
                    // 선택 즉시 해당 연도의 현재 월로 이동
                    setState(() {
                      _focused  = DateTime(date.year, _focused.month, 1);
                      // 선택 상태는 유지/초기화 중 택1
                      // _selected = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

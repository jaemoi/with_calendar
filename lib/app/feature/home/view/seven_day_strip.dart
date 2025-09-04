import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 7일 스트립: 오늘을 중앙(인덱스 3)으로, 탭 시 선택 색상 변경
class SevenDayStrip extends StatefulWidget {
  const SevenDayStrip({
    super.key,
    this.initialDate,              // 기본값: 오늘
    this.onChanged,                // 선택된 날짜 콜백
  });

  final DateTime? initialDate;
  final ValueChanged<DateTime>? onChanged;

  @override
  State<SevenDayStrip> createState() => _SevenDayStripState();
}

class _SevenDayStripState extends State<SevenDayStrip> {
  late DateTime _center;           // 기본: 오늘(또는 주어진 날짜)
  late List<DateTime> _days;       // _center 기준 -3 ~ +3
  late int _selectedIndex;         // 기본: 3 (오늘)

  @override
  void initState() {
    super.initState();
    _center = _normalize(widget.initialDate ?? DateTime.now());
    _rebuildDays(center: _center, selectedIndex: 3);
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  void _rebuildDays({required DateTime center, required int selectedIndex}) {
    _days = List.generate(7, (i) => center.add(Duration(days: i - 3)));
    _selectedIndex = selectedIndex;
  }

  String _label(DateTime d) {
    // "18\nMo" 형식 만들기 (영문 2글자 요일)
    final day = DateFormat('dd').format(d);
    final dow = DateFormat('E').format(d); // Mon, Tue...
    final two = dow.length >= 2 ? dow.substring(0, 2) : dow;
    return '$day\n$two';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, __) => const SizedBox(width: 0),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final date = _days[index];
          final isSelected = index == _selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onChanged?.call(date);
            },
            child: Container(
              width: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFEFF3) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _label(date),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFFDE496E) : Colors.black,
                  height: 1.05, // 줄간격 살짝 타이트하게
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

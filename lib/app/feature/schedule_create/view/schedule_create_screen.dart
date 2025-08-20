import 'package:flutter/material.dart';

class ScheduleCreateScreen extends StatefulWidget {
  const ScheduleCreateScreen({super.key});

  @override
  State<ScheduleCreateScreen> createState() => _ScheduleCreateScreenState();
}

class _ScheduleCreateScreenState extends State<ScheduleCreateScreen> {
  // ===== Palette (스크린샷 느낌) =====
  static const kBg = Color(0xFFFFFFFF);
  static const kHeadline = Color(0xFF0E1B2A);
  static const kSubtle = Color(0xFF9AA3AE);
  static const kCard = Color(0xFFF2F6FA);
  static const kSelected = Color(0xFF8C7BFF); // 날짜 선택 보라
  static const kDivider = Color(0xFFE8EDF3);
  static const kChipText = Color(0xFF0E1B2A);

  // 시간
  TimeOfDay _from = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _to = const TimeOfDay(hour: 14, minute: 0);

  // 날짜 카드(오늘부터 3일 + Other Date)
  late final List<DateTime> _dates = List.generate(
    3,
        (i) => DateTime.now().add(Duration(days: i)),
  );
  int _selectedDateIndex = 1; // 예시로 가운데(스크린샷처럼)
  DateTime? _customDate;

  // 카테고리
  final _categories = <_Cat>[
    _Cat('Meeting', Colors.orange, const Color(0xFFFFF3D7)),
    _Cat('Hangout', const Color(0xFF5D2E8C), const Color(0xFFF6EFFF)),
    _Cat('Cooking', const Color(0xFFCC2A2A), const Color(0xFFFFECEC)),
    _Cat('Other', const Color(0xFF3A3A3A), const Color(0xFFF1F1F1)),
    _Cat('Weekend', const Color(0xFF0B7A28), const Color(0xFFEFF9F1)),
  ];
  final Set<String> _selectedCats = {'Meeting'};

  final _noteCtrl = TextEditingController();

  // ===== Helpers =====
  String _fmtDay(DateTime d) => d.day.toString().padLeft(2, '0');
  String _wdShort(DateTime d) {
    const ws = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return ws[d.weekday - 1];
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}.${(t.minute ~/ 1).toString().padLeft(2, '0')}';

  Future<void> _pickFrom() async {
    final picked = await showTimePicker(context: context, initialTime: _from);
    if (picked != null) {
      setState(() {
        _from = picked;
        // from이 to보다 크면 to를 따라오게
        final fromMinutes = _from.hour * 60 + _from.minute;
        final toMinutes = _to.hour * 60 + _to.minute;
        if (toMinutes <= fromMinutes) {
          final newToMinutes = fromMinutes + 60;
          _to = TimeOfDay(
            hour: (newToMinutes ~/ 60) % 24,
            minute: newToMinutes % 60,
          );
        }
      });
    }
  }

  Future<void> _pickTo() async {
    final picked = await showTimePicker(context: context, initialTime: _to);
    if (picked != null) {
      setState(() => _to = picked);
    }
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _selectedDateIndex = 3; // Other Date 카드 선택
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Stack(
        children: [
          // 상단 원형 데코 (가벼운 느낌)

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Let's set the\nschedule easily",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: kHeadline,
                  ),
                ),
                const SizedBox(height: 28),

                _SectionTitle('Select the date'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      Expanded(
                        child: _DateCard(
                          day: _fmtDay(_dates[i]),
                          week: _wdShort(_dates[i]),
                          selected: _selectedDateIndex == i,
                          onTap: () => setState(() => _selectedDateIndex = i),
                        ),
                      ),
                      if (i != 2) const SizedBox(width: 12),
                    ],
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OtherDateCard(
                        labelTop: 'Other',
                        labelBottom: _customDate == null ? 'Date' : _fmtDay(_customDate!),
                        selected: _selectedDateIndex == 3,
                        onTap: _pickCustomDate,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                _SectionTitle('Select time'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimeCell(
                          label: 'From',
                          value: _fmtTime(_from),
                          onTap: _pickFrom,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right_rounded, size: 24, color: Colors.black87),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _TimeCell(
                          label: 'To',
                          value: _fmtTime(_to),
                          onTap: _pickTo,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                _SectionTitle('Category'),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final c in _categories)
                      _CategoryChip(
                        label: c.name,
                        dot: c.dot,
                        bg: c.bg,
                        selected: _selectedCats.contains(c.name),
                        onTap: () {
                          setState(() {
                            if (_selectedCats.contains(c.name)) {
                              _selectedCats.remove(c.name);
                            } else {
                              _selectedCats.add(c.name);
                            }
                          });
                        },
                      ),
                    _AddChip(onTap: () {
                      // TODO: 카테고리 추가 플로우
                    }),
                  ],
                ),

                const SizedBox(height: 28),
                _SectionTitle('Note'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kDivider),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _noteCtrl,
                    maxLines: 5,
                    minLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write a note...',
                      hintStyle: TextStyle(color: kSubtle),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                _SaveButton(onTap: () {
                  // TODO: 저장 로직
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved! (demo)')),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Widgets =====

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: _ScheduleCreateScreenState.kHeadline,
    ),
  );
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.day,
    required this.week,
    required this.selected,
    required this.onTap,
  });

  final String day;
  final String week;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? _ScheduleCreateScreenState.kSelected : _ScheduleCreateScreenState.kCard;
    final fg = selected ? Colors.white : _ScheduleCreateScreenState.kHeadline;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(day,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: fg,
                )),
            const SizedBox(height: 4),
            Text(week,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white70 : _ScheduleCreateScreenState.kSubtle,
                )),
          ],
        ),
      ),
    );
  }
}

class _OtherDateCard extends StatelessWidget {
  const _OtherDateCard({
    required this.labelTop,
    required this.labelBottom,
    required this.selected,
    required this.onTap,
  });

  final String labelTop;
  final String labelBottom;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? _ScheduleCreateScreenState.kSelected : _ScheduleCreateScreenState.kCard;
    final fg = selected ? Colors.white : _ScheduleCreateScreenState.kHeadline;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(labelTop,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white70 : _ScheduleCreateScreenState.kSubtle,
                )),
            const SizedBox(height: 4),
            Text(labelBottom,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: fg,
                )),
          ],
        ),
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  const _TimeCell({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  color: _ScheduleCreateScreenState.kSubtle,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                  color: _ScheduleCreateScreenState.kHeadline,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                )),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.dot,
    required this.bg,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color dot;
  final Color bg;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected ? Border.all(color: dot.withOpacity(0.6), width: 1) : null;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: _ScheduleCreateScreenState.kChipText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF817CFF)),
        ),
        child: const Icon(Icons.add, size: 18, color: Color(0xFF6F68FF)),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6E91), Color(0xFFDE496E)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Save',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _Rings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _ring(260, const Color(0xFFE1F2EF)),
        Positioned(top: 28, left: 28, child: _ring(204, const Color(0xFFF39AA8))),
        Positioned(top: 54, left: 54, child: _ring(148, const Color(0xFFC3B7FF))),
      ],
    );
  }

  Widget _ring(double size, Color c) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );
}

class _Cat {
  final String name;
  final Color dot;
  final Color bg;
  const _Cat(this.name, this.dot, this.bg);
}

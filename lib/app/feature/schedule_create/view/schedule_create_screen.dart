import 'package:flutter/material.dart';

class ScheduleCreateScreen extends StatefulWidget {
  const ScheduleCreateScreen({super.key});

  @override
  State<ScheduleCreateScreen> createState() => _ScheduleCreateScreenState();
}

class _ScheduleCreateScreenState extends State<ScheduleCreateScreen> {
  // ===== Palette =====
  static const kBg = Color(0xFFFFFFFF);
  static const kHeadline = Color(0xFF0E1B2A);
  static const kSubtle = Color(0xFF9AA3AE);
  static const kCard = Color(0xFFF2F6FA);
  static const kSelected = Color(0xFF8C7BFF);
  static const kDivider = Color(0xFFE8EDF3);
  static const kChipText = Color(0xFF0E1B2A);

  // 시간
  TimeOfDay _from = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _to = const TimeOfDay(hour: 14, minute: 0);

  // 날짜 카드(오늘부터 3일 + Other Date) - 시작일
  late final List<DateTime> _dates =
  List.generate(3, (i) => DateTime.now().add(Duration(days: i)));
  int _selectedDateIndex = 1; // 가운데 선택
  DateTime? _customDate;

  // NEW: 다중 일자 여부 + 끝나는 날 상태
  bool _multiDay = false; // End date 토글
  late final List<DateTime> _endDates =
  List.generate(3, (i) => DateTime.now().add(Duration(days: i)));
  int _endSelectedIndex = 1;
  DateTime? _endCustomDate;

  // 카테고리
  final _categories = <_Cat>[
    _Cat('약속', Colors.orange, const Color(0xFFFFF3D7)),
    _Cat('여행', const Color(0xFF5D2E8C), const Color(0xFFF6EFFF)),
    _Cat('Cooking', const Color(0xFFCC2A2A), const Color(0xFFFFECEC)),
    _Cat('Other', const Color(0xFF3A3A3A), const Color(0xFFF1F1F1)),
    _Cat('Weekend', const Color(0xFF0B7A28), const Color(0xFFEFF9F1)),
  ];
  final Set<String> _selectedCats = {'약속'}; // FIX: 존재하는 라벨로

  final _noteCtrl = TextEditingController();

  // ===== Helpers =====
  String _fmtDay(DateTime d) => d.day.toString().padLeft(2, '0');
  String _wdShort(DateTime d) {
    const ws = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return ws[d.weekday - 1];
  }

  String _fmtDateShort(DateTime d) => '${_wdShort(d)} ${_fmtDay(d)}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  DateTime get _startDate =>
      _selectedDateIndex == 3 ? (_customDate ?? DateTime.now()) : _dates[_selectedDateIndex];

  DateTime get _endDate {
    if (!_multiDay) return _startDate;
    return _endSelectedIndex == 3
        ? (_endCustomDate ?? _startDate)
        : _endDates[_endSelectedIndex];
  }

  void _ensureEndNotBeforeStart() {
    if (_endDate.isBefore(DateTime(_startDate.year, _startDate.month, _startDate.day))) {
      setState(() {
        // 끝나는 날이 시작일보다 빠르면 시작일로 보정
        if (_multiDay) {
          _endSelectedIndex = _selectedDateIndex;
          _endCustomDate = _customDate;
        }
      });
    }
  }

  Future<void> _pickFrom() async {
    final picked = await showTimePicker(context: context, initialTime: _from);
    if (picked != null) {
      setState(() {
        _from = picked;
        // 같은 날일 때 from >= to 이면 to를 한 시간 뒤로
        if (!_multiDay) {
          final fromM = _from.hour * 60 + _from.minute;
          final toM = _to.hour * 60 + _to.minute;
          if (toM <= fromM) {
            final newTo = fromM + 60;
            _to = TimeOfDay(hour: (newTo ~/ 60) % 24, minute: newTo % 60);
          }
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
      initialDate: _customDate ?? _startDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _selectedDateIndex = 3; // Other Date
        if (!_multiDay) {
          // 단일일자라면 끝나는 날도 따라오게
          _endSelectedIndex = _selectedDateIndex;
          _endCustomDate = _customDate;
        }
      });
    }
  }

  // NEW: 끝나는 날 커스텀
  Future<void> _pickEndCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endCustomDate ?? _endDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _endCustomDate = picked;
        _endSelectedIndex = 3;
      });
      _ensureEndNotBeforeStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Let's set the\nschedule easily",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: kHeadline,
              ),
            ),
            const SizedBox(height: 28),

            // ===== Start date =====
            const _SectionTitle('Select the date'),
            const SizedBox(height: 12),
            Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Expanded(
                    child: _DateCard(
                      day: _fmtDay(_dates[i]),
                      week: _wdShort(_dates[i]),
                      selected: _selectedDateIndex == i,
                      onTap: () => setState(() {
                        _selectedDateIndex = i;
                        if (!_multiDay) {
                          _endSelectedIndex = i;
                          _endCustomDate = null;
                        }
                      }),
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
            const _SectionTitle('Select time'),
            const SizedBox(height: 12),

            // Time range
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
                      // NEW: 다중 일자면 캡션으로 끝나는 날짜 표시
                      caption: _multiDay ? _fmtDateShort(_endDate) : null,
                      onTap: _pickTo,
                    ),
                  ),
                ],
              ),
            ),

            // NEW: End date 토글 & (펼침) 선택
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('End date', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Switch.adaptive(
                  value: _multiDay,
                  activeColor: kSelected,
                  onChanged: (v) {
                    setState(() {
                      _multiDay = v;
                      if (_multiDay) {
                        // 기본값: 시작일과 같게 두되, 필요 시 사용자가 바꾸게
                        _endSelectedIndex = _selectedDateIndex;
                        _endCustomDate = _selectedDateIndex == 3 ? _customDate : null;
                      } else {
                        // 단일일자 모드로 복귀
                        _endSelectedIndex = _selectedDateIndex;
                        _endCustomDate = _selectedDateIndex == 3 ? _customDate : null;
                      }
                    });
                  },
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState:
              _multiDay ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const _SectionTitle('Select end date'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (int i = 0; i < 3; i++) ...[
                        Expanded(
                          child: _DateCard(
                            day: _fmtDay(_endDates[i]),
                            week: _wdShort(_endDates[i]),
                            selected: _endSelectedIndex == i,
                            onTap: () {
                              setState(() {
                                _endSelectedIndex = i;
                                _endCustomDate = null;
                              });
                              _ensureEndNotBeforeStart();
                            },
                          ),
                        ),
                        if (i != 2) const SizedBox(width: 12),
                      ],
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OtherDateCard(
                          labelTop: 'Other',
                          labelBottom: _endCustomDate == null
                              ? 'Date'
                              : _fmtDay(_endCustomDate!),
                          selected: _endSelectedIndex == 3,
                          onTap: _pickEndCustomDate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const _SectionTitle('Category'),
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
                        _selectedCats.contains(c.name)
                            ? _selectedCats.remove(c.name)
                            : _selectedCats.add(c.name);
                      });
                    },
                  ),
                _AddChip(onTap: () {
                  // TODO: 카테고리 추가
                }),
              ],
            ),

            const SizedBox(height: 28),
            const _SectionTitle('Note'),
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
                decoration: const InputDecoration(
                  hintText: 'Write a note...',
                  hintStyle: TextStyle(color: kSubtle),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 32),
            _SaveButton(onTap: () {
              // TODO: 저장 로직
              // start: _startDate + _from, end: _endDate + _to
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved! (demo)')),
              );
            }),
          ],
        ),
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
            Text(day, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: fg)),
            const SizedBox(height: 4),
            Text(
              week,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white70 : _ScheduleCreateScreenState.kSubtle,
              ),
            ),
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
            Text(
              labelTop,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white70 : _ScheduleCreateScreenState.kSubtle,
              ),
            ),
            const SizedBox(height: 4),
            Text(labelBottom, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fg)),
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
    this.caption, // NEW: 보조 캡션
  });

  final String label;
  final String value;
  final String? caption;
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
            Text(
              value,
              style: const TextStyle(
                color: _ScheduleCreateScreenState.kHeadline,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 4),
              Text(
                caption!,
                style: const TextStyle(
                  fontSize: 12,
                  color: _ScheduleCreateScreenState.kSubtle,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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

class _Cat {
  final String name;
  final Color dot;
  final Color bg;
  const _Cat(this.name, this.dot, this.bg);
}

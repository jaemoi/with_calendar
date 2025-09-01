import 'package:flutter/material.dart';
import 'package:with_calendar/app/shared/theme/palette.dart';

import '../widget/add_chip.dart';
import '../widget/category_chip.dart';
import '../widget/date_card.dart';
import '../widget/other_date_card.dart';
import '../widget/participant_chip.dart';
import '../widget/save_button.dart';
import '../widget/section_title.dart';
import '../widget/time_cell.dart';

class ScheduleCreateScreen extends StatefulWidget {
  const ScheduleCreateScreen({super.key});

  @override
  State<ScheduleCreateScreen> createState() => _ScheduleCreateScreenState();
}

class _ScheduleCreateScreenState extends State<ScheduleCreateScreen> {
  final String _meName = '나'; // 로그인 사용자 닉네임
  final List<String> _familyMembers = ['나', '배우자1234', '첫째', '둘째', '할머니']; // 예시
  late final List<String> _selectableMembers =
      _familyMembers.where((n) => n != _meName).toList();

  final Set<String> _selectedParticipants = {};

//ㅈㅔ목
  final _titleCtrl = TextEditingController();

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

  String _fmtDateCaption(DateTime d) =>
      '${d.month}.${d.day.toString().padLeft(2, '0')} ${_wdShort(d)}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  DateTime get _startDate => _selectedDateIndex == 3
      ? (_customDate ?? DateTime.now())
      : _dates[_selectedDateIndex];

  DateTime get _endDate {
    if (!_multiDay) return _startDate;
    return _endSelectedIndex == 3
        ? (_endCustomDate ?? _startDate)
        : _endDates[_endSelectedIndex];
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _ensureEndNotBeforeStart() {
    final s = _dateOnly(_startDate);
    final e = _dateOnly(_endDate);
    if (e.isBefore(s)) {
      setState(() {
        _selectedDateIndex = _endSelectedIndex;
        _customDate = _endSelectedIndex == 3 ? _endCustomDate : null;
      });
    }
  }

  void _ensureStartNotAfterEnd() {
    final s = _dateOnly(_startDate);
    final e = _dateOnly(_endDate);
    if (s.isAfter(e)) {
      setState(() {
        _endSelectedIndex = _selectedDateIndex;
        _endCustomDate = _selectedDateIndex == 3 ? _customDate : null;
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
      _ensureStartNotAfterEnd();
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
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
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
                color: AppColors.headline,
              ),
            ),

            const SizedBox(height: 20),

            // NEW: Title 입력
            const SectionTitle('Title'),
            const SizedBox(height: 13),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _titleCtrl,
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Enter a title (e.g., Family dinner)',
                  hintStyle: TextStyle(color: AppColors.subtle),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ===== Start date =====
            Row(children: [
              const SectionTitle('Select the date'),
              const Spacer(),
              const Text('복수 일정',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              Switch.adaptive(
                value: _multiDay,
                activeColor: AppColors.selected,
                onChanged: (v) {
                  setState(() {
                    _multiDay = v;
                    if (_multiDay) {
                      // 기본값: 시작일과 같게 두되, 필요 시 사용자가 바꾸게
                      _endSelectedIndex = _selectedDateIndex;
                      _endCustomDate =
                          _selectedDateIndex == 3 ? _customDate : null;
                    } else {
                      // 단일일자 모드로 복귀
                      _endSelectedIndex = _selectedDateIndex;
                      _endCustomDate =
                          _selectedDateIndex == 3 ? _customDate : null;
                    }
                  });
                },
              ),
            ]),
            Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Expanded(
                    child: DateCard(
                      day: _fmtDay(_dates[i]),
                      week: _wdShort(_dates[i]),
                      selected: _selectedDateIndex == i,
                      onTap: () {
                        setState(() {
                          _selectedDateIndex = i;
                          _customDate = null;
                          if (!_multiDay) {
                            _endSelectedIndex = i;
                            _endCustomDate = null;
                          }
                        });
                        _ensureStartNotAfterEnd();
                      },
                    ),
                  ),
                  if (i != 2) const SizedBox(width: 12),
                ],
                const SizedBox(width: 12),
                Expanded(
                  child: OtherDateCard(
                    labelTop: 'Other',
                    labelBottom: _customDate == null
                        ? 'Date'
                        : _fmtDateCaption(_customDate!),
                    selected: _selectedDateIndex == 3,
                    onTap: _pickCustomDate,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _multiDay
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const SectionTitle('Select end date'),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      for (int i = 0; i < 3; i++) ...[
                        Expanded(
                          child: DateCard(
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
                        child: OtherDateCard(
                          labelTop: 'Other',
                          labelBottom: _endCustomDate == null
                              ? 'Date'
                              : _fmtDateCaption(_endCustomDate!),
                          selected: _endSelectedIndex == 3,
                          onTap: _pickEndCustomDate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const SectionTitle('Select time'),
            const SizedBox(height: 13),

            // Time range
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: TimeCell(
                      label: 'From',
                      value: _fmtTime(_from),
                      caption: _multiDay ? _fmtDateCaption(_endDate) : null,
                      onTap: _pickFrom,
                    ),
                  ),
                  //const SizedBox(width: 6),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      size: 24, color: Colors.black87),
                  const Spacer(),
                  Expanded(
                    child: TimeCell(
                      label: 'To',
                      value: _fmtTime(_to),
                      // NEW: 다중 일자면 캡션으로 끝나는 날짜 표시
                      caption: _multiDay ? _fmtDateCaption(_endDate) : null,
                      onTap: _pickTo,
                    ),
                  ),
                ],
              ),
            ),

            // NEW: End date 토글 & (펼침) 선택
            const SizedBox(height: 40),
            const SectionTitle('Category'),
            const SizedBox(height: 13),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in _categories)
                  CategoryChip(
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
                AddChip(onTap: () {
                  // TODO: 카테고리 추가
                }),
              ],
            ),

            const SizedBox(height: 28),
            const SectionTitle('Participants'),
            const SizedBox(height: 13),

            if (_selectableMembers.isEmpty)
              const Text('표시할 가족이 없어요.',
                  style: TextStyle(color: AppColors.subtle))
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final name in _selectableMembers)
                    ParticipantChip(
                      label: name,
                      selected: _selectedParticipants.contains(name),
                      onTap: () {
                        setState(() {
                          if (_selectedParticipants.contains(name)) {
                            _selectedParticipants.remove(name);
                          } else {
                            _selectedParticipants.add(name);
                          }
                        });
                      },
                    ),
                ],
              ),

            const SizedBox(height: 28),
            const SectionTitle('Note'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _noteCtrl,
                maxLines: 5,
                minLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write a note...',
                  hintStyle: TextStyle(color: AppColors.subtle),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 32),
            SaveButton(onTap: () {
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

class _Cat {
  final String name;
  final Color dot;
  final Color bg;

  const _Cat(this.name, this.dot, this.bg);
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:with_calendar/app/shared/theme/palette.dart';

import '../../schedule_detail/view/schedule_detail_screen.dart';
import '../widget/add_chip.dart';
import '../widget/category_chip.dart';
import '../widget/date_card.dart';
import '../widget/other_date_card.dart';
import '../widget/participant_chip.dart';
import '../widget/save_button.dart';
import '../widget/section_title.dart';
import '../widget/time_cell.dart';

enum ScheduleFormMode { create, edit }

class ScheduleForm extends StatefulWidget {
  const ScheduleForm({
    super.key,
    required this.mode,
    this.initial, // edit 모드일 때만 사용
    this.initialDate,
  });

  final ScheduleFormMode mode;
  final Schedule? initial;
  final DateTime? initialDate;

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  // ===== 상태값 =====
  final String _meName = '나';
  final List<String> _familyMembers = ['나', '배우자1234', '첫째', '둘째', '할머니'];
  late final List<String> _selectableMembers =
      _familyMembers.where((n) => n != _meName).toList();

  final Set<String> _selectedParticipants = {};

  // 제목/노트
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // 시간
  TimeOfDay _from = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _to = const TimeOfDay(hour: 14, minute: 0);

  // 날짜 카드(오늘부터 3일 + Other Date)
  late final List<DateTime> _dates =
      List.generate(3, (i) => DateTime.now().add(Duration(days: i)));
  int _selectedDateIndex = 1; // 가운데 선택
  DateTime? _customDate;

  // 다중 일자 + 끝나는 날
  bool _multiDay = false;
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
  final Set<String> _selectedCats = {'약속'};

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
          _endSelectedIndex = _selectedDateIndex;
          _endCustomDate = _customDate;
        }
      });
      _ensureStartNotAfterEnd();
    }
  }

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
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s != null) {
      // ✅ 편집 모드 초기값 주입
      _titleCtrl.text = s.title;
      _noteCtrl.text = s.note ?? '';

      _from = TimeOfDay(hour: s.start.hour, minute: s.start.minute);
      _to = TimeOfDay(hour: s.end.hour, minute: s.end.minute);

      // 날짜 선택: 프리셋 범위를 고려해 'Other'로 고정
      _customDate = DateTime(s.start.year, s.start.month, s.start.day);
      _selectedDateIndex = 3;

      final sameDate = DateUtils.isSameDay(s.start, s.end);
      _multiDay = !sameDate;

      if (_multiDay) {
        _endCustomDate = DateTime(s.end.year, s.end.month, s.end.day);
        _endSelectedIndex = 3;
      } else {
        _endCustomDate = _customDate;
        _endSelectedIndex = _selectedDateIndex;
      }

      _selectedCats
        ..clear()
        ..addAll(s.categories);
      _selectedParticipants
        ..clear()
        ..addAll(s.participants.map((p) => p.name));
    }

    // ✅ 생성 모드에서 initialDate가 넘어온 경우: 'Other Date'로 선택해둔다
    if (widget.initialDate != null) {
      final d = widget.initialDate!;
      _customDate = DateTime(d.year, d.month, d.day);
      _selectedDateIndex = 3; // Other Date 선택
      _multiDay = false;
      _endCustomDate = _customDate;
      _endSelectedIndex = _selectedDateIndex;
      // _from/_to는 네 기본값(12:00~14:00) 유지
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == ScheduleFormMode.edit;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // ✅ 확실한 뒤로가기
        ),
        title: Text(
          isEdit ? 'Edit Schedule' : 'Create Schedule',
          style: const TextStyle(color: AppColors.headline),
        ),
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

            // Title
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
                      _endSelectedIndex = _selectedDateIndex;
                      _endCustomDate =
                          _selectedDateIndex == 3 ? _customDate : null;
                    } else {
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
                      // ✅ 시작 날짜 캡션
                      caption: _multiDay ? _fmtDateCaption(_startDate) : null,
                      onTap: _pickFrom,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      size: 24, color: Colors.black87),
                  const Spacer(),
                  Expanded(
                    child: TimeCell(
                      label: 'To',
                      value: _fmtTime(_to),
                      // ✅ 끝 날짜 캡션
                      caption: _multiDay ? _fmtDateCaption(_endDate) : null,
                      onTap: _pickTo,
                    ),
                  ),
                ],
              ),
            ),

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
            SaveButton(
              onTap: _onSubmit, // ✅ 저장/업데이트
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해 주세요.')),
      );
      return;
    }

    // 날짜+시간 합치기
    final start = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _from.hour,
      _from.minute,
    );
    var end = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _to.hour,
      _to.minute,
    );
    if (!end.isAfter(start)) {
      end = start.add(const Duration(hours: 1)); // 안전망
    }

    final participants = _selectedParticipants
        .map((n) => Participant(n))
        .toList(growable: false);

    final isEdit = widget.mode == ScheduleFormMode.edit;

    final id = isEdit ? widget.initial!.id : _IdService.next();

    final schedule = Schedule(
      id: id,
      title: title,
      start: start,
      end: end,
      categories: _selectedCats.toList(),
      participants: participants,
      note: _noteCtrl.text.trim(),
    );

    await ScheduleRepository.instance.put(schedule);
    if (!mounted) return;

    // 저장 후 이동: 생성은 push, 수정은 go로 치환
    if (isEdit) {
      context.go('/schedule/$id');
    } else {
      context.push('/schedule/$id');
    }
  }
}

// ===== 내부 전용 클래스/유틸 =====

class _Cat {
  final String name;
  final Color dot;
  final Color bg;

  const _Cat(this.name, this.dot, this.bg);
}

// 임시 int ID 생성기 — 필요 시 프로젝트 고유 로직으로 교체
class _IdService {
  static int _next = 1000;

  static int next() => _next++;
}

import 'package:flutter/material.dart';
import 'package:with_calendar/app/shared/theme/palette.dart';

class ScheduleDetailScreen extends StatelessWidget {
  final Schedule schedule;

  const ScheduleDetailScreen({super.key, required this.schedule});

  String _wdShort(DateTime d) {
    const ws = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return ws[d.weekday - 1];
  }

  String _fmtYmd(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')} (${_wdShort(d)})';

  String _fmtHhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final sameDay = DateUtils.isSameDay(
      DateTime(schedule.start.year, schedule.start.month, schedule.start.day),
      DateTime(schedule.end.year, schedule.end.month, schedule.end.day),
    );

    final timeLine = sameDay
        ? '${_fmtYmd(schedule.start)}  ${_fmtHhmm(schedule.start)} – ${_fmtHhmm(schedule.end)}'
        : '${_fmtYmd(schedule.start)} ${_fmtHhmm(schedule.start)}  →  ${_fmtYmd(schedule.end)} ${_fmtHhmm(schedule.end)}';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(),
        title: const Text('Schedule Detail',
            style: TextStyle(color: AppColors.headline)),
      ),

      // ✅ 하단 고정 “수정하기” 버튼
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: SizedBox(
          width: double.infinity,
          child: _PrimaryActionButton(
            label: '수정하기',
            onPressed: () {
              // TODO: 편집 흐름 연결
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit action (TODO)')),
              );
            },
          ),
        ),
      ),

      // 본문
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              schedule.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.15,
                color: AppColors.headline,
              ),
            ),
            const SizedBox(height: 16),

            // Time card
            _InfoCard(
              child: Row(
                children: [
                  const Icon(Icons.schedule,
                      size: 22, color: AppColors.headline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      timeLine,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.headline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Category (✅ 생성 화면과 같은 “작은 칩” 느낌)
            const _SectionHeader(icon: Icons.category, label: 'Category'),
            const SizedBox(height: 10),
            if (schedule.categories.isEmpty)
              const Text('카테고리 없음', style: TextStyle(color: AppColors.subtle))
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final name in schedule.categories)
                    _CategoryPill(name: name), // ✅ 작은 칩
                ],
              ),

            const SizedBox(height: 24),

            // Participants (✅ 생성 화면의 ParticipantChip 톤과 동일: AppColors.card 배경, 중앙 텍스트)
            const _SectionHeader(icon: Icons.group, label: 'Participants'),
            const SizedBox(height: 10),
            if (schedule.participants.isEmpty)
              _InfoCard(
                child: const Text(
                  '함께 참여하는 사람이 없어요.',
                  style: TextStyle(color: AppColors.subtle, fontSize: 14),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final p in schedule.participants)
                    const _ParticipantPillDivider(), // 시각적 간격 & 균일 높이 확보용
                  for (final p in schedule.participants)
                    _ParticipantPill(label: p.name),
                ],
              ),

            const SizedBox(height: 24),

            // Detail (✅ 생성 화면의 Note 카드처럼 충분한 높이 유지)
            const _SectionHeader(icon: Icons.notes, label: 'Detail'),
            const SizedBox(height: 10),
            _NoteCard(
              text: (schedule.note?.trim().isNotEmpty ?? false)
                  ? schedule.note!.trim()
                  : '상세 내용이 없습니다.',
            ),

            const SizedBox(height: 16), // bottomNavigationBar와 간섭 방지 여백
          ],
        ),
      ),
    );
  }
}

// 공용 섹션 헤더
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.headline),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.headline,
            )),
      ],
    );
  }
}

// 카드 컨테이너
class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

// ✅ Detail(노트) 영역: 생성 화면 Note처럼 충분한 높이 유지
class _NoteCard extends StatelessWidget {
  final String text;
  const _NoteCard({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120), // 충분한 높이
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        softWrap: true,
        style: const TextStyle(fontSize: 15, color: AppColors.headline, height: 1.4),
      ),
    );
  }
}

// ✅ Category 작은 칩 (생성 화면 CategoryChip 느낌)
class _CategoryPill extends StatelessWidget {
  final String name;
  const _CategoryPill({required this.name});

  // 생성 화면과 동일한 팔레트 매핑 (필요 시 공용화 가능)
  (Color dot, Color bg) _styleOf(String n) {
    switch (n) {
      case '약속':
        return (Colors.orange, const Color(0xFFFFF3D7));
      case '여행':
        return (const Color(0xFF5D2E8C), const Color(0xFFF6EFFF));
      case 'Cooking':
        return (const Color(0xFFCC2A2A), const Color(0xFFFFECEC));
      case 'Other':
        return (const Color(0xFF3A3A3A), const Color(0xFFF1F1F1));
      case 'Weekend':
        return (const Color(0xFF0B7A28), const Color(0xFFEFF9F1));
      default:
        return (AppColors.headline, AppColors.card);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (dot, bg) = _styleOf(name);
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 작은 점
          Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.headline,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Participant 작은 칩 (생성 화면 ParticipantChip의 읽기 전용 버전)
class _ParticipantPill extends StatelessWidget {
  final String label;
  const _ParticipantPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.headline,
        ),
      ),
    );
  }
}

// 칩들의 시각적 균일 높이/간격을 위해 넣은 얇은 구분자(옵션)
class _ParticipantPillDivider extends StatelessWidget {
  const _ParticipantPillDivider();
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// SaveButton 톤을 그대로 쓴 프라이머리 액션 버튼
class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.selected,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        elevation: 0,
      ),
      child: Text(label),
    );
  }
}

// 태그 칩 (AppColors.card 고정 / 가운데 정렬 / 크기 고정 느낌)
class _TagChip extends StatelessWidget {
  final String text;

  const _TagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.headline,
        ),
      ),
    );
  }
}

// // SaveButton 톤을 그대로 쓴 프라이머리 액션 버튼
// class _PrimaryActionButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onPressed;
//
//   const _PrimaryActionButton({required this.label, required this.onPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.selected,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//         textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         elevation: 0,
//       ),
//       child: Text(label),
//     );
//   }
// }

class Participant {
  final String name;
  final String? avatarUrl;

  const Participant(this.name, {this.avatarUrl});
}

class Schedule {
  final int id;
  final String title;
  final DateTime start;
  final DateTime end;
  final List<String> categories;
  final List<Participant> participants;
  final String? note;

  const Schedule({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.categories,
    required this.participants,
    this.note,
  });
}

// schedule_repository.dart
class ScheduleRepository {
  ScheduleRepository._() {
    _seedMockIfDebug(); // ✅ 앱 시작 시 1회 시드
  }
  static final instance = ScheduleRepository._();

  final Map<int, Schedule> _store = {};

  Iterable<Schedule> get all => List.unmodifiable(_store.values);

  Future<void> put(Schedule s) async => _store[s.id] = s;
  Future<Schedule?> getById(int id) async => _store[id];

  Future<List<Schedule>> listByDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end   = start.add(const Duration(days: 1));
    bool overlaps(Schedule s) => s.start.isBefore(end) && s.end.isAfter(start);
    return _store.values.where(overlaps).toList();
  }

  // ─────────────────────────────────────────────────────────────
  // 디버그(개발)에서만 목데이터 주입
  void _seedMockIfDebug() {
    assert(() {
      final now = DateTime.now();
      final y = now.year, m = now.month, d = now.day;

      // 이미 시드되어 있으면 스킵 (핫리로드/재호출 방지)
      if (_store.isNotEmpty) return true;

      _store[101] = Schedule(
        id: 101,
        title: '브루스 웨인과 회의',
        start: DateTime(y, m, d, 8, 40),
        end:   DateTime(y, m, d, 9,  0),
        categories: const ['약속'],
        participants: const [Participant('브루스 웨인')],
        note: '웨인타워 14F 대회의실',
      );

      _store[102] = Schedule(
        id: 102,
        title: '국가고시 모의',
        start: DateTime(y, m, d, 12, 0),
        end:   DateTime(y, m, d, 14, 30),
        categories: const ['시험'],
        participants: const [],
        note: '입실 11:40',
      );

      _store[103] = Schedule(
        id: 103,
        title: '팀 스탠드업',
        start: DateTime(y, m, d, 12, 0),
        end:   DateTime(y, m, d, 17, 45),
        categories: const ['회의'],
        participants: const [Participant('홍길동'), Participant('김철수')],
        note: null,
      );
      return true;
    }());
  }
}



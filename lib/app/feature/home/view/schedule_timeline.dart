// 3) 타임라인 위젯: 왼쪽(라벨 2시간 간격), 오른쪽(정확한 시간 위치에 카드)
import 'package:flutter/material.dart';
import 'package:with_calendar/app/feature/home/view/schedule_event.dart';
import 'package:with_calendar/app/feature/schedule_detail/view/schedule_detail_screen.dart';

class ScheduleTimeLine extends StatelessWidget {
  const ScheduleTimeLine(
      {super.key,
      required this.events,
      this.tickCount = 5,
      this.slotMinutes = 120,
      this.pixelsPerMinute = 0.6,
      this.viewportHeight = 240,
      this.onEventTap});

  final List<ScheduleEvent> events;
  final int tickCount; // 라벨 개수(기본 5개)
  final int slotMinutes; // 라벨 간격(분) — 기본 120분(=2h)
  final double pixelsPerMinute;
  final double viewportHeight;
  final void Function(ScheduleEvent event)? onEventTap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Text("오늘 일정이 없어요", style: TextStyle(color: Colors.grey));
    }

    // 1) 시작 기준: 가장 이른 이벤트의 시간을 2시간 단위로 내림
    final minStartMin = events
        .map((e) => e.start.hour * 60 + e.start.minute)
        .reduce((a, b) => a < b ? a : b);

    // 가장 늦게 끝나는 시간(분)
    final maxEndMin = events
        .map((e) => e.end.hour * 60 + e.end.minute)
        .reduce((a, b) => a > b ? a : b);

    final baseMin =
        (minStartMin ~/ slotMinutes) * slotMinutes; // e.g., 8:13 → 8:00
    // (필요한 슬롯 수) = (maxEndMin이 포함되도록) 올림 나눗셈
    final requiredSlots =
        ((maxEndMin - baseMin) + (slotMinutes - 1)) ~/ slotMinutes;

    // 실제 사용할 라벨 개수(기존 tickCount보다 작게 내려가지 않게)
    final usedTickCount =
        (requiredSlots + 1) > tickCount ? (requiredSlots + 1) : tickCount;

    // 여기부터는 모두 usedTickCount 기준으로 계산
    final rangeMin = (usedTickCount - 1) * slotMinutes;
    final endMin = baseMin + rangeMin;

    final totalHeight = rangeMin * pixelsPerMinute;
    final segmentHeight = slotMinutes * pixelsPerMinute;

    final railWidth = 56.0;

    // 2) 그리드/라벨용 시간 리스트
    final tickMins =
        List.generate(usedTickCount, (i) => baseMin + i * slotMinutes);

    // 3) 화면에 보이는 범위로 이벤트 클램프
    final visible = events
        .map((e) {
          final s = e.start.hour * 60 + e.start.minute;
          final t = e.end.hour * 60 + e.end.minute;
          final cs = s.clamp(baseMin, endMin);
          final ct = t.clamp(baseMin, endMin);
          return (ct > cs) ? (e, cs as int, ct as int) : null;
        })
        .whereType<(ScheduleEvent, int, int)>()
        .toList();

    // === 추가: 같은 시작 시각(분)으로 그룹핑 ===
    const double minVisualHeight = 44.0; // 너무 얇은 카드 방지
    final Map<int, List<(ScheduleEvent e, int s, int t, double visualHeight)>>
        groups = {};
    for (final tup in visible) {
      final e = tup.$1;
      final s = tup.$2;
      final t = tup.$3;
      final rawHeight = (t - s) * pixelsPerMinute;
      final vh = rawHeight < minVisualHeight ? minVisualHeight : rawHeight;
      groups.putIfAbsent(s, () => []).add((e, s, t, vh));
    }
    final groupKeys = groups.keys.toList()..sort(); // 위에서 아래로 정렬

    return SizedBox(
      height: viewportHeight,
      child: SingleChildScrollView(
        child: SizedBox(
          height: totalHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT: 2시간 간격 라벨(5개)
              SizedBox(
                width: railWidth,
                height: totalHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(usedTickCount, (i) {
                    final label = _fmtTime(tickMins[i]);
                    return Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(label,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          )),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              // RIGHT: 그리드 + 이벤트 카드들
              Expanded(
                child: SizedBox(
                  height: totalHeight,
                  child: Stack(
                    children: [
                      for (final key in groupKeys)
                        ...() {
                          final g = groups[key]!;
                          final groupTop = (key - baseMin) * pixelsPerMinute;
                          final groupHeight = g
                              .map((x) => x.$4)
                              .reduce((a, b) => a > b ? a : b);

                          return [
                            Positioned(
                              top: groupTop,
                              left: 0,
                              right: 0,
                              height: groupHeight,
                              child: Row(
                                children: [
                                  for (final item in g)
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: _eventTile(
                                          e: item.$1,
                                          s: item.$2,
                                          t: item.$3,
                                          height: item.$4, // 각 카드 고유 높이
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ];
                        }(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventTile({
    required ScheduleEvent e,
    required int s,
    required int t,
    required double height,
  }) {
    // 짧은 일정은 컴팩트 폰트/패딩
    final dense = height <= 44.0 + 0.1;
    final padV = dense ? 6.0 : 12.0;
    final titleFont = dense ? 13.0 : 16.0; // 제목 더 크게
    final titleLines = dense ? 2 : 3; // 공간 허용 시 최대 3줄

    return SizedBox(
      height: height,
      child: ClipRect(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onEventTap?.call(e),
            child: Stack(
              children: [
                // 배경 + 제목(왼쪽 상단 정렬, 시간 텍스트 제거)
                Positioned.fill(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: padV),
                    decoration: BoxDecoration(
                      color: e.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        e.title,
                        maxLines: titleLines,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFont,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                // 참가자 아바타: 우하단에 겹쳐 표시
                if (e.participants.isNotEmpty)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _avatarStack(e.participants),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmtTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _avatarStack(List<Participant> avatars) {
    const double size = 10; // 아바타 지름
    const double overlap = 7; // 겹치는 정도
    const int maxShow = 5; // 최대 표시 수

    final show = avatars.take(maxShow).toList();
    final extra = avatars.length - show.length;

    return SizedBox(
      height: size,
      // 가로 폭은 동적으로: (표시개수 + 추가버튼) * overlap 정도
      width: (show.length + (extra > 0 ? 1 : 0)) * overlap + (size - overlap),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < show.length; i++)
            Positioned(
              right: i * overlap,
              child: _avatarCircle(show[show.length - 1 - i], size),
            ),
          if (extra > 0)
            Positioned(
              right: show.length * overlap,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(size / 2),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  '+$extra',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatarCircle(Participant p, double size) {
    final url = p.avatarUrl;

    if (url != null && url.isNotEmpty) {
      final ImageProvider provider = url.startsWith('http')
          ? NetworkImage(url)
          : AssetImage(url) as ImageProvider;

      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.white, // 경계선 대비
        child: CircleAvatar(
          radius: (size / 2) - 1.5,
          backgroundImage: provider,
        ),
      );
    }

    final initial = _firstChar(p.name);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: (size / 2) - 1.5,
        backgroundColor: Colors.black26,
        child: Text(
          initial,
          style: const TextStyle(
              fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  // 유니코드 첫 글자 안전 추출 (한글/이모지 포함)
  String _firstChar(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return String.fromCharCodes(t.runes.take(1)).toUpperCase();
  }
}

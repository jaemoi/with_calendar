// 3) 타임라인 위젯: 왼쪽(라벨 2시간 간격), 오른쪽(정확한 시간 위치에 카드)
import 'package:flutter/material.dart';
import 'package:with_calendar/app/feature/home/view/schedule_event.dart';

class ScheduleTimeLine extends StatelessWidget {
  const ScheduleTimeLine({
    super.key,
    required this.events,
    this.tickCount = 5,
    this.slotMinutes = 120,
    this.pixelsPerMinute = 0.6,
    this.viewportHeight = 240,
  });

  final List<ScheduleEvent> events;
  final int tickCount;         // 라벨 개수(기본 5개)
  final int slotMinutes;       // 라벨 간격(분) — 기본 120분(=2h)
  final double pixelsPerMinute;
  final double viewportHeight;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Text("오늘 일정이 없어요", style: TextStyle(color: Colors.grey));
    }

    // 1) 시작 기준: 가장 이른 이벤트의 시간을 2시간 단위로 내림
    final minStartMin = events
        .map((e) => e.start.hour * 60 + e.start.minute)
        .reduce((a, b) => a < b ? a : b);

    final baseMin = (minStartMin ~/ slotMinutes) * slotMinutes; // e.g., 8:13 → 8:00
    // 총 표시 범위: (tickCount - 1) * slotMinutes (기본 8시간)
    final rangeMin = (tickCount - 1) * slotMinutes;
    final endMin = baseMin + rangeMin;

    final totalHeight = rangeMin * pixelsPerMinute; // 예: 480px
    final segmentHeight = slotMinutes * pixelsPerMinute;
    final railWidth = 56.0;

    // 2) 그리드/라벨용 시간 리스트
    final tickMins = List.generate(tickCount, (i) => baseMin + i * slotMinutes);

    // 3) 화면에 보이는 범위로 이벤트 클램프
    final visible = events.map((e) {
      final s = e.start.hour * 60 + e.start.minute;
      final t = e.end.hour * 60 + e.end.minute;
      final cs = s.clamp(baseMin, endMin);
      final ct = t.clamp(baseMin, endMin);
      return (ct > cs)
          ? (e, cs as int, ct as int)
          : null;
    }).whereType<(ScheduleEvent, int, int)>().toList();

    // === 추가: 같은 시작 시각(분)으로 그룹핑 ===
    const double minVisualHeight = 44.0; // 너무 얇은 카드 방지
    final Map<int, List<(ScheduleEvent e, int s, int t, double visualHeight)>> groups = {};
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
                  children: List.generate(tickCount, (i) {
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
                      for (final key in groupKeys) ...() {
                        final g = groups[key]!;
                        final groupTop = (key - baseMin) * pixelsPerMinute;
                        final groupHeight = g.map((x) => x.$4).reduce((a,
                            b) => a > b ? a : b);

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
    // 짧은 일정은 컴팩트 레이아웃
    final dense = height <= 44.0 + 0.1;
    final padV = dense ? 6.0 : 12.0;
    final titleFont = dense ? 12.0 : 15.0;
    final titleLines = dense ? 1 : 2;

    return SizedBox(
      height: height,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: padV),
        decoration: BoxDecoration(
          color: e.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 제목: 공간이 부족하면 생략(…)
            Expanded(
              child: Text(
                e.title,
                maxLines: titleLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFont,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // ⬅️ 시간은 항상 표시
            Text(
              '${_fmtTime(s)} - ${_fmtTime(t)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }


  String _fmtTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

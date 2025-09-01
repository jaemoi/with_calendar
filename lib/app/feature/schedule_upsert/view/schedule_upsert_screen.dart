// lib/app/feature/schedule_upsert/view/schedule_upsert_screen.dart
import 'package:flutter/material.dart';
import 'package:with_calendar/app/feature/schedule_upsert/view/schedule_form.dart';
import 'package:with_calendar/app/shared/theme/palette.dart';

import '../../schedule_detail/view/schedule_detail_screen.dart';

class ScheduleUpsertScreen extends StatelessWidget {
  const ScheduleUpsertScreen({super.key, this.scheduleId});

  final int? scheduleId; // null이면 '추가', 값 있으면 '수정'

  @override
  Widget build(BuildContext context) {
    // 추가 모드
    if (scheduleId == null) {
      return const ScheduleForm(mode: ScheduleFormMode.create);
    }

    // 수정 모드: id로 로딩
    return FutureBuilder<Schedule?>(
      future: ScheduleRepository.instance.getById(scheduleId!),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final s = snap.data;
        if (s == null) {
          return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(child: Text('일정을 찾을 수 없어요.')),
          );
        }
        return ScheduleForm(mode: ScheduleFormMode.edit, initial: s);
      },
    );
  }
}

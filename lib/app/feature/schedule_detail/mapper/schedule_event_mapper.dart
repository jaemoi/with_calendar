import '../view/schedule_detail_screen.dart';

extension ScheduleQueries on ScheduleRepository {
  Future<List<Schedule>> listByDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end   = start.add(const Duration(days: 1));
    bool overlaps(Schedule s) => !(s.end.isBefore(start) || s.start.isAfter(end));
    return all.where(overlaps).toList(); // ✅ _store가 아니라 공개 all 사용
  }
}

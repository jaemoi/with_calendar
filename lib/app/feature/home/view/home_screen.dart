import 'package:flutter/material.dart';
import 'package:with_calendar/app/feature/home/view/schedule_event.dart';
import 'package:with_calendar/app/feature/home/view/schedule_timeline.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 인사말 + 프로필
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Good Morning,\nShuri",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: AssetImage("assets/images/profile.png"),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 요일 선택 (가로)
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(7, (index) {
                    final days = [
                      "18\nMo",
                      "19\nTu",
                      "20\nWe",
                      "21\nTh",
                      "22\nFr",
                      "23\nSa",
                      "24\nSu"
                    ];
                    final isSelected = index == 3;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        width: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFEFF3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          days[index],
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFFDE496E)
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 15),

              // Schedule Today
              const Text(
                "Schedule Today",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Builder(builder: (context) {
                final today = DateTime.now();
                final events = <ScheduleEvent>[
                  ScheduleEvent(
                    start: DateTime(today.year, today.month, today.day, 8, 40),
                    end: DateTime(today.year, today.month, today.day, 9, 0),
                    title: "브루스 웨인과 회의",
                    color: const Color(0xFFFF6E91),
                  ),
                  ScheduleEvent(
                    start: DateTime(today.year, today.month, today.day, 12, 0),
                    end:   DateTime(today.year, today.month, today.day, 14, 30),
                    title: "국가고시 모의",
                    color: const Color(0xFFFF6E91),
                  ),
                  ScheduleEvent(
                    start: DateTime(today.year, today.month, today.day, 12, 0),
                    end:   DateTime(today.year, today.month, today.day, 17, 45),
                    title: "팀 스탠드업",
                    color: Colors.deepPurpleAccent,
                  ),
                ];
                return ScheduleTimeLine(events: events,
                tickCount: 5,
                slotMinutes: 120,
                pixelsPerMinute: 0.7,);
              }),

              const SizedBox(height: 24),

              // Reminder
              const Text(
                "Reminder",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 1),
              const Text(
                "내일의 일정입니다.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              reminderCard(
                title: "Urus SIM di samsat Klayatan",
                time: "12.00 - 16.00",
                color: Colors.deepPurpleAccent.shade200,
              ),
              const SizedBox(height: 12),
              reminderCard(
                title: "Urus SIM di samsat Klayatan",
                time: "12.00 - 16.00",
                color: Colors.purpleAccent.shade200,
              ),

              const SizedBox(height: 40),

              // Set schedule 버튼
              Center(
                child: SizedBox(
                  width: 250,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Ink(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFDE496E), Color(0xFFFF6E91)],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          "일정을 추가해보세요",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 일정 카드 위젯
  Widget scheduleCard(
      {required String time, required String title, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reminder 카드 위젯
  Widget reminderCard(
      {required String title, required String time, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(time,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

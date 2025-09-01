import 'package:flutter/material.dart';
import 'package:with_calendar/app/shared/theme/palette.dart';

class ParticipantChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ParticipantChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(minHeight: 40),
        // 높이 고정 느낌
        decoration: BoxDecoration(
          color: AppColors.card, // 요청: 고정 배경색
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.selected : AppColors.divider,
            width: 1, // ✅ 두께 고정 -> 크기 변화 없음
          ),
          boxShadow: selected
              ? [
                  const BoxShadow(
                      blurRadius: 6,
                      offset: Offset(0, 2),
                      color: Colors.black12)
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.headline, // 텍스트 굵기/크기 변화 X -> 폭 안정
              ),
            ),
          ],
        ),
      ),
    );
  }
}

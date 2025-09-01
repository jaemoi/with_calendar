import 'package:flutter/material.dart';

import '../../../shared/theme/palette.dart';

class DateCard extends StatelessWidget {
  const DateCard({
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
    final bg = selected ? AppColors.selected : AppColors.card;
    final fg = selected ? Colors.white : AppColors.headline;

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
            Text(day,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: fg)),
            const SizedBox(height: 4),
            Text(
              week,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white70 : AppColors.subtle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../../shared/theme/palette.dart';

class OtherDateCard extends StatelessWidget {
  const OtherDateCard({
    required this.labelTop,
    required this.labelBottom,
    required this.selected,
    required this.onTap,
  });

  final String labelTop;
  final String labelBottom;
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
            Text(
              labelTop,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white70 : AppColors.subtle,
              ),
            ),
            const SizedBox(height: 4),
            Text(labelBottom,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: fg)),
          ],
        ),
      ),
    );
  }
}
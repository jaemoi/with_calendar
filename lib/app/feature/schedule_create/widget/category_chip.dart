import 'package:flutter/material.dart';

import '../../../shared/theme/palette.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key,
    required this.label,
    required this.dot,
    required this.bg,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color dot;
  final Color bg;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border =
    selected ? Border.all(color: dot.withOpacity(0.6), width: 1) : null;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.chipText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
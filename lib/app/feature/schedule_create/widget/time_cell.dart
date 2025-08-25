import 'package:flutter/material.dart';

import '../../../shared/theme/palette.dart';

class TimeCell extends StatelessWidget {
  const TimeCell({
    required this.label,
    required this.value,
    required this.onTap,
    this.caption, // NEW: 보조 캡션
  });

  final String label;
  final String value;
  final String? caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  color: AppColors.subtle,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 6),
            Transform.translate(
              offset: const Offset(-5, 0),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.headline,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 4),
              Text(
                caption!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.subtle,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
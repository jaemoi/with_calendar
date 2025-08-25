import 'package:flutter/material.dart';

import '../../../shared/theme/palette.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.headline,
        ),
      );
}

import 'package:flutter/material.dart';
import 'palette.dart';

class AppText {

  // schedule_create_creen
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: AppColors.headline,
  );

  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.headline,
  );

  static const labelSubtle = TextStyle(
    color: AppColors.subtle,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const timeValue = TextStyle(
    color: AppColors.headline,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    // 숫자 좌측 여백 문제시, letterSpacing 제거/조정
    // fontFeatures: [FontFeature.tabularFigures()], // 폰트 지원 시 활성화
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.subtle,
    fontWeight: FontWeight.w600,
  );
}

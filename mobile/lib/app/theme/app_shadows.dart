import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static final subtle = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: .04),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];
  static final card = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: .06),
      offset: const Offset(0, 4),
      blurRadius: 16,
    ),
  ];
  static final elevated = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: .10),
      offset: const Offset(0, 10),
      blurRadius: 30,
    ),
  ];
  static final modal = [
    BoxShadow(
      color: AppColors.ink.withValues(alpha: .18),
      offset: const Offset(0, 20),
      blurRadius: 50,
    ),
  ];
}

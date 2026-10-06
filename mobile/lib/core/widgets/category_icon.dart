import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon(
    this.icon, {
    required this.foreground,
    required this.background,
    this.size = 40,
    this.iconSize,
    this.round = true,
    super.key,
  });
  final IconData icon;
  final Color foreground;
  final Color background;
  final double size;
  final double? iconSize;
  final bool round;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(
        round ? AppRadius.pill : AppRadius.control,
      ),
    ),
    child: Icon(
      icon,
      size: iconSize ?? (size == 40 ? 20 : 18),
      color: foreground,
    ),
  );
}

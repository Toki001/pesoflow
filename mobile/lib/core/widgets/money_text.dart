import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';
import '../formatting/money_formatter.dart';

class MoneyText extends StatelessWidget {
  const MoneyText(
    this.centavos, {
    this.decimals = true,
    this.signed = false,
    this.compact = false,
    this.style,
    super.key,
  });
  final int centavos;
  final bool decimals;
  final bool signed;
  final bool compact;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) => Text(
    compact
        ? MoneyFormatter.compact(centavos, signed: signed)
        : MoneyFormatter.php(centavos, decimals: decimals, signed: signed),
    style: style ?? AppTypography.numericMedium,
    softWrap: false,
  );
}

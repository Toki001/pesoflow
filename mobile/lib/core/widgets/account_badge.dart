import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';
import '../../features/accounts/domain/financial_account.dart';

/// Letter identifiers, not official logos or claims of provider connectivity.
class AccountBadge extends StatelessWidget {
  const AccountBadge({required this.account, this.size = 40, super.key});
  final FinancialAccount account;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (letters, color, icon) = _identity();
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size / 4),
        ),
        child: letters == null
            ? Icon(icon, size: size / 2, color: Colors.white)
            : Text(
                letters,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
                style: AppTypography.labelSmall.copyWith(color: Colors.white),
              ),
      ),
    );
  }

  (String?, Color, IconData?) _identity() {
    if (account.type == AccountType.cash) {
      return (null, const Color(0xFF374151), Icons.payments_outlined);
    }
    // Explicit metadata takes precedence over a user-defined account nickname.
    final name =
        (account.institution.trim().isEmpty
                ? account.name
                : account.institution)
            .trim();
    final normalized = name.toLowerCase();
    for (final (pattern, letters, color) in const [
      (r'^bdo\b', 'BDO', Color(0xFF003B70)),
      (r'^g\s?cash\b', 'G', Color(0xFF006BD6)),
      (r'^go\s?tyme\b', 'GT', Color(0xFF007B91)),
      (r'^(maya|paymaya)\b', 'M', Color(0xFF15803D)),
      (r'^bpi\b', 'BPI', Color(0xFF9B1C31)),
    ]) {
      if (RegExp(pattern).hasMatch(normalized)) return (letters, color, null);
    }
    final words = name.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    final initials = words.take(2).map((word) => word.characters.first).join();
    return (initials.toUpperCase(), const Color(0xFF475569), null);
  }
}

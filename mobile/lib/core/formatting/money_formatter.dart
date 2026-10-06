/// Money is represented in integer PHP centavos. No floating-point money math.
abstract final class MoneyFormatter {
  static String php(int centavos, {bool decimals = true, bool signed = false}) {
    final amount = centavos.abs();
    final pesos = (amount ~/ 100).toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    final fraction = decimals
        ? '.${(amount % 100).toString().padLeft(2, '0')}'
        : '';
    final sign = centavos < 0 ? '-' : (signed && centavos > 0 ? '+' : '');
    return '$sign₱$pesos$fraction';
  }

  /// Approved dashboard values are exact to a tenth of a thousand pesos.
  static String compact(int centavos, {bool signed = false}) {
    if (centavos.abs() < 100000) {
      return php(centavos, decimals: false, signed: signed);
    }
    final tenths = (centavos.abs() + 5000) ~/ 10000;
    final fraction = tenths % 10 == 0 ? '' : '.${tenths % 10}';
    final sign = centavos < 0 ? '-' : (signed && centavos > 0 ? '+' : '');
    return '$sign₱${tenths ~/ 10}${fraction}k';
  }
}

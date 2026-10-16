import 'ocr_document.dart';
import 'amount_in_words.dart';
import 'receipt_draft.dart';

class ParsedReceipt {
  ParsedReceipt({
    required this.rawText,
    required this.merchant,
    required this.date,
    required this.total,
    required this.items,
    required this.confidence,
    required this.warnings,
    this.subtotal,
    this.tax,
    this.discount,
    this.currency = 'PHP',
    this.paymentMethod,
  });
  final String rawText, merchant, currency;
  final String? paymentMethod;
  final DateTime? date;
  final int? total, subtotal, tax, discount;
  final List<ReceiptItem> items;
  final Map<String, int> confidence;
  final List<String> warnings;
}

/// Philippine receipt heuristics, not calibrated OCR accuracy. Never chooses
/// cash/change or the largest number as an unlabeled expense total.
abstract final class ReceiptParser {
  static const version = 3;
  static final paperTitle = RegExp(
    r'\b(?:S[E3][RK]V[I1]?CE\s*[I1]?N[VY]O[I1]?CE|SERVICE\s*INVOICE|SALES\s*INVOICE|OFFICIAL\s*RECEIPT)\b',
    caseSensitive: false,
  );
  static bool isPaperReceipt(String text) =>
      paperTitle.hasMatch(text) ||
      RegExp(r'AMOUNT\s+IN\s+WORDS', caseSensitive: false).hasMatch(text);

  static final _money = RegExp(
    r'(?<![\d.,])(?:\d{1,3}(?:,\d{3})+|\d+)\.\d{2}(?!\d)',
  );
  static final _notItem = RegExp(
    r'\b(TOTAL|SUBTOTAL|SUB TOTAL|VAT|VATABLE|EXEMPT|ZERO.?RATED|TAX|DISCOUNT|CHANGE|CASH|TENDERED|GCASH|MAYA|PAYMAYA|EM[-\s]?PAY|CARD|BALANCE|AMOUNT|TIN|TERMINAL|INVOICE|RECEIPT|DATE|TIME)\b',
    caseSensitive: false,
  );
  static int _amount(String s) {
    final parts = s.replaceAll(',', '').split('.');
    return int.parse(parts.first) * 100 +
        (parts.length == 1 ? 0 : int.parse(parts.last));
  }

  static ParsedReceipt parse(OcrDocument document) {
    if (document.text.length > 200000) {
      throw const FormatException('Receipt text too long.');
    }
    final lines = _lines(document);
    final warnings = <String>[];
    final confidence = <String, int>{'merchant': 0, 'date': 0, 'total': 0};
    String merchant = '';
    // Block reading order preserves the business header; row geometry can put
    // the separate top-right invoice title ahead of the actual merchant.
    for (final original in document.text.split(RegExp(r'[\r\n]+')).take(12)) {
      final label = paperTitle.firstMatch(original);
      final line =
          (label == null ? original : original.substring(0, label.start))
              .trim()
              .replaceFirst(
                RegExp(r',\s*ING\.?$', caseSensitive: false),
                ', INC.',
              );
      if (line.length <= 100 &&
          RegExp(r'[A-Za-z]{3}').hasMatch(line) &&
          !RegExp(
            r'\b(TIN|VAT|RECEIPT|INVOICE|TERMINAL|CASHIER|ADDRESS|TEL|PHONE|DATE|TIME|WELCOME|THANK|STREET|ROAD|CITY|BARANGAY|BRGY|AVE|AVENUE)\b|^\d',
            caseSensitive: false,
          ).hasMatch(line) &&
          !_money.hasMatch(line)) {
        merchant = line;
        confidence['merchant'] = 80;
        break;
      }
    }
    if (merchant.isEmpty) {
      warnings.add('Merchant was not found. Enter the store name.');
    }
    final candidates = <({int amount, int rank})>[];
    int? subtotal, tax, discount;
    String? payment;
    String currency = 'PHP';
    final items = <ReceiptItem>[];
    var itemTable = false;
    for (final line in lines) {
      final upper = line.toUpperCase();
      if (RegExp(
        r'\b(PARTICULARS|DESCRIPTION|ITEMS?)\b.*\b(AMOUNT|PRICE|QTY)\b|^PARTICULARS$',
      ).hasMatch(upper)) {
        itemTable = true;
      }
      if (RegExp(r'\b(TOTAL|AMOUNT IN WORDS|FORM OF PAYMENT)\b')
          .hasMatch(upper)) {
        itemTable = false;
      }

      if (RegExp(r'\b(USD|EUR|SGD|AUD|GBP)\b|\$|€|£').hasMatch(upper)) {
        currency = 'UNKNOWN';
      }
      for (final method in [
        'GCASH',
        'MAYA',
        'CARD',
        'BANK TRANSFER',
        'CHEQUE',
        'CASH',
      ]) {
        final label = method == 'MAYA' ? '(?:PAY)?MAYA' : method;
        if (RegExp('\\b$label\\b').hasMatch(upper)) {
          // Blank payment-option lists are not evidence of a selected method.
          final options = RegExp(r'\b(CASH|CARD|CHECK|CHEQUE|BANK|DEBIT|PMO)\b')
              .allMatches(upper)
              .length;
          if ((method != 'CASH' ||
                  RegExp(
                    r'\bCASH\s+(?:PHP\s*)?\d|PAID\s+(?:IN|BY|WITH)\s+CASH|[✓✔xX]\s*CASH',
                  ).hasMatch(upper)) &&
              options <= 1 &&
              !RegExp(r'\[\s*\]|□|☐').hasMatch(upper)) {
            if (method != 'CASH' || payment == null) payment = method;
          }
          break;
        }
      }
      var matches = _money.allMatches(line).toList();
      // Whole-peso handwritten values are valid, but only a labeled total or
      // a named item can supply one; dates, serials and tender remain excluded.
      if (matches.isEmpty && !RegExp(r'\d[-/]\d').hasMatch(line)) {
        final whole = RegExp(
          r'(?<![\d.,])\d{1,3}(?:,\d{3})*\s*$|(?<![\d.,])\d+\s*$',
        ).firstMatch(line);
        if (whole != null &&
            RegExp(r'[A-Za-z]').hasMatch(line.substring(0, whole.start))) {
          matches = [whole];
        }
      }
      if (matches.isEmpty) continue;
      final amount = _amount(matches.last.group(0)!);
      if (amount > 99999999999) continue;
      if (RegExp(r'\bSUB\s?TOTAL\b').hasMatch(upper)) {
        subtotal = amount;
        continue;
      }
      if (RegExp(r'\bDISCOUNT\b|\bDISC\b').hasMatch(upper)) {
        discount = amount;
        continue;
      }
      if (RegExp(r'\bVAT(?:\s+AMOUNT)?\b|\bTAX\b').hasMatch(upper) &&
          !RegExp(r'VATABLE|EXEMPT|ZERO.?RATED|SALES').hasMatch(upper)) {
        tax = amount;
        continue;
      }
      if (RegExp(
        r'\b(CASH|CHANGE|TENDERED|VATABLE|EXEMPT|ZERO.?RATED|SAVINGS)\b',
      ).hasMatch(upper)) {
        continue;
      }
      var rank = 0;
      if (RegExp(r'\bGRAND\s+TOTAL\b').hasMatch(upper)) {
        rank = 4;
      } else if (RegExp(r'\b(TOTAL\s+DUE|AMOUNT\s+DUE|NET\s+TOTAL)\b')
          .hasMatch(upper)) {
        rank = 3;
      } else if (RegExp(r'^\s*TOTAL\b').hasMatch(upper) &&
          !RegExp(r'ITEMS|QTY|QUANTITY|DISCOUNT').hasMatch(upper)) {
        rank = 2;
      }
      if (rank > 0 && amount > 0) {
        candidates.add((amount: amount, rank: rank));
        continue;
      }
      if (_notItem.hasMatch(line) || amount <= 0) continue;
      if (RegExp(
        r'^\s*(?:N[O0Eº°]?|SERIAL|REF(?:ERENCE)?)\.?\s*[:#]?\s*\d',
        caseSensitive: false,
      ).hasMatch(line)) {
        continue;
      }
      if (!_money.hasMatch(line) && !itemTable) continue;
      var name = line
          .substring(0, matches.first.start)
          .replaceAll(RegExp(r'(?:PHP|₱|\bP)\s*$', caseSensitive: false), '')
          .trim();
      var quantity = 1;
      var unit = amount;
      final qty = RegExp(r'^(\d{1,3})\s*[xX@]\s*').firstMatch(name);
      if (qty != null) {
        quantity = int.parse(qty[1]!);
        name = name.substring(qty.end).trim();
      }
      if (quantity > 1) {
        if (amount % quantity != 0) continue;
        unit = amount ~/ quantity;
      }
      // A trailing "2 x 91.00 182.00" keeps explicit quantity/price semantics.
      final trailingQty = RegExp(r'\s+(\d{1,3})\s*[xX@]\s*$').firstMatch(name);
      if (trailingQty != null && matches.length > 1) {
        quantity = int.parse(trailingQty[1]!);
        unit = _amount(matches.first.group(0)!);
        name = name.substring(0, trailingQty.start).trim();
        if (quantity * unit != amount) continue;
      }
      if (name.length < 2 ||
          !RegExp(r'[A-Za-z]').hasMatch(name) ||
          quantity < 1 ||
          name.length > 200) {
        continue;
      }
      items.add(
        ReceiptItem(
          id: 'line-${items.length}',
          name: name,
          quantity: quantity,
          unitPrice: unit,
          confidence: 70,
        ),
      );
    }
    candidates.sort((a, b) => b.rank.compareTo(a.rank));
    var total = candidates.firstOrNull?.amount;
    if (total == null) {
      for (var i = 0; i < lines.length; i++) {
        final label = RegExp(
          r'\bAMOUNT\s+IN\s+WORDS\s*:?\s*',
          caseSensitive: false,
        ).firstMatch(lines[i]);
        if (label == null) continue;
        final words = lines[i].substring(label.end).trim();
        total = receiptAmountInWords(
          words.isEmpty && i + 1 < lines.length ? lines[i + 1] : words,
        );
        if (total != null) {
          confidence['total'] = 55;
          warnings.add(
            'Total suggested from amount in words. Verify against the handwritten amount.',
          );
          break;
        }
      }
    }
    if (total == null) {
      warnings.add('Total was not found. Enter the final amount due.');
    } else {
      final ambiguous = candidates.map((c) => c.amount).toSet().length > 1;
      if (confidence['total'] == 0) confidence['total'] = ambiguous ? 55 : 90;
      if (ambiguous) {
        warnings.add('Several totals were found. Verify the final amount due.');
      }
    }
    final date = _date(lines.join('\n'), confidence, warnings);
    if (items.isEmpty) {
      warnings.add(
        'No item rows were recognized. You can save the verified total without items.',
      );
    }
    if (total != null &&
        items.isNotEmpty &&
        items.fold<int>(0, (s, i) => s + i.total) - (discount ?? 0) != total) {
      warnings.add(
        'Items and adjustments do not match the total. Check the receipt; the verified total controls the expense.',
      );
    }
    if (currency != 'PHP') {
      warnings.add(
        'A non-PHP currency was detected. Only PHP expenses are supported.',
      );
    }
    return ParsedReceipt(
      rawText: document.text,
      merchant: merchant,
      date: date,
      total: total,
      items: List.unmodifiable(items),
      confidence: Map.unmodifiable(confidence),
      warnings: List.unmodifiable(warnings),
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      currency: currency,
      paymentMethod: payment,
    );
  }

  static List<String> _lines(OcrDocument doc) {
    final source = doc.blocks.expand((b) => b.lines).toList();
    if (source.isEmpty || source.any((l) => l.box == null)) {
      return doc.text
          .split(RegExp(r'[\r\n]+'))
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
    }
    source.sort((a, b) => a.box!.top.compareTo(b.box!.top));
    final rows = <List<OcrLine>>[];
    for (final line in source) {
      if (rows.isEmpty ||
          (line.box!.top - rows.last.first.box!.top).abs() >
              rows.last.first.box!.height * .4) {
        rows.add([line]);
      } else {
        rows.last.add(line);
      }
    }
    return rows.map((r) {
      r.sort((a, b) => a.box!.left.compareTo(b.box!.left));
      return r.map((l) => l.text).join(' ');
    }).toList();
  }

  static DateTime? _date(
    String text,
    Map<String, int> confidence,
    List<String> warnings,
  ) {
    int? y, m, d;
    final iso = RegExp(r'\b(20\d{2})[-/](\d{1,2})[-/](\d{1,2})\b')
        .firstMatch(text);
    final numeric = RegExp(
      r'\b(\d{1,2})\s*[/-]\s*(\d{1,2})\s*[/-]\s*(20\d{2}|\d{2})\b',
    ).firstMatch(text);
    final named = RegExp(
      r'\b(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\s+(\d{1,2}),?\s+(20\d{2})\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (iso != null) {
      y = int.parse(iso[1]!);
      m = int.parse(iso[2]!);
      d = int.parse(iso[3]!);
      confidence['date'] = 90;
    } else if (numeric != null) {
      final a = int.parse(numeric[1]!), b = int.parse(numeric[2]!);
      y = int.parse(numeric[3]!);
      if (y < 100) {
        y += 2000;
        warnings.add(
          'Two-digit year interpreted as $y. Verify the receipt date.',
        );
      }
      m = a > 12 ? b : a;
      d = a > 12 ? a : b;
      confidence['date'] = a <= 12 && b <= 12 && a != b ? 45 : 85;
      if (confidence['date'] == 45) {
        warnings.add(
          'Ambiguous numeric date interpreted month/day. Verify the date.',
        );
      }
    } else if (named != null) {
      y = int.parse(named[3]!);
      d = int.parse(named[2]!);
      m =
          [
            'jan',
            'feb',
            'mar',
            'apr',
            'may',
            'jun',
            'jul',
            'aug',
            'sep',
            'oct',
            'nov',
            'dec',
          ].indexOf(named[1]!.substring(0, 3).toLowerCase()) +
          1;
      confidence['date'] = 90;
    }
    final time = RegExp(
      r'\b(\d{1,2}):(\d{2})(?::\d{2})?\s*(AM|PM)?\b',
      caseSensitive: false,
    ).firstMatch(text);
    var hour = time == null ? 0 : int.parse(time[1]!);
    final minute = time == null ? 0 : int.parse(time[2]!);
    if (time?[3] != null && hour >= 1 && hour <= 12) {
      hour = hour % 12 + (time![3]!.toUpperCase() == 'PM' ? 12 : 0);
    }
    if (y != null && m != null && d != null && hour < 24 && minute < 60) {
      final date = DateTime(y, m, d, hour, minute);
      if (date.year == y && date.month == m && date.day == d) {
        if (time == null) {
          warnings.add(
            'Time was not found; midnight is suggested. Verify if needed.',
          );
        }
        return date;
      }
    }
    confidence['date'] = 0;
    warnings.add(
      'Date was missing or invalid. Today is suggested only; verify before saving.',
    );
    return null;
  }
}

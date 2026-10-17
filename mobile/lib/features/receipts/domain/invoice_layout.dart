import 'ocr_document.dart';

/// Conservative associations between recognized text and invoice field geometry.
/// This never manufactures digits that the recognizer did not return.
class InvoiceLayout {
  InvoiceLayout(OcrDocument document)
    : cells = [
        for (final block in document.blocks)
          for (final line in block.lines)
            if (line.elements.isNotEmpty) ...[
              for (final element in line.elements)
                if (element.box != null)
                  OcrLine(element.text, box: element.box),
            ] else if (line.box != null)
              line,
      ];

  final List<OcrLine> cells;
  static final dateValue = RegExp(
    r'\b(?:20\d{2}\s*[-/]\s*\d{1,2}\s*[-/]\s*\d{1,2}|\d{1,2}\s*[-/]\s*\d{1,2}\s*[-/]\s*(?:20\d{2}|\d{2}))\b',
  );
  static bool dateLabel(String text) =>
      RegExp(r'^D[A4E][TL]E\s*:?$', caseSensitive: false).hasMatch(text.trim());
  static bool amountLabel(String text) => RegExp(
    r'^AM[O0](?:I?U|L)NT\s*:?$',
    caseSensitive: false,
  ).hasMatch(text.trim());
  bool get hasFormDate =>
      cells.any((cell) => dateLabel(cell.text)) &&
      cells.any(
        (cell) =>
            RegExp(r'^RECEIVED\b', caseSensitive: false).hasMatch(cell.text),
      );
  static bool _description(String text) => RegExp(
    r'^(PARTICULARS|DESCRIPTION|ITEMS?)$',
    caseSensitive: false,
  ).hasMatch(text.trim());
  static bool _sameRow(OcrBox a, OcrBox b) =>
      (a.top + a.height / 2 - b.top - b.height / 2).abs() <=
      (a.height > b.height ? a.height : b.height);

  String? get labeledDate {
    final matches = <String>{};
    for (final label in cells.where((cell) => dateLabel(cell.text))) {
      final box = label.box!;
      // On paper forms the date value is to the right of Date, with Received
      // From on the following row. That next label is an explicit lower bound.
      final nextRows =
          cells
              .where(
                (cell) =>
                    RegExp(
                      r'^RECEIVED\b',
                      caseSensitive: false,
                    ).hasMatch(cell.text) &&
                    cell.box!.top > box.top &&
                    (cell.box!.left - box.left).abs() < box.height * 4,
              )
              .map((cell) => cell.box!.top)
              .toList()
            ..sort();
      final row =
          cells
              .where(
                (cell) =>
                    cell.box!.left >= box.left + box.width &&
                    _sameRow(box, cell.box!) &&
                    (nextRows.isEmpty || cell.box!.top < nextRows.first),
              )
              .toList()
            ..sort((a, b) => a.box!.left.compareTo(b.box!.left));
      for (final match in dateValue.allMatches(
        row.map((c) => c.text).join(' '),
      )) {
        matches.add(match[0]!);
      }
    }
    return matches.length == 1 ? matches.single : null;
  }

  List<({String name, int amount})> get amountEntries {
    final tables = <List<({String name, int amount})>>[];
    for (final header in cells.where((cell) => amountLabel(cell.text))) {
      final box = header.box!;
      final descriptions = cells.where(
        (cell) =>
            _description(cell.text) &&
            cell.box!.left < box.left &&
            _sameRow(box, cell.box!),
      );
      if (descriptions.length != 1) continue;
      final description = descriptions.single.box!;
      final endings =
          cells
              .where(
                (cell) =>
                    RegExp(
                      r'^TOTAL\b',
                      caseSensitive: false,
                    ).hasMatch(cell.text) &&
                    cell.box!.top > box.top &&
                    cell.box!.left >= description.left,
              )
              .map((cell) => cell.box!.top)
              .toList()
            ..sort();
      if (endings.isEmpty) continue;
      final rows = cells
          .where(
            (cell) =>
                cell.box!.top > box.top + box.height &&
                cell.box!.top < endings.first,
          )
          .toList();
      final entries = <({String name, int amount})>[];
      final assignedNames = <OcrLine>{};
      var ambiguous = false;
      for (final cell in rows) {
        final number = RegExp(
          r'^(?:PHP\s*|₱\s*|P\s*)?(\d{1,3}(?:,\d{3})+|\d+)(?:\.(\d{2}))?$',
          caseSensitive: false,
        ).firstMatch(cell.text.trim());
        final center = cell.box!.left + cell.box!.width / 2;
        if (center < box.left - box.height * 2 ||
            center > box.left + box.width + box.height * 4) {
          continue;
        }
        if (number == null) {
          if (RegExp(r'\d').hasMatch(cell.text)) ambiguous = true;
          continue;
        }
        final amount = int.tryParse(number[1]!.replaceAll(',', ''));
        if (amount == null || amount <= 0 || amount > 999999999) {
          ambiguous = true;
          continue;
        }
        final names =
            rows
                .where(
                  (other) =>
                      other.box!.left >=
                          description.left - description.height &&
                      other.box!.left + other.box!.width <
                          box.left - box.height &&
                      _sameRow(other.box!, cell.box!) &&
                      RegExp(r'[A-Za-z]{2}').hasMatch(other.text) &&
                      !RegExp(
                        r'\b(TOTAL|TAX|VAT|DISCOUNT|CASH|CHANGE|INVOICE|SERIAL|REF)\b',
                        caseSensitive: false,
                      ).hasMatch(other.text),
                )
                .toList()
              ..sort((a, b) => a.box!.left.compareTo(b.box!.left));
        final name = names.map((cell) => cell.text).join(' ').trim();
        if (name.isEmpty || name.length > 200) {
          ambiguous = true;
          continue;
        }
        if (names.any(assignedNames.contains)) ambiguous = true;
        assignedNames.addAll(names);
        entries.add((
          name: name,
          amount: amount * 100 + int.parse(number[2] ?? '0'),
        ));
      }
      // A readable row description without a corresponding amount means this
      // is an incomplete table, not evidence of a single-item invoice.
      if (rows.any(
        (cell) =>
            cell.box!.left >= description.left - description.height &&
            cell.box!.left + cell.box!.width < box.left - box.height &&
            RegExp(r'[A-Za-z]{2}').hasMatch(cell.text) &&
            !assignedNames.contains(cell),
      )) {
        ambiguous = true;
      }
      if (!ambiguous && entries.isNotEmpty) tables.add(entries);
    }
    // Two amount tables (e.g. a tax breakdown and payments) need manual review.
    return tables.length == 1 ? tables.single : const [];
  }
}

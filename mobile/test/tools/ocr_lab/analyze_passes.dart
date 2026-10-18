import 'dart:convert';
import 'dart:io';

import 'package:pesoflow/features/receipts/domain/ocr_document.dart';
import 'package:pesoflow/features/receipts/domain/receipt_parser.dart';

OcrBox? box(Map<String, dynamic> cell) {
  final values = (cell['box'] as List?)?.cast<num>();
  return values == null
      ? null
      : OcrBox(
          values[0].toDouble(),
          values[1].toDouble(),
          values[2].toDouble(),
          values[3].toDouble(),
        );
}

// Prints only anonymous IDs, timings and match flags, never recognized text.
void main(List<String> args) {
  if (args.length != 2) {
    throw ArgumentError(
      'Usage: analyze_passes.dart passes.json expectations.json',
    );
  }
  final passes = jsonDecode(File(args[0]).readAsStringSync()) as List;
  final expected = jsonDecode(File(args[1]).readAsStringSync()) as Map;
  final result = <Map<String, Object?>>[];
  for (final pass in passes.cast<Map<String, dynamic>>()) {
    if (pass['error'] != null) {
      result.add({
        'case': pass['case'],
        'stage': pass['stage'],
        'failed': true,
      });
      continue;
    }
    final document = OcrDocument(pass['text'] as String, [
      for (final block in (pass['blocks'] as List).cast<Map<String, dynamic>>())
        OcrBlock([
          for (final line
              in (block['lines'] as List).cast<Map<String, dynamic>>())
            OcrLine(
              line['text'] as String,
              box: box(line),
              elements: [
                for (final element
                    in (line['elements'] as List).cast<Map<String, dynamic>>())
                  OcrElement(element['text'] as String, box: box(element)),
              ],
            ),
        ]),
    ]);
    final parsed = ReceiptParser.parse(document);
    final amountToken = RegExp.escape(expected['amount_token'] as String);
    result.add({
      'case': pass['case'],
      'stage': pass['stage'],
      'recognition_ms': pass['recognition_ms'],
      'amount_token_found': RegExp('(?<![0-9])$amountToken(?![0-9])')
          .hasMatch(document.text),
      'date_token_found': document.text
          .replaceAll(RegExp(r'\s+'), '')
          .contains(expected['date_token'] as String),
      'parsed_amount_matches': parsed.total == expected['amount_minor'],
      'parsed_date_matches':
          parsed.date == DateTime.parse(expected['date'] as String),
      'has_parsed_amount': parsed.total != null,
      'has_parsed_date': parsed.date != null,
    });
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(result));
}

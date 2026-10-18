// Local diagnostic tooling only. No private inputs belong in the repository.
import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as image;
import 'package:pesoflow/features/receipts/data/prepare_receipt_image.dart';

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    throw ArgumentError('Usage: prepare_inputs.dart manifest.json output-dir');
  }
  final cases = jsonDecode(await File(args[0]).readAsString()) as List;
  final output = await Directory(args[1]).create(recursive: true);
  var repository = File.fromUri(Platform.script).parent;
  for (var i = 0; i < 4; i++) {
    repository = repository.parent;
  }
  final destination = output.resolveSymbolicLinksSync();
  final root = repository.resolveSymbolicLinksSync();
  if (destination == root ||
      destination.startsWith('$root${Platform.pathSeparator}')) {
    throw ArgumentError('Private OCR inputs must stay outside the repository.');
  }
  if (!await output.list().isEmpty) {
    throw ArgumentError('Use an empty output directory to avoid stale inputs.');
  }
  final inputs = <Map<String, String>>[];
  for (final entry in cases.cast<Map<String, dynamic>>()) {
    final id = entry['id'] as String;
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(id)) {
      throw ArgumentError('Case IDs must be anonymous lowercase identifiers.');
    }
    var bytes = await File(entry['path'] as String).readAsBytes();
    if (entry['crop'] case final List crop) {
      final source = image.bakeOrientation(image.decodeImage(bytes)!);
      final values = crop.cast<num>().map((v) => v.toDouble()).toList();
      if (values.length != 4 ||
          values.any((v) => !v.isFinite || v < 0 || v > 1) ||
          values[2] == 0 ||
          values[3] == 0 ||
          values[0] + values[2] > 1 ||
          values[1] + values[3] > 1) {
        throw ArgumentError('Crop must be normalized x/y/width/height.');
      }
      bytes = image.encodeJpg(
        image.copyCrop(
          source,
          x: (source.width * values[0]).round(),
          y: (source.height * values[1]).round(),
          width: (source.width * values[2]).round(),
          height: (source.height * values[3]).round(),
        ),
        quality: 100,
      );
    }
    final prepared = await prepareReceiptImage(bytes);
    for (final stage in ['original', 'contrast', 'shadow']) {
      final name = '${id}_$stage.${stage == 'original' ? 'jpg' : 'png'}';
      final data = stage == 'original'
          ? prepared
          : await enhanceReceiptForOcr(
              prepared,
              correctShadows: stage == 'shadow',
            );
      await File('${output.path}/$name').writeAsBytes(data);
      inputs.add({'case': id, 'stage': stage, 'file': name});
    }
  }
  await File('${output.path}/inputs.json').writeAsString(jsonEncode(inputs));
  stdout.writeln('Prepared ${inputs.length} local diagnostic inputs.');
}

# Public handwritten receipt evaluation images

Test-only photographs, retrieved from Wikimedia Commons on 19 October 2026.
These are not Flutter assets, financial fixtures, training examples or evidence
that PesoFlow supports their currencies. Originals are unmodified. `manifest.json`
records SHA-256 hashes, attribution, manually selected normalized x/y/width/height
field crops and visual transcription targets, fixed before model inference.

- **abbott.jpg**: [Abbott and Holder receipt, 21 August 1969](https://commons.wikimedia.org/wiki/File:Abbott_and_Holder_receipt_-_21_August_1969.jpg),
  Eric Holder. Commons marks this public domain (PD-ineligible). The handwritten
  amount is pre-decimal pounds/shillings/pence, **not decimal £36.50 or PHP**.
- **kuitansi.jpg**: [Bukti Kuitansi Uang makan 2–7 April 2018 Ahmad](https://commons.wikimedia.org/wiki/File:Bukti_Kuitansi_Uang_makan_2-7_April_2018_Ahmad.jpg),
  Goyat1, [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
  The source describes an example receipt. Its handwritten date is read as
  09-04-2018 (day-month-year), not the photo metadata's April 10 date.
  The amount uses Indonesian grouping and a trailing currency notation.
  Cropped/contrast/shadow derivatives of this image retain CC BY-SA 4.0;
  identify those transformations when sharing them. No endorsement is implied.

Only these public photographs are licensed as stated above; this notice does not
relicense application code. Keep attribution and source/license links with any
redistributed images. No private user receipts belong in this directory.

## Reproduce the crop experiment

From repository root, with Python 3 and the configured Dart SDK:

```sh
python3 - <<'PY'
import hashlib, json
from pathlib import Path
root = Path('mobile/test/fixtures/public_receipts').resolve()
samples = json.loads((root / 'manifest.json').read_text())
cases = []
for sample in samples:
    source = root / sample['file']
    assert hashlib.sha256(source.read_bytes()).hexdigest() == sample['sha256']
    for field in sample['fields']:
        cases.append(dict(id=field['id'], path=str(source), crop=field['crop']))
Path('/tmp/public-receipt-crops.json').write_text(json.dumps(cases))
PY
cd mobile
dart --packages=.dart_tool/package_config.json test/tools/ocr_lab/prepare_inputs.dart /tmp/public-receipt-crops.json /tmp/public-receipt-variants
```

Use a new empty output directory. This existing tool rounds normalized x/y/width/
height to pixels, encodes the crop at JPEG quality 100, then produces the same
original/contrast/shadow variants used by the production preprocessing functions.
It does not draw, remove ruling lines, substitute digits or change source photos.

Convert `inputs.json` into the existing offline runners' cases format:

```sh
# Run from repository root after the preparation above.
python3 - <<'PY'
import json
from pathlib import Path
samples = json.loads(Path('mobile/test/fixtures/public_receipts/manifest.json').read_text())
expected = {f['id']: f['expected'] for s in samples for f in s['fields']}
root = Path('/tmp/public-receipt-variants')
cases = [dict(id=i['case'] + '_' + i['stage'], path=str(root / i['file']),
              expected=expected[i['case']])
         for i in json.loads((root / 'inputs.json').read_text())]
Path('/tmp/public-receipt-model-cases.json').write_text(json.dumps(cases))
PY
```

Pass that manifest to `evaluate_trocr.py` or `evaluate_paddle_native.py` with a
local model directory, following [the tool instructions](../../tools/ocr_lab/README.md).
Use the pinned revisions in the [public evaluation report](../../../../docs/verification/receipt-ocr-public-evaluation-20261019.md).
Compare transcriptions with whitespace removed only. Do not apply the PHP field
scorer to historical British money or Indonesian separators. Four fields from two
receipts and three variants each are **two independent receipt samples**, not
12 independent receipts. Manual crops bypass field detection, so results cannot
establish full-image or physical-device accuracy.

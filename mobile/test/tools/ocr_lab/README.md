# Local receipt recognition lab

Test-only tools for separating native recognition failures from parser/selection
failures. They do not alter PesoFlow, its application ID, encrypted data or UI.
Keep all images, manifests with private paths/expected values, predictions, model
weights, generated Android projects and APKs outside this repository. Use an
isolated temporary directory with `umask 077`; delete private artifacts afterward.
No private receipt fixtures are included. Do not send receipt data to model hubs.

## ML Kit per-pass probe

From `mobile/`, with its current dependencies resolved:

```
dart --packages=.dart_tool/package_config.json test/tools/ocr_lab/prepare_inputs.dart /tmp/cases.json /tmp/ocr-inputs
python3 test/tools/ocr_lab/create_probe.py /tmp/ocr-probe /tmp/ocr-inputs "$ANDROID_SDK_ROOT"
android/gradlew -p /tmp/ocr-probe --no-daemon assembleDebug
```

The local input manifest is an array of objects with anonymous `id`, image `path`
and optional normalized `crop: [x, y, width, height]`. Crop coordinates are manual
experimental annotations, **not** a production region detector. The generator
uses PesoFlow's actual preparation/contrast/shadow functions. All three variants
are evaluated, even when production would stop early. The output directory must
be empty and outside the repository.

The generated app has package **`dev.pesoflow.ocrprobe`**, uses the same bundled
`com.google.mlkit:text-recognition:16.0.1` as the Flutter adapter, and explicitly
removes Internet/network-state permission. Verify the resulting APK with
`aapt dump permissions` before installing. It has no financial-storage dependencies,
gallery permissions or backend. The prepared inputs are private test APK assets.
Use a connected, authorized device; if this package already exists, stop and
inspect it rather than overwriting an unknown installation.

```
adb install /tmp/ocr-probe/build/outputs/apk/debug/PesoFlowOcrProbe-debug.apk
adb shell am start -W -n dev.pesoflow.ocrprobe/.OcrProbeActivity
```

Wait for “Diagnostic complete.” Then read its private output locally:

```
adb exec-out run-as dev.pesoflow.ocrprobe cat files/passes.json > /tmp/passes.json
dart --packages=.dart_tool/package_config.json test/tools/ocr_lab/analyze_passes.dart /tmp/passes.json /tmp/expectations.json
```

The expectations file has `amount_minor` (integer), `date` (ISO calendar date),
`amount_token` and `date_token` fields. It is never passed to the recognizer.
The analyzer uses the current production ReceiptParser and prints anonymous
case IDs, timings and match flags only. Target-token presence is a diagnostic,
not proof of correct field association. Date-token matching ignores whitespace;
alternate valid date formats are assessed separately by the parser-match flag.

The Java probe uses upright decoded bitmaps, equivalent in orientation to the
prepared file inputs; it exports native line/word boxes without selecting a pass.
Recognition timings exclude preparation, I/O setup and user navigation. Native
confidence is not used by the parser and is not exported. This is a diagnostic
comparison, not a production end-to-end speed benchmark or handwriting corpus.

After exporting results, remove **only this newly created test app**, never the
installed PesoFlow package. Remove its generated project/APK and private inputs
and output after documenting sanitized results. Leave the user's originals intact.

## Offline handwriting model experiment

Create a separate Python 3.12 environment using `requirements.txt`. Download
official model/tokenizer files at an immutable revision **before** loading private
inputs. Inference uses local paths, `local_files_only=True`, offline environment
flags and disabled Hugging Face telemetry. No remote code is enabled.

```
python evaluate_trocr.py /tmp/pinned-model /tmp/line-cases.json /tmp/private-predictions.json
```

`line-cases.json` contains anonymous `id`, local `path` and `expected` strings.
The expected string is used only after inference for exact-match evaluation, never
as a prompt, decoder prefix or character constraint. Whitespace alone is normalized.
Private predictions go to the specified file; stdout contains match flags/timing.
Run against independently annotated single-line crops, varied known controls and
blank input. Do not treat a plausible number, one correct crop or nonempty output
as acceptable financial accuracy. Manually selected crops do not establish an
automatic full-receipt solution. Desktop latency is not Android latency.

Primary references:

- [ML Kit Digital Ink](https://developers.google.com/ml-kit/vision/digital-ink-recognition)
  takes touch/pen strokes, not receipt photographs.
- [TrOCR-small](https://huggingface.co/microsoft/trocr-small-handwritten) and
  [TrOCR-base](https://huggingface.co/microsoft/trocr-base-handwritten) are
  single-text-line models; weights are not included or shipped in PesoFlow.

Review licensing, mobile runtime/size, false positives, confidence calibration,
image-region association and a broader consented corpus before proposing a
production model change. Findings are recorded in `docs/verification/` at repo root.

## Field-level scoring and lightweight OCR candidates

Use a separate temporary Python 3.12 environment with `requirements-ppocr.txt`.
These dependencies are desktop experiment tools, not Flutter dependencies.
Download official model files at a recorded immutable revision separately from
inference. Do not execute model-repository Python files. The two runners load
only local configuration/weights and write private results outside this repo:

```
python evaluate_ppocr.py /tmp/official-safetensors-model /tmp/cases.json /tmp/results.json
python evaluate_paddle_native.py /tmp/official-paddle-model /tmp/cases.json /tmp/native-results.json
python score_fields.py /tmp/cases.json /tmp/results.json > /tmp/summary.json
```

`evaluate_ppocr.py` uses the official Transformers processor/model classes;
`evaluate_paddle_native.py` uses Paddle's CPU inference API with the model's
BGR image layout, proportional height-48 resize, normalized padding and CTC
dictionary. It checks supported configuration and output/dictionary size.
Neither runner uses expected values during recognition. Prediction files are
private, newly created with owner-only access. Empty-output nonfinite scores
become JSON null. Raw character scores are **not** calibrated field confidence.

Each local case includes:

```
{
  "id": "sample_a_amount",
  "path": "/tmp/private-line.png",
  "group": "private_amount",
  "field": "amount",
  "expected": 42500,
  "transcription": "425",
  "date_order": "mdy"
}
```

This example is invented. Amount expectations are integer minor units; date
expectations are ISO calendar strings. Set `expected: null` for negative controls.
Date order is an explicit corpus annotation, not inferred from the expected
answer. Two-digit years use the documented 2000–2099 corpus convention. The
scorer accepts only entire unambiguous amounts/dates; it does not strip surrounding
labels, turn O into 0, pick one of several numbers, or drop suspicious punctuation.

Outcomes distinguish `correct`, `wrong_value`, `abstained`, `false_positive` and
`rejected_negative`. Here, abstention/rejection means **the test scorer** could
not accept the output, not that the OCR model or app declined to suggest anything.
`nonempty` records gibberish on blank inputs separately. Exact transcription and
field equivalence are separate metrics. Groups prevent synthetic control results
from obscuring private-receipt failures. Duplicate, missing and extra prediction
IDs fail evaluation rather than silently changing denominators. No raw text or
expected value is printed by the scorer; keep IDs/groups anonymous.

Generate reproducible sanity controls outside the repo with a local font:

```
python create_field_controls.py /path/to/Arial.ttf /tmp/field-controls
python -m unittest discover -s mobile/test/tools/ocr_lab -p 'test_*.py' -v
```

The unittest command runs from the repository root; other examples run from this
directory. The generator creates 28 cases: 12 printed amounts, 8 printed dates,
two blanks, one empty grid, three nonfield labels and two invalid dates. Printed
positives use 40/80px text on identical 880×130 canvases, so the smaller text tests
extra surrounding whitespace. They are **not handwritten receipts**. Nonfield
and invalid-date rejection exercises the scorer as well as recognition, and must
not be reported as model-only safety. Do not manufacture handwritten digits or
claim a synthetic control suite establishes handwriting accuracy.

Official references: [multilingual model](https://huggingface.co/PaddlePaddle/PP-OCRv5_mobile_rec_safetensors),
[English model](https://huggingface.co/PaddlePaddle/en_PP-OCRv5_mobile_rec),
[native preprocessing](https://github.com/PaddlePaddle/PaddleOCR/blob/v3.3.2/tools/infer/predict_rec.py),
and [CTC decoding](https://github.com/PaddlePaddle/PaddleOCR/blob/v3.3.2/ppocr/postprocess/rec_postprocess.py).

## Pixel-preserving preprocessing benchmark

From `mobile/`:

```
dart compile exe --packages=.dart_tool/package_config.json test/tools/ocr_lab/benchmark_luminance.dart -o /tmp/pf-luminance-benchmark
/tmp/pf-luminance-benchmark
```

The benchmark compares the former image-library resize/illumination/normalization
steps with the optimized luminance operations on deterministic 3000×2250 synthetic
pixels. All output pixels must match before timing is reported. It performs five
runs; use the final four to exclude the first run and run without competing builds
or benchmarks. Times cover those operations only, not image decoding, ML Kit,
storage or navigation. Desktop AOT timing does not establish Android scan latency.
No private image, expected receipt field or financial writer is involved.

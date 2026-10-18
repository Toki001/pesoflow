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

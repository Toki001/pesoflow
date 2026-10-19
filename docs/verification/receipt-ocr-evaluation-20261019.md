# Receipt recognition evaluation — 19 October 2026

## Outcome

Handwritten amount/date acceptance remains open. The native per-pass experiment
found no correct target fields in any of 15 inputs. An offline TrOCR-base
experiment recovered the correct amount digits in one of six amount variants,
with extra punctuation, but no correct date in six date variants. Both evaluated
handwriting models generated nonempty output for a blank control. No model was
promoted into PesoFlow and no production dependency or recognition rule changed.

These are diagnostic observations on one owner-authorized invoice, not a diverse
accuracy benchmark. Repeated crops of one field are not independent receipts.
Expected values were used only for evaluation, never decoder prompts, character
constraints or production defaults. Private images, predictions and expected
financial values are excluded from this report and repository.

## Native ML Kit: every pass collected

Tooling milestone `6df3c94` adds [isolated diagnostic tools](../../mobile/test/tools/ocr_lab/README.md).
A temporary Android app used bundled `com.google.mlkit:text-recognition:16.0.1`,
matching the production Flutter adapter. Its APK was inspected and had no Internet
or gallery/storage permissions. It used embedded private input assets and exported
text and geometry through its app-private output, not logcat.

The authorized original was 4080×3072. Inputs comprised the full image, manually
annotated amount/date regions, and tighter amount/date line crops. Each used
PesoFlow's original, contrast and shadow-corrected preparation variants. Every
pass was evaluated, bypassing production early stopping and pass selection.

| Input | Variants | Correct amount/date tokens | Correct parsed amount/date | Native recognition time per variant |
| --- | --- | --- | --- | --- |
| Full receipt | 3 | None | None | 1,135–2,025 ms |
| Amount region | 3 | None | None | 133–262 ms |
| Date region | 3 | None | None | 102–138 ms |
| Amount line | 3 | None | None | 61–230 ms |
| Date line | 3 | None | None | 69–128 ms |

The analyzer applied the actual production ReceiptParser to native line/word
geometry. Its match checks also passed an invented positive-control case. Timing
excludes image preparation, setup and navigation; it cannot be compared directly
with the previous 33.9-second app scan. Region crops do not represent full receipts.

For these inputs, selection is not hiding a successful recognition. This narrows
the observed failure to recognition rather than establishing a universal ML Kit
limitation. It does not justify another automatic crop/contrast pass by itself.

## Offline handwriting models

Public model files were downloaded separately before inference on the Mac. The
evaluation used local files only, offline flags, disabled telemetry, no remote
code, CPU inference, four threads, seed 0, greedy decoding and at most 48 new
tokens. Receipt data was not uploaded. No model weights are bundled in the app.

| Model | Immutable revision | Exact receipt-field strings | Correct target amount token | Correct target date token | Exact synthetic controls |
| --- | --- | --- | --- | --- | --- |
| microsoft/trocr-small-handwritten | `b4648cfa171985a6745f37ddd637e98c0da958ac` | 0/12 | 0/6 | 0/6 | 0/4 |
| microsoft/trocr-base-handwritten | `eaacaf452b06415df8f10bb6fad3a4c11e609406` | 0/12 | 1/6 | 0/6 | 2/4 |

The 12 real inputs were the four field crops × three preparation variants. Four
additional controls were synthetic printed integer, decimal, date and blank
images. They are pipeline sanity checks, not a handwriting corpus. The models
target single text lines; broader regions deliberately test tolerance for nearby
form labels. The date line also retains some neighboring printed text.

Exact comparison ignores whitespace only. Consequently, an exact failure does
not always mean the digits are wrong. In TrOCR-base's shadow-corrected amount
region, the sole numeric token matched the expected amount; the output contained
two extra punctuation characters and no letters. This is a partial recognition
success, not a verified total association or automatic full-receipt solution.

TrOCR-base transcribed the synthetic decimal and date exactly, but changed the
integer control and generated digits from blank input. TrOCR-small added or
changed characters on all controls, including extra punctuation after the correct
synthetic date; it also generated text from blank input. Neither model produced
the correct real receipt date. Plausible output alone must not establish a field.

Small-model inference took 54–91 ms on real crops. Base-model inference took
223–415 ms after a 1,554 ms first inference. These single desktop observations
exclude loading/preprocessing and say nothing about Android latency. Downloaded
weight files were approximately 235 MiB and 1.2 GiB respectively; mobile model
size, runtime, licensing and confidence calibration need separate assessment.

Primary model references: [TrOCR-small model card](https://huggingface.co/microsoft/trocr-small-handwritten)
and [TrOCR-base model card](https://huggingface.co/microsoft/trocr-base-handwritten).
ML Kit [Digital Ink](https://developers.google.com/ml-kit/vision/digital-ink-recognition)
accepts pen/touch strokes and is not a replacement for photo recognition.

## Verification and data safety

- Dart formatting: PASS, 167 files, unchanged.
- Flutter analysis: PASS, no issues.
- Full Flutter suite: PASS, 252 tests including 31 existing golden comparisons.
- Python tooling compilation and synthetic analyzer positive control: PASS.
- Standalone Android diagnostic APK: build and permission inspection PASS.
- Physical Redmi: all 15 native inputs completed; private results exported locally.
- Diagnostic app removed after testing; PesoFlow reopened on Home with the same
  two accounts, total and October spending as the preceding baseline.
- No financial command, production reinstall, key/schema change or gallery edit
  was performed. Original receipt and saved evidence remain untouched.
- Temporary local receipt copies/crops, private manifests/expectations, native
  output, model predictions and the generated diagnostic project/APK were removed
  after recording these sanitized findings. Public model caches contain no receipt
  data and are separate from the repository.

Production APK/AAB/iOS and backend builds were not rerun for this test-tool-only
change; the preceding successful production builds remain the latest build
checkpoint. Physical iPhone testing remains unavailable. This evaluation does
not add 15 or 32 passing app tests: it records measured recognition failures and
partial success separately from the automated regression suite.

## Next implementation gate

Evaluate a numeric-handwriting recognizer using a broader, consented set of
independently labeled receipt fields before choosing a mobile integration. Include
blank/blurred fields, printed serial numbers, printer dates, multiple table rows,
decimal amounts and varied handwriting. Keep exact transcription, numeric/date
equivalence, field association and false-positive rates separate. Do not tune
against this invoice's known answer or treat a model's plausible number as a
verified financial fact. Automatic region detection and mobile performance also
need evidence before adding another production recognition stage.

Until then, retain explicit review/correction for missing or uncertain values.
The existing pre-scan rotate/crop controls remain available; this checkpoint does
not claim the user's handwritten receipt now scans correctly.

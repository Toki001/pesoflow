# Lightweight receipt-field OCR evaluation — 19 October 2026

## Decision

Do not integrate either tested PP-OCR candidate into PesoFlow on this evidence.
Neither recovered the owner's handwritten amount/date correctly. The English
model produced one wrong but syntactically valid amount, with a raw character
score of approximately 0.946. That score is not a calibrated probability of
financial correctness. No app recognition rule, UI, dependency or stored record
changed. Handwritten receipt acceptance remains open.

The owner confirmed that only the previously authorized invoice is available.
This experiment therefore uses one real receipt, repeated crop variants and
explicitly synthetic controls. It cannot establish accuracy across handwriting,
merchants or receipt layouts. Do not tune a production rule to this receipt's
known answer. Previous [ML Kit/TrOCR results](receipt-ocr-evaluation-20261019.md)
remain separate; they used a smaller control suite and different scoring.

## Reproducible setup

Tooling milestone `5b4cec6` adds offline runners, generated controls and a strict
field scorer under [the receipt lab](../../mobile/test/tools/ocr_lab/README.md).
Official public weights were downloaded before local inference. No receipt data
was uploaded, and no model-repository Python code was executed.

| Candidate | Pinned revision | Weights | Runtime |
| --- | --- | --- | --- |
| PaddlePaddle/PP-OCRv5_mobile_rec_safetensors | `485a9a9781535ad477de3b1eea5f96a2e7300d8d` | 31,152,668 bytes | Transformers 5.5.0 / Torch 2.8.0 |
| PaddlePaddle/en_PP-OCRv5_mobile_rec | `267c36e24c331595590fe7bd72bde2436fd286f2` | 7,772,315 bytes | PaddlePaddle 3.2.2 / OpenCV 4.11.0.86 |

Both ran on the Mac CPU with four configured threads. The multilingual runner
uses official local Transformers image processing and CTC decoding; the native
English runner follows model-configured BGR, height-48 proportional resize,
normalized padding and CTC dictionary conventions. Native output dimensions are
checked against the dictionary. Different models/runtimes mean this is not an
isolated architecture or speed comparison. Neither is integrated or timed on Android.

The official [multilingual model card](https://huggingface.co/PaddlePaddle/PP-OCRv5_mobile_rec_safetensors)
and [English model card](https://huggingface.co/PaddlePaddle/en_PP-OCRv5_mobile_rec)
describe text-line recognition including handwriting. These published capabilities
motivated testing; they do not establish accuracy on this invoice.

## Inputs and scoring

Each candidate processed 40 cases:

- 12 private real-image variants: amount/date regions and tighter lines, each
  using the same original/contrast/shadow preparation as the previous experiment.
  Crop locations were fixed before this comparison. Expectations never entered
  inference. The full-resolution original was copied read-only from the same
  explicitly authorized gallery file; unrelated photos were not inspected.
- 20 synthetic positive controls: six amounts and four dates at two font sizes.
- Eight synthetic negative controls: two blanks, an empty grid, three nonfield
  labels and two invalid calendar dates.

Controls use Arial 40/80px on 880×130 white canvases. The smaller font leaves more
surrounding whitespace; height-48 recognition reduces its visible text size.
These controls are intentionally printed and are not a handwriting dataset.
Private region crops include surrounding form content and are not all clean text
lines. Neither model performs automatic receipt-region detection in this test.

The test scorer accepts a whole amount with optional PHP/peso prefix and standard
grouping/decimal syntax, or a whole valid calendar date. It preserves integer
minor units, requires an explicit local date order, and rejects guessed digits,
multiple numbers, extra labels and suspicious punctuation. Two-digit years use
the explicitly documented 2000–2099 corpus convention. This scoring logic is
test-only and is not added to the app parser.

Exact transcription, accepted correct value, wrong value and unparsable output
are distinct. A negative case with an accepted value is a false positive. Nonempty
output on blanks is tracked even when it is not parseable. Missing/duplicate/extra
predictions fail evaluation. Raw predictions, expected financial values and paths
are not included in the sanitized report.

## Observations

| Cases | Multilingual candidate | English candidate |
| --- | --- | --- |
| Private amount, 6 | 0 correct; 6 rejected by scorer | 0 correct; **1 wrong value**; 5 rejected by scorer |
| Private date, 6 | 0 correct; 6 rejected by scorer | 0 correct; 6 rejected by scorer |
| Printed amount, 12 | 6 correct; 6 rejected by scorer | 7 correct; 5 rejected by scorer |
| Printed date, 8 | 4 correct; 4 rejected by scorer | 4 correct; 4 rejected by scorer |
| Blank images, 2 | Empty text on both | Nonempty, nonnumeric text on both |
| Empty grid, 1 | Empty text | Empty text |
| Nonfield labels, 3 | All rejected by scorer; 1 exact transcription | All rejected by scorer; 2 exact transcriptions |
| Invalid dates, 2 | Both rejected by scorer; 0 exact transcriptions | Both rejected by scorer; 1 exact transcription |

There were no accepted values on the eight negative controls, but that is a
property of the **model plus strict test scorer**, not model-only safety or
production-parser behavior. In particular, the English model did produce text
from blanks. Neither model has demonstrated a safe abstention policy.

The wrong real amount came from the English model's original tight amount crop.
Its approximately 0.946 raw score demonstrates why thresholds must be calibrated
on independent samples, not chosen to accept plausible numbers from one receipt.
Do not repair letter/digit confusion by replacing characters until the known
answer appears. Exact matching alone also understates usable formatting variants;
the scorer tests exact and semantic equivalence separately.

Final multilingual forward-pass observations were 179–198 ms; native English
observations were 54–70 ms. These exclude model loading, preparation and navigation.
They are single desktop runs, not Android latency or end-to-end app benchmarks.
The multilingual run was repeated after normalizing nonfinite empty-output scores
to JSON null; all 40 transcriptions were unchanged and strict JSON validation passed.

## Verification and scope

- Python scoring regressions: **8 PASS**, including decimal preservation,
  ambiguous/invalid dates, wrong values, blank false positives and missing results.
- Black 26.1.0 formatting: PASS for all five new Python files.
- Python compilation and `git diff --check`: PASS.
- Dart formatting: PASS, 167 files unchanged; Flutter analysis: PASS.
- Full Flutter suite: **252 PASS**, including the existing 31 golden comparisons.
- Both offline candidates completed all 40 cases. These observations are not
  80 additional passing app tests and do not satisfy handwritten-field acceptance.

No production build was needed or rerun for test-only Python tooling; prior
APK/AAB/unsigned iOS build results remain the latest production build checkpoint.
Backend and physical iPhone testing were not performed. On Android, only device
presence and a read-only copy of the previously authorized file were used; no app
installation, UI operation, financial save, gallery edit or baseline remeasurement
was performed. Original gallery data and stored receipt evidence were untouched.
After recording the sanitized findings, temporary local receipt copies/crops,
private case manifests and all candidate prediction files were removed. Generated
control images were also removed. Public weights and temporary Python dependencies
remain separate from the repository and contain no private receipt inputs.

## Remaining limitation and next step

The owner has no additional handwritten receipt samples available. A diverse,
consented field corpus and independent holdout examples remain prerequisites for
claiming improved handwriting accuracy or selecting a replacement recognizer.
The new evaluation can score those examples without changing production logic.
Until representative evidence exists, retain the current on-device pipeline and
explicit correction. This checkpoint does not make the Skyline receipt scan
correctly and does not justify shipping a larger model or guessing missing values.

# Public handwritten receipt evaluation — 19 October 2026

At the owner's request, two public handwritten receipt photos were located,
visually inspected and evaluated locally. The original photos, source attribution,
licenses, SHA-256 hashes, crop coordinates, transcription targets and all 24 model
outputs are retained in [test-only fixtures](../../mobile/test/fixtures/public_receipts/README.md).
No personal receipt was uploaded. No model or image was added to runtime assets.

## Samples and method

- [Abbott & Holder](https://commons.wikimedia.org/wiki/File:Abbott_and_Holder_receipt_-_21_August_1969.jpg):
  Eric Holder; Commons public-domain designation. Handwritten historical money and
  date on a printed letterhead.
- [Indonesian example receipt](https://commons.wikimedia.org/wiki/File:Bukti_Kuitansi_Uang_makan_2-7_April_2018_Ahmad.jpg):
  Goyat1; CC BY-SA 4.0. Handwriting crosses ruling and signature strokes.

Four field crops were selected visually before inference. Each passed through
existing original/contrast/shadow preparation, giving 12 inputs per candidate.
This is two independent receipts, not 12. Crops bypass detection and do not measure
full-image OCR. Targets are human visual annotations; Indonesian date strokes are
partly overlapped, and historical-money punctuation is not standardized. No model
was trained or tuned using them. The source caption independently supports the
Abbott date. Photo metadata is not used as a transaction date.

Models use the existing offline runners and previously downloaded pinned weights:

| Candidate | Repository | Revision |
| --- | --- | --- |
| TrOCR-base handwritten | microsoft/trocr-base-handwritten | `eaacaf452b06415df8f10bb6fad3a4c11e609406` |
| English PP-OCRv5 mobile | PaddlePaddle/en_PP-OCRv5_mobile_rec | `267c36e24c331595590fe7bd72bde2436fd286f2` |

CPU inference ran locally, four threads, using the environments recorded in the
[TrOCR](receipt-ocr-evaluation-20261019.md) and
[lightweight](receipt-ocr-lightweight-evaluation-20261019.md) reports. Runs overlapped;
timings in the raw output are diagnostic only, not a model-speed comparison or
phone latency measurement. TrOCR reported newly initialized unused encoder pooler
weights, as in the earlier experiment. No training was performed.

## Results

| Field target | TrOCR-base: original / contrast / shadow | English PP-OCR: original / contrast / shadow |
| --- | --- | --- |
| `£36.5.0` | `-L 36.15.` / `. ( 36.30` / `( 136.25` | `36.5` / `36.50` / `36.50` |
| `21.8.1969` | `21. 8.1969 .` in all three | `2.8.1965` / `2.8.1965` / `2.8.1665` |
| `360.000,-` | `3,3to.000,` / `3/3to.000 ,` / `3/3to.000 ,` | empty in all three |
| `09-04-2018` | `of that` / `of the proposals` / repeated unrelated words | `%07718` / `O07718` / `O07718` |

Strict transcription equality, removing whitespace only: **0/12 for each model**.
This is deliberately punctuation-sensitive: TrOCR recovered the Abbott date's
correct digits in all three variants, with a trailing period. That is partial
success, not three independent correct receipts. PP-OCR's wrong `2.8.1965` date
had raw character score 0.902 on the contrast variant. Model scores are not
calibrated financial confidence.

Do not feed historical pounds/shillings/pence into the PHP decimal scorer or
interpret `36.50` as a successful monetary extraction. Indonesian grouping is also
outside PesoFlow's PHP parsing scope. These samples evaluate transcription and
failure behavior, not supported currency conversion or end-to-end expense saving.

## Decision and verification

Neither candidate is promoted. Keep mandatory review and the current production
recognizer; partial date success does not overcome incorrect monetary values,
previous blank-control hallucinations and failures on the owner's invoice.
Next: seek a varied, explicitly licensed modern handwritten numeric-field dataset
with reliable labels and negative controls before selecting another recognizer.
Two public receipts plus one private receipt do not establish general accuracy.

Verified original hashes/dimensions, crop preparation (12 outputs), both local
inference runs (24 outputs), and exact-match recomputation. Existing Python scorer
regressions pass (8 tests). This milestone changes test images/metadata/docs only;
the preceding preprocessing milestone passed 262 Flutter tests, analysis and
APK/AAB/unsigned-iOS builds, and an in-place Android update/cold restart. Those
builds were not repeated for public fixture files. No financial data changed.

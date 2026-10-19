"""Create printed/blank sanity controls, never a claimed handwriting corpus."""

import argparse
import json
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

os.umask(0o077)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("font", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[4]
if args.output.resolve() == root or root in args.output.resolve().parents:
    parser.error("Generated inputs belong outside the repository")
args.output.mkdir(parents=True, exist_ok=False)
cases = []


def render(identifier, text, field, expected, group, size=64, grid=False):
    canvas = Image.new("RGB", (880, 130), "white")
    draw = ImageDraw.Draw(canvas)
    if grid:
        for x in range(0, 880, 110):
            draw.line((x, 0, x, 130), fill="gray", width=2)
        draw.line((0, 65, 880, 65), fill="gray", width=2)
    draw.text(
        (20, 20), text, font=ImageFont.truetype(str(args.font), size), fill="black"
    )
    path = args.output / f"{identifier}.png"
    canvas.save(path)
    cases.append(
        dict(
            id=identifier,
            path=str(path.resolve()),
            field=field,
            expected=expected,
            transcription=text,
            group=group,
            date_order="mdy",
        )
    )


for size in (40, 80):
    for i, (text, expected) in enumerate(
        [
            ("425", 42500),
            ("1,275.50", 127550),
            ("0.00", 0),
            ("18.05", 1805),
            ("PHP 62.75", 6275),
            ("9000.10", 900010),
        ]
    ):
        render(
            f"printed_amount_{i}_{size}",
            text,
            "amount",
            expected,
            "printed_amount",
            size,
        )
    for i, (text, expected) in enumerate(
        [
            ("12-19-24", "2024-12-19"),
            ("02/29/2024", "2024-02-29"),
            ("2025-11-23", "2025-11-23"),
            ("04-06-24", "2024-04-06"),
        ]
    ):
        render(f"printed_date_{i}_{size}", text, "date", expected, "printed_date", size)
for identifier, text, field, group in [
    ("blank_amount", "", "amount", "blank"),
    ("blank_date", "", "date", "blank"),
    ("grid_amount", "", "amount", "empty_grid"),
    ("alphabet", "ABCD", "amount", "nonfield"),
    ("serial_label", "INVOICE NO 026841", "amount", "nonfield"),
    ("printer_label", "PRINTER DATE 11-23-24", "date", "nonfield"),
    ("invalid_leap", "02-29-23", "date", "invalid_date"),
    ("invalid_month", "13-19-24", "date", "invalid_date"),
]:
    render(
        identifier, text, field, None, group, size=40, grid=identifier == "grid_amount"
    )
(args.output / "cases.json").write_text(json.dumps(cases, indent=2))
print(f"Created {len(cases)} synthetic controls; these are not handwritten receipts.")

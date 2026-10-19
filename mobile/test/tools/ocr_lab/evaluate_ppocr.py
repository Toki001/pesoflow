"""Offline PP-OCR text-line experiment; private results stay outside the repo."""

import os

os.environ["HF_HUB_OFFLINE"] = "1"
os.environ["TRANSFORMERS_OFFLINE"] = "1"
os.environ["HF_HUB_DISABLE_TELEMETRY"] = "1"
os.umask(0o077)

import argparse
import json
import math
from pathlib import Path
import re
import time

from PIL import Image
import torch
from transformers import AutoImageProcessor, AutoModelForTextRecognition

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("model", type=Path)
parser.add_argument("cases", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[4]
destination = args.output.resolve()
if destination == root or root in destination.parents:
    parser.error("Private predictions must stay outside the repository")
if args.output.exists():
    parser.error("Use a new output file")
cases = json.loads(args.cases.read_text())
ids = [c["id"] for c in cases]
if len(set(ids)) != len(ids) or not all(re.fullmatch(r"[a-z0-9_]+", i) for i in ids):
    parser.error("Use unique anonymous IDs")
torch.set_num_threads(4)
torch.manual_seed(0)
processor = AutoImageProcessor.from_pretrained(args.model, local_files_only=True)
model = AutoModelForTextRecognition.from_pretrained(args.model, local_files_only=True)
model.eval()
results = []
for case in cases:
    # Only image pixels enter inference. Expectations are scored separately.
    with Image.open(case["path"]) as source:
        inputs = processor(images=source.convert("RGB"), return_tensors="pt")
    start = time.monotonic()
    with torch.inference_mode():
        output = model(**inputs)
    elapsed = round((time.monotonic() - start) * 1000)
    result = processor.post_process_text_recognition(output)[0]
    score = float(result["score"])
    results.append(
        {
            "case": case["id"],
            "prediction": result["text"],
            "score": score if math.isfinite(score) else None,
            "inference_ms": elapsed,
        }
    )
    print(json.dumps({"case": case["id"], "inference_ms": elapsed}), flush=True)
with args.output.open("x") as destination:
    json.dump(results, destination, indent=2, allow_nan=False)

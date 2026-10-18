"""Offline line-recognition experiment; never a production financial writer."""
import os

os.environ["HF_HUB_OFFLINE"] = "1"
os.environ["TRANSFORMERS_OFFLINE"] = "1"
os.environ["HF_HUB_DISABLE_TELEMETRY"] = "1"
os.umask(0o077)

import argparse
import json
import pathlib
import re
import time

from PIL import Image
import torch
from transformers import TrOCRProcessor, VisionEncoderDecoderModel

parser = argparse.ArgumentParser()
parser.add_argument("model", type=pathlib.Path)
parser.add_argument("cases", type=pathlib.Path)
parser.add_argument("output", type=pathlib.Path)
args = parser.parse_args()
root = pathlib.Path(__file__).resolve().parents[4]
if args.output.resolve() == root or root in args.output.resolve().parents:
    parser.error("Private predictions must stay outside the repository.")
torch.set_num_threads(4)
torch.manual_seed(0)
processor = TrOCRProcessor.from_pretrained(str(args.model), local_files_only=True, use_fast=False)
model = VisionEncoderDecoderModel.from_pretrained(str(args.model), local_files_only=True)
model.eval()
results = []
for case in json.loads(args.cases.read_text()):
    if not re.fullmatch(r"[a-z0-9_]+", case["id"]):
        parser.error("Use anonymous case IDs.")
    with Image.open(case["path"]) as source:
        pixels = processor(images=source.convert("RGB"), return_tensors="pt").pixel_values
    start = time.monotonic()
    with torch.inference_mode():
        tokens = model.generate(pixels, max_new_tokens=48, num_beams=1, do_sample=False)
    prediction = processor.batch_decode(tokens, skip_special_tokens=True)[0]
    # Normalize whitespace only; do not coerce ambiguous letters into digits.
    matches = re.sub(r"\s+", "", prediction) == re.sub(r"\s+", "", case["expected"])
    elapsed = round((time.monotonic() - start) * 1000)
    results.append({"case": case["id"], "prediction": prediction,
                    "matches": matches, "inference_ms": elapsed})
    print(json.dumps({"case": case["id"], "matches": matches, "inference_ms": elapsed}), flush=True)
args.output.write_text(json.dumps(results, indent=2))
args.output.chmod(0o600)

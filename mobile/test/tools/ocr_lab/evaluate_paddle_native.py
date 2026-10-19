"""Local Paddle inference using the model's BGR/CTC configuration; no downloader."""

import argparse
import json
import math
import os
from pathlib import Path
import re
import time

import cv2
import numpy as np
from paddle.inference import Config, create_predictor

os.umask(0o077)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("model", type=Path)
parser.add_argument("cases", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[4]
if args.output.resolve() == root or root in args.output.resolve().parents:
    parser.error("Private predictions must stay outside the repository")
if args.output.exists():
    parser.error("Use a new output file")
cases = json.loads(args.cases.read_text())
ids = [c["id"] for c in cases]
if len(set(ids)) != len(ids) or not all(re.fullmatch(r"[a-z0-9_]+", i) for i in ids):
    parser.error("Use unique anonymous IDs")
metadata = json.loads((args.model / "config.json").read_text())
if metadata["PostProcess"]["name"] != "CTCLabelDecode":
    parser.error("Only CTC models supported")
ops = metadata["PreProcess"]["transform_ops"]
decode = next(op["DecodeImage"] for op in ops if "DecodeImage" in op)
if decode != {"channel_first": False, "img_mode": "BGR"}:
    parser.error("Unsupported model image layout")
shape = next(op["RecResizeImg"]["image_shape"] for op in ops if "RecResizeImg" in op)
if shape != [3, 48, 320]:
    parser.error("Unsupported recognition shape")
characters = [""] + metadata["PostProcess"]["character_dict"] + [" "]
config = Config(
    str(args.model / "inference.json"), str(args.model / "inference.pdiparams")
)
config.disable_gpu()
config.disable_mkldnn()
config.set_cpu_math_library_num_threads(4)
config.disable_glog_info()
predictor = create_predictor(config)
input_handle = predictor.get_input_handle(predictor.get_input_names()[0])
output_handle = predictor.get_output_handle(predictor.get_output_names()[0])
results = []
for case in cases:
    # OpenCV BGR, height 48, proportional width and zero normalized padding.
    # These are the upstream SVTR inference conventions, not receipt-specific rules.
    pixels = cv2.imread(case["path"])
    if pixels is None:
        parser.error("Unreadable local input")
    width = math.ceil(48 * pixels.shape[1] / pixels.shape[0])
    if width > 3200:
        parser.error("Input exceeds the evaluated width limit")
    normalized = cv2.resize(pixels, (width, 48)).astype("float32") / 127.5 - 1
    tensor = np.zeros((1, 3, 48, max(320, width)), dtype=np.float32)
    tensor[0, :, :, :width] = normalized.transpose(2, 0, 1)
    input_handle.reshape(tensor.shape)
    input_handle.copy_from_cpu(tensor)
    start = time.monotonic()
    predictor.run()
    probabilities = output_handle.copy_to_cpu()[0]
    elapsed = round((time.monotonic() - start) * 1000)
    if probabilities.shape[-1] != len(characters):
        parser.error("Model output and character dictionary disagree")
    ids = probabilities.argmax(axis=-1)
    selected = np.ones(len(ids), dtype=bool)
    selected[1:] = ids[1:] != ids[:-1]
    selected &= ids != 0
    prediction = "".join(characters[i] for i in ids[selected])
    score = (
        float(probabilities.max(axis=-1)[selected].mean()) if selected.any() else None
    )
    results.append(
        dict(
            case=case["id"],
            prediction=prediction,
            score=score if score is not None and math.isfinite(score) else None,
            inference_ms=elapsed,
        )
    )
    print(json.dumps({"case": case["id"], "inference_ms": elapsed}), flush=True)
with args.output.open("x") as destination:
    json.dump(results, destination, indent=2, allow_nan=False)

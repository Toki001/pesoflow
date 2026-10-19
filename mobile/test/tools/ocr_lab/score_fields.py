"""Strict, test-only field scoring. Never used to populate financial records."""

import argparse
from collections import Counter
from datetime import date
import json
from pathlib import Path
import re


def field_value(text, field, date_order=None):
    """Reject ambiguous/multiple values instead of searching for the answer."""
    text = text.strip()
    if field == "amount":
        match = re.fullmatch(
            r"(?:PHP\s*|₱\s*)?([0-9]+|[0-9]{1,3}(?:,[0-9]{3})+)(?:\.([0-9]{1,2}))?",
            text,
            re.IGNORECASE,
        )
        if not match:
            return None
        return int(match[1].replace(",", "")) * 100 + int(
            (match[2] or "").ljust(2, "0")
        )
    if field != "date":
        raise ValueError("Unsupported field")
    iso = re.fullmatch(r"([0-9]{4})-([0-9]{2})-([0-9]{2})", text)
    local = re.fullmatch(r"([0-9]{1,2})([-/])([0-9]{1,2})\2([0-9]{2}|[0-9]{4})", text)
    if iso:
        year, month, day = map(int, iso.groups())
    elif local and date_order in ("mdy", "dmy"):
        a, b, year = int(local[1]), int(local[3]), int(local[4])
        # Corpus convention is explicit: two-digit years refer to 2000–2099.
        year += 2000 if len(local[4]) == 2 else 0
        month, day = (a, b) if date_order == "mdy" else (b, a)
    else:
        return None
    try:
        return date(year, month, day).isoformat()
    except ValueError:
        return None


def score_case(case, prediction):
    field = case["field"]
    expected = case["expected"]
    if expected is not None:
        if field == "amount":
            if type(expected) is not int or expected < 0:
                raise ValueError(
                    "Expected amount must be nonnegative integer minor units"
                )
        elif field == "date":
            if (
                not isinstance(expected, str)
                or field_value(expected, "date") != expected
            ):
                raise ValueError("Expected date must be a valid ISO calendar date")
        else:
            raise ValueError("Unsupported field")
    value = field_value(prediction, field, case.get("date_order"))
    if expected is None:
        outcome = "false_positive" if value is not None else "rejected_negative"
    elif value is None:
        outcome = "abstained"
    else:
        outcome = "correct" if value == expected else "wrong_value"
    return {
        "case": case["id"],
        "group": case["group"],
        "field": field,
        "outcome": outcome,
        "exact": prediction.strip() == case.get("transcription"),
        "nonempty": bool(prediction.strip()),
    }


def score_all(cases, predictions):
    ids = [c["id"] for c in cases]
    predicted_ids = [p["case"] for p in predictions]
    if len(set(ids)) != len(ids) or len(set(predicted_ids)) != len(predicted_ids):
        raise ValueError("Duplicate case IDs")
    if not ids or set(ids) != set(predicted_ids):
        raise ValueError("Prediction IDs must match every case exactly")
    for c in cases:
        if not all(re.fullmatch(r"[a-z0-9_]+", c[k]) for k in ("id", "group")):
            raise ValueError("Use anonymous identifiers")
    by_id = {p["case"]: p["prediction"] for p in predictions}
    rows = [score_case(c, by_id[c["id"]]) for c in cases]
    groups = {}
    for group in sorted({r["group"] for r in rows}):
        selected = [r for r in rows if r["group"] == group]
        groups[group] = {
            "cases": len(selected),
            "exact": sum(r["exact"] for r in selected),
            "outcomes": dict(Counter(r["outcome"] for r in selected)),
        }
    return {"groups": groups, "cases": rows}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cases", type=Path)
    parser.add_argument("predictions", type=Path)
    args = parser.parse_args()
    print(
        json.dumps(
            score_all(
                json.loads(args.cases.read_text()),
                json.loads(args.predictions.read_text()),
            ),
            indent=2,
        )
    )

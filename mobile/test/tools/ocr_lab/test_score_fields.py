import unittest

from score_fields import field_value, score_all, score_case


class FieldScoringTest(unittest.TestCase):
    def test_amount_equivalence_preserves_cents(self):
        for text in ("PHP 1,275.50", "₱1275.5", "1275.50"):
            self.assertEqual(field_value(text, "amount"), 127550)
        self.assertEqual(field_value("0", "amount"), 0)

    def test_amount_rejects_guessing_and_extra_values(self):
        for text in (
            "12,75",
            "12O.50",
            "425 000",
            "425. 25",
            "12.345",
            "(425)",
            "-425",
            "425?",
            "TOTAL 425",
            "4 25",
            "",
            "NaN",
        ):
            self.assertIsNone(field_value(text, "amount"), text)

    def test_date_requires_explicit_order(self):
        self.assertIsNone(field_value("04-06-24", "date"))
        self.assertEqual(field_value("04-06-24", "date", "mdy"), "2024-04-06")
        self.assertEqual(field_value("04-06-24", "date", "dmy"), "2024-06-04")
        self.assertEqual(field_value("2024-02-29", "date"), "2024-02-29")

    def test_date_rejects_invalid_calendar_and_surrounding_text(self):
        for text in (
            "02-29-23",
            "13-19-24",
            "11-31-24",
            "12-19/24",
            "Date 12-19-24",
            "12-19-24 .",
            "12-19-24 12-20-24",
        ):
            self.assertIsNone(field_value(text, "date", "mdy"), text)

    def test_wrong_value_is_not_abstention(self):
        case = dict(
            id="a",
            group="synthetic",
            field="amount",
            expected=42500,
            transcription="425",
        )
        self.assertEqual(score_case(case, "425.00")["outcome"], "correct")
        self.assertFalse(score_case(case, "425.00")["exact"])
        self.assertEqual(score_case(case, "425.25")["outcome"], "wrong_value")
        self.assertEqual(score_case(case, "425?")["outcome"], "abstained")

    def test_blank_false_positive_and_nonempty_rejection_are_separate(self):
        case = dict(
            id="a", group="negative", field="amount", expected=None, transcription=""
        )
        self.assertEqual(score_case(case, "0")["outcome"], "false_positive")
        row = score_case(case, "gibberish")
        self.assertEqual(row["outcome"], "rejected_negative")
        self.assertTrue(row["nonempty"])

    def test_missing_duplicate_and_extra_predictions_fail(self):
        case = dict(id="a", group="synthetic", field="amount", expected=100)
        for predictions in (
            [],
            [dict(case="b", prediction="1")],
            [dict(case="a", prediction="1")] * 2,
        ):
            with self.assertRaises(ValueError):
                score_all([case], predictions)

    def test_expected_values_are_validated(self):
        for field, expected in (
            ("amount", 1.25),
            ("amount", True),
            ("date", "2023-02-29"),
        ):
            with self.assertRaises(ValueError):
                score_case(
                    dict(id="a", group="test", field=field, expected=expected), ""
                )


if __name__ == "__main__":
    unittest.main()

import base64
import importlib.util
import json
import pathlib
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parent.parent / "iap_price_schedule.py"
SPEC = importlib.util.spec_from_file_location("iap_price_schedule", SCRIPT)
iap_price_schedule = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(iap_price_schedule)


def point(number, price):
    encoded = base64.urlsafe_b64encode(json.dumps({"s": "1", "t": "LVA", "p": number}).encode()).decode().rstrip("=")
    return {"id": encoded, "attributes": {"customerPrice": price}}


POINTS = [point("10000", "0.0"), point("10036", "2.99"), point("10075", "5.99")]
ENTRIES = [{"price": "2.99"}, {"price": "5.99", "startDate": "2026-12-01"}]


class IapPriceScheduleTests(unittest.TestCase):
    def test_each_price_ends_where_the_next_starts(self):
        planned = iap_price_schedule.schedule(ENTRIES, POINTS)

        self.assertEqual(
            iap_price_schedule.prices_argument(planned),
            f"{POINTS[1]['id']}::2026-12-01,{POINTS[2]['id']}:2026-12-01",
        )

    def test_matching_schedule_is_unchanged(self):
        planned = iap_price_schedule.schedule(ENTRIES, POINTS)
        summary = {
            "currentPrice": {"amount": "2.99"},
            "scheduledChanges": [
                {"territory": "LVA", "fromPricePoint": "10036", "toPricePoint": "10075", "effectiveDate": "2026-12-01"},
                {"territory": "USA", "fromPricePoint": "10036", "toPricePoint": "10062", "effectiveDate": "2026-12-01"},
            ],
        }

        self.assertTrue(iap_price_schedule.matches(planned, summary, "LVA"))

    def test_different_current_price_is_changed(self):
        planned = iap_price_schedule.schedule([{"price": "2.99"}], POINTS)

        self.assertFalse(iap_price_schedule.matches(planned, {"currentPrice": {"amount": "5.99"}}, "LVA"))

    def test_missing_scheduled_change_is_changed(self):
        planned = iap_price_schedule.schedule(ENTRIES, POINTS)

        self.assertFalse(iap_price_schedule.matches(planned, {"currentPrice": {"amount": "2.99"}}, "LVA"))

    def test_free_price_matches_zero(self):
        planned = iap_price_schedule.schedule([{"price": "0"}], POINTS)

        self.assertTrue(iap_price_schedule.matches(planned, {"currentPrice": {"amount": "0.0"}}, "LVA"))

    def test_unknown_price_is_rejected(self):
        with self.assertRaises(ValueError):
            iap_price_schedule.schedule([{"price": "1.11"}], POINTS)


if __name__ == "__main__":
    unittest.main()

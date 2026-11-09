import importlib.util
import pathlib
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parent.parent / "storekit_config.py"
SPEC = importlib.util.spec_from_file_location("storekit_config", SCRIPT)
storekit_config = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(storekit_config)

PRODUCTS = {
    "products": [
        {
            "type": "NON_CONSUMABLE",
            "referenceName": "Unlock",
            "productId": "com.example.unlock",
            "familySharable": False,
            "localizations": [{"locale": "en-GB", "name": "Unlock", "description": "Unlock everything."}],
        }
    ]
}
PRICES = {"baseTerritory": "LVA", "prices": {"com.example.unlock": [{"price": "2.99"}, {"price": "5.99", "startDate": "2026-12-01"}]}}


OFFER_CODES = {"com.example.unlock": [{"name": "Full Version", "price": "0"}]}


class StoreKitConfigTests(unittest.TestCase):
    def test_free_offer_code_is_listed_on_its_product(self):
        configuration = storekit_config.configuration(PRODUCTS, PRICES, OFFER_CODES)
        product = configuration["products"][0]

        self.assertEqual(
            product["offerCodes"],
            [
                {
                    "internalID": storekit_config.stable_id("offer:com.example.unlock:Full Version")[:8],
                    "paymentMode": "free",
                    "referenceName": "Full Version",
                }
            ],
        )
        self.assertEqual(configuration["version"], {"major": 6, "minor": 3})

    def test_paid_offer_code_is_rejected(self):
        with self.assertRaises(ValueError):
            storekit_config.configuration(PRODUCTS, PRICES, {"com.example.unlock": [{"name": "Half", "price": "1.99"}]})

    def test_product_without_offer_codes_has_none(self):
        product = storekit_config.configuration(PRODUCTS, PRICES, {})["products"][0]

        self.assertNotIn("offerCodes", product)

    def test_product_takes_the_price_in_effect_now(self):
        product = storekit_config.configuration(PRODUCTS, PRICES, {})["products"][0]

        self.assertEqual(product["displayPrice"], "2.99")
        self.assertEqual(product["type"], "NonConsumable")
        self.assertEqual(product["productID"], "com.example.unlock")
        self.assertEqual(
            product["localizations"],
            [{"description": "Unlock everything.", "displayName": "Unlock", "locale": "en_GB"}],
        )

    def test_settings_use_the_base_territory_and_first_locale(self):
        settings = storekit_config.configuration(PRODUCTS, PRICES, {})["settings"]

        self.assertEqual(settings, {"_locale": "en_GB", "_storefront": "LVA"})

    def test_identifiers_are_stable(self):
        first = storekit_config.configuration(PRODUCTS, PRICES, {})
        second = storekit_config.configuration(PRODUCTS, PRICES, {})

        self.assertEqual(first["identifier"], second["identifier"])
        self.assertEqual(first["products"][0]["internalID"], second["products"][0]["internalID"])

    def test_product_without_a_current_price_is_rejected(self):
        prices = {"baseTerritory": "LVA", "prices": {"com.example.unlock": [{"price": "5.99", "startDate": "2026-12-01"}]}}

        with self.assertRaises(ValueError):
            storekit_config.configuration(PRODUCTS, prices, {})


if __name__ == "__main__":
    unittest.main()

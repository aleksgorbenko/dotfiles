#!/usr/bin/env python3
import argparse
import json
import pathlib
import uuid

TYPES = {"CONSUMABLE": "Consumable", "NON_CONSUMABLE": "NonConsumable", "NON_RENEWING_SUBSCRIPTION": "NonRenewingSubscription"}


def stable_id(text: str) -> str:
    return str(uuid.uuid5(uuid.NAMESPACE_URL, text)).upper()


def current_price(entries: list[dict]) -> str:
    starting_now = [entry for entry in entries if not entry.get("startDate")]
    if not starting_now:
        raise ValueError("every product needs a price without a startDate")
    return starting_now[0]["price"]


def offer_codes(product_id: str, entries: list[dict]) -> list[dict]:
    codes = []
    for entry in entries:
        if entry["price"] != "0":
            raise ValueError(f"offer code {entry['name']} must be free")
        codes.append(
            {
                "internalID": stable_id(f"offer:{product_id}:{entry['name']}")[:8],
                "paymentMode": "free",
                "referenceName": entry["name"],
            }
        )
    return codes


def configuration(products: dict, prices: dict, codes: dict) -> dict:
    items = []
    for product in products["products"]:
        product_id = product["productId"]
        item = {
            "displayPrice": current_price(prices["prices"][product_id]),
            "familyShareable": product.get("familySharable", False),
            "internalID": stable_id(f"internal:{product_id}"),
            "localizations": [
                {
                    "description": localization["description"],
                    "displayName": localization["name"],
                    "locale": localization["locale"].replace("-", "_"),
                }
                for localization in product.get("localizations", [])
            ],
            "productID": product_id,
            "referenceName": product["referenceName"],
            "type": TYPES[product["type"]],
        }
        if codes.get(product_id):
            item["offerCodes"] = offer_codes(product_id, codes[product_id])
        items.append(dict(sorted(item.items())))
    locale = items[0]["localizations"][0]["locale"] if items and items[0]["localizations"] else "en_US"
    return {
        "identifier": stable_id("storekit:" + ",".join(item["productID"] for item in items)),
        "nonRenewingSubscriptions": [],
        "products": items,
        "settings": {"_locale": locale, "_storefront": prices["baseTerritory"]},
        "subscriptionGroups": [],
        "version": {"major": 6, "minor": 3},
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--products", required=True)
    parser.add_argument("--app-config", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    products = json.loads(pathlib.Path(args.products).read_text(encoding="utf-8"))
    app_config = json.loads(pathlib.Path(args.app_config).read_text(encoding="utf-8"))
    codes = app_config.get("inAppPurchaseOfferCodes", {})
    text = json.dumps(configuration(products, app_config["inAppPurchasePrices"], codes), indent=2, ensure_ascii=False) + "\n"
    pathlib.Path(args.output).write_text(text, encoding="utf-8")


if __name__ == "__main__":
    main()

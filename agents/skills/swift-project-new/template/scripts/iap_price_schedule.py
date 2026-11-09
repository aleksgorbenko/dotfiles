#!/usr/bin/env python3
import argparse
import base64
import json
import pathlib
import sys
from decimal import Decimal


def point_number(point_id: str) -> str:
    padded = point_id + "=" * (-len(point_id) % 4)
    return json.loads(base64.urlsafe_b64decode(padded))["p"]


def schedule(entries: list[dict], price_points: list[dict]) -> list[dict]:
    by_price = {Decimal(point["attributes"]["customerPrice"]): point["id"] for point in price_points}
    planned = []
    for index, entry in enumerate(entries):
        point_id = by_price.get(Decimal(entry["price"]))
        if point_id is None:
            raise ValueError(f"no price point at {entry['price']}")
        end = entries[index + 1]["startDate"] if index + 1 < len(entries) else None
        planned.append({"pointId": point_id, "price": entry["price"], "start": entry.get("startDate"), "end": end})
    return planned


def prices_argument(planned: list[dict]) -> str:
    parts = []
    for item in planned:
        if item["end"]:
            parts.append(f"{item['pointId']}:{item['start'] or ''}:{item['end']}")
        elif item["start"]:
            parts.append(f"{item['pointId']}:{item['start']}")
        else:
            parts.append(item["pointId"])
    return ",".join(parts)


def matches(planned: list[dict], summary: dict, territory: str) -> bool:
    if planned[0]["start"]:
        return False
    current = summary.get("currentPrice") or {}
    if current.get("amount") is None or Decimal(current["amount"]) != Decimal(planned[0]["price"]):
        return False
    remote = [
        (change["toPricePoint"], change["effectiveDate"])
        for change in summary.get("scheduledChanges") or []
        if change["territory"] == territory
    ]
    wanted = [(point_number(item["pointId"]), item["start"]) for item in planned[1:]]
    return remote == wanted


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--app-config", required=True)
    parser.add_argument("--product-id", required=True)
    parser.add_argument("--price-points", required=True)
    parser.add_argument("--summary", required=True)
    args = parser.parse_args()
    prices = json.loads(pathlib.Path(args.app_config).read_text(encoding="utf-8"))["inAppPurchasePrices"]
    price_points = json.loads(pathlib.Path(args.price_points).read_text(encoding="utf-8"))["data"]
    summaries = json.loads(pathlib.Path(args.summary).read_text(encoding="utf-8"))["iaps"]
    summary = next((item for item in summaries if item["productId"] == args.product_id), {})
    try:
        planned = schedule(prices["prices"][args.product_id], price_points)
    except ValueError as error:
        sys.exit(f"{args.product_id}: {error}")
    print(json.dumps({"prices": prices_argument(planned), "unchanged": matches(planned, summary, prices["baseTerritory"])}))


if __name__ == "__main__":
    main()

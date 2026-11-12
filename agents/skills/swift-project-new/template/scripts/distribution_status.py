#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import dataclass

SPARKLE = "{http://www.andymatuschak.org/xml-namespaces/sparkle}"
LABELS = {"ok": "ok", "problem": "PROBLEM", "note": "note"}
LABEL_WIDTH = 8
CHANNEL_WIDTH = 14
TIMEOUT_SECONDS = 20


@dataclass(frozen=True)
class Check:
    state: str
    channel: str
    detail: str


def appcast_check(feed: str, version: str, download_url: str) -> Check:
    items = ET.fromstring(feed).findall("./channel/item")
    if not items:
        return Check("problem", "Appcast", "no items")
    latest = max(items, key=lambda item: int(item.findtext(f"{SPARKLE}version") or 0))
    latest_version = latest.findtext(f"{SPARKLE}shortVersionString") or "?"
    build = latest.findtext(f"{SPARKLE}version") or "?"
    enclosure = latest.find("enclosure")
    url = enclosure.get("url", "") if enclosure is not None else ""
    if latest_version != version:
        return Check("problem", "Appcast", f"latest is {latest_version}, not {version}")
    if url != download_url:
        return Check("problem", "Appcast", f"{version} links {url}")
    return Check("ok", "Appcast", f"{version} (build {build})")


def website_check(page: str, links: list[str]) -> Check:
    missing = [link for link in links if link not in page]
    if missing:
        return Check("problem", "Website", "missing " + ", ".join(missing))
    return Check("ok", "Website", "checkout, App Store and download links present")


def homebrew_check(cask: dict | None, version: str) -> Check:
    if cask is None:
        return Check("note", "Homebrew", "no cask yet")
    if cask.get("version") != version:
        return Check("problem", "Homebrew", f"has {cask.get('version')}")
    return Check("ok", "Homebrew", version)


def status_lines(app_name: str, version: str, checks: list[Check]) -> list[str]:
    counts = [f"{sum(check.state == state for check in checks)} {state}" for state in LABELS]
    lines = [f"Distribution status: {app_name} {version}", "  " + ", ".join(counts), ""]
    lines += [
        f"  {LABELS[check.state].ljust(LABEL_WIDTH)}  {check.channel.ljust(CHANNEL_WIDTH)}  {check.detail}"
        for check in checks
    ]
    return lines


def _run(*arguments: str) -> subprocess.CompletedProcess:
    return subprocess.run(arguments, capture_output=True, text=True, check=False)


def _fetch(url: str) -> tuple[int, str]:
    request = urllib.request.Request(url, headers={"User-Agent": "distribution-status"})
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT_SECONDS) as response:
            return response.status, response.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as error:
        return error.code, ""


def _app_store(app_id: str, version: str) -> Check:
    result = _run("asc", "versions", "list", "--app", app_id, "--platform", "MAC_OS", "--output", "json")
    if result.returncode != 0:
        return Check("problem", "App Store", "cannot reach App Store Connect")
    states = {
        item["attributes"]["versionString"]: item["attributes"]["appStoreState"]
        for item in json.loads(result.stdout).get("data", [])
    }
    state = states.get(version)
    if state is None:
        return Check("problem", "App Store", f"no version {version}")
    return Check("ok" if state == "READY_FOR_SALE" else "note", "App Store", f"{version} {state}")


def _tag(version: str) -> Check:
    repo = _run("gh", "repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner").stdout.strip()
    refs = _run("gh", "api", f"repos/{repo}/git/matching-refs/tags/v{version}", "--jq", ".[].ref").stdout.split()
    if f"refs/tags/v{version}" in refs:
        return Check("ok", "Tag", f"v{version} on {repo}")
    return Check("problem", "Tag", f"no v{version} on {repo}")


def _github_release(releases_repo: str, version: str, dmg_name: str) -> Check:
    result = _run("gh", "release", "view", f"v{version}", "--repo", releases_repo, "--json", "assets")
    if result.returncode != 0:
        return Check("problem", "GitHub release", f"no release v{version} on {releases_repo}")
    assets = [asset["name"] for asset in json.loads(result.stdout).get("assets", [])]
    if dmg_name not in assets:
        return Check("problem", "GitHub release", f"v{version} has no {dmg_name}")
    return Check("ok", "GitHub release", f"v{version} with {dmg_name}")


def _download(url: str) -> Check:
    status, _ = _fetch(url)
    if status != 200:
        return Check("problem", "Download link", f"{url} returns {status}")
    return Check("ok", "Download link", url)


def _lemon_squeezy(directory: str, slug: str, dmg: str) -> Check:
    product = _run("make", "-C", directory, "check", f"SLUG={slug}")
    if product.returncode != 0:
        return Check("problem", "Lemon Squeezy", "product differs from storefronts - run make -C lemonsqueezy check")
    if not os.path.isfile(dmg):
        return Check("note", "Lemon Squeezy", f"product matches; no local {os.path.basename(dmg)} to compare the file")
    file = _run("make", "-C", directory, "check-file", f"SLUG={slug}", f"FILE={os.path.abspath(dmg)}")
    if file.returncode != 0:
        errors = [line for line in (file.stderr + file.stdout).splitlines() if line.startswith("error:")]
        return Check("problem", "Lemon Squeezy", errors[0] if errors else "file check failed")
    return Check("ok", "Lemon Squeezy", f"product matches, serves {os.path.basename(dmg)}")


def _homebrew(token: str, version: str) -> Check:
    status, body = _fetch(f"https://formulae.brew.sh/api/cask/{token}.json")
    return homebrew_check(json.loads(body) if status == 200 else None, version)


def main() -> int:
    env = os.environ
    app_name, slug, version = env["APP_NAME"], env["APP_SLUG"], env["VERSION"]
    host = env["FEED_HOST"]
    dmg_name = f"{app_name}-{version}.dmg"
    download_url = f"https://{host}/apps/{slug}/download/v{version}/{dmg_name}"
    app_store_url = f"https://apps.apple.com/app/id{env['APP_STORE_APP_ID']}"
    checkout_url = env["CHECKOUT_URL"].replace("$()", "")

    checks = [_app_store(env["APP_STORE_APP_ID"], version)]
    checks.append(_github_release(f"{env['RELEASES_OWNER']}/{slug}-releases", version, dmg_name))
    checks.append(_download(download_url))
    feed_status, feed = _fetch(f"https://{host}/apps/{slug}/appcast.xml")
    feed_ok = feed_status == 200
    checks.append(appcast_check(feed, version, download_url) if feed_ok else Check("problem", "Appcast", f"returns {feed_status}"))
    page_status, page = _fetch(f"https://{host}/apps/{slug}/")
    page_ok = page_status == 200
    checks.append(website_check(page, [checkout_url, app_store_url, download_url]) if page_ok else Check("problem", "Website", f"returns {page_status}"))
    checks.append(_lemon_squeezy(env["LEMONSQUEEZY_DIR"], slug, env["DMG"]))
    checks.append(_homebrew(slug, version))
    checks.append(_tag(version))

    sys.stdout.write("\n".join(status_lines(app_name, version, checks)) + "\n")
    return 1 if any(check.state == "problem" for check in checks) else 0


if __name__ == "__main__":
    sys.exit(main())

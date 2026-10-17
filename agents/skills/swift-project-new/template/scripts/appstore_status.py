#!/usr/bin/env python3
import datetime
import json
import subprocess
import sys


def _time(value, tz, with_clock=True):
    if not value:
        return "-"
    moment = datetime.datetime.fromisoformat(value).astimezone(tz)
    return moment.strftime("%Y-%m-%d %H:%M" if with_clock else "%Y-%m-%d")


def status_lines(versions, builds, tz=None):
    included = {(item["type"], item["id"]): item.get("attributes", {}) for item in builds.get("included", [])}

    def related(build, name):
        data = build.get("relationships", {}).get(name, {}).get("data")
        if data is None:
            return []
        items = data if isinstance(data, list) else [data]
        return [included.get((item["type"], item["id"]), {}) for item in items]

    lines = ["App Store versions"]
    for version in versions.get("data", []):
        attributes = version["attributes"]
        lines.append(
            f"  {attributes['versionString']}  {attributes['appStoreState']}"
            f"  created {_time(attributes.get('createdDate'), tz, with_clock=False)}"
        )

    lines += ["", "Builds (newest first)"]
    public_link = None
    for build in builds.get("data", []):
        attributes = build["attributes"]
        marketing = next((item.get("version") for item in related(build, "preReleaseVersion")), "?")
        processing = attributes["processingState"] + (", expired" if attributes.get("expired") else "")
        review = next(iter(related(build, "betaAppReviewSubmission")), None)
        review_text = (
            f"beta review {review['betaReviewState']} (submitted {_time(review.get('submittedDate'), tz)})"
            if review
            else "beta review not submitted"
        )
        groups = related(build, "betaGroups")
        group_names = ", ".join(group["name"] for group in groups) or "none"
        for group in groups:
            if group.get("publicLink") and public_link is None:
                public_link = group
        lines.append(
            f"  {marketing} ({attributes['version']})  {processing}"
            f"  uploaded {_time(attributes.get('uploadedDate'), tz)}"
            f"  expires {_time(attributes.get('expirationDate'), tz, with_clock=False)}"
            f"  {review_text}  groups {group_names}"
        )

    if public_link:
        state = "enabled" if public_link.get("publicLinkEnabled") else "disabled"
        lines += ["", f"Public link: {public_link['publicLink']} ({state})"]
    return lines


def _asc(*arguments):
    return json.loads(subprocess.run(["asc", *arguments, "--output", "json"], capture_output=True, check=True).stdout)


def main():
    app_id, limit = sys.argv[1], sys.argv[2]
    versions = _asc("versions", "list", "--app", app_id, "--platform", "MAC_OS")
    builds = _asc(
        "builds", "list", "--app", app_id, "--platform", "MAC_OS", "--limit", limit, "--sort", "-uploadedDate",
        "--include", "betaAppReviewSubmission,preReleaseVersion,betaGroups",
    )
    print("\n".join(status_lines(versions, builds)))


if __name__ == "__main__":
    main()

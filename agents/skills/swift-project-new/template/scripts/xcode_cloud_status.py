#!/usr/bin/env python3
import datetime
import json
import subprocess
import sys


def _time(value, tz):
    if not value:
        return "-"
    return datetime.datetime.fromisoformat(value).astimezone(tz).strftime("%Y-%m-%d %H:%M")


def status_lines(workflow_name, runs, tz=None):
    lines = [f"Workflow {workflow_name}"]
    if not runs.get("data"):
        return lines + ["  no builds"]
    for build_run in runs["data"]:
        attributes = build_run["attributes"]
        commit = attributes.get("sourceCommit") or {}
        result = attributes.get("completionStatus") or attributes.get("executionProgress", "?")
        message = (commit.get("message") or "").splitlines()[0] if commit.get("message") else ""
        lines.append(
            f"  #{attributes['number']}  {result}  {(commit.get('commitSha') or '?')[:7]}"
            f"  finished {_time(attributes.get('finishedDate'), tz)}  {message}"
        )
    return lines


def _asc(*arguments):
    return json.loads(subprocess.run(["asc", *arguments, "--output", "json"], capture_output=True, check=True).stdout)


def main():
    app_id, limit = sys.argv[1], sys.argv[2]
    for workflow in _asc("xcode-cloud", "workflows", "--app", app_id)["data"]:
        runs = _asc("xcode-cloud", "build-runs", "--workflow-id", workflow["id"], "--limit", limit, "--sort", "-number")
        print("\n".join(status_lines(workflow["attributes"]["name"], runs)))


if __name__ == "__main__":
    main()

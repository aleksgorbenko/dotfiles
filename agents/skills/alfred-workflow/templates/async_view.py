import hashlib
import json
import os
import subprocess
import sys
import time
from pathlib import Path  # noqa: TC003
from typing import Any

WAIT_SECONDS = 0.35
POLL_SECONDS = 0.02
FRESH_SECONDS = 5.0
JOB_TIMEOUT_SECONDS = 60.0
KEEP_SECONDS = 3600.0
RERUN_SECONDS = 0.3
DEBOUNCE_SECONDS = 0.25
PRIVATE_FILE = 0o600
PRIVATE_DIRECTORY = 0o700

Payload = dict[str, Any]


def _views(directory: Path) -> Path:
    path = directory / "views"
    path.mkdir(mode=PRIVATE_DIRECTORY, parents=True, exist_ok=True)
    return path


def view_stem(directory: Path, query: str) -> Path:
    return _views(directory) / hashlib.sha256(query.encode()).hexdigest()


def loading(label: str, subtitle: str = "") -> Payload:
    row: Payload = {"title": label, "valid": False}
    if subtitle:
        row["subtitle"] = subtitle
    return {"rerun": RERUN_SECONDS, "items": [row]}


def _age(path: Path) -> float | None:
    try:
        return time.time() - path.stat().st_mtime
    except OSError:
        return None


def _read_fresh(path: Path) -> Payload | None:
    age = _age(path)
    if age is None or age > FRESH_SECONDS:
        return None
    try:
        payload: Payload = json.loads(path.read_text())
    except (OSError, ValueError):
        return None
    return payload


def _claim(lock: Path) -> bool:
    age = _age(lock)
    if age is not None and age < JOB_TIMEOUT_SECONDS:
        return False
    lock.unlink(missing_ok=True)
    try:
        descriptor = os.open(lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY, PRIVATE_FILE)
    except FileExistsError:
        return False
    os.close(descriptor)
    return True


def _prune(directory: Path) -> None:
    for path in _views(directory).iterdir():
        age = _age(path)
        if age is not None and age > KEEP_SECONDS:
            path.unlink(missing_ok=True)


DETACH = '"$@" </dev/null >/dev/null 2>&1 &'


def _start(command: list[str]) -> None:
    subprocess.run(  # noqa: S603
        ["/bin/sh", "-c", DETACH, "sh", *command],
        check=False,
        start_new_session=True,
    )


def _latest(directory: Path) -> Path:
    return _views(directory) / "latest"


def _digest(query: str) -> str:
    return hashlib.sha256(query.encode()).hexdigest()


def settle(directory: Path, query: str) -> bool:
    time.sleep(DEBOUNCE_SECONDS)
    try:
        latest = _latest(directory).read_text()
    except OSError:
        return True
    if latest == _digest(query):
        return True
    view_stem(directory, query).with_suffix(".lock").unlink(missing_ok=True)
    return False


def serve(
    query: str,
    *,
    directory: Path,
    command: list[str],
    label: str,
    wait: float = WAIT_SECONDS,
) -> Payload:
    stem = view_stem(directory, query)
    result = stem.with_suffix(".json")
    _latest(directory).write_text(_digest(query))
    fresh = _read_fresh(result)
    if fresh is not None:
        return fresh
    if _claim(stem.with_suffix(".lock")):
        _prune(directory)
        result.unlink(missing_ok=True)
        _start(command)
    deadline = time.monotonic() + wait
    while time.monotonic() < deadline:
        fresh = _read_fresh(result)
        if fresh is not None:
            return fresh
        time.sleep(POLL_SECONDS)
    return loading(label)


def finish(directory: Path, query: str, payload: Payload) -> None:
    stem = view_stem(directory, query)
    temporary = stem.with_suffix(".tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False))
    temporary.chmod(PRIVATE_FILE)
    temporary.replace(stem.with_suffix(".json"))
    stem.with_suffix(".lock").unlink(missing_ok=True)


def job_command(script: str, query: str) -> list[str]:
    return [sys.executable, script, "--job", query]

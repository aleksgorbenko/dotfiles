import json
import os
import sys
import time
from pathlib import Path

import async_view

MODE_MASK = 0o777
PAYLOAD = {"items": [{"title": "Done", "valid": False}]}


def writer(directory: Path, query: str, delay: float) -> list[str]:
    code = (
        "import sys,time;sys.path.insert(0,sys.argv[1]);import async_view,pathlib;"
        f"time.sleep({delay});"
        f"async_view.finish(pathlib.Path(sys.argv[2]),{query!r},{PAYLOAD!r})"
    )
    source = str(Path(async_view.__file__).parent)
    return [sys.executable, "-c", code, source, str(directory)]


def test_loading_payload_reruns() -> None:
    payload = async_view.loading("Loading…", "Please wait")
    assert payload["rerun"] == async_view.RERUN_SECONDS
    assert payload["items"] == [
        {"title": "Loading…", "subtitle": "Please wait", "valid": False}
    ]
    assert "subtitle" not in async_view.loading("Loading…")["items"][0]


def test_fast_job_returns_its_result(tmp_path: Path) -> None:
    result = async_view.serve(
        "q", directory=tmp_path, command=writer(tmp_path, "q", 0), label="Loading…", wait=5
    )
    assert result == PAYLOAD


def test_slow_job_shows_loading_then_the_result(tmp_path: Path) -> None:
    command = writer(tmp_path, "q", 0.6)
    first = async_view.serve(
        "q", directory=tmp_path, command=command, label="Loading…", wait=0.05
    )
    assert first["items"][0]["title"] == "Loading…"
    again = async_view.serve(
        "q", directory=tmp_path, command=command, label="Loading…", wait=0.05
    )
    assert again["items"][0]["title"] == "Loading…"
    deadline = time.monotonic() + 10
    result = again
    while time.monotonic() < deadline and result != PAYLOAD:
        result = async_view.serve(
            "q", directory=tmp_path, command=command, label="Loading…", wait=0.2
        )
    assert result == PAYLOAD


def test_fresh_result_is_reused_without_a_job(tmp_path: Path) -> None:
    async_view.finish(tmp_path, "q", PAYLOAD)
    assert async_view.serve("q", directory=tmp_path, command=["false"], label="x") == (
        PAYLOAD
    )


def test_stale_result_and_lock_are_replaced(tmp_path: Path) -> None:
    async_view.finish(tmp_path, "q", {"items": []})
    stem = async_view.view_stem(tmp_path, "q")
    old = time.time() - async_view.JOB_TIMEOUT_SECONDS - 10
    stem.with_suffix(".lock").write_text("")
    for suffix in (".json", ".lock"):
        os.utime(stem.with_suffix(suffix), (old, old))
    result = async_view.serve(
        "q", directory=tmp_path, command=writer(tmp_path, "q", 0), label="x", wait=5
    )
    assert result == PAYLOAD


def test_finish_writes_private_files_and_releases_the_lock(tmp_path: Path) -> None:
    stem = async_view.view_stem(tmp_path, "q")
    stem.with_suffix(".lock").write_text("")
    async_view.finish(tmp_path, "q", PAYLOAD)
    assert not stem.with_suffix(".lock").exists()
    assert stem.with_suffix(".json").stat().st_mode & MODE_MASK == async_view.PRIVATE_FILE
    assert json.loads(stem.with_suffix(".json").read_text()) == PAYLOAD


def test_corrupt_result_is_ignored(tmp_path: Path) -> None:
    stem = async_view.view_stem(tmp_path, "q")
    stem.with_suffix(".json").write_text("{")
    result = async_view.serve(
        "q", directory=tmp_path, command=writer(tmp_path, "q", 0), label="x", wait=5
    )
    assert result == PAYLOAD


def test_old_views_are_pruned(tmp_path: Path) -> None:
    async_view.finish(tmp_path, "old", PAYLOAD)
    path = async_view.view_stem(tmp_path, "old").with_suffix(".json")
    ancient = time.time() - async_view.KEEP_SECONDS - 10
    os.utime(path, (ancient, ancient))
    async_view.serve(
        "q", directory=tmp_path, command=writer(tmp_path, "q", 0), label="x", wait=5
    )
    assert not path.exists()


def test_job_command_targets_the_script() -> None:
    assert async_view.job_command("app.py", "q")[1:] == ["app.py", "--job", "q"]


def test_settle_runs_the_latest_query_and_drops_superseded_ones(
    tmp_path: Path,
) -> None:
    assert async_view.settle(tmp_path, "q")
    async_view.serve(
        "newer", directory=tmp_path, command=writer(tmp_path, "newer", 0), label="x", wait=5
    )
    lock = async_view.view_stem(tmp_path, "old").with_suffix(".lock")
    lock.write_text("")
    assert not async_view.settle(tmp_path, "old")
    assert not lock.exists()
    assert async_view.settle(tmp_path, "newer")

import json
import subprocess
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "src" / "maintenance.sh"
FILE_COUNT = 2


def run(cache: Path, *args: str) -> str:
    return subprocess.run(  # noqa: S603
        ["/bin/bash", str(SCRIPT), *args],
        env={
            "alfred_workflow_cache": str(cache),
            "alfred_workflow_name": ".Sample",
            "PATH": "/usr/bin:/bin",
            "LANG": "en_US.UTF-8",
        },
        capture_output=True,
        text=True,
        check=True,
    ).stdout


def test_menu_shows_cache_size_and_file_count(tmp_path: Path) -> None:
    (tmp_path / "a.json").write_text("x" * 2048)
    (tmp_path / "b.json").write_text("y")
    rows = json.loads(run(tmp_path, "--menu", "feeds"))["items"]
    assert rows[0]["title"].startswith("Sample cache: ")
    assert rows[0]["subtitle"].startswith(f"feeds・{FILE_COUNT} files・")
    assert rows[0]["icon"] == {"path": "icon.png"}
    assert rows[1]["title"] == "Empty Sample Cache"
    assert rows[1]["subtitle"] == "Delete feeds; fetched again when needed"
    assert [row["arg"] for row in rows] == ["--reveal", "--clear"]


def test_missing_cache_is_empty(tmp_path: Path) -> None:
    rows = json.loads(run(tmp_path / "missing"))["items"]
    assert rows[0]["title"] == "Sample cache: 0 KB"
    assert rows[0]["subtitle"].startswith("cached data・0 files")


def test_clear_empties_the_cache_and_keeps_the_folder(tmp_path: Path) -> None:
    (tmp_path / "nested").mkdir()
    (tmp_path / "nested" / "c.json").write_text("z")
    assert run(tmp_path, "--clear") == "Cache emptied\n"
    assert tmp_path.is_dir()
    assert list(tmp_path.iterdir()) == []

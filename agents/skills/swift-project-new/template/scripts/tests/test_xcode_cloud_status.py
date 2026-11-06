import datetime
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from xcode_cloud_status import status_lines

UTC = datetime.timezone.utc


def run(number, status, progress="COMPLETE", sha="df3cefcdb97b", message="Merge branch 'x'\n\nbody", finished="2026-10-18T06:03:04Z"):
    return {"attributes": {
        "number": number,
        "createdDate": "2026-10-18T05:58:27Z",
        "finishedDate": finished,
        "executionProgress": progress,
        "completionStatus": status,
        "sourceCommit": {"commitSha": sha, "message": message},
    }}


class StatusLinesTests(unittest.TestCase):
    def test_lists_runs_with_result_commit_and_first_message_line(self):
        lines = status_lines("Default", {"data": [run(20, "SUCCEEDED")]}, tz=UTC)
        self.assertEqual(lines, [
            "Workflow Default",
            "  #20  SUCCEEDED  df3cefc  finished 2026-10-18 06:03  Merge branch 'x'",
        ])

    def test_running_build_shows_progress_instead_of_result(self):
        lines = status_lines("Default", {"data": [run(21, None, progress="RUNNING", finished=None)]}, tz=UTC)
        self.assertEqual(lines[1], "  #21  RUNNING  df3cefc  finished -  Merge branch 'x'")

    def test_workflow_without_runs(self):
        self.assertEqual(status_lines("Default", {"data": []}, tz=UTC), ["Workflow Default", "  no builds"])


if __name__ == "__main__":
    unittest.main()

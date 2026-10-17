import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from launch_time import Phase, launch_ms, phases, report

ONE_MS = 1_000_000
BUDGET_MS = 100
TRACE = """<?xml version="1.0"?>
<trace-query-result><node>
<row><start-time id="1">10000000</start-time><duration id="2">5000000</duration>
<app-period id="3" fmt="Initializing - Static Runtime Initialization">x</app-period></row>
<row><start-time id="4">20000000</start-time><duration ref="2"/>
<app-period id="5" fmt="Launching - applicationDidFinishLaunching()">x</app-period></row>
<row><start-time id="6">50000000</start-time><duration id="7">1000000</duration>
<app-period id="8" fmt="Running">x</app-period></row>
</node></trace-query-result>
"""


def trace_lasting(milliseconds):
    return f"""<trace-query-result><row><start-time id="1">0</start-time>
<duration id="2">{milliseconds * ONE_MS}</duration><app-period id="3" fmt="Launching">x</app-period></row>
</trace-query-result>"""


class LaunchTimeTests(unittest.TestCase):
    def test_reads_initializing_and_launching_phases_only(self):
        self.assertEqual(phases(TRACE), [
            Phase("Initializing - Static Runtime Initialization", 10 * ONE_MS, 5 * ONE_MS),
            Phase("Launching - applicationDidFinishLaunching()", 20 * ONE_MS, 5 * ONE_MS),
        ])

    def test_launch_runs_from_the_first_phase_start_to_the_last_phase_end(self):
        self.assertEqual(launch_ms(phases(TRACE)), 15.0)

    def test_report_passes_when_the_median_run_is_within_budget(self):
        traces = [trace_lasting(BUDGET_MS - 10), trace_lasting(BUDGET_MS + 50), trace_lasting(BUDGET_MS - 20)]
        lines, passed = report(traces, BUDGET_MS)
        self.assertTrue(passed)
        self.assertIn(f"Median launch: {BUDGET_MS - 10:.0f} ms (budget {BUDGET_MS} ms)", lines)

    def test_report_fails_when_the_median_run_is_over_budget(self):
        _, passed = report([trace_lasting(BUDGET_MS + 1)], BUDGET_MS)
        self.assertFalse(passed)

    def test_report_fails_without_launch_phases(self):
        _, passed = report(["<trace-query-result/>"], BUDGET_MS)
        self.assertFalse(passed)


if __name__ == "__main__":
    unittest.main()

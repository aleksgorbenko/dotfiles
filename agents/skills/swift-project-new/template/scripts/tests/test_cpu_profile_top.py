import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from cpu_profile_top import FunctionCost, format_table, top_functions

ONE_MS = 1_000_000
ALL_ROWS = 10
TRACE = """<?xml version="1.0"?>
<trace-query-result><node>
<row><weight id="1" fmt="1.00 ms">1000000</weight><tagged-backtrace id="2">
<frame id="3" name="leaf"><binary id="4" name="App"/></frame>
<frame id="5" name="caller"><binary ref="4"/></frame>
<frame id="6" name="main"><binary id="7" name="dyld"/></frame>
</tagged-backtrace></row>
<row><weight ref="1"/><tagged-backtrace ref="2"/></row>
<row><weight id="8" fmt="2.00 ms">2000000</weight><backtrace id="9">
<frame ref="5"/><frame ref="5"/><frame ref="6"/>
</backtrace></row>
<row><weight ref="1"/><sentinel/></row>
</node></trace-query-result>
"""


class TopFunctionsTests(unittest.TestCase):
    def test_charges_self_time_to_the_first_frame_and_total_time_once_per_stack(self):
        self.assertEqual(top_functions(TRACE, ALL_ROWS), [
            FunctionCost("caller", "App", 2 * ONE_MS, 4 * ONE_MS),
            FunctionCost("leaf", "App", 2 * ONE_MS, 2 * ONE_MS),
            FunctionCost("main", "dyld", 0, 4 * ONE_MS),
        ])

    def test_limits_the_rows(self):
        self.assertEqual([cost.function for cost in top_functions(TRACE, 1)], ["caller"])

    def test_formats_milliseconds_and_shares_of_all_samples(self):
        lines = format_table(top_functions(TRACE, 1), total=4 * ONE_MS)
        self.assertEqual(lines[0].split(), ["SELF", "SELF%", "TOTAL", "TOTAL%", "FUNCTION", "BINARY"])
        self.assertEqual(lines[1].split(), ["2.0ms", "50.0%", "4.0ms", "100.0%", "caller", "App"])

    def test_an_empty_trace_has_no_rows(self):
        self.assertEqual(top_functions("<trace-query-result/>", ALL_ROWS), [])


if __name__ == "__main__":
    unittest.main()

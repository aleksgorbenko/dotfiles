#!/usr/bin/env python3
import statistics
import sys
import xml.etree.ElementTree as ElementTree
from dataclasses import dataclass

LAUNCH_PERIODS = ("Initializing", "Launching")


@dataclass(frozen=True)
class Phase:
    name: str
    start: int
    duration: int


def phases(xml_text: str) -> list[Phase]:
    root = ElementTree.fromstring(xml_text)
    by_id = {element.get("id"): element for element in root.iter() if element.get("id")}

    def value(row: ElementTree.Element, tag: str) -> ElementTree.Element | None:
        element = row.find(tag)
        if element is not None and element.get("ref"):
            return by_id.get(element.get("ref"))
        return element

    result = []
    for row in root.iter("row"):
        start, duration, period = value(row, "start-time"), value(row, "duration"), value(row, "app-period")
        if start is None or duration is None or period is None:
            continue
        name = period.get("fmt", "")
        if name.startswith(LAUNCH_PERIODS):
            result.append(Phase(name, int(start.text or 0), int(duration.text or 0)))
    return result


def launch_ms(launch_phases: list[Phase]) -> float:
    begin = min(phase.start for phase in launch_phases)
    end = max(phase.start + phase.duration for phase in launch_phases)
    return (end - begin) / 1e6


def report(traces: list[str], budget_ms: int) -> tuple[list[str], bool]:
    runs = [phases(trace) for trace in traces]
    if not all(runs):
        return ["error: a trace has no launch phases"], False
    totals = [launch_ms(run) for run in runs]
    median = statistics.median(totals)
    slowest = runs[totals.index(max(totals))]
    lines = ["Runs: " + ", ".join(f"{total:.0f} ms" for total in totals), "", "Slowest run phases:"]
    lines += [f"  {phase.duration / 1e6:>8.1f} ms  {phase.name}" for phase in slowest]
    lines += ["", f"Median launch: {median:.0f} ms (budget {budget_ms} ms)"]
    return lines, median <= budget_ms


def main() -> None:
    budget_ms = int(sys.argv[1])
    traces = [open(path, encoding="utf-8").read() for path in sys.argv[2:]]
    lines, passed = report(traces, budget_ms)
    print("\n".join(lines))
    sys.exit(0 if passed else 1)


if __name__ == "__main__":
    main()

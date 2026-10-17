#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ElementTree
from collections import defaultdict
from dataclasses import dataclass

BACKTRACES = ("tagged-backtrace", "backtrace")


@dataclass(frozen=True)
class Frame:
    function: str
    binary: str


@dataclass(frozen=True)
class Sample:
    weight: int
    frames: tuple[Frame, ...]


@dataclass(frozen=True)
class FunctionCost:
    function: str
    binary: str
    self_weight: int
    total_weight: int


def samples(xml_text: str) -> list[Sample]:
    root = ElementTree.fromstring(xml_text)
    by_id = {element.get("id"): element for element in root.iter() if element.get("id")}

    def resolve(element: ElementTree.Element) -> ElementTree.Element:
        return by_id.get(element.get("ref"), element) if element.get("ref") else element

    def frame(element: ElementTree.Element) -> Frame:
        element = resolve(element)
        binary = element.find("binary")
        binary_name = resolve(binary).get("name", "?") if binary is not None else "?"
        return Frame(element.get("name", element.get("addr", "?")), binary_name)

    result = []
    for row in root.iter("row"):
        weight = row.find("weight")
        stack = next((row.find(tag) for tag in BACKTRACES if row.find(tag) is not None), None)
        if weight is None or stack is None:
            continue
        frames = tuple(frame(element) for element in resolve(stack).findall("frame"))
        result.append(Sample(int(resolve(weight).text or 0), frames))
    return result


def top_functions(xml_text: str, limit: int) -> list[FunctionCost]:
    self_weight: dict[Frame, int] = defaultdict(int)
    total_weight: dict[Frame, int] = defaultdict(int)
    for sample in samples(xml_text):
        if not sample.frames:
            continue
        self_weight[sample.frames[0]] += sample.weight
        for frame in set(sample.frames):
            total_weight[frame] += sample.weight
    costs = [FunctionCost(frame.function, frame.binary, self_weight[frame], total) for frame, total in total_weight.items()]
    costs.sort(key=lambda cost: (-cost.self_weight, -cost.total_weight, cost.function))
    return costs[:limit]


def format_table(costs: list[FunctionCost], total: int) -> list[str]:
    def share(weight: int) -> str:
        return f"{100 * weight / total:.1f}%" if total else "-"

    lines = [f"{'SELF':>9} {'SELF%':>6} {'TOTAL':>9} {'TOTAL%':>6}  FUNCTION  BINARY"]
    for cost in costs:
        lines.append(
            f"{cost.self_weight / 1e6:>7.1f}ms {share(cost.self_weight):>6} {cost.total_weight / 1e6:>7.1f}ms"
            f" {share(cost.total_weight):>6}  {cost.function}  {cost.binary}"
        )
    return lines


def main() -> None:
    xml_text = open(sys.argv[1], encoding="utf-8").read()
    total = sum(sample.weight for sample in samples(xml_text))
    print(f"Samples: {total / 1e6:.1f}ms of CPU")
    print("\n".join(format_table(top_functions(xml_text, int(sys.argv[2])), total)))


if __name__ == "__main__":
    main()

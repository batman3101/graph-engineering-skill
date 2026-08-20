#!/usr/bin/env python3
"""
Lightweight Graph Engineering lint helper.

It validates a generic DAG JSON file, not Mermaid.
Expected keys:
  nodes: [{"id": "...", ...}]
  edges: [{"from": "...", "to": "...", "type": "...", "routing_owner": "..."}]
  start_node: optional
  success_nodes: optional
"""

import json
import sys
from collections import defaultdict, deque

VALID_OWNERS = {"deterministic", "model", "human", "external"}
DECISION_TYPES = {"conditional", "loop", "escalation"}

def lint(data):
    errors = []
    warnings = []

    nodes = data.get("nodes", [])
    edges = data.get("edges", [])
    ids = [n.get("id") for n in nodes]

    if not ids:
        errors.append("No nodes defined.")
        return errors, warnings

    if any(not x for x in ids):
        errors.append("Every node must have a non-empty id.")

    if len(ids) != len(set(ids)):
        errors.append("Duplicate node ids found.")

    node_set = set(ids)
    incoming = defaultdict(list)
    outgoing = defaultdict(list)

    for e in edges:
        src, dst = e.get("from"), e.get("to")
        if src not in node_set:
            errors.append(f"Edge source does not exist: {src}")
        if dst not in node_set:
            errors.append(f"Edge target does not exist: {dst}")
        if src in node_set and dst in node_set:
            outgoing[src].append(dst)
            incoming[dst].append(src)

        etype = e.get("type", "sequential")
        if etype in DECISION_TYPES and e.get("routing_owner") not in VALID_OWNERS:
            errors.append(
                f"Edge {src}->{dst} type={etype} requires routing_owner "
                f"in {sorted(VALID_OWNERS)}."
            )
        if etype == "loop" and not e.get("condition"):
            errors.append(
                f"Loop edge {src}->{dst} has no condition (stop rule required)."
            )

    start = data.get("start_node")
    if not start:
        candidates = [n for n in ids if not incoming[n]]
        if len(candidates) == 1:
            start = candidates[0]
        else:
            warnings.append(
                f"Could not infer one start node; candidates={candidates}."
            )
    elif start not in node_set:
        errors.append(f"start_node does not exist: {start}")

    if start in node_set:
        seen = {start}
        q = deque([start])
        while q:
            cur = q.popleft()
            for nxt in outgoing[cur]:
                if nxt not in seen:
                    seen.add(nxt)
                    q.append(nxt)
        unreachable = sorted(node_set - seen)
        if unreachable:
            errors.append(f"Unreachable nodes: {unreachable}")

    success_nodes = data.get("success_nodes", [])
    for n in success_nodes:
        if n not in node_set:
            errors.append(f"Unknown success node: {n}")

    terminal = [n for n in ids if not outgoing[n]]
    if not terminal:
        warnings.append("No terminal node found; graph may contain only cycles.")

    for node in nodes:
        ntype = node.get("type")
        if ntype in {"deployment", "tool"} and node.get("high_risk"):
            has_comp = bool(node.get("compensation"))
            has_human = bool(node.get("human_gate"))
            if not (has_comp or has_human):
                warnings.append(
                    f"High-risk node {node.get('id')} has no compensation or human_gate."
                )
        if node.get("retry", {}).get("max_attempts") is None and node.get("retry"):
            warnings.append(
                f"Node {node.get('id')} retry policy has no max_attempts."
            )
        if node.get("important") and not node.get("completion_evidence"):
            warnings.append(
                f"Important node {node.get('id')} has no completion_evidence."
            )

    # Fan-out declarations must be bounded and have a reducer.
    for fo in data.get("fanouts", []):
        if not fo.get("max_parallel"):
            warnings.append(
                f"Fanout on {fo.get('worker_node')} has no max_parallel (hard cap required)."
            )
        if not fo.get("fanin_reducer"):
            warnings.append(
                f"Fanout on {fo.get('worker_node')} has no fanin_reducer."
            )

    # Fan-in guard: join nodes (2+ incoming) should declare expected_inputs
    # so silent node failures cannot produce a 'complete' report.
    for n in nodes:
        nid = n.get("id")
        if len(incoming.get(nid, [])) >= 2 and not n.get("expected_inputs"):
            warnings.append(
                f"Join node {nid} has {len(incoming[nid])} incoming edges but no "
                f"expected_inputs guard (silent-failure risk)."
            )

    return errors, warnings

def main():
    if len(sys.argv) != 2:
        print("Usage: python graph_lint.py graph.json")
        raise SystemExit(2)

    with open(sys.argv[1], "r", encoding="utf-8") as f:
        data = json.load(f)

    errors, warnings = lint(data)

    for w in warnings:
        print(f"WARNING: {w}")
    for e in errors:
        print(f"ERROR: {e}")

    if errors:
        raise SystemExit(1)

    print("PASS: Graph lint completed without errors.")

if __name__ == "__main__":
    main()

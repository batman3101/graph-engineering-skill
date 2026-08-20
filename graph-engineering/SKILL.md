---
name: graph-engineering
description: Convert a user's intent, development request, automation idea, or operational process into a validated execution graph for Codex or Claude Code. Use when work has meaningful dependencies, parallelism, branching, retries, validation gates, checkpoints, human approval, or multi-agent coordination. Do not use for trivial one-step edits.
compatibility: "Designed for Codex and Claude Code. Produces Mermaid plus executable Markdown workflow contracts."
metadata:
  version: "4.0.0"
---

# Graph Engineering

Turn ambiguous intent into a **validated execution contract**, not merely a diagram.

## Trigger

Use this skill when one or more are true:

- 3+ meaningful dependent stages
- parallelizable work
- branching or routing decisions
- build/test/review gates
- retry, rollback, compensation, or resume
- multiple agents/owners/tools
- long-running or cross-session work
- destructive or production operations
- user explicitly asks for graph/workflow/DAG/Graph Engineering

Do **not** force graph architecture onto trivial tasks.

## Required workflow

1. Parse user intent.
2. Run the Complexity Gate from `references/GRAPH_RULES.md`.
3. Discover current repository/system facts before committing to a route.
4. Define measurable Definition of Done.
5. Decompose work into responsibility-based nodes.
6. Give important nodes a Work Contract using `references/GRAPH_SCHEMA.md`.
7. Define state ownership and reducers before parallel execution.
8. Define edges and routing owners: deterministic, model, human, or external.
9. Add fan-out/fan-in only where tasks are truly independent.
10. Add validation gates and completion evidence. For heavy fan-out or high-stakes verification, also read `references/ADVANCED.md` (fresh-context verifier, 3-lens checks, anchors, layered fan-in, fan-in guard, model tiering).
11. Add retry, recovery, compensation, checkpoint, or fork paths where needed.
12. Add least-privilege authority boundaries.
13. Run Graph Lint using `scripts/graph_lint.py` conceptually or directly when possible.
14. Render the final workflow: use `templates/GRAPH_WORKFLOW_TEMPLATE.md` for a full contract, or `templates/GRAPH_SPEC_QUICK.md` for a small graph (<7 nodes) as a paste-ready quick spec.
15. For Codex-specific execution, read `references/CODEX_ADAPTER.md`.
16. For Claude Code-specific execution, read `references/CLAUDE_CODE_ADAPTER.md`.

## Core rules

- Repository/system reality overrides the initial plan.
- A node is complete only when evidence proves its postconditions.
- Prefer deterministic routing over model routing when rules can decide.
- Prefer tests, compilers, schemas, lint, and runtime checks over model self-review.
- Parallel nodes must not silently write the same files/state without deterministic merge rules.
- Side-effect nodes that can retry/resume should be idempotent.
- High-risk irreversible operations require an explicit human gate unless the user clearly delegated that authority.
- Large graphs must be hierarchical; use subgraphs rather than a flat wall of nodes.
- The graph must include failure behavior, not only the happy path.
- Builder and verifier must never share context; the verifier receives only artifacts, diffs, and test output (fresh context).
- Every graph needs at least one anchor: an unarguable signal such as an actually-run test, real measured data, or a frozen rule. Topology does not buy truth; anchors do.
- Fan-in nodes must count received inputs against expected inputs and halt on a mismatch; never synthesize a "complete" report from partial data.
- Large fan-ins must be layered (batch summaries first), never a raw pile into one node.
- Tier models by node type: cheap models for mechanical nodes, strong models for judgment nodes, plain code for reduce steps.
- Dynamic discovery loops stop after two consecutive rounds with zero new findings, under a hard agent cap.
- Do not expose private chain-of-thought; record concise decisions, assumptions, evidence, and outcomes only.

## Default deliverables

Unless the user asks otherwise, produce:

1. `GRAPH_<TASK>.md` — human-readable execution contract
2. Mermaid flowchart
3. Node Work Contracts
4. Validation / recovery / approval rules
5. Codex or Claude Code execution instructions
6. Graph Lint result

Optional:
- `GRAPH_<TASK>.json` using the generic DAG schema
- implementation blueprint for LangGraph or another orchestration framework

## Invocation examples

User:
> Graph Engineering으로 로그인 기능 구현 워크플로우 만들어줘.

User:
> 이 작업을 Codex가 병렬 실행할 수 있게 그래프로 설계해줘.

User:
> Claude Code용으로 subagent와 validation gate까지 포함한 graph workflow를 만들어줘.

## Reference loading

Load only what is needed:

- Graph design / complexity / validation → `references/GRAPH_RULES.md`
- Pattern catalog (Pipeline, Fan-out/in, Diamond, Verifier, Human Gate) with Mermaid → `references/PATTERNS.md`
- Advanced supplement (fresh-context verifier, 3-lens, anchors, fan-in traps, model tiering, discovery stop rule) → `references/ADVANCED.md`
- Node/edge/state JSON/YAML contracts → `references/GRAPH_SCHEMA.md`
- Codex execution → `references/CODEX_ADAPTER.md`
- Claude Code execution → `references/CLAUDE_CODE_ADAPTER.md`
- Full output document → `templates/GRAPH_WORKFLOW_TEMPLATE.md`
- Quick paste-ready spec (small graphs) → `templates/GRAPH_SPEC_QUICK.md`
- Example → `examples/OEE_FANUC_EXAMPLE.md`

## Final quality gate

Before returning a graph, confirm:

- no unreachable node
- no loop without a stop condition
- no ambiguous decision owner
- no high-risk side effect without rollback/approval handling
- no parallel file/state conflict without ownership/merge rules
- all terminal success paths satisfy Definition of Done
- every important completion claim has evidence

# Codex Adapter

## Skill locations

Use one:

- Personal/global: `$HOME/.agents/skills/graph-engineering/SKILL.md`
- Repository: `<repo>/.agents/skills/graph-engineering/SKILL.md`

Codex scans `.agents/skills` from the current working directory up to the repository root and also loads `$HOME/.agents/skills`.

## Recommended repository layout

```text
repo/
├─ AGENTS.md
├─ .agents/
│  └─ skills/
│     └─ graph-engineering/
│        ├─ SKILL.md
│        ├─ references/
│        ├─ templates/
│        ├─ scripts/
│        └─ examples/
└─ docs/
   └─ workflows/
      └─ GRAPH_<TASK>.md
```

## Role separation

- `AGENTS.md`: always-on repository rules and facts
- Graph Engineering Skill: reusable procedure
- `GRAPH_<TASK>.md`: current task execution contract

## Suggested invocation

```text
Use the graph-engineering skill.
Turn this request into GRAPH_<TASK>.md before implementation.
Validate the graph, then execute it node-by-node.
Do not skip validation, recovery, approval, or compensation edges.
Attach evidence after every completed node.
```

Or explicitly invoke the skill if your Codex interface supports skill selection/invocation.

## Parallel execution

If parallel coding is worthwhile:
- assign non-overlapping file ownership
- prefer separate git worktrees/branches
- fan-in through an integration/review node
- validate combined diff, not only each worker's local result

## Re-plan rule

Re-plan when repository facts invalidate assumptions. Preserve already validated completed nodes whenever possible.

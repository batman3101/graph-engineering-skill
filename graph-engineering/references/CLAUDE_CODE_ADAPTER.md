# Claude Code Adapter

## Skill locations

Use one:

- Personal/global: `~/.claude/skills/graph-engineering/SKILL.md`
- Repository: `<repo>/.claude/skills/graph-engineering/SKILL.md`

The directory name becomes the normal slash command name, so this skill can be invoked as:

```text
/graph-engineering
```

Claude Code can also load it automatically when the description matches the request.

## Recommended division of responsibility

```text
Skill     = reusable reasoning/workflow
Subagent  = isolated specialist context
Hook      = deterministic enforcement
```

## Recommended patterns

Use subagents for:
- large codebase exploration
- independent implementation slices
- independent review/verification

Use deterministic hooks for:
- blocking dangerous commands
- preventing forbidden file writes
- post-edit lint/format
- pre-stop DoD validation

## Example invocation

```text
/graph-engineering
현재 로그인 기능을 리팩터링하려고 한다.
먼저 실행 그래프를 만들고 graph lint를 통과시킨 뒤,
독립적인 작업은 subagent로 분리하고,
각 단계의 completion evidence를 남겨라.
```

## Skill vs CLAUDE.md

Keep stable project facts/rules in `CLAUDE.md`.
Keep reusable multi-step Graph Engineering logic in this Skill.

## Isolation

For independent high-risk experiments, use isolated worktrees/branches when available rather than letting parallel workers edit the same files.

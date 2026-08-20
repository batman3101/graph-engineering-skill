# Graph Engineering Rules

## 1. Complexity Gate

Score each dimension 0–2:

- dependency depth
- parallelism
- branching
- recovery need
- human approval
- cross-session resume
- multiple owners

Guidance:

- 0–3: single agent loop
- 4–6: structured linear workflow
- 7–10: graph workflow
- 11+: hierarchical graph + subgraphs

Override upward for production deploy, destructive operations, DB migrations, multi-agent parallel edits, cross-session resume, or audit-heavy work.

## 2. Node design

A node is a responsibility boundary, not a function call.

Every important node should define:
- objective
- reads
- writes
- forbidden writes
- inputs
- outputs
- preconditions
- postconditions
- validation
- completion evidence
- retry policy
- failure route
- authority

## 3. Routing ownership

Each decision edge declares one owner:

- deterministic: code/rules/test exit code
- model: judgment/semantic interpretation
- human: approval/accountability
- external: API, DB, CI, device, or external reality

Prefer deterministic when possible.

## 4. Fact-grounded routing

Before executing a node, verify its preconditions against current repository/system reality.

Examples:
- file already exists?
- endpoint already exists?
- migration already applied?
- tests already failing before changes?
- branch dirty?
- dependency installed?
- device reachable?

Do not blindly follow stale assumptions.

## 5. Context budget

Give each node only necessary context. Use subagents primarily for context isolation and independent work, not just to increase agent count.

Return concise evidence:
- conclusion
- file/line or artifact reference
- relevant files
- risks
- decisions needed

## 6. Parallelism

Parallelize only when:
- dependencies allow it
- file ownership does not conflict
- state writes have deterministic reducers
- side effects do not race

Possible reducers:
- replace
- append
- unique_union
- merge_map
- min/max
- custom deterministic reducer

## 7. Dynamic fan-out

Use dynamic fan-out when work item count is discovered at runtime:
- files
- endpoints
- tickets
- machines
- failed tests
- documents

Define:
- source collection
- worker contract
- max parallelism
- fan-in reducer

## 8. Checkpointing

Checkpoint before/after:
- expensive operations
- large code changes
- external writes
- fan-in
- human approval
- deploy/migration

Checkpoint stores:
- completed nodes
- state
- artifacts
- decisions
- pending requests
- evidence
- resume node

## 9. Retry and idempotency

Every retry loop needs:
- stop condition
- max retry or equivalent bound
- failure classification

Side-effect nodes should have idempotency keys or existence checks where practical.

## 10. Compensation

Side effects should define rollback/compensation where feasible:
- deploy → rollback
- create resource → delete resource
- feature enable → disable
- migration → down migration / restore / manual recovery gate

## 11. Validation evidence priority

Prefer:
1. deterministic tests
2. compiler/type checker
3. schema validation
4. static analysis/lint
5. runtime observation
6. browser/screenshot verification
7. independent reviewer
8. model self-review

## 12. Independent verification

Builder and validator should be separated for important work. Give the validator requirement + artifact/diff + test output + expected behavior rather than the builder's long reasoning.

## 13. Adversarial review

For auth, payments, migrations, production systems, security, or major refactors, optionally add a reviewer whose explicit task is to find:
- hidden assumptions
- failure modes
- edge cases
- rollback gaps
- data loss/security risk

## 14. Speculative parallelism

If uncertainty is high and experiments are cheap, try 2–3 approaches in isolated branches/worktrees, then select by tests/benchmark/simplicity/maintainability.

## 15. Progressive commitment

Make reversible decisions early. Defer irreversible decisions until evidence is strong.

## 16. Authority

Model an authority graph separately from data flow.

Typical pattern:
Research(read) → Planner(plan) → Builder(write) → Validator(test) → Human(approve) → Deploy

Grant minimum required permissions.

## 17. Deterministic guardrails

Important enforcement should not rely only on prose prompts.

Examples:
- prevent `.env` edits
- block destructive shell commands
- require approval for production DB writes
- run formatter/lint after edits
- verify DoD before stop

## 18. Observability

Recommended event names:
- node_started
- node_completed
- node_failed
- retry_started
- checkpoint_created
- human_requested
- human_resumed
- validation_passed
- validation_failed
- graph_replanned

## 19. Critical path

Optimize the longest dependency chain before simply adding more parallel agents.

## 20. Completion contract

The graph is done only when all required terminal conditions are satisfied and backed by evidence.

# Graph Schema

Use these shapes when a structured graph representation is useful.

## Workflow

```yaml
workflow:
  id: ""
  name: ""
  objective: ""
  assumptions: []
  constraints: []
  definition_of_done: []
  start_node: N1
  success_nodes: []
  failure_nodes: []
```

## Node Work Contract

```yaml
node:
  id: N1
  name: ""
  type: intent|research|context|planning|implementation|tool|validation|review|decision|approval|integration|deployment|observation|recovery|documentation

  objective: ""

  reads: []
  writes: []
  forbidden_writes: []

  inputs: []
  outputs: []

  preconditions: []
  postconditions: []

  authority:
    read: true
    write: false
    shell: false
    db_write: false
    deploy: false
    destructive: false

  persistence: invocation
  checkpoint_after: false

  retry:
    max_attempts: 1
    stop_conditions: []

  validation: []
  completion_evidence: []

  on_failure:
    route: ""
    compensation: ""
```

## Edge

```yaml
edge:
  from: N1
  to: N2
  type: sequential|conditional|parallel|join|loop|escalation|compensation
  condition: ""
  routing_owner: deterministic|model|human|external
```

## State

```yaml
state:
  key:
    owner: planner|validator|multiple|external
    merge: replace|append|unique_union|merge_map|custom_reducer
```

## Fan-out

```yaml
fanout:
  source: work_items
  worker_node: N_REVIEW
  max_parallel: 4
  fanin_reducer: aggregate_findings
```

## Checkpoint

```yaml
checkpoint:
  id: C1
  after_node: N4
  save:
    - completed_nodes
    - state
    - artifacts
    - decisions
    - evidence
```

## Generic DAG JSON

```json
{
  "workflow": {
    "id": "workflow-id",
    "name": "Workflow name",
    "objective": "Objective"
  },
  "nodes": [],
  "edges": [],
  "state": {},
  "checkpoints": [],
  "human_gates": []
}
```

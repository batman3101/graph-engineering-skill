# GRAPH_OEE_FANUC_INTEGRATION — Example

## Objective

Automatically ingest FANUC Robodrill production counter, alarms, runtime, and downtime data into an existing Supabase-backed OEE application without requiring operators to manually duplicate machine data.

## Selected mode

Hierarchical Graph, because the work crosses machine connectivity, edge collection, database contract, application integration, validation, and production rollout.

## Graph

```mermaid
flowchart TD
    A[Inspect current OEE app]
    B[Verify FANUC controller connectivity/options]
    C[Define machine data contract]
    D1[Design edge collector]
    D2[Design Supabase schema/API]
    D3[Design OEE app mapping]
    E[Build pilot for one machine]
    F[Connectivity test]
    G[Data integrity validation]
    H{Evidence passes?}
    I[Diagnose and repair]
    J[Human pilot approval]
    K[Scale rollout]
    L[Monitoring]
    M[Done]

    A --> B --> C
    C --> D1
    C --> D2
    C --> D3
    D1 --> E
    D2 --> E
    D3 --> E
    E --> F --> G --> H
    H -- No --> I --> E
    H -- Yes --> J --> K --> L --> M
```

## Key evidence

- counter values match machine display over a defined sample window
- alarm timestamps are preserved
- runtime/downtime totals reconcile within accepted tolerance
- reconnect does not duplicate records
- current manual OEE workflow remains usable during pilot

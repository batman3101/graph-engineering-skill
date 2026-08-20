# Graph Engineering Skill Package

사용자의 자연어 의도를 Codex / Claude Code에서 실행할 수 있는 **검증된 작업 그래프**로 변환하는 설치형 Skill 패키지입니다.

## 구성

```text
graph-engineering/
├─ SKILL.md
├─ references/
│  ├─ GRAPH_RULES.md          # 설계 규칙 20조 (Complexity Gate, 라우팅, 체크포인트 등)
│  ├─ PATTERNS.md             # 패턴 카탈로그 5종 + Mermaid + 안티패턴
│  ├─ ADVANCED.md             # 보완: fresh-context 검증, 3-lens, 앵커, fan-in 트랩, 모델 티어링
│  ├─ GRAPH_SCHEMA.md
│  ├─ CODEX_ADAPTER.md
│  └─ CLAUDE_CODE_ADAPTER.md
├─ templates/
│  ├─ GRAPH_WORKFLOW_TEMPLATE.md   # 정식 실행 계약 문서
│  └─ GRAPH_SPEC_QUICK.md          # 소형 그래프용 붙여넣기 축약 스펙 5종
├─ examples/
│  ├─ OEE_FANUC_EXAMPLE.md
│  └─ SAMPLE_GRAPH.json
└─ scripts/
   └─ graph_lint.py
```

## 가장 쉬운 사용법

### Codex 전역 설치

이 `graph-engineering` 폴더 전체를 다음 위치에 복사:

- macOS/Linux: `~/.agents/skills/graph-engineering/`
- Windows: `%USERPROFILE%\.agents\skills\graph-engineering\`

그 뒤 Codex에서 예:

```text
graph-engineering 스킬을 사용해서
현재 프로젝트에 사용자 승인 기반 로그인 기능을 추가하는
실행 그래프를 먼저 만들어줘.
GRAPH_AUTH.md로 작성하고 graph lint 후 구현까지 진행해.
```

### Claude Code 전역 설치

폴더 전체를:

- macOS/Linux: `~/.claude/skills/graph-engineering/`
- Windows: `%USERPROFILE%\.claude\skills\graph-engineering\`

Claude Code에서는 직접:

```text
/graph-engineering 로그인 시스템 리팩터링 workflow를 만들어줘.
```

라고 호출할 수 있습니다.

## 프로젝트 전용 설치

Codex:
`<project>/.agents/skills/graph-engineering/`

Claude Code:
`<project>/.claude/skills/graph-engineering/`

프로젝트 폴더에 넣고 Git에 포함하면 팀원과 동일한 workflow 규칙을 공유하기 쉽습니다.

## 권장 2단계 사용 방식

### 1단계 — 그래프만 설계

```text
graph-engineering을 사용해 이 요구사항을 분석해.
아직 코드는 수정하지 말고 GRAPH_<TASK>.md만 만들어.
Complexity Gate, node contracts, validation, recovery,
parallel plan, Graph Lint까지 포함해.
```

그래프를 사람이 먼저 검토합니다.

### 2단계 — 승인 후 실행

```text
GRAPH_<TASK>.md를 실행 계약으로 사용해서 구현을 시작해.
dependency-ready node만 실행하고,
각 node 완료 후 evidence를 남겨.
graph에 없는 고위험 작업은 실행하지 마.
```

이 방식이 가장 안전합니다.

## 빠른 one-shot 방식

위험도가 낮은 개발 작업:

```text
graph-engineering 스킬을 사용해 이 기능을 분석하고,
graph lint를 통과한 실행 그래프를 만든 다음 그대로 구현해.
테스트가 실패하면 recovery edge를 따르고,
Definition of Done이 모두 검증되면 종료해.
```

## Graph Linter 사용

Skill이 JSON DAG도 만든 경우:

```bash
python scripts/graph_lint.py examples/SAMPLE_GRAPH.json
```

이 스크립트는 기본적으로:
- 존재하지 않는 node 참조
- unreachable node
- decision edge routing owner 누락
- **loop edge의 종료 조건 누락 (ERROR)**
- terminal node 이상
- high-risk node의 보상/승인 누락
- 중요한 node의 evidence 누락
- **fanout의 max_parallel / fanin_reducer 누락 (하드캡 강제)**
- **join node의 expected_inputs 누락 (silent failure 방지 가드)**

등을 검사합니다.

## 초보자에게 권장하는 호출 공식

아래 문장만 기억해도 됩니다.

```text
graph-engineering 스킬을 사용해
[내가 하고 싶은 일]을 분석하고,
먼저 실행 그래프 문서를 만들어줘.
그래프를 lint한 후,
안전한 범위에서 node 순서대로 구현해.
각 node가 끝날 때 실제 테스트 증거를 남겨.
```

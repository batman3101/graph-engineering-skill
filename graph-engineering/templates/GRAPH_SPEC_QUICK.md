# GRAPH SPEC 템플릿 (붙여넣기용)

간단한 워크플로우는 전체 md 문서 대신 아래 **GRAPH SPEC** 축약 형식으로도 산출 가능하다.
Claude Code에서는 프롬프트를 "workflow"로 시작하면 그래프로 실행된다.

## 기본 형식

```
▸ GRAPH SPEC
GOAL:       [목표 한 문장]
FAN OUT:    [병렬 작업 정의 — 무엇을 기준으로 몇 개로 나누는가]
RULE:       [모든 산출물이 지켜야 할 계약 — 예: 근거 링크+날짜 필수]
VERIFY:     [검증 노드 — fresh context, 판정 기준]
MERGE:      [종합 규칙 — 통과분만 사용]
CAP:        [하드 리밋 — 파일 수/에이전트 수/재시도 횟수]
ON FAIL:    [실패 노드 처리 — 절대 조용히 건너뛰지 말 것]
ANCHOR:     [반박 불가 판정 근거 — 실제 테스트/실측 데이터]
HUMAN GATE: [사람 승인 지점]
REPORT:     [최종 산출물 — 받은 입력 수를 기대 수와 대조하여 명시]
```

## 예시 1: 코드 감사 (보안/품질)

```
▸ GRAPH SPEC
GOAL:       src/routes/ 아래 모든 라우트의 인증 누락 감사
FAN OUT:    파일당 에이전트 1개, 병렬 (읽기 전용: Read, Grep, Glob만)
VERIFY:     후보 발견마다 독립 검증자(fresh context)가 원본 파일 재확인
CAP:        첫 실행 20개 파일
ON FAIL:    응답 없는 파일은 반드시 플래그, 건너뛰기 금지
MERGE:      검증 통과 발견만 route-auth-report.md에 취합
REPORT:     검사 파일 목록 + 기각/통과 발견 분리 + 근거 스니펫
HUMAN GATE: 코드 수정 제안 전 반드시 승인 대기
```

## 예시 2: 의사결정용 리서치

```
▸ GRAPH SPEC
GOAL:       [질문]에 대한 의사결정급 리서치
FAN OUT:    5개 관점으로 분해, 관점당 리서처 1개 병렬
RULE:       모든 발견에 출처 링크 + 날짜 필수
VERIFY:     회의론자 노드가 각 발견 반증 시도, 실패한 발견 폐기
MERGE:      생존 발견을 신뢰도순으로 보고서화
REPORT:     research-report.md 저장 후 상위 발견 요약
HUMAN GATE: 이후 어떤 변경도 승인 없이 금지
```

## 예시 3: 대량 리팩토링 스윕

```
▸ GRAPH SPEC
GOAL:       100라인 초과 함수 전수 조사 및 리팩토링 제안
FAN OUT:    파일당 에이전트 1개 병렬 (git worktree로 작업 공간 격리)
VERIFY:     제안별 독립 검증자 (fresh context)
DEDUPE:     기존 발견과 중복 제거
CAP:        첫 실행 50개 파일
REPORT:     회수된 결과 수 명시 (silent failure 방지)
```

## 예시 4: 제조/품질 문서 파이프라인 (공장 워크플로우 예)

```
▸ GRAPH SPEC
GOAL:       [설비/공정] 작업표준서 초안 → 검증 → 이중언어 문서화
FAN OUT (병렬):
  1. 기존 표준서/불량 이력 수집
  2. 공정 파라미터·판정 기준 정리
  3. 사진/도해 요구사항 목록화
MERGE:      3개 결과를 개요로 종합 후 초안 작성
VERIFY:     체크리스트 검증 (IQC/PQC/OQC 판정 기준 포함 여부, 단위 일치)
ANCHOR:     실제 공정 데이터/현행 판정 기준표 (수정 금지 항목)
HUMAN GATE: 현장 배포 전 관리자 승인
REPORT:     KR/VN 이중언어 md → 이후 pptx/docx 변환
```

## 예시 5: Dynamic Discovery (규모 미상 작업)

```
▸ GRAPH SPEC
GOAL:       리포지토리에서 [보안 이슈/에러 처리 누락/데드 코드] 사냥
FAN OUT:    발견자 병렬 실행
DEDUPE:     신규 발견을 기존 발견 전체와 대조
VERIFY:     생존 발견에 독립 검증자
LOOP:       연속 2라운드 신규 발견 0이면 종료
CAP:        총 에이전트 수 하드 리밋 (폭주 방지)
REPORT:     심각도순 최종 목록
```

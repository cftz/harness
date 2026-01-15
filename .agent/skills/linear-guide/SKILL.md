---
name: linear-guide
description: |
  Linear 작업 시 행동 지침. Linear 이슈, 문서, 댓글 등을 다룰 때 이 가이드라인을 따라야 합니다.

  IMPORTANT: Linear 관련 작업을 수행할 때 반드시 이 지침을 참고하세요.
user-invocable: false
---

# Linear Guide

Linear 관련 작업 수행 시 따라야 하는 행동 지침입니다.

## 핵심 원칙

### 1. Skill 우선 사용

Linear 작업 시 **MCP보다 Skill을 우선 사용**해야 합니다.

| 작업 | 사용할 Skill | MCP 사용 금지 |
|------|-------------|---------------|
| 이슈 조회/생성/수정 | `linear-issue` | linear MCP get/create/update |
| 문서 조회/생성/수정 | `linear-document` | linear MCP document |
| 댓글 조회/생성 | `linear-comment` | linear MCP comment |
| 이슈 관계 관리 | `linear-issue-relation` | linear MCP relation |
| 워크플로우 상태 조회 | `linear-state` | linear MCP state |
| 팀 조회 | `linear-team` | linear MCP team |
| 프로젝트 조회 | `linear-project` | linear MCP project |
| 라벨 조회 | `linear-issue-label` | linear MCP label |
| 현재 컨텍스트 | `linear-current` | - |

**예외**: Skill에서 지원하지 않는 기능만 MCP 사용 허용

### 2. 이슈 리스트 조회 시 필수 파라미터

이슈 목록을 가져올 때는 **반드시 다음 파라미터를 명시**해야 합니다:

```
skill: linear-issue
args: list PROJECT_ID=<project_id> STATE=<state> FIRST=<limit>
```

| 파라미터 | 필수 | 설명 |
|----------|------|------|
| `PROJECT_ID` | **Yes** | 프로젝트 ID 또는 이름 |
| `STATE` | **Yes** | 상태 필터 (예: Todo, In Progress, Done) |
| `FIRST` | **Yes** | 가져올 최대 개수 (기본값 없음, 명시 필수) |

**잘못된 예시:**
```
skill: linear-issue
args: list
```

**올바른 예시:**
```
skill: linear-issue
args: list PROJECT_ID=cops STATE=Todo FIRST=10
```

## 사용 가능한 Linear Skills

| Skill | 용도 |
|-------|------|
| `linear-issue` | 이슈 CRUD (get, list, create, update) |
| `linear-document` | 문서 CRUD (get, list, search, create, update) |
| `linear-comment` | 댓글 (list, create) |
| `linear-issue-relation` | 이슈 관계 (create, list, update, delete) |
| `linear-state` | 워크플로우 상태 조회 |
| `linear-team` | 팀 목록 조회 |
| `linear-project` | 프로젝트 목록 조회 |
| `linear-issue-label` | 라벨 목록 조회 |
| `linear-current` | 현재 팀/프로젝트/사용자 컨텍스트 |

## 체크리스트

Linear 작업 전 확인:

- [ ] 해당 작업을 수행하는 Skill이 있는가?
- [ ] 이슈 리스트 조회 시 PROJECT_ID, STATE, FIRST가 모두 명시되었는가?
- [ ] MCP 사용이 불가피한 경우인가? (Skill 미지원 기능)

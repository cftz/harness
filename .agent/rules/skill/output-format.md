# Skill Output Format Rule

모든 스킬은 다음 표준 포맷으로 결과를 출력합니다.

## Standard Format

| Status  | Format                                            |
| ------- | ------------------------------------------------- |
| SUCCESS | `STATUS: SUCCESS` + `OUTPUT: {...}` (OUTPUT 선택) |
| AWAIT   | `STATUS: AWAIT` + `CONTEXT_PATH: {path}`          |
| ERROR   | `STATUS: ERROR` + `OUTPUT: {error message}`       |

## 핵심 원칙

- STATUS는 스킬 실행 상태만 나타냄
- 스킬 결과(리뷰 PASS/FAIL 등)는 OUTPUT에 포함
- AWAIT 시 모든 정보는 Context 문서에 저장 (OUTPUT 없음)
- ERROR 시 OUTPUT에 에러 메시지 문자열

## 예시

**SUCCESS (OUTPUT 있는 경우):**
```
STATUS: SUCCESS
OUTPUT:
  RESULT: CHANGES_REQUIRED
  REVIEW_PATH: .agent/tmp/review.md
```

**SUCCESS (OUTPUT 없는 경우):**
```
STATUS: SUCCESS
```

**AWAIT:**
```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

**ERROR:**
```
STATUS: ERROR
OUTPUT: Linear API 호출 실패: 401 Unauthorized
```

## AWAIT 상태 처리

AWAIT 상태는 스킬이 사용자 입력이나 외부 이벤트를 기다릴 때 사용합니다.

- CONTEXT_PATH에 지정된 문서에 모든 컨텍스트 정보 저장
- Context 문서는 `context` 스킬을 사용하여 생성
- Resume 시 CONTEXT_PATH의 문서를 로드하여 상태 복원

## OUTPUT 필드 정의

각 스킬의 SKILL.md에서는 `## Output` 섹션에 SUCCESS/AWAIT/ERROR 형식을 정의합니다.

**OUTPUT 필드가 있는 경우:**
```markdown
## Output

SUCCESS:
- DRAFT_PATH: 생성된 드래프트 경로
- RESULT: 결과 상태 (PASS/CHANGES_REQUIRED)

AWAIT: context 스킬로 Context 문서 생성

ERROR: 에러 메시지 문자열
```

**OUTPUT 필드가 없는 경우:**
```markdown
## Output

SUCCESS: (no output fields)

ERROR: 에러 메시지 문자열
```

**Note:** SUCCESS 시 OUTPUT이 없는 것은 유효함. 단, SKILL.md 문서에서 이를 명시해야 함.

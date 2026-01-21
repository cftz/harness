# Skill System Rules

스킬의 출력 형식과 AWAIT/Resume 패턴을 정의합니다.

---

## 1. Output Format

### Standard Format

| Status  | Format                                            |
| ------- | ------------------------------------------------- |
| SUCCESS | `STATUS: SUCCESS` + `OUTPUT: {...}` (OUTPUT 선택) |
| AWAIT   | `STATUS: AWAIT` + `CONTEXT_PATH: {path}`          |
| ERROR   | `STATUS: ERROR` + `OUTPUT: {error message}`       |

### 핵심 원칙

- STATUS는 스킬 실행 상태만 나타냄
- 스킬 결과(리뷰 PASS/FAIL 등)는 OUTPUT에 포함
- AWAIT 시 모든 정보는 Context 문서에 저장
- ERROR 시 OUTPUT에 에러 메시지 문자열

### 예시

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

### SKILL.md Output 섹션 작성

각 스킬의 SKILL.md에서는 SUCCESS와 ERROR만 정의합니다.

**OUTPUT 필드가 있는 경우:**
```markdown
## Output

SUCCESS:
- DRAFT_PATH: 생성된 드래프트 경로

ERROR: 에러 메시지 문자열
```

**OUTPUT 필드가 없는 경우:**
```markdown
## Output

SUCCESS: (no output fields)

ERROR: 에러 메시지 문자열
```

---

## 2. AWAIT 반환하기 (Skill 관점)

사용자 입력이 필요할 때 AskUserQuestion 대신 AWAIT를 반환합니다.

### 언제 AWAIT를 반환하는가

- 사용자 선택이 필요한 경우 (패키지 선택, 아키텍처 결정)
- 요구사항 확인이 필요한 경우
- fork context에서 실행 중일 때 (직접 AskUserQuestion 불가)

### 반환 방법

1. `checkpoint save`로 상태 저장
2. AWAIT 상태 반환

```
STATUS: AWAIT
CONTEXT_PATH: .agent/tmp/xxx-context.md
```

---

## 3. AWAIT 응답 처리하기 (Workflow 관점)

스킬이 AWAIT를 반환했을 때 workflow가 해야 할 일:

1. **Load**: `checkpoint load CONTEXT_PATH=...`로 context 로드
2. **Ask**: 질문들을 AskUserQuestion으로 변환하여 사용자에게 질문
3. **Fill**: 답변을 context 파일의 Answer 필드에 기록
4. **Validate**: `checkpoint update CONTEXT_PATH=...`로 검증
5. **Resume**: `{skill} resume CONTEXT_PATH=...`로 스킬 재개

---

## 4. Resume 커맨드 처리하기 (Skill 관점)

AWAIT를 반환하는 모든 스킬은 자동으로 resume 커맨드를 지원합니다.

### Resume 커맨드 형식

```
skill: {skill-name}
args: resume CONTEXT_PATH=<path>
```

### 처리 방법

1. **Load**: `checkpoint load`로 context 로드
   - Original invocation and parameters
   - Progress summary (what was done, why paused)
   - Partial outputs (files created, data collected)
   - Answered questions (from filled Answer fields)

2. **Validate**: 모든 질문에 답변이 있는지 확인
   ```
   skill: checkpoint
   args: update CONTEXT_PATH={CONTEXT_PATH}
   ```
   If validation fails (INCOMPLETE status), return error:
   ```
   STATUS: ERROR
   OUTPUT: Context file has unanswered questions: {list}
   ```

3. **Restore**: 저장된 상태에서 실행 재개
   - Restore execution state from Progress Summary
   - Load partial outputs from context

4. **Continue**: 답변을 적용하여 작업 계속
   - Apply answered questions to continue execution
   - Complete the skill's original task

5. **Return**: SUCCESS 또는 새로운 AWAIT 반환

### Error Handling

| Error                   | Response                                          |
| ----------------------- | ------------------------------------------------- |
| Context file not found  | `STATUS: ERROR`, `OUTPUT: Context file not found` |
| Unanswered questions    | `STATUS: ERROR`, `OUTPUT: Questions not answered` |
| Invalid context format  | `STATUS: ERROR`, `OUTPUT: Invalid context format` |

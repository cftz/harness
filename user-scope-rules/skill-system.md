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

### CRITICAL: Resume의 목적

> **Resume은 중단된 작업을 완료하는 것이다.**
>
> checkpoint 검증만 하고 끝내는 것은 resume이 아니다.
> 반드시 원래 스킬의 남은 프로세스를 끝까지 실행해야 한다.

### 필수 처리 단계 (MUST follow all steps)

**Step 1. Load** - checkpoint load로 context 로드
- Original invocation and parameters
- Progress summary (what was done, why paused)
- Partial outputs (files created, data collected)
- Answered questions (from filled Answer fields)

**Step 2. Validate** - 모든 질문에 답변이 있는지 확인
```
skill: checkpoint
args: update CONTEXT_PATH={CONTEXT_PATH}
```
If validation fails (INCOMPLETE status), return error.

**Step 3. Restore** - 원래 스킬의 프로세스 문서 로드 **(MUST)**
- Context의 `invocation` 필드에서 원래 커맨드 파악 (예: `/draft-clarify create ...` → `create`)
- **MUST READ**: `{baseDir}/references/{command}.md` 파일을 읽어서 프로세스 확인
- Progress Summary에서 **중단된 단계** 확인

**Step 4. Continue** - 중단된 단계부터 끝까지 실행 **(MUST)**
- Answered questions를 변수로 활용
- Partial outputs가 있다면 재사용
- **MUST EXECUTE**: reference 문서의 프로세스를 중단된 단계부터 순서대로 실행
- 모든 남은 단계를 완료할 때까지 진행
- **DO NOT SKIP**: 파일 생성, 출력물 작성 등 모든 단계 수행

**Step 5. Return** - SUCCESS 또는 새로운 AWAIT 반환
- 모든 단계 완료 시: 원래 커맨드의 Output 형식에 맞게 SUCCESS 반환
- 추가 질문 필요 시: 새로운 AWAIT 반환

### WARNING: 잘못된 Resume 패턴

```
# WRONG - checkpoint 검증만 하고 끝냄
1. checkpoint load ✓
2. checkpoint update → READY ✓
3. SUCCESS 반환 ✗ ← 이렇게 하면 안 됨!

# CORRECT - 원래 작업을 완료함
1. checkpoint load ✓
2. checkpoint update → READY ✓
3. {baseDir}/references/{command}.md 읽기 ✓
4. 남은 프로세스 실행 (파일 생성 등) ✓
5. SUCCESS 반환 (생성된 파일 경로 포함) ✓
```

### WARNING: 하위 스킬 SUCCESS ≠ 전체 작업 완료

> **하위 스킬의 SUCCESS를 자신의 최종 결과로 착각하지 마라.**

실행 중 호출하는 하위 스킬(checkpoint, mktemp 등)이 SUCCESS를 반환해도:
- 그것은 **해당 스킬만** 완료된 것
- **전체 작업의 완료가 아님**
- reference 문서의 **모든 단계**가 끝날 때까지 계속 진행해야 함

```
# WRONG - 하위 스킬 SUCCESS를 최종 결과로 반환
mktemp 호출 → "STATUS: SUCCESS, FILE_PATHS: ..."
→ 이걸 그대로 반환 ✗

# CORRECT - 모든 단계 완료 후 반환
mktemp 호출 → 파일 경로 받음
→ Write 도구로 파일에 내용 작성 (Step 7)
→ 모든 단계 완료 후 SUCCESS 반환 ✓
```

### 예시: draft-clarify resume

```
# Context 로드 결과:
invocation: /draft-clarify create REQUEST="사용자 인증 기능 추가"
Progress Summary: "Step 3에서 중단됨 - 질문 5개 생성 완료"
Answered Questions: Q1=Email/Password, Q2=Next.js, ...

# 올바른 처리 흐름:
1. checkpoint load → invocation에서 커맨드 파악 → "create"
2. checkpoint update → READY 확인
3. Read {baseDir}/references/create.md ← MUST!
4. Progress Summary에서 "Step 3" 중단 확인
5. create.md의 Step 4부터 끝까지 실행: ← MUST!
   - Step 4: Break Down into Tasks (태스크 분해)
   - Step 5: Save Original Prompt (프롬프트 파일 저장)
   - Step 6: Create Output Files (출력 파일 생성)
   - Step 7: Write Draft Task Documents (태스크 문서 작성)
6. SUCCESS 반환 (PROMPT_PATH, DRAFT_PATHS 포함)
```

### Error Handling

| Error                   | Response                                          |
| ----------------------- | ------------------------------------------------- |
| Context file not found  | `STATUS: ERROR`, `OUTPUT: Context file not found` |
| Unanswered questions    | `STATUS: ERROR`, `OUTPUT: Questions not answered` |
| Invalid context format  | `STATUS: ERROR`, `OUTPUT: Invalid context format` |

# Best Practice Approach

Use this approach when the problem is **General** - well-known with existing standardized solutions.

## When to Use

```
┌─────────────────────────────────────────────────────────────────────┐
│  ✓ 로그인/인증 구현                                                 │
│  ✓ 캐싱 전략                                                        │
│  ✓ API 설계                                                         │
│  ✓ 에러 핸들링                                                      │
│  ✓ 데이터베이스 스키마 설계                                         │
│  ✓ 테스트 전략                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Process

### 1. Formulate Search Queries

Create multiple search queries to cover different aspects:

| Query Type | Template | Example |
|------------|----------|---------|
| Direct | `"{problem}" best practices` | "caching best practices" |
| Pattern | `"{problem}" design pattern` | "caching design pattern" |
| Architecture | `"{problem}" architecture` | "caching architecture" |
| Domain-specific | `"{domain}" "{problem}" solution` | "distributed systems caching solution" |
| Comparison | `"{solution A}" vs "{solution B}"` | "Redis vs Memcached" |

### 2. Execute WebSearch

Use `WebSearch` tool with formulated queries.

**Priority sources to look for:**
- Academic papers (Google Scholar, arXiv)
- Official documentation (framework/library docs)
- Tech company engineering blogs (Netflix, Uber, Airbnb, etc.)
- Well-known books and their summaries
- RFC documents (for protocols/standards)

### 3. Extract Information

For each relevant finding, extract:

```
┌─────────────────────────────────────────────────────────────────────┐
│  Solution Name     │ What is this approach called?                  │
├────────────────────┼────────────────────────────────────────────────┤
│  Core Principle    │ What is the fundamental idea?                  │
├────────────────────┼────────────────────────────────────────────────┤
│  Implementation    │ How is it typically implemented?               │
├────────────────────┼────────────────────────────────────────────────┤
│  Pros              │ Benefits and strengths                         │
├────────────────────┼────────────────────────────────────────────────┤
│  Cons              │ Drawbacks and limitations                      │
├────────────────────┼────────────────────────────────────────────────┤
│  When to Use       │ Ideal scenarios for this approach              │
├────────────────────┼────────────────────────────────────────────────┤
│  When NOT to Use   │ Scenarios to avoid                             │
├────────────────────┼────────────────────────────────────────────────┤
│  Reference         │ Link to source material                        │
└─────────────────────────────────────────────────────────────────────┘
```

### 4. Categorize Findings

Group solutions by approach type:

```
                    ┌─────────────────┐
                    │    Solutions    │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   Patterns    │   │   Libraries   │   │  Frameworks   │
│               │   │               │   │               │
│ - Singleton   │   │ - Redis       │   │ - Spring      │
│ - Factory     │   │ - RabbitMQ    │   │ - Django      │
│ - Observer    │   │ - Kafka       │   │ - Rails       │
└───────────────┘   └───────────────┘   └───────────────┘
```

### 5. Compile Results

Present findings in structured format with clear recommendations.

## Output Format

Follow the Output Format defined in `{baseDir}/SKILL.md`.

Use `**Source**:` for the source attribution field (reference link to documentation, article, etc.).

## Example

**Problem**: "How to implement rate limiting for API endpoints"

**Search Queries**:
- "API rate limiting best practices"
- "rate limiting design patterns"
- "distributed rate limiting architecture"
- "token bucket vs sliding window"

**Expected Findings**:
1. Token Bucket Algorithm
2. Sliding Window Algorithm
3. Fixed Window Counter
4. Leaky Bucket Algorithm
5. Redis-based distributed rate limiting

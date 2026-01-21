# Repository Layer Checklist

Check items to verify when analyzing repository layer code.

---

## Interface Separation

**Severity**: High

Verify that repositories are abstracted through interfaces.

- If the service layer directly depends on concrete repository types, mocking becomes difficult during testing
- Define repository public methods as interfaces, and services should depend on interfaces
- Interface separation also facilitates implementation replacement (e.g., migrating to a different database)

---

## Single Responsibility

**Severity**: High

Verify that each repository handles only one entity/aggregate.

- When a single repository handles multiple entities, the scope of change impact increases
- Risk of unrelated code being affected when a specific entity schema changes
- A repository should only contain CRUD and query methods for its responsible entity

---

## Business Logic Leakage

**Severity**: High

Check if business logic is mixed into the repository.

- Repositories should only handle data access (storage/retrieval)
- Conditional branching, calculations, and validation belong to the service layer
- When business logic exists in repositories, logic becomes scattered and maintenance becomes difficult
- "How to process data after retrieval" is not a decision for the repository

---

## Transaction Boundaries

**Severity**: High

Verify that transaction management occurs outside the repository (in services).

- Starting transactions inside repositories causes problems when combining multiple repositories
- When a single business operation calls multiple repositories, the entire operation cannot be wrapped in one transaction
- Transaction start/commit/rollback should be controlled at the service layer
- Repositories should perform work within the transaction context passed to them

---

## N+1 Queries

**Severity**: High

Check for patterns where queries are called inside loops.

- After retrieving N records, executing additional queries for each record results in N+1 total queries
- Performance degrades rapidly as data grows
- When related data is needed, fetch it all at once using JOIN or batch queries (IN clause)
- Query calls inside loops are almost always refactoring targets

---

## SQL Injection

**Severity**: Critical

Check if user input is directly concatenated into query strings.

- Building queries through string concatenation makes them vulnerable to SQL injection attacks
- Attackers can inject malicious SQL syntax to leak/modify/delete data
- Parameter binding (Prepared Statements) must always be used
- Even when using ORM/query builders, raw query parts need caution

---

## Error Handling

**Severity**: High

Verify that database errors are properly wrapped/transformed.

- Exposing raw database errors to upper layers can leak internal implementation (table names, column names, etc.)
- Database-specific error codes/messages should be converted to domain-level errors
- Example: "Record not found" becomes a "Not Found" domain error; constraint violations become appropriate business errors
- Log original errors but only return abstracted errors externally

---

## Connection Leaks

**Severity**: Critical

Verify that resources are returned after using query results or transactions.

- Database connections are limited resources (connection pool)
- Not returning result sets, transactions, or connections after use leads to pool exhaustion
- Pool exhaustion causes new queries to wait or timeout
- Resource release must execute regardless of error occurrence

---

## Hardcoded Queries

**Severity**: Medium

Check if table names, column names, etc. are scattered throughout the code.

- When table/column names are hardcoded as strings in multiple places, there is risk of omission during changes
- All reference locations must be found and modified when the schema changes
- Managing them in one place as constants or mapping definitions minimizes change impact
- Recommended to use ORM/query builder entity mapping features

---

## Select *

**Severity**: Medium

Check for unnecessary full column retrieval.

- SELECT * retrieves all columns including unnecessary ones, wasting network/memory
- Especially impactful when BLOB, TEXT, or other large columns exist
- Only necessary columns should be explicitly listed for retrieval
- Also prevents unexpected data from being included when columns are added to the schema

---

## Missing Pagination

**Severity**: Medium

Check for Limit/Offset when retrieving large datasets.

- Full retrieval (findAll) with large data risks memory exhaustion (OOM)
- Can suddenly cause failures in production as data accumulates
- List retrieval APIs must accept pagination parameters
- Even internal batch processing should query in chunks for safety

---

## Index Considerations

**Severity**: Medium

Check if WHERE clauses use columns without indexes.

- Using columns without indexes in conditions causes table full scans
- Query performance degrades rapidly as data grows
- Frequently searched/sorted columns need indexes
- Consider composite indexes for complex condition searches

---

## Nullable Handling

**Severity**: Medium

Check for handling of NULL-able columns.

- Mapping NULL-allowed columns to regular types risks runtime errors
- May encounter unexpected default values or errors when reading NULL values
- Should map to nullable-specific types or pointer/optional types
- Explicit handling logic needed when query results can be NULL

---

## Missing Logging

**Severity**: Low

Check if query execution/error logging exists.

- Without logging for query execution and errors, problem diagnosis during operation is difficult
- Slow queries, failed queries, and exceptional situations should be logged
- However, be careful not to include sensitive data (passwords, personal information) in logs
- Logs should include information useful for debugging: query type, execution time, affected row count

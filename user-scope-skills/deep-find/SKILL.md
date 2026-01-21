---
name: deep-find
description: |
  Recursively explores file system and caches file summaries for intelligent searching.

  Commands:
    init - Scan directory and build cache
    query - Search files based on natural language query

  Args:
    init [DIR=<path>] [GITIGNORE=true|false]
    query [DIR=<path>] QUERY="<prompt>"

  Examples:
    /deep-find init
    /deep-find init DIR=src GITIGNORE=false
    /deep-find query QUERY="Find files that handle authentication"
    /deep-find query DIR=src QUERY="API endpoint definitions"
model: claude-sonnet-4-20250514
context: fork
agent: step-by-step-agent
allowed-tools:
  - Bash
  - Task
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: "python3 {baseDir}/scripts/pretooluse-hook.py"
---

# Description

Recursively explores the file system to build a comprehensive cache of file contents and summaries. Enables intelligent searching based on natural language queries.

**IMPORTANT: Script-Only File Access**

This skill can ONLY access files through the provided scripts. Direct Read/Write tools are disabled to enforce cache consistency.

- Use `read.sh` to read files or directories (returns cached summary or full content)
- Use `write.sh` to record file summaries to cache
- Use `write-dir.sh` to record directory summaries to cache
- If cache is invalid, you MUST generate a summary and save it before proceeding

**Key Principles:**
- Each invocation operates ONLY at the given directory level
- **Skip non-essential directories**: Directories like `node_modules`, `.venv`, `dist`, `vendor` contain dependencies or build outputs - you don't need to explore them to understand the codebase
- **DIRECTORIES FIRST**: Always process subdirectories before files
- **BATCH FILES**: Process files in batches of 8 to prevent context explosion
- **PARALLEL EXECUTION**: Launch ALL Tasks/Bash calls in a SINGLE message
- Subdirectory exploration is delegated to recursive `/deep-find` calls via Task tool
- ALL file operations go through scripts (no direct Read/Write)
- Cache invalid = must re-summarize before proceeding

## Parameters

### init Command

| Parameter   | Required | Default | Description                 |
| ----------- | -------- | ------- | --------------------------- |
| `DIR`       | No       | CWD     | Target directory to scan    |
| `GITIGNORE` | No       | `true`  | Respect .gitignore patterns |

### query Command

| Parameter | Required | Default | Description                   |
| --------- | -------- | ------- | ----------------------------- |
| `DIR`     | No       | CWD     | Target directory to search    |
| `QUERY`   | Yes      | -       | Natural language search query |

## Scripts Reference

| Script                                | Purpose                                              |
| ------------------------------------- | ---------------------------------------------------- |
| `list-files.sh DIR GITIGNORE`         | List files/dirs in directory (respects gitignore)    |
| `read.sh PATH [OFFSET] [LIMIT]`       | Read file or directory with cache awareness          |
| `write.sh FILE "SUMMARY"`             | Save file summary to cache                           |
| `write-dir.sh DIR "SUMMARY"`          | Save directory summary to cache                      |
| `get-metadata.sh FILE`                | Get file metadata (size, mtime, hash) - internal use |

## Process

### Command: init

Scan the given directory and build/update cache.

**Step 1: List files and directories**

```bash
{baseDir}/scripts/list-files.sh "$DIR" "$GITIGNORE"
```

Returns JSON:
```json
{
  "files": ["file1.ts", "file2.ts"],
  "directories": ["subdir1", "subdir2"]
}
```

**Step 2: Process ALL subdirectories FIRST (parallel)**

┌──────────────────────────────────────────────────────────────┐
│  CRITICAL: Process directories BEFORE files                  │
│  Launch ALL directory Tasks in a SINGLE message              │
└──────────────────────────────────────────────────────────────┘

For ALL directories in the `directories` array, launch Task tools simultaneously:

```
// ALL tasks in ONE message:
Task(subagent_type: "step-by-step-agent", prompt: "/deep-find init DIR=$DIR/subdir1 GITIGNORE=$GITIGNORE", description: "init subdir1")
Task(subagent_type: "step-by-step-agent", prompt: "/deep-find init DIR=$DIR/subdir2 GITIGNORE=$GITIGNORE", description: "init subdir2")
Task(subagent_type: "step-by-step-agent", prompt: "/deep-find init DIR=$DIR/subdir3 GITIGNORE=$GITIGNORE", description: "init subdir3")
// Wait for ALL results together
```

**Important:**
- Do NOT use `run_in_background`
- Do NOT send Tasks one by one (sequential)
- ALL Tasks must be in a SINGLE message
- Use `step-by-step-agent` for recursive skill calls

Collect the returned summaries from each subdirectory.

(Note: Each subdirectory has its own cache entry. No need to save subdirectory summaries here.)

**Step 3: Process files in BATCHES of 8**

┌──────────────────────────────────────────────────────────────┐
│  CRITICAL: Batch processing to prevent context explosion     │
│  Max 8 files per batch → summarize → next batch              │
└──────────────────────────────────────────────────────────────┘

Divide files into batches of maximum 8 files each.

For each batch:

**3a. Read batch files (parallel Bash calls in ONE message)**:

```bash
# All read.sh calls for current batch in a SINGLE message:
{baseDir}/scripts/read.sh "$DIR/$FILE1"
{baseDir}/scripts/read.sh "$DIR/$FILE2"
{baseDir}/scripts/read.sh "$DIR/$FILE3"
# ... up to 8 files
```

**3b. Process each file result**:

**If cached (valid):**
```json
{
  "status": "cached",
  "file": "/absolute/path/to/file",
  "summary": "Previously generated summary...",
  "metadata": { "size": 1234, "mtime": 1705312200, "total_lines": 150 }
}
```
→ Use the cached summary. No action needed.

**If needs_summary (cache invalid or missing):**
```json
{
  "status": "needs_summary",
  "file": "/absolute/path/to/file",
  "content": "... file content (first 500 lines) ...",
  "metadata": { "size": 1234, "mtime": 1705312200, "total_lines": 800 },
  "slice": { "offset": 1, "limit": 500, "lines_read": 500, "has_more": true }
}
```

Default reads first 500 lines. If `has_more: true`, you MUST continue reading:
```bash
{baseDir}/scripts/read.sh "$DIR/$FILE" 501 500  # Lines 501-1000
{baseDir}/scripts/read.sh "$DIR/$FILE" 1001 500 # Lines 1001-1500
# ... continue until has_more: false
```

**IMPORTANT:** Read the ENTIRE file before generating summary. Do not summarize partial content.

→ You MUST:
1. Generate a **detailed file summary** including:
   - Main purpose/role of the file
   - Key functions/methods and what they do
   - Important classes, types, or data structures
   - Data or state being managed
   - Dependencies or relationships with other modules

   Example file summary:
   ```
   Authentication middleware for Express. Exports: verifyToken() validates JWT and attaches user to req,
   requireRole(role) checks user permissions, refreshToken() issues new JWT. Uses jsonwebtoken package.
   Depends on config/auth.ts for secret keys. Manages user session state via req.user object.
   ```

**3c. Write summaries for this batch**:

For each file that needed summary, save it:
```bash
{baseDir}/scripts/write.sh "$FILE" "Your detailed summary here"
```

(Multiple write.sh calls can be batched in parallel)

**3d. Repeat for next batch**:

Continue until all files processed.

**Example with 20 files:**
- Batch 1: files 1-8 → read (parallel) → summarize → write (parallel)
- Batch 2: files 9-16 → read (parallel) → summarize → write (parallel)
- Batch 3: files 17-20 → read (parallel) → summarize → write (parallel)

**Step 4: Record current directory summary**

After processing all files and subdirectories, generate a **broad directory summary**:
- Overall purpose of the directory
- Categories of files it contains
- How it fits into the larger codebase structure

Example directory summary:
```
Authentication and authorization module. Contains JWT token handling (auth.ts),
role-based access control (rbac.ts), OAuth providers (oauth/), and session management (session.ts).
Core security layer used by all API routes.
```

```bash
{baseDir}/scripts/write-dir.sh "$DIR" "Your directory summary here"
```

**Step 5: Return result**

Output the directory summary for the parent caller.

### Command: query

Search for files matching the query.

**Step 1: List files and directories**

```bash
{baseDir}/scripts/list-files.sh "$DIR" "true"
```

Returns JSON with `files` and `directories` arrays.

**Step 2: Read files and subdirectories in BATCHES of 8**

┌──────────────────────────────────────────────────────────────┐
│  CRITICAL: Batch cache reads to prevent context explosion    │
│  Max 8 items per batch → collect summaries → next batch      │
└──────────────────────────────────────────────────────────────┘

Combine files and directories into a single list, then process in batches of 8.

For each batch:

**2a. Read batch items (parallel Bash calls in ONE message)**:

```bash
# All read.sh calls for current batch in a SINGLE message:
{baseDir}/scripts/read.sh "$DIR/$ITEM1"
{baseDir}/scripts/read.sh "$DIR/$ITEM2"
# ... up to 8 items (files or directories)
```

**2b. Process each result**:

For files:
- **If `needs_summary`:** Cache is missing/invalid. Run `/deep-find init DIR="$DIR"` first, then restart query.
- **If `cached`:** Collect the summary for matching.

For directories:
- **If `needs_init`:** Cache is missing/invalid. Run `/deep-find init DIR="$DIR/$SUBDIR"` first.
- **If `cached`:** Collect the summary for matching.

**2c. Repeat for next batch** until all items processed.

**Step 3: Match files to query**

Review collected summaries. Identify files whose summaries suggest they contain information relevant to the query.

**Step 4: Search relevant subdirectories (parallel)**

┌──────────────────────────────────────────────────────────────┐
│  CRITICAL: Launch ALL directory Tasks in a SINGLE message    │
└──────────────────────────────────────────────────────────────┘

For each subdirectory whose name or context suggests relevance to the query, launch Task tools simultaneously:

```
// ALL tasks in ONE message:
Task(subagent_type: "step-by-step-agent", prompt: "/deep-find query DIR=$DIR/$SUBDIR1 QUERY=\"$QUERY\"", description: "query subdir1")
Task(subagent_type: "step-by-step-agent", prompt: "/deep-find query DIR=$DIR/$SUBDIR2 QUERY=\"$QUERY\"", description: "query subdir2")
// Wait for ALL results together
```

**Important:**
- Do NOT use `run_in_background`
- Do NOT send Tasks one by one (sequential)
- ALL Tasks must be in a SINGLE message
- Use `step-by-step-agent` for recursive skill calls

**Step 5: Return results**

Combine file paths from current directory and subdirectory searches:

```json
[
  "/path/to/dir/file1.ts",
  "/path/to/dir/subdir/file2.ts"
]
```

## Cache Structure

Cache files are stored in `.agent/cache/deep-find/` with path-based filenames.

```json
{
  "version": 1,
  "path": "/Users/user/project/src",
  "timestamp": "2024-01-15T10:30:00Z",
  "entries": {
    "index.ts": {
      "type": "file",
      "metadata": {
        "size": 1234,
        "mtime": 1705312200,
        "hash": "abc123..."
      },
      "summary": "Main entry point that initializes the Express server."
    },
    "utils": {
      "type": "directory",
      "metadata": {
        "list_hash": "def456...",
        "max_mtime": 1705312200
      },
      "summary": "Utility functions for string manipulation and validation."
    }
  }
}
```

## Output

### init Command

SUCCESS:
- DIR: Target directory path
- FILES_PROCESSED: Total number of files processed
- CACHED: Number of files with valid cache (no update needed)
- UPDATED: Number of files with new/updated summaries
- SUBDIRECTORIES: Number of subdirectories processed
- SUMMARY: Directory summary string

ERROR: Error message string (e.g., "Directory not found: /invalid/path")

### query Command

SUCCESS:
- QUERY: The search query used
- DIR: Target directory searched
- RESULTS: Array of matching file paths (empty array if no matches)

ERROR: Error message string (e.g., "Cache not initialized. Run /deep-find init first.")

## Quality Checklist

Before completing the skill execution, verify:

### init Command
- [ ] All non-excluded files in directory have been processed
- [ ] Subdirectories processed via recursive Task calls (in parallel)
- [ ] Files processed in batches of 8 maximum
- [ ] Cache entries written for all processed files
- [ ] Directory summary written to cache
- [ ] Output follows standard format with STATUS: SUCCESS

### query Command
- [ ] Cache exists for target directory (or init suggested)
- [ ] All cached summaries retrieved and analyzed
- [ ] Relevant subdirectories queried recursively (in parallel)
- [ ] Results combined from current directory and subdirectories
- [ ] Output follows standard format with STATUS: SUCCESS

# deep-find

## Intent

Provides thorough, recursive file system exploration with intelligent caching. Unlike simple grep/glob searches, deep-find builds a comprehensive understanding of the codebase by reading and summarizing every file, enabling natural language queries like "find files that handle authentication" rather than requiring exact keyword matches.

## Motivation

Standard code search tools (grep, ripgrep, glob) require knowing specific keywords or patterns. This creates friction when:
- Exploring unfamiliar codebases
- Searching for conceptual functionality ("where is error handling done?")
- Understanding project structure at a high level

deep-find addresses this by pre-indexing the codebase with AI-generated summaries, enabling semantic search capabilities.

## Design Decisions

1. **Directory-level isolation**: Each deep-find invocation operates only at its given directory level. Subdirectory exploration is delegated to recursive calls. This ensures consistent behavior and prevents a single invocation from becoming overwhelmed by large codebases.

2. **Script-first, AI-minimal**: File listing, metadata collection, and cache management are handled by shell scripts. AI is used only for:
   - Generating file content summaries (during init)
   - Matching queries to summaries (during query)

3. **Cache invalidation via file hash/mtime**: Each cached file entry stores its hash and modification time. When cache is accessed, files with changed hashes are re-summarized. This ensures summaries stay current without full re-indexing.

4. **Gitignore by default**: Respects .gitignore to avoid indexing build artifacts, node_modules, and other generated content that would add noise without value.

5. **Asset exclusion**: Binary files, images, and other non-text assets are automatically excluded to focus on meaningful code content.

## Constraints

- **NOT a replacement for grep/glob**: For known keyword searches, use standard tools. deep-find is for conceptual/semantic searches.
- **NOT real-time**: Relies on cached data that may be stale. Run `init` to refresh.
- **NOT for binary files**: Only processes text-based source files.
- **Single directory scope**: Each invocation handles one directory level only.

---
*This document captures the original intent. Modifications should preserve this intent or explicitly update it with user approval.*

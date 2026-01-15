# Codex Skill

## Intent

Enable collaboration between Claude and OpenAI Codex by wrapping the Codex CLI tool. This skill allows Claude to delegate tasks to Codex for alternative perspectives, code generation, or leveraging Codex's specific capabilities.

## Motivation

Different AI models have different strengths. By enabling Claude to invoke Codex, users can benefit from both models' capabilities in a single workflow.

## Design Decisions

1. **CLI wrapper**: Uses Codex CLI rather than direct API for simplicity
2. **Prompt passthrough**: Passes prompts directly without modification
3. **Minimal abstraction**: Simple interface to maximize flexibility

## Constraints

- This skill only wraps the CLI interface; it does not provide direct API access
- Requires Codex CLI to be installed and configured on the system

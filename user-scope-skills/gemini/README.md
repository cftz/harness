# Gemini Skill

## Intent

Enable collaboration between Claude and Google Gemini by wrapping the Gemini CLI tool. This skill allows Claude to delegate tasks to Gemini for alternative perspectives, code generation, or leveraging Gemini's specific capabilities.

## Motivation

Different AI models have different strengths. By enabling Claude to invoke Gemini, users can benefit from both models' capabilities in a single workflow.

## Design Decisions

1. **CLI wrapper**: Uses Gemini CLI rather than direct API for simplicity
2. **Prompt passthrough**: Passes prompts directly without modification
3. **Minimal abstraction**: Simple interface to maximize flexibility

## Constraints

- This skill only wraps the CLI interface; it does not provide direct API access
- Requires Gemini CLI to be installed and configured on the system

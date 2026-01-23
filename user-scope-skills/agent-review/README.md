# agent-review

## Intent

Verify agent files follow the established Best Practice standards for persona definition, process clarity, and decision criteria. This ensures agents are well-structured and consistently behave as intended.

## Motivation

Agents are used for:
- **Persona assignment**: Acting as a specific role/expert
- **Decision-making guidance**: Following specific criteria
- **Process definition**: Enforcing step-by-step workflows

Without standardized structure, agents become inconsistent and hard to maintain.

## Design Decisions

1. **Analogous to skill-review**: Same phase-based verification approach
2. **Focus on core use cases**: Persona, process, decision criteria - not type classification
3. **Severity levels**: Critical (load failure), High (behavior issues), Medium (quality)

## Constraints

- Does NOT modify agent files (read-only analysis)
- Does NOT create agents (use `/agents` command for that)
- Does NOT classify agent types (simplicity over taxonomy)

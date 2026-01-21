# Analogous Domain Approach

Use this approach when the problem is **Specialized** - domain-specific but similar problems exist in related engineering fields.

## When to Use

```
┌─────────────────────────────────────────────────────────────────────┐
│  ✓ State synchronization → Reference PLC Controllers               │
│  ✓ Resource scheduling → Reference OS schedulers                   │
│  ✓ UI interactions → Reference game design                         │
│  ✓ Data pipelines → Reference signal processing systems            │
│  ✓ Fault recovery → Reference aviation/medical systems             │
└─────────────────────────────────────────────────────────────────────┘
```

## Process

### 1. Abstract the Problem

Remove domain-specific terminology to reveal the core challenge:

```
┌─────────────────────────────────────────────────────────────────────┐
│  Original Problem                                                   │
│  "State synchronization between microservices"                      │
│                                                                     │
│                          ▼                                          │
│                                                                     │
│  Abstracted Problem                                                 │
│  "Maintaining consistent state across distributed entities"         │
└─────────────────────────────────────────────────────────────────────┘
```

### 2. Identify Related Domains

Map your domain to related engineering fields:

```
┌─────────────────┐         ┌─────────────────────────────────────────┐
│  Your Domain    │         │        Related Domains                  │
├─────────────────┤         ├─────────────────────────────────────────┤
│  Software       │ ──────▶ │ Hardware, Embedded, Network, Telecom   │
│  Backend        │ ──────▶ │ Distributed Systems, Database, OS      │
│  Frontend/UI    │ ──────▶ │ Game Design, Industrial Design, UX     │
│  Data Pipeline  │ ──────▶ │ Signal Processing, Manufacturing       │
│  Security       │ ──────▶ │ Physical Security, Military, Banking   │
│  DevOps         │ ──────▶ │ Factory Automation, Logistics          │
└─────────────────┘         └─────────────────────────────────────────┘
```

### 3. Search for Analogous Solutions

Use `WebSearch` with cross-domain queries:

| Query Template | Example |
|----------------|---------|
| `"how does {related-domain} handle {abstract-problem}"` | "how does PLC handle state synchronization" |
| `"{related-domain}" "{problem-keyword}" solution` | "industrial automation state machine" |
| `"{related-domain}" vs "{your-domain}" "{problem}"` | "hardware vs software state management" |

### 4. Analyze Analogies

For each analogous solution found:

```
┌─────────────────────────────────────────────────────────────────────┐
│  Source Domain       │ Where does this solution come from?         │
├──────────────────────┼──────────────────────────────────────────────┤
│  Original Problem    │ What problem did it solve there?            │
├──────────────────────┼──────────────────────────────────────────────┤
│  Original Context    │ What constraints/requirements existed?      │
├──────────────────────┼──────────────────────────────────────────────┤
│  Core Mechanism      │ How does it actually work?                  │
├──────────────────────┼──────────────────────────────────────────────┤
│  Key Insight         │ What makes this approach effective?         │
├──────────────────────┼──────────────────────────────────────────────┤
│  Adaptation Strategy │ How to apply it to current problem?         │
├──────────────────────┼──────────────────────────────────────────────┤
│  Potential Gaps      │ What doesn't translate directly?            │
└─────────────────────────────────────────────────────────────────────┘
```

### 5. Evaluate Transferability

Check if the analogy holds:

```
                    Is the analogy valid?
                            │
            ┌───────────────┼───────────────┐
            │               │               │
            ▼               ▼               ▼
     ┌────────────┐  ┌────────────┐  ┌────────────┐
     │   Strong   │  │  Moderate  │  │    Weak    │
     │            │  │            │  │            │
     │ Same core  │  │ Similar    │  │ Surface    │
     │ constraints│  │ principles │  │ similarity │
     │ and goals  │  │ different  │  │ only       │
     │            │  │ context    │  │            │
     └────────────┘  └────────────┘  └────────────┘
```

## Output Format

Follow the Output Format defined in `{baseDir}/SKILL.md`.

Use `**Source**:` for the source attribution field (engineering field where this approach comes from).

Additional fields for analogous approach:
- **What Translates Well**: Aspects that directly apply
- **What Needs Adjustment**: Gaps that need adaptation

## Common Analogies Reference

| Software Problem | Analogous Domain | Solution Reference |
|-----------------|------------------|-------------------|
| State Sync | Industrial PLC | State Machine Pattern |
| Load Balancing | Airport Operations | Queue Management |
| Cache Invalidation | Library Systems | Catalog Management |
| Circuit Breaker | Electrical Engineering | Fuse/Breaker Design |
| Retry Logic | Telecommunications | Error Correction |
| Resource Pooling | Transportation | Fleet Management |
| Event Sourcing | Accounting | Double-Entry Bookkeeping |
| Consensus | Politics/Governance | Voting Systems |

## Example

**Problem**: "Conflict resolution in real-time collaborative documents"

**Abstracted**: "Resolving concurrent edit conflicts among distributed users"

**Related Domains**:
- Database (MVCC, conflict resolution)
- Version Control (Git merge strategies)
- Distributed Systems (CRDTs)

**Analogous Solution Found**:
- **Source**: Google Docs / Operational Transformation
- **Original Problem**: Real-time collaboration without central lock
- **Core Mechanism**: Transform operations based on concurrent changes
- **Adaptation**: Apply OT or CRDT algorithms

# CODITECT Distributed Architecture - Claude Instructions

## Project Overview

This repository contains Architecture Decision Records (ADRs) and design documentation for CODITECT's distributed intelligence system. All critical architectural decisions about how CODITECT operates across multiple projects are documented here.

## Purpose

- Document architectural decisions with full context (problem, options, decision, consequences)
- Maintain research and analysis supporting each decision
- Track design evolution over time
- Provide single source of truth for CODITECT architecture

## Repository Structure

```
docs/
├── adrs/           # Architecture Decision Records
├── research/       # Research and analysis documents
└── design/         # SDDs, TDDs, technical specifications

diagrams/           # Visual architecture diagrams
```

## ADR Format

All ADRs follow this format:

```markdown
# ADR-NNN: Title

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXX]

## Context
What is the issue that we're seeing that is motivating this decision?

## Decision
What is the change that we're proposing/have agreed to implement?

## Consequences
What becomes easier or more difficult because of this change?
```

## Key Architectural Decisions

### ADR-001: Distributed Brain Architecture
- Single `.coditect` git submodule at PROJECTS root
- Symlinks from all projects to shared brain
- Local `.claude/` directories for project-specific config

### ADR-002: Centralized Memory Context (Proposed)
- All `/export` files to central MEMORY-CONTEXT
- Global deduplication prevents forgetting
- Session continuity across all projects

### ADR-003: Project-Local Configuration (Proposed)
- Each project gets `.claude/` directory
- Contains PROJECT-PLAN.md and TASKLIST.md
- Inherits agents/commands from shared brain

## Working with ADRs

### Creating a New ADR

1. Copy `docs/adrs/ADR-TEMPLATE.md`
2. Number sequentially (ADR-001, ADR-002, etc.)
3. Fill out all sections completely
4. Add to ADR index in README.md
5. Submit for review

### Updating an ADR

- **Minor updates**: Edit in place, note in header
- **Major changes**: Create new ADR that supersedes old one
- **Deprecation**: Update status, link to replacement

## Research Guidelines

### Adding Research

1. Create document in `docs/research/`
2. Use descriptive filename: `YYYY-MM-DD-topic.md`
3. Include sources, analysis, recommendations
4. Link from relevant ADRs

### Research Document Format

```markdown
# Research: Topic Title

## Date
YYYY-MM-DD

## Summary
Brief summary of findings

## Analysis
Detailed analysis

## Recommendations
Actionable recommendations

## Sources
- Links and references
```

## Best Practices

1. **Document decisions, not implementations** - ADRs capture the "why", not the "how"
2. **Include rejected alternatives** - Show what was considered
3. **Link related ADRs** - Build a knowledge graph
4. **Keep research separate** - ADRs reference research, don't include it
5. **Update when superseded** - Don't delete, mark as superseded

## Integration with CODITECT

This repo is a submodule of `coditect-rollout-master`:

```
coditect-rollout-master/
└── submodules/
    └── coditect-distributed-architecture/  # This repo
```

Changes here affect CODITECT architecture globally.

## Workflow

1. **Identify decision needed** - Problem or opportunity
2. **Research options** - Document in `docs/research/`
3. **Draft ADR** - Propose solution
4. **Review** - Get stakeholder input
5. **Accept/Reject** - Update status
6. **Implement** - Track in relevant project TASKLISTs

---

**Last Updated**: 2025-11-18
**Maintainer**: CODITECT Architecture Team

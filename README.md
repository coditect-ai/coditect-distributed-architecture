# CODITECT Distributed Architecture

Architecture Decision Records (ADRs), research, and design documentation for CODITECT's distributed intelligence system.

## Purpose

This repository serves as the authoritative source for:
- **Architecture Decision Records (ADRs)** - Documenting critical design decisions
- **Research & Analysis** - Supporting research for architectural choices
- **Design Documents** - SDDs, TDDs, and technical specifications
- **Diagrams** - Visual representations of architecture

## Core Architecture

CODITECT operates as a **distributed brain** across all projects:

```
PROJECTS/
├── .coditect/                    # THE BRAIN (single source of truth)
├── MEMORY-CONTEXT/               # Central memory (zero forgetting)
│
├── Project-1/
│   ├── .coditect -> ../.coditect # Symlink to brain
│   └── .claude/                  # Local project config
│
├── Project-2/
│   ├── .coditect -> ../.coditect # Symlink to brain
│   └── .claude/                  # Local project config
│
└── ...
```

## Key Principles

1. **Single Brain**: One `coditect-project-dot-claude` submodule shared by all
2. **Distributed Access**: Symlinks provide access from any project depth
3. **Local Context**: Each project maintains its own `.claude/` with plans and tasks
4. **Git Isolation**: Each submodule tracks its own changes independently
5. **Centralized Memory**: All `/export` files to one MEMORY-CONTEXT
6. **Zero Catastrophic Forgetting**: Every unique message preserved via deduplication

## Directory Structure

```
coditect-distributed-architecture/
├── README.md                     # This file
├── CLAUDE.md                     # Claude Code instructions
├── docs/
│   ├── adrs/                     # Architecture Decision Records
│   │   ├── ADR-001-distributed-brain.md
│   │   ├── ADR-002-memory-context.md
│   │   └── ...
│   ├── research/                 # Research and analysis
│   └── design/                   # SDDs, TDDs, specifications
└── diagrams/                     # Architecture diagrams
```

## ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-001](docs/adrs/ADR-001-distributed-brain.md) | Distributed Brain Architecture | Accepted | 2025-11-18 |
| ADR-002 | Centralized Memory Context | Proposed | TBD |
| ADR-003 | Project-Local Configuration | Proposed | TBD |

## Related Repositories

- **coditect-project-dot-claude** - The CODITECT brain implementation
- **coditect-rollout-master** - CODITECT framework rollout
- **coditect-projects** - Example projects using CODITECT

## Contributing

1. Create ADR using template in `docs/adrs/ADR-TEMPLATE.md`
2. Add supporting research in `docs/research/`
3. Submit PR for review

## License

MIT License - See LICENSE file

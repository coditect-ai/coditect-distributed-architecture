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
├── scripts/                      # Automation scripts
│   ├── setup-project.sh          # Setup new project
│   ├── migrate-project.sh        # Migrate existing project
│   └── health-check.sh           # Verify architecture health
├── docs/
│   ├── adrs/                     # Architecture Decision Records
│   │   ├── ADR-001-distributed-brain.md
│   │   ├── ADR-002-centralized-memory-context.md
│   │   ├── ADR-003-project-local-configuration.md
│   │   ├── ADR-004-export-deduplication-strategy.md
│   │   └── ADR-TEMPLATE.md
│   ├── research/                 # Research and analysis
│   └── design/                   # SDDs, TDDs, specifications
└── diagrams/                     # Architecture diagrams
```

## ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-001](docs/adrs/ADR-001-distributed-brain.md) | Distributed Brain Architecture | Accepted | 2025-11-18 |
| [ADR-002](docs/adrs/ADR-002-centralized-memory-context.md) | Centralized Memory Context | Accepted | 2025-11-18 |
| [ADR-003](docs/adrs/ADR-003-project-local-configuration.md) | Project-Local Configuration | Accepted | 2025-11-18 |
| [ADR-004](docs/adrs/ADR-004-export-deduplication-strategy.md) | Export Deduplication Strategy | Accepted | 2025-11-18 |

## Scripts

| Script | Purpose |
|--------|---------|
| `setup-project.sh` | Setup new project with CODITECT architecture |
| `migrate-project.sh` | Migrate existing project from submodule to symlink |
| `health-check.sh` | Verify project architecture health |

### Usage

```bash
# Setup new project
./scripts/setup-project.sh /path/to/PROJECTS/my-new-project

# Migrate existing project
./scripts/migrate-project.sh /path/to/PROJECTS/existing-project

# Check health
./scripts/health-check.sh /path/to/PROJECTS/my-project
```

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

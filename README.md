# coditect-core-architecture

**Core Repository - AZ1.AI CODITECT Ecosystem**

---

## Overview

**coditect-core-architecture** is the authoritative source for architectural decisions, design specifications, and research documentation that governs how all CODITECT components should be structured. This repository contains Architecture Decision Records (ADRs), Software Design Documents (SDDs), and research supporting the distributed intelligence architecture that powers the entire CODITECT platform.

**Status:** Production
**Category:** core
**Priority:** P0
**Type:** Documentation/Architectural Reference

---

## Purpose

### What Problem This Solves

As the CODITECT ecosystem grows to 42+ submodules, maintaining architectural consistency becomes critical. Without a central source of truth for architectural decisions, each repository would evolve independently, leading to:

- **Inconsistent patterns** across projects
- **Conflicting approaches** to common problems
- **Lost context** on why decisions were made
- **Difficult onboarding** for new team members
- **Integration challenges** between components

### What This Repository Provides

1. **Architecture Decision Records (ADRs)** - Documented rationale for critical design choices
2. **Research Documentation** - Analysis and findings that inform decisions
3. **Design Specifications** - SDDs and TDDs for major system components
4. **Setup/Migration Scripts** - Tools to implement architectural patterns
5. **Templates** - Standardized formats for new documentation

### Who Uses It

| Audience | Use Case |
|----------|----------|
| **Developers** | Reference when implementing features across repos |
| **Architects** | Propose and document new architectural decisions |
| **New Team Members** | Understand why the system is designed this way |
| **AI Agents** | Context for making consistent recommendations |

### How It Fits Into CODITECT

```
CODITECT Architecture Governance
=================================

coditect-core-architecture
(Architectural Authority)
        │
        ▼
┌───────────────────────────────────┐
│  Governs ALL CODITECT Repos       │
│                                   │
│  • ADR-001: Distributed Brain     │
│  • ADR-002: MEMORY-CONTEXT        │
│  • ADR-003: Local Configuration   │
│  • ADR-004: Export Deduplication  │
└───────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────────┐
│  core/     cloud/    dev/    ops/    ...  │
│  42+ Submodules Follow These Standards    │
└───────────────────────────────────────────┘
```

---

## Key Features

- **4 Active ADRs** - Governing distributed brain, memory context, local config, and export deduplication
- **ADR Template** - Standardized format for documenting new decisions
- **Design Documents** - Comprehensive SDD (109KB) and migration plan
- **Research Library** - Multi-agent architecture patterns analysis (31KB)
- **Automation Scripts** - Setup, migration, and health check tools
- **Living Documentation** - Updated as architecture evolves

---

## Architecture Decision Records (ADRs)

### Current ADRs

| ADR | Title | Status | Date | Description |
|-----|-------|--------|------|-------------|
| [ADR-001](docs/adrs/ADR-001-distributed-brain.md) | Distributed Brain Architecture | Accepted | 2025-11-18 | Single `.coditect` shared via symlinks to all projects |
| [ADR-002](docs/adrs/ADR-002-centralized-memory-context.md) | Centralized Memory Context | Accepted | 2025-11-18 | All `/export` files to central MEMORY-CONTEXT |
| [ADR-003](docs/adrs/ADR-003-project-local-configuration.md) | Project-Local Configuration | Accepted | 2025-11-18 | Each project has `.claude/` for local context |
| [ADR-004](docs/adrs/ADR-004-export-deduplication-strategy.md) | Export Deduplication Strategy | Accepted | 2025-11-18 | Hash-based dedup for zero catastrophic forgetting |

### ADR Format

Each ADR follows this structure:

```markdown
# ADR-NNN: Title

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXX]

## Context
What is the issue motivating this decision?

## Decision
What change are we implementing?

## Alternatives Considered
What other options were evaluated?

## Consequences
What becomes easier or more difficult?

## Implementation
How do we implement this decision?
```

### Creating New ADRs

1. Copy `docs/adrs/ADR-TEMPLATE.md`
2. Number sequentially (ADR-005, ADR-006, etc.)
3. Complete all sections
4. Submit for architectural review
5. Update status to "Accepted" after approval

---

## Core Architecture: Distributed Brain

The primary architectural pattern documented here is CODITECT's **distributed brain** system:

```
PROJECTS/
├── .coditect/                    # THE BRAIN (single source of truth)
│   └── [50 agents, 72 commands, 24 skills]
│
├── MEMORY-CONTEXT/               # Central memory (zero forgetting)
│   ├── dedup_state/
│   ├── exports-archive/
│   └── sessions/
│
├── Project-1/
│   ├── .coditect -> ../.coditect # SYMLINK (not submodule)
│   └── .claude/                  # LOCAL directory
│       ├── CLAUDE.md             # Project-specific instructions
│       ├── PROJECT-PLAN.md
│       └── TASKLIST.md
│
└── Project-2/
    ├── .coditect -> ../.coditect # SYMLINK
    └── .claude/                  # Local context
```

### Key Principles

1. **Single Brain** - One `coditect-core` shared by all projects
2. **Distributed Access** - Symlinks provide access from any project depth
3. **Local Context** - Each project maintains its own `.claude/` with plans and tasks
4. **Git Isolation** - Each submodule tracks its own changes independently
5. **Centralized Memory** - All `/export` files flow to one MEMORY-CONTEXT
6. **Zero Catastrophic Forgetting** - Every unique message preserved via deduplication

---

## Directory Structure

```
coditect-core-architecture/
├── .coditect -> ../../../.coditect    # Distributed intelligence symlink
├── .claude -> .coditect               # Claude Code compatibility
├── .git                               # Git submodule reference
├── .gitignore                         # Git ignores
│
├── CLAUDE.md                          # AI agent configuration
├── README.md                          # This file
│
├── docs/
│   ├── adrs/                          # Architecture Decision Records
│   │   ├── ADR-001-distributed-brain.md
│   │   ├── ADR-002-centralized-memory-context.md
│   │   ├── ADR-003-project-local-configuration.md
│   │   ├── ADR-004-export-deduplication-strategy.md
│   │   └── ADR-TEMPLATE.md
│   │
│   ├── design/                        # Design specifications
│   │   ├── DISTRIBUTED-BRAIN-SDD.md   # Software Design Document (109KB)
│   │   └── MIGRATION-PLAN.md          # Migration procedures (12KB)
│   │
│   └── research/                      # Research and analysis
│       └── 2025-11-18-multi-agent-architecture-patterns.md (31KB)
│
└── scripts/                           # Automation tools
    ├── setup-project.sh               # Setup new project with architecture
    ├── migrate-project.sh             # Migrate existing project
    └── health-check.sh                # Verify architecture health
```

---

## Technology Stack

- **Format:** Markdown documentation
- **Scripts:** Bash automation
- **Templates:** Structured Markdown templates
- **Diagrams:** Mermaid (GitHub-compatible)
- **Version Control:** Git

### No Runtime Dependencies

This repository is purely documentation and scripts. No compilation or runtime environment required.

---

## Quick Start

### Prerequisites

- Git for cloning and version control
- Bash for running automation scripts
- Understanding of CODITECT architecture

### View Documentation

```bash
# Clone the repository
git clone https://github.com/coditect-ai/coditect-core-architecture.git
cd coditect-core-architecture

# Read the primary ADRs
cat docs/adrs/ADR-001-distributed-brain.md
cat docs/adrs/ADR-002-centralized-memory-context.md
```

### Use Scripts

```bash
# Setup new project with CODITECT architecture
./scripts/setup-project.sh /path/to/PROJECTS/my-new-project

# Migrate existing project from submodule to symlink
./scripts/migrate-project.sh /path/to/PROJECTS/existing-project

# Check project health (verify architecture compliance)
./scripts/health-check.sh /path/to/PROJECTS/my-project
```

### Create New ADR

```bash
# Copy template
cp docs/adrs/ADR-TEMPLATE.md docs/adrs/ADR-005-my-decision.md

# Edit the new ADR
# Fill in: Status, Context, Decision, Alternatives, Consequences, Implementation

# Commit and submit for review
git add docs/adrs/ADR-005-my-decision.md
git commit -m "docs(adr): propose ADR-005 my decision"
```

---

## Scripts Documentation

### setup-project.sh

Sets up a new project with the CODITECT distributed brain architecture.

```bash
./scripts/setup-project.sh /path/to/project

# Creates:
# /path/to/project/.coditect -> ../.coditect  (symlink to brain)
# /path/to/project/.claude/                    (local config directory)
# /path/to/project/.claude/CLAUDE.md          (project instructions)
# /path/to/project/.claude/PROJECT-PLAN.md    (development plan)
# /path/to/project/.claude/TASKLIST.md        (task tracking)
```

### migrate-project.sh

Migrates an existing project from git submodule to symlink architecture.

```bash
./scripts/migrate-project.sh /path/to/project

# Actions:
# 1. Removes .coditect git submodule
# 2. Creates symlink to shared brain
# 3. Creates .claude/ directory with local config
# 4. Preserves project-specific CLAUDE.md content
```

### health-check.sh

Verifies a project follows the CODITECT architecture correctly.

```bash
./scripts/health-check.sh /path/to/project

# Checks:
# - .coditect symlink exists and points to correct location
# - .claude directory exists with required files
# - CLAUDE.md has proper structure
# - No conflicting submodule references
```

---

## Distributed Intelligence

This repository is part of the CODITECT distributed intelligence architecture:

```
.coditect -> ../../../.coditect  # Links to master brain
.claude -> .coditect             # Claude Code compatibility
```

### How Symlinks Work

CODITECT uses a symlink chain pattern to share a single "brain" across all projects:

```
coditect-rollout-master/
├── .coditect                          # THE BRAIN (actual directory)
│   └── [50 agents, 72 commands, 24 skills]
│
└── submodules/
    └── core/
        └── coditect-core-architecture/
            └── .coditect -> ../../../.coditect   # SYMLINK
```

### Benefits for This Repository

- **Self-documenting** - Architecture repo uses its own patterns
- **Access to full toolset** - All agents and commands available
- **Consistent experience** - Same development workflow as all projects

### Learn More

- [WHAT-IS-CODITECT.md](https://github.com/coditect-ai/coditect-core/blob/main/WHAT-IS-CODITECT.md) - Complete architecture documentation
- [ADR-001: Distributed Brain Architecture](docs/adrs/ADR-001-distributed-brain.md) - This pattern's rationale

---

## Integration with CODITECT Platform

### Dependencies

This repository has no technical dependencies - it is the authoritative reference.

| Repository | Relationship |
|------------|--------------|
| None | This is a root dependency |

### Dependents

**Every CODITECT repository** depends on this as the architectural reference:

| Category | Repositories |
|----------|--------------|
| **core/** | coditect-core, coditect-core-framework |
| **cloud/** | coditect-cloud-backend, coditect-cloud-frontend, coditect-cloud-ide, coditect-cloud-infra |
| **dev/** | coditect-cli, coditect-analytics, coditect-automation, and 6 more |
| **ops/** | coditect-ops-distribution, coditect-ops-license, coditect-ops-projects |
| **docs/** | coditect-docs-main, coditect-docs-blog, coditect-docs-training, and 2 more |
| **gtm/** | coditect-gtm-strategy, coditect-gtm-comms, and 4 more |
| **labs/** | coditect-labs-multi-agent-rag, coditect-labs-mcp-auth, and 9 more |

### Governance Model

1. **Propose** - Create ADR in draft status
2. **Review** - Architecture team evaluates
3. **Accept/Reject** - Decision made
4. **Implement** - All repos follow the accepted ADR
5. **Evolve** - New ADRs supersede old when needed

---

## Development Guidelines

### Working with ADRs

**Creating ADRs:**
- Use the provided template
- Document the problem clearly
- List all alternatives considered
- Be specific about consequences
- Include implementation guidance

**Updating ADRs:**
- Minor updates: Edit in place, note in header
- Major changes: Create new ADR that supersedes
- Never delete - mark as deprecated/superseded

### Research Documents

**Format:**
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

### Commit Messages

Follow conventional commit format:
```
docs(adr): add ADR-005 for new pattern
docs(research): analyze authentication approaches
fix(script): correct symlink depth calculation
```

---

## Testing

### Script Testing

```bash
# Test setup script (dry run)
./scripts/setup-project.sh --dry-run /tmp/test-project

# Test health check
./scripts/health-check.sh /path/to/known-good-project

# Test migration (on copy)
cp -r /path/to/project /tmp/migration-test
./scripts/migrate-project.sh /tmp/migration-test
```

### Documentation Validation

- Verify all internal links resolve
- Check Mermaid diagrams render on GitHub
- Ensure ADR status is current
- Validate template compliance

---

## Documentation Index

### ADRs (Architecture Decision Records)

- **[ADR-001: Distributed Brain Architecture](docs/adrs/ADR-001-distributed-brain.md)** - Core symlink pattern
- **[ADR-002: Centralized Memory Context](docs/adrs/ADR-002-centralized-memory-context.md)** - Session export system
- **[ADR-003: Project-Local Configuration](docs/adrs/ADR-003-project-local-configuration.md)** - `.claude/` directory pattern
- **[ADR-004: Export Deduplication Strategy](docs/adrs/ADR-004-export-deduplication-strategy.md)** - Hash-based dedup
- **[ADR-TEMPLATE.md](docs/adrs/ADR-TEMPLATE.md)** - Template for new ADRs

### Design Documents

- **[DISTRIBUTED-BRAIN-SDD.md](docs/design/DISTRIBUTED-BRAIN-SDD.md)** - Complete Software Design Document (109KB)
- **[MIGRATION-PLAN.md](docs/design/MIGRATION-PLAN.md)** - Procedures for migrating projects

### Research

- **[Multi-Agent Architecture Patterns](docs/research/2025-11-18-multi-agent-architecture-patterns.md)** - Analysis of orchestration approaches (31KB)

### Configuration

- **[CLAUDE.md](CLAUDE.md)** - AI agent instructions for this repository

---

## Related Resources

### CODITECT Repositories

- **Master Repository:** [coditect-rollout-master](https://github.com/coditect-ai/coditect-rollout-master)
- **Core Brain:** [coditect-core](https://github.com/coditect-ai/coditect-core)
- **Framework Distribution:** [coditect-core-framework](https://github.com/coditect-ai/coditect-core-framework)
- **Documentation Site:** [docs.coditect.ai](https://docs.coditect.ai) (when available)

### External Resources

- **ADR Standards:** [adr.github.io](https://adr.github.io/) - Architecture Decision Records
- **Claude Code:** [docs.anthropic.com/claude-code](https://docs.anthropic.com/claude-code)
- **Git Submodules:** [git-scm.com](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

---

## Contributing

### How to Contribute

1. **Propose ADRs** - Document new architectural decisions
2. **Add Research** - Share analysis that informs decisions
3. **Improve Scripts** - Enhance automation tools
4. **Update Documentation** - Keep docs current and accurate

### Process

1. Fork the repository
2. Create feature branch
3. Make changes following guidelines
4. Submit pull request
5. Address review feedback
6. Merge after approval

### For CODITECT-wide contribution guidelines, see the [master repository](https://github.com/coditect-ai/coditect-rollout-master).

---

## Roadmap

### Current (2025-11)

- [x] ADR-001: Distributed Brain Architecture
- [x] ADR-002: Centralized Memory Context
- [x] ADR-003: Project-Local Configuration
- [x] ADR-004: Export Deduplication Strategy
- [x] Setup and migration scripts
- [x] Research documentation

### Planned

- [ ] ADR-005: Agent Communication Patterns
- [ ] ADR-006: Multi-Tenant Isolation
- [ ] ADR-007: Deployment Architecture
- [ ] Enhanced health check validation
- [ ] Automated compliance reporting

---

## FAQ

### Q: Why ADRs instead of inline documentation?

ADRs provide:
- Historical context preserved
- Alternatives considered documented
- Consequences explicitly stated
- Single location for architectural truth

### Q: How do I know which ADR applies to my work?

Check the ADR index in this README or CLAUDE.md. Each ADR has clear scope in its Context section.

### Q: Can ADRs be changed after acceptance?

Minor clarifications: yes. Significant changes: create a new ADR that supersedes the old one.

### Q: How do scripts handle edge cases?

Run health-check.sh to identify issues. Scripts have verbose output explaining each action.

---

## License

Copyright (C) 2025 AZ1.AI INC. All Rights Reserved.

**PROPRIETARY AND CONFIDENTIAL** - This repository contains AZ1.AI INC. trade secrets and confidential information. Unauthorized copying, transfer, or use is strictly prohibited.

---

*Built with Excellence by AZ1.AI CODITECT*
*Systematic Development. Continuous Context. Exceptional Results.*

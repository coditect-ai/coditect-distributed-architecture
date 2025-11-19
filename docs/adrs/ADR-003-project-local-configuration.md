# ADR-003: Project-Local Configuration

## Status

**Accepted** - 2025-11-18

## Context

Claude Code looks for `.claude/CLAUDE.md` for project instructions. With a shared CODITECT brain, we need to determine how projects provide:
- Project-specific context and instructions
- Custom commands or overrides
- Planning documents (PROJECT-PLAN, TASKLIST)

### Current Problems

1. **Shared CLAUDE.md**: All projects get same generic instructions
2. **No project context**: Claude doesn't know "this is a CRM project"
3. **Planning scattered**: PROJECT-PLAN and TASKLIST in various locations
4. **Override difficulty**: Can't customize agents/commands per project

### Requirements

1. Project-specific instructions for Claude
2. Access to shared agents/commands from brain
3. Local planning documents
4. Optional project-specific overrides
5. Clear inheritance model

## Decision

Implement **project-local `.claude/` directories** with three-tier configuration inheritance.

### Architecture

```
PROJECTS/
├── .coditect/                    # Tier 1: Global brain (shared)
│   ├── agents/
│   ├── commands/
│   └── CLAUDE.md                 # Global defaults
│
├── Project-1/
│   ├── .coditect -> ../.coditect # Symlink to brain
│   └── .claude/                  # Tier 2: Project-specific
│       ├── CLAUDE.md             # Project instructions
│       ├── PROJECT-PLAN.md       # Implementation plan
│       ├── TASKLIST.md           # Task checklist
│       └── commands/             # (optional) Project commands
│
└── Project-1/submodule/
    ├── .coditect -> ../../.coditect
    └── .claude/                  # Tier 3: Submodule-specific
        └── CLAUDE.md             # Submodule instructions
```

### Configuration Inheritance

```
Tier 1 (Brain)     → Default agents, commands, skills
       ↓
Tier 2 (Project)   → Project context, plans, overrides
       ↓
Tier 3 (Submodule) → Submodule-specific context
```

**Resolution order**: Brain < Project < Submodule (most specific wins)

### .claude/CLAUDE.md Structure

```markdown
# Project Name - Claude Instructions

## Project Overview
[What this project is about]

## Shared Resources
Access CODITECT resources via `.coditect/`:
- Agents: `.coditect/agents/`
- Commands: `.coditect/commands/`
- Skills: `.coditect/skills/`

## Project-Specific Context
[Detailed context for this specific project]

## Planning Documents
- [PROJECT-PLAN.md](PROJECT-PLAN.md)
- [TASKLIST.md](TASKLIST.md)

## Conventions
[Project-specific conventions, patterns, etc.]
```

### Directory Contents

| File | Purpose | Required |
|------|---------|----------|
| `CLAUDE.md` | Project instructions | Yes |
| `PROJECT-PLAN.md` | Implementation phases | Recommended |
| `TASKLIST.md` | Tasks with checkboxes | Recommended |
| `commands/` | Project-specific commands | Optional |
| `agents/` | Project-specific agents | Optional |

### Override Mechanism

**Commands**: Project commands override brain commands with same name
```
.coditect/commands/build.md    → Default build command
.claude/commands/build.md      → Project-specific override
```

**Agents**: Project agents extend brain agents
```
.coditect/agents/rust-expert.md    → Base rust expert
.claude/agents/rust-expert.md      → Project additions
```

## Alternatives Considered

### Alternative 1: Single .claude Symlink (No Local Config)

```
.claude -> .coditect
```

**Rejected because**:
- No project-specific instructions
- All projects identical
- No planning document location

### Alternative 2: Everything in .coditect (No Separation)

```
.coditect/
  ├── agents/
  ├── commands/
  ├── PROJECT-PLAN.md    # Mixed in with brain
  └── CLAUDE.md
```

**Rejected because**:
- Project files mixed with brain
- Unclear what's shared vs local
- Git conflicts between projects

### Alternative 3: Environment Variables

```
export PROJECT_CONTEXT="This is a CRM project"
```

**Rejected because**:
- Not persistent
- Not in version control
- Complex setup per project

## Consequences

### Positive

1. **Clear separation**: Brain (shared) vs project (local)
2. **Full context**: Claude knows exactly what project it's in
3. **Organized planning**: PROJECT-PLAN and TASKLIST have a home
4. **Flexible overrides**: Projects can customize as needed
5. **Git-friendly**: Each project tracks its own config

### Negative

1. **Setup overhead**: Must create .claude/ for each project
   - **Mitigation**: Setup script provided

2. **Duplication risk**: Similar CLAUDE.md across projects
   - **Mitigation**: Use templates, reference brain

3. **Discovery complexity**: Multiple places to look for commands
   - **Mitigation**: Clear resolution order documented

### Risks

1. **Stale project config**: CLAUDE.md outdated as project evolves
   - **Mitigation**: Include in code review checklist

2. **Override conflicts**: Unclear which version applies
   - **Mitigation**: Explicit resolution order, logging

## Implementation

### Creating Project Config

```bash
cd PROJECTS/my-project

# Create .claude directory
mkdir -p .claude

# Create CLAUDE.md from template
cat > .claude/CLAUDE.md << 'EOF'
# My Project - Claude Instructions

## Project Overview
[Describe your project here]

## Shared Resources
Access CODITECT resources via `.coditect/`:
- Agents: `.coditect/agents/`
- Commands: `.coditect/commands/`
- Skills: `.coditect/skills/`

## Project-Specific Context
[Add project-specific details]

## Planning Documents
- [PROJECT-PLAN.md](PROJECT-PLAN.md) - Implementation phases
- [TASKLIST.md](TASKLIST.md) - Task checklist with checkboxes
EOF

# Create planning documents
touch .claude/PROJECT-PLAN.md
touch .claude/TASKLIST.md
```

### Verification

```bash
# Check structure
ls -la .claude/
# Should show: CLAUDE.md, PROJECT-PLAN.md, TASKLIST.md

# Verify symlink
ls -la .coditect
# Should show: .coditect -> ../.coditect
```

## Related Decisions

- **ADR-001**: Distributed Brain Architecture (symlink pattern)
- **ADR-002**: Centralized Memory Context (where exports go)

## References

- [Nx Project Configuration](https://nx.dev/concepts/inferred-tasks)
- [Claude Code Configuration](https://docs.anthropic.com/claude-code)
- [Monorepo Best Practices](https://monorepo.tools/)

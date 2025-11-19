# ADR-001: Distributed Brain Architecture

## Status

**Accepted** - 2025-11-18

## Context

CODITECT serves as the "brain" for AI-assisted development across multiple projects. We need to determine how this brain should be deployed and accessed across:

- Multiple projects in a PROJECTS directory
- Submodules within those projects
- Submodules of submodules (arbitrary depth)

### Current Problems

1. **Duplicate submodules**: Each project has its own copy of `coditect-project-dot-claude` as a git submodule
2. **Inconsistent state**: Different projects may have different versions of CODITECT
3. **Wasted storage**: Same files duplicated across all projects
4. **Update overhead**: Must update submodule in each project separately
5. **Confusing structure**: `.claude` symlinks to `.coditect` which is a submodule that contains internal symlinks

### Requirements

1. Single source of truth for CODITECT brain
2. Access from any project at any depth
3. Each project maintains its own context (plans, tasks, etc.)
4. Git isolation - each project's changes tracked separately
5. Claude Code compatibility (looks for `.claude/`)

## Decision

Implement a **single brain, distributed access** architecture:

### Architecture

```
PROJECTS/
├── .coditect/                        # Git submodule (THE BRAIN)
│   └── [coditect-project-dot-claude]
│
├── MEMORY-CONTEXT/                   # Centralized memory
│   ├── dedup_state/
│   ├── exports-archive/
│   └── sessions/
│
├── Project-1/
│   ├── .coditect -> ../.coditect     # SYMLINK (not submodule!)
│   └── .claude/                      # LOCAL directory
│       ├── CLAUDE.md                 # Project-specific instructions
│       ├── PROJECT-PLAN.md
│       └── TASKLIST.md
│
├── Project-1/submodule-a/
│   ├── .coditect -> ../../.coditect  # SYMLINK
│   └── .claude/                      # Submodule-specific config
│
└── Project-2/
    ├── .coditect -> ../.coditect     # SYMLINK
    └── .claude/
```

### Key Components

1. **`.coditect/` (THE BRAIN)**
   - Single git submodule at `PROJECTS/.coditect`
   - Contains: agents, commands, skills, scripts
   - Updated once, affects all projects
   - Source: `coditect-project-dot-claude.git`

2. **`.coditect` symlinks**
   - Each project has symlink: `.coditect -> ../.coditect`
   - Submodules calculate relative path to PROJECTS root
   - Provides access to shared brain without duplication

3. **`.claude/` directories**
   - Actual directories (not symlinks)
   - Project-specific configuration:
     - `CLAUDE.md` - Instructions for this specific project
     - `PROJECT-PLAN.md` - Implementation phases and milestones
     - `TASKLIST.md` - Tasks with checkboxes
     - `commands/` (optional) - Project-specific commands
   - Claude Code finds `.claude/CLAUDE.md`
   - CLAUDE.md can reference `.coditect/` for shared resources

4. **`MEMORY-CONTEXT/` (Centralized)**
   - All `/export` files from all projects go here
   - Global deduplication via `export-dedup.py`
   - Session continuity across projects
   - Zero catastrophic forgetting

### How `.claude/CLAUDE.md` Works

```markdown
# Project Name - Claude Instructions

## Project Overview
[Project-specific description]

## Shared Resources
Access shared CODITECT resources via `.coditect/`:
- Agents: `.coditect/agents/`
- Commands: `.coditect/commands/`
- Skills: `.coditect/skills/`

## Project-Specific Configuration
[Local instructions, plans, context]
```

### Symlink Depth Calculation

| Location | Symlink Target |
|----------|---------------|
| `PROJECTS/Project-1/` | `.coditect -> ../.coditect` |
| `PROJECTS/Project-1/sub-a/` | `.coditect -> ../../.coditect` |
| `PROJECTS/Project-1/sub-a/sub-b/` | `.coditect -> ../../../.coditect` |

## Alternatives Considered

### Alternative 1: Submodule per Project (Current)

```
Project-1/.coditect  (submodule)
Project-2/.coditect  (submodule)
```

**Rejected because**:
- Duplicate storage
- Inconsistent versions
- Complex updates
- Nested submodule confusion

### Alternative 2: Copy Files per Project

```
Project-1/.coditect  (copied files)
Project-2/.coditect  (copied files)
```

**Rejected because**:
- No version control
- Manual sync required
- Drift between projects

### Alternative 3: Environment Variable

```
export CODITECT_PATH=/path/to/.coditect
```

**Rejected because**:
- Requires shell setup
- Not visible in git
- Breaks portability

## Consequences

### Positive

1. **Single update point**: Update `.coditect` once, all projects get it
2. **Storage efficiency**: No duplicate files
3. **Version consistency**: All projects use same CODITECT version
4. **Clear separation**: Brain (shared) vs context (local)
5. **Scalability**: Works for any number of projects at any depth
6. **Git cleanliness**: Projects track only their own code
7. **Zero forgetting**: Centralized MEMORY-CONTEXT preserves all context

### Negative

1. **Symlink overhead**: Must create symlinks in each project
2. **Depth calculation**: Symlinks must calculate correct relative path
3. **Breaking change**: Existing projects need migration
4. **Single point of failure**: Brain issues affect all projects

### Risks

1. **Symlink breaks**: If PROJECTS root moves, symlinks break
   - **Mitigation**: Use relative paths, not absolute

2. **Merge conflicts**: Multiple projects updating CLAUDE.md
   - **Mitigation**: Project-specific CLAUDE.md in `.claude/`, not `.coditect/`

3. **Permission issues**: Symlinks across filesystems
   - **Mitigation**: Keep all projects on same filesystem

## Implementation

### For New Projects

```bash
cd /path/to/PROJECTS/new-project

# Create symlink to brain
ln -s ../.coditect .coditect

# Create local config
mkdir .claude
touch .claude/CLAUDE.md
touch .claude/PROJECT-PLAN.md
touch .claude/TASKLIST.md
```

### For Existing Projects (Migration)

```bash
cd /path/to/PROJECTS/existing-project

# Remove submodule
git submodule deinit .coditect
git rm .coditect
rm -rf .git/modules/.coditect

# Create symlink
ln -s ../.coditect .coditect

# Move/create local config
mkdir .claude
# Move project-specific content to .claude/
```

### For Submodules

```bash
cd /path/to/PROJECTS/project/submodule

# Calculate depth and create symlink
ln -s ../../.coditect .coditect

# Create submodule-specific config
mkdir .claude
```

## Related Decisions

- **ADR-002**: Centralized Memory Context (proposed)
- **ADR-003**: Project-Local Configuration (proposed)
- **ADR-004**: Export Deduplication Strategy (proposed)

## References

- [CODITECT Framework Documentation](../../../coditect-project-dot-claude/README.md)
- [Claude Code Configuration](https://docs.anthropic.com/claude-code)
- [Git Submodules Best Practices](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

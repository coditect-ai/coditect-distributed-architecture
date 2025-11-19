# CODITECT Distributed Brain Architecture - Migration Plan

## Overview

This document provides a complete migration procedure for transitioning projects from individual `.coditect` submodules to the Distributed Brain Architecture, where all projects share a single master brain at `PROJECTS/.coditect`.

### Target Architecture

```
PROJECTS/
├── .coditect/                    # Master brain (single git submodule)
├── .claude -> .coditect          # Root symlink for compatibility
├── MEMORY-CONTEXT/               # Centralized memory for ALL projects
│
├── ProjectA/
│   ├── .coditect -> ../.coditect # SYMLINK to master brain
│   └── .claude/                  # ACTUAL DIRECTORY with local config
│       ├── CLAUDE.md             # Project-specific instructions
│       └── [other local config]
│
└── ProjectB/
    ├── .coditect -> ../.coditect # SYMLINK to master brain
    └── .claude/                  # ACTUAL DIRECTORY with local config
        └── CLAUDE.md             # Project-specific instructions
```

### Benefits

1. **Single Source of Truth**: All agents, commands, and skills maintained in one location
2. **Automatic Updates**: Update master brain once, all projects get updates
3. **Reduced Complexity**: No more managing multiple submodule versions
4. **Local Customization**: Project-specific config in `.claude/` directories
5. **Centralized Memory**: All context exports go to `MEMORY-CONTEXT/`

---

## Pre-Migration Checklist

Before starting migration for any project:

- [ ] **Backup gitmodules**: `cat PROJECTS/.gitmodules > /tmp/gitmodules-backup-$(date +%Y%m%d)`
- [ ] **Verify master brain exists**: `ls -la PROJECTS/.coditect/`
- [ ] **Check project has no uncommitted changes**: `cd PROJECT && git status`
- [ ] **Document current .coditect commit**: `cd PROJECT/.coditect && git rev-parse HEAD`
- [ ] **Ensure MEMORY-CONTEXT exists**: `mkdir -p PROJECTS/MEMORY-CONTEXT`
- [ ] **Note any local modifications** in project's .coditect (should be none)

---

## Migration Procedures

### Type A: Project with .coditect as Submodule (e.g., ERP-ODOO-FORK)

This is the most common case when a project was set up with its own .coditect submodule.

#### Step 1: Navigate to Project
```bash
cd /Users/halcasteel/PROJECTS/ERP-ODOO-FORK
```

#### Step 2: Remove the .claude Symlink
```bash
# Remove existing symlink that points to .coditect
rm .claude
```

#### Step 3: Deinitialize the Submodule
```bash
# Deinitialize the submodule (removes from working tree)
git submodule deinit -f .coditect
```

#### Step 4: Remove Submodule from Git Index
```bash
# Remove from git index
git rm -f .coditect
```

#### Step 5: Clean Up Git Modules Cache
```bash
# Remove cached submodule data from parent .git directory
# Note: Path varies depending on whether project is tracked by parent or has own .git
rm -rf ../.git/modules/ERP-ODOO-FORK/.coditect 2>/dev/null
rm -rf .git/modules/.coditect 2>/dev/null
```

#### Step 6: Create Symlink to Master Brain
```bash
# Create symlink pointing to parent's .coditect
ln -s ../.coditect .coditect
```

#### Step 7: Create Local .claude Directory
```bash
# Create actual directory for project-specific configuration
mkdir .claude
```

#### Step 8: Create Project-Specific CLAUDE.md
```bash
# Create the CLAUDE.md file (content depends on project)
# See template below
```

#### Step 9: Verify Migration
```bash
# Verify .coditect is a symlink
ls -la .coditect
# Should show: .coditect -> ../.coditect

# Verify .claude is a directory
ls -la .claude
# Should show: drwxr-xr-x ... .claude

# Verify access to master brain
ls .coditect/agents/
# Should list agents from master brain
```

#### Step 10: Commit Changes
```bash
git add -A
git status  # Review changes
git commit -m "chore: Migrate to CODITECT distributed brain architecture

- Remove .coditect submodule (now using shared master brain)
- Create .coditect symlink to PROJECTS/.coditect
- Create .claude directory for project-specific configuration
- Add CLAUDE.md with project context

ADR-001: Distributed Brain Architecture"
```

---

### Type B: Project Without .coditect (New Projects)

For projects that don't have any CODITECT integration yet.

#### Step 1: Navigate to Project
```bash
cd /Users/halcasteel/PROJECTS/NewProject
```

#### Step 2: Create Symlinks and Directory
```bash
# Create symlink to master brain
ln -s ../.coditect .coditect

# Create local configuration directory
mkdir .claude
```

#### Step 3: Create CLAUDE.md
```bash
# Create project-specific CLAUDE.md (see template below)
```

#### Step 4: Update .gitignore (Optional)
```bash
# If you want to track .claude but not certain files within
echo "# Local Claude configuration" >> .gitignore
echo ".claude/local/" >> .gitignore
```

#### Step 5: Commit
```bash
git add .coditect .claude
git commit -m "feat: Add CODITECT distributed brain integration

- Add .coditect symlink to shared master brain
- Create .claude directory for project-specific configuration
- Add CLAUDE.md with project context"
```

---

### Type C: Submodules Within Projects

For projects that contain submodules which also need CODITECT access.

#### Step 1: Navigate to Submodule
```bash
cd /Users/halcasteel/PROJECTS/MainProject/submodule-name
```

#### Step 2: Create Relative Symlink
```bash
# Symlink needs to go up two levels
ln -s ../../.coditect .coditect

# Create local config
mkdir .claude
```

#### Step 3: Create CLAUDE.md
```bash
# Include context about being a submodule
# Reference parent project's documentation
```

---

## CLAUDE.md Template

```markdown
# [Project Name] - CODITECT Project Configuration

## Project Overview

[Brief description of the project, its purpose, and current phase]

## Shared Resources

This project uses the CODITECT Distributed Brain Architecture:

- **Master Brain**: `../.coditect/` (symlinked)
- **Agents**: Access all 50+ specialized agents
- **Commands**: 72 slash commands available
- **Skills**: 189 reusable skills

## Project-Specific Context

### Current Phase
[Current development phase and focus]

### Key Documents
- `docs/design/PROJECT-PLAN.md` - Master project plan
- `docs/design/TASKLIST.md` - Active task list
- [Other key documents]

### Architecture
[Brief architecture description or link to ADRs]

### Technology Stack
- [List key technologies]

## Development Guidelines

### Code Standards
[Project-specific coding standards]

### Testing Requirements
[Testing approach and coverage requirements]

### Documentation
[Documentation standards and locations]

## Memory Context

All session exports should go to:
```
/Users/halcasteel/PROJECTS/MEMORY-CONTEXT/
```

Use naming convention:
```
YYYY-MM-DD-EXPORT-[project-name]-[description].txt
```

## Agent Usage

For this project, commonly used agents include:
- `orchestrator` - Multi-agent coordination
- [Other relevant agents]

Invoke using Task Tool pattern:
```python
Task(subagent_type="general-purpose", prompt="Use [agent-name] subagent to [task]")
```

---

**Last Updated**: [Date]
**Architecture Version**: ADR-001 Distributed Brain
```

---

## Post-Migration Verification

After completing migration:

### Verification Checklist

- [ ] `.coditect` is a symlink pointing to `../.coditect`
- [ ] `.claude` is an actual directory (not symlink)
- [ ] `.claude/CLAUDE.md` exists and contains project context
- [ ] `git status` shows expected changes (no errors)
- [ ] Can access agents: `ls .coditect/agents/`
- [ ] Can access commands: `ls .coditect/commands/`
- [ ] Claude Code recognizes `.claude/CLAUDE.md`
- [ ] No references to old submodule in `.gitmodules`

### Test Commands

```bash
# Verify symlink
test -L .coditect && echo "OK: .coditect is symlink" || echo "ERROR: .coditect is not symlink"

# Verify directory
test -d .claude && echo "OK: .claude is directory" || echo "ERROR: .claude is not directory"

# Verify CLAUDE.md
test -f .claude/CLAUDE.md && echo "OK: CLAUDE.md exists" || echo "ERROR: CLAUDE.md missing"

# Verify master brain access
ls .coditect/agents/ | head -5 && echo "OK: Can access master brain" || echo "ERROR: Cannot access master brain"
```

---

## Rollback Procedure

If migration fails and you need to restore the submodule:

### Step 1: Remove Failed Migration
```bash
rm -rf .claude
rm .coditect
```

### Step 2: Restore Submodule
```bash
# Re-add submodule
git submodule add https://github.com/coditect-ai/coditect-project-dot-claude.git .coditect

# Recreate .claude symlink
ln -s .coditect .claude
```

### Step 3: Verify Restoration
```bash
git status
ls -la .coditect
ls -la .claude
```

### Step 4: Update Parent .gitmodules if Needed
```bash
# If entry was removed from parent's .gitmodules, restore from backup
cat /tmp/gitmodules-backup-* | grep -A3 "ERP-ODOO-FORK"
# Manually add back to .gitmodules if needed
```

---

## Automation Script

For migrating multiple projects, use this script:

```bash
#!/bin/bash
# migrate-to-distributed-brain.sh
# Usage: ./migrate-to-distributed-brain.sh /path/to/project

set -e

PROJECT_PATH="$1"
PROJECT_NAME=$(basename "$PROJECT_PATH")

if [ -z "$PROJECT_PATH" ]; then
    echo "Usage: $0 /path/to/project"
    exit 1
fi

echo "=== Migrating $PROJECT_NAME to Distributed Brain Architecture ==="

cd "$PROJECT_PATH"

# Check if .coditect exists and is a submodule
if [ -d ".coditect" ] && [ ! -L ".coditect" ]; then
    echo "Step 1: Removing .claude symlink..."
    rm -f .claude

    echo "Step 2: Deinitializing submodule..."
    git submodule deinit -f .coditect 2>/dev/null || true

    echo "Step 3: Removing from git index..."
    git rm -f .coditect 2>/dev/null || true

    echo "Step 4: Cleaning up git modules cache..."
    rm -rf ../.git/modules/"$PROJECT_NAME"/.coditect 2>/dev/null || true
    rm -rf .git/modules/.coditect 2>/dev/null || true
fi

# Skip if already a symlink
if [ -L ".coditect" ]; then
    echo "Note: .coditect is already a symlink, skipping removal"
fi

echo "Step 5: Creating symlink to master brain..."
ln -sf ../.coditect .coditect

echo "Step 6: Creating .claude directory..."
mkdir -p .claude

echo "Step 7: Verification..."
if [ -L ".coditect" ] && [ -d ".claude" ]; then
    echo "SUCCESS: Migration complete!"
    echo "  - .coditect -> $(readlink .coditect)"
    echo "  - .claude is directory"
    echo ""
    echo "Next steps:"
    echo "  1. Create .claude/CLAUDE.md with project-specific configuration"
    echo "  2. git add -A && git commit -m 'Migrate to distributed brain'"
else
    echo "ERROR: Migration verification failed"
    exit 1
fi
```

Make executable:
```bash
chmod +x migrate-to-distributed-brain.sh
```

---

## Migration Log

Track all project migrations here:

| Project | Date | Status | Notes |
|---------|------|--------|-------|
| ERP-ODOO-FORK | 2025-11-18 | In Progress | First migration |
| | | | |

---

## Troubleshooting

### Issue: "fatal: not removing '.coditect' file"
**Cause**: File not tracked by git or already removed
**Solution**: Manually remove with `rm -rf .coditect`

### Issue: Symlink shows "Permission denied"
**Cause**: Target doesn't exist or wrong path
**Solution**: Verify `../.coditect` exists and is accessible

### Issue: Claude Code doesn't find CLAUDE.md
**Cause**: Wrong directory structure or file permissions
**Solution**: Verify `.claude/CLAUDE.md` exists and is readable

### Issue: Git complains about submodule in parent
**Cause**: Entry still in parent's `.gitmodules`
**Solution**: Remove entry from `/Users/halcasteel/PROJECTS/.gitmodules`

---

## References

- **ADR-001**: Distributed Brain Architecture Decision Record
- **PROJECTS/.coditect**: Master brain repository
- **CODITECT Framework Documentation**: See `.coditect/README.md`

---

**Document Version**: 1.0
**Created**: 2025-11-18
**Author**: CODITECT Migration Orchestrator

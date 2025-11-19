#!/bin/bash
# migrate-project.sh - Migrate project from submodule to symlink architecture
#
# Usage: ./migrate-project.sh <project-path>
# Example: ./migrate-project.sh /Users/halcasteel/PROJECTS/ERP-ODOO-FORK

set -e

PROJECT_PATH="$1"
PROJECTS_ROOT="$(dirname "$PROJECT_PATH")"

if [ -z "$PROJECT_PATH" ]; then
    echo "Usage: $0 <project-path>"
    exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "Error: $PROJECT_PATH does not exist"
    exit 1
fi

# Verify PROJECTS root has .coditect
if [ ! -d "$PROJECTS_ROOT/.coditect" ]; then
    echo "Error: $PROJECTS_ROOT/.coditect not found"
    echo "Please ensure CODITECT brain is installed at PROJECTS root"
    exit 1
fi

PROJECT_NAME="$(basename "$PROJECT_PATH")"
cd "$PROJECT_PATH"

echo "Migrating $PROJECT_NAME to distributed brain architecture"
echo ""

# Check current state
if [ -d ".coditect" ] && [ ! -L ".coditect" ]; then
    echo "Found: .coditect as directory (likely submodule)"
    IS_SUBMODULE=true
elif [ -L ".coditect" ]; then
    echo "Found: .coditect as symlink (already migrated?)"
    IS_SUBMODULE=false
else
    echo "No .coditect found, will create symlink"
    IS_SUBMODULE=false
fi

# Backup current state
echo ""
echo "Step 1: Creating backup..."
BACKUP_DIR="/tmp/coditect-migration-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f ".gitmodules" ]; then
    cp .gitmodules "$BACKUP_DIR/"
fi

if [ -d ".coditect" ]; then
    # Save any project-specific content
    if [ -f ".coditect/CLAUDE.md" ]; then
        cp ".coditect/CLAUDE.md" "$BACKUP_DIR/CLAUDE.md.backup"
    fi
fi

echo "Backup saved to: $BACKUP_DIR"

# Remove submodule if present
if [ "$IS_SUBMODULE" = true ]; then
    echo ""
    echo "Step 2: Removing .coditect submodule..."

    # Check if it's actually a git submodule
    if [ -f ".coditect/.git" ]; then
        git submodule deinit -f .coditect 2>/dev/null || true
        git rm -f .coditect 2>/dev/null || true

        # Clean up .git/modules
        PARENT_GIT="$(git rev-parse --git-dir)"
        if [ -d "$PARENT_GIT/modules/.coditect" ]; then
            rm -rf "$PARENT_GIT/modules/.coditect"
        fi
    else
        # Just a directory, remove it
        rm -rf .coditect
    fi

    echo "Removed .coditect submodule"
fi

# Remove old .claude symlink if present
if [ -L ".claude" ]; then
    echo ""
    echo "Step 3: Removing old .claude symlink..."
    rm .claude
    echo "Removed .claude symlink"
fi

# Create new .coditect symlink
echo ""
echo "Step 4: Creating .coditect symlink..."
ln -s ../.coditect .coditect
echo "Created: .coditect -> ../.coditect"

# Create .claude directory
echo ""
echo "Step 5: Creating .claude directory..."
mkdir -p .claude

# Create CLAUDE.md
if [ -f "$BACKUP_DIR/CLAUDE.md.backup" ]; then
    # Use backed up version as starting point
    cp "$BACKUP_DIR/CLAUDE.md.backup" .claude/CLAUDE.md
    echo "Restored CLAUDE.md from backup"
else
    # Create new CLAUDE.md
    cat > .claude/CLAUDE.md << EOF
# $PROJECT_NAME - Claude Instructions

## Project Overview
[Migrated project - add description]

## Shared Resources
Access CODITECT resources via \`.coditect/\`:
- Agents: \`.coditect/agents/\`
- Commands: \`.coditect/commands/\`
- Skills: \`.coditect/skills/\`

## Project-Specific Context
[Add project-specific details]

## Planning Documents
- [PROJECT-PLAN.md](PROJECT-PLAN.md)
- [TASKLIST.md](TASKLIST.md)
EOF
    echo "Created: .claude/CLAUDE.md"
fi

# Create planning documents if missing
if [ ! -f ".claude/PROJECT-PLAN.md" ]; then
    touch .claude/PROJECT-PLAN.md
    echo "Created: .claude/PROJECT-PLAN.md"
fi

if [ ! -f ".claude/TASKLIST.md" ]; then
    touch .claude/TASKLIST.md
    echo "Created: .claude/TASKLIST.md"
fi

# Verify
echo ""
echo "Step 6: Verification..."
echo ""

if [ -L ".coditect" ]; then
    echo "  .coditect: $(readlink .coditect)"
else
    echo "  ERROR: .coditect is not a symlink"
    exit 1
fi

if [ -d ".claude" ]; then
    echo "  .claude/: directory"
    ls -la .claude/
else
    echo "  ERROR: .claude is not a directory"
    exit 1
fi

echo ""
echo "Migration complete!"
echo ""
echo "Next steps:"
echo "  1. Review .claude/CLAUDE.md and update with project context"
echo "  2. git add .coditect .claude"
echo "  3. git commit -m 'Migrate to distributed brain architecture'"
echo "  4. git push"
echo ""
echo "Backup location: $BACKUP_DIR"

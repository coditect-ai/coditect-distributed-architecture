#!/bin/bash
# setup-project.sh - Setup a new project with CODITECT distributed architecture
#
# Usage: ./setup-project.sh <project-path>
# Example: ./setup-project.sh /Users/halcasteel/PROJECTS/my-new-project

set -e

PROJECT_PATH="$1"
PROJECTS_ROOT="$(dirname "$PROJECT_PATH")"

if [ -z "$PROJECT_PATH" ]; then
    echo "Usage: $0 <project-path>"
    echo "Example: $0 /Users/halcasteel/PROJECTS/my-new-project"
    exit 1
fi

# Verify PROJECTS root has .coditect
if [ ! -d "$PROJECTS_ROOT/.coditect" ]; then
    echo "Error: $PROJECTS_ROOT/.coditect not found"
    echo "Please ensure CODITECT brain is installed at PROJECTS root"
    exit 1
fi

# Calculate relative path depth
PROJECT_NAME="$(basename "$PROJECT_PATH")"
DEPTH=$(echo "$PROJECT_PATH" | tr -cd '/' | wc -c)
PROJECTS_DEPTH=$(echo "$PROJECTS_ROOT" | tr -cd '/' | wc -c)
REL_DEPTH=$((DEPTH - PROJECTS_DEPTH))

# Build relative path to .coditect
REL_PATH=""
for i in $(seq 1 $REL_DEPTH); do
    REL_PATH="../$REL_PATH"
done
REL_PATH="${REL_PATH}.coditect"

echo "Setting up CODITECT for: $PROJECT_PATH"
echo "Relative path to brain: $REL_PATH"

# Create project directory if needed
mkdir -p "$PROJECT_PATH"
cd "$PROJECT_PATH"

# Create .coditect symlink
if [ -L ".coditect" ] || [ -d ".coditect" ]; then
    echo "Warning: .coditect already exists, skipping symlink"
else
    ln -s "$REL_PATH" .coditect
    echo "Created symlink: .coditect -> $REL_PATH"
fi

# Create .claude directory
mkdir -p .claude

# Create CLAUDE.md from template
if [ ! -f ".claude/CLAUDE.md" ]; then
    cat > .claude/CLAUDE.md << EOF
# $PROJECT_NAME - Claude Instructions

## Project Overview
[Describe your project here]

## Shared Resources
Access CODITECT resources via \`.coditect/\`:
- Agents: \`.coditect/agents/\`
- Commands: \`.coditect/commands/\`
- Skills: \`.coditect/skills/\`

## Project-Specific Context
[Add project-specific details, conventions, important information]

## Planning Documents
- [PROJECT-PLAN.md](PROJECT-PLAN.md) - Implementation phases and milestones
- [TASKLIST.md](TASKLIST.md) - Task checklist with checkboxes

## Key Directories
[Document important directories in this project]

## Development Workflow
[Describe how to work on this project]
EOF
    echo "Created: .claude/CLAUDE.md"
fi

# Create PROJECT-PLAN.md
if [ ! -f ".claude/PROJECT-PLAN.md" ]; then
    cat > .claude/PROJECT-PLAN.md << EOF
# $PROJECT_NAME - Project Plan

## Overview
[Project description and goals]

## Timeline
[Overall timeline estimate]

## Phases

### Phase 1: [Name]
- **Duration**: X weeks
- **Goals**: [What this phase accomplishes]
- **Deliverables**:
  - [ ] Deliverable 1
  - [ ] Deliverable 2

### Phase 2: [Name]
- **Duration**: X weeks
- **Goals**: [What this phase accomplishes]
- **Deliverables**:
  - [ ] Deliverable 1
  - [ ] Deliverable 2

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Risk 1 | Medium | High | Mitigation strategy |
EOF
    echo "Created: .claude/PROJECT-PLAN.md"
fi

# Create TASKLIST.md
if [ ! -f ".claude/TASKLIST.md" ]; then
    cat > .claude/TASKLIST.md << EOF
# $PROJECT_NAME - Task List

## In Progress
- [ ] Task 1
  - **Acceptance Criteria**: [What done looks like]
  - **Estimated Hours**: X
  - **Assigned**: [Who]

## Pending
- [ ] Task 2
- [ ] Task 3

## Completed
<!-- Move completed tasks here -->
EOF
    echo "Created: .claude/TASKLIST.md"
fi

echo ""
echo "CODITECT setup complete for $PROJECT_NAME"
echo ""
echo "Structure:"
echo "  $PROJECT_PATH/"
echo "  ├── .coditect -> $REL_PATH"
echo "  └── .claude/"
echo "      ├── CLAUDE.md"
echo "      ├── PROJECT-PLAN.md"
echo "      └── TASKLIST.md"
echo ""
echo "Next steps:"
echo "  1. Edit .claude/CLAUDE.md with project details"
echo "  2. Fill out .claude/PROJECT-PLAN.md"
echo "  3. Add tasks to .claude/TASKLIST.md"

#!/bin/bash
# health-check.sh - Verify CODITECT distributed architecture health
#
# Usage: ./health-check.sh [project-path]
# Example: ./health-check.sh /Users/halcasteel/PROJECTS/ERP-ODOO-FORK

set -e

PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH"

PROJECT_NAME="$(basename "$(pwd)")"
ERRORS=0
WARNINGS=0

echo "CODITECT Health Check: $PROJECT_NAME"
echo "========================================"
echo ""

# Check .coditect symlink
echo "Checking .coditect..."
if [ -L ".coditect" ]; then
    TARGET="$(readlink .coditect)"
    if [ -d ".coditect" ]; then
        echo "  [OK] .coditect -> $TARGET"
    else
        echo "  [ERROR] .coditect symlink broken: $TARGET"
        ERRORS=$((ERRORS + 1))
    fi
elif [ -d ".coditect" ]; then
    echo "  [WARNING] .coditect is directory (should be symlink)"
    WARNINGS=$((WARNINGS + 1))
else
    echo "  [ERROR] .coditect not found"
    ERRORS=$((ERRORS + 1))
fi

# Check .claude directory
echo ""
echo "Checking .claude/..."
if [ -d ".claude" ]; then
    echo "  [OK] .claude/ exists"

    # Check CLAUDE.md
    if [ -f ".claude/CLAUDE.md" ]; then
        LINES=$(wc -l < .claude/CLAUDE.md)
        if [ "$LINES" -gt 10 ]; then
            echo "  [OK] CLAUDE.md ($LINES lines)"
        else
            echo "  [WARNING] CLAUDE.md is very short ($LINES lines)"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo "  [ERROR] CLAUDE.md not found"
        ERRORS=$((ERRORS + 1))
    fi

    # Check PROJECT-PLAN.md
    if [ -f ".claude/PROJECT-PLAN.md" ]; then
        LINES=$(wc -l < .claude/PROJECT-PLAN.md)
        echo "  [OK] PROJECT-PLAN.md ($LINES lines)"
    else
        echo "  [WARNING] PROJECT-PLAN.md not found"
        WARNINGS=$((WARNINGS + 1))
    fi

    # Check TASKLIST.md
    if [ -f ".claude/TASKLIST.md" ]; then
        LINES=$(wc -l < .claude/TASKLIST.md)
        echo "  [OK] TASKLIST.md ($LINES lines)"
    else
        echo "  [WARNING] TASKLIST.md not found"
        WARNINGS=$((WARNINGS + 1))
    fi
elif [ -L ".claude" ]; then
    echo "  [ERROR] .claude is symlink (should be directory)"
    ERRORS=$((ERRORS + 1))
else
    echo "  [ERROR] .claude not found"
    ERRORS=$((ERRORS + 1))
fi

# Check brain accessibility
echo ""
echo "Checking brain accessibility..."
if [ -d ".coditect/agents" ]; then
    AGENT_COUNT=$(ls -1 .coditect/agents/*.md 2>/dev/null | wc -l)
    echo "  [OK] agents/ accessible ($AGENT_COUNT agents)"
else
    echo "  [ERROR] agents/ not accessible"
    ERRORS=$((ERRORS + 1))
fi

if [ -d ".coditect/commands" ]; then
    CMD_COUNT=$(ls -1 .coditect/commands/*.md 2>/dev/null | wc -l)
    echo "  [OK] commands/ accessible ($CMD_COUNT commands)"
else
    echo "  [ERROR] commands/ not accessible"
    ERRORS=$((ERRORS + 1))
fi

if [ -d ".coditect/skills" ]; then
    SKILL_COUNT=$(ls -1 .coditect/skills/*.md 2>/dev/null | wc -l)
    echo "  [OK] skills/ accessible ($SKILL_COUNT skills)"
else
    echo "  [ERROR] skills/ not accessible"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo ""
echo "========================================"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "Result: HEALTHY"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "Result: $WARNINGS warning(s)"
    exit 0
else
    echo "Result: $ERRORS error(s), $WARNINGS warning(s)"
    exit 1
fi

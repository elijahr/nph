#!/bin/bash

# Script to verify all content changes from master-backup are in feature branches

set -euo pipefail

BACKUP_DIR="./nph-backup"
FIX_BLOCK_DIR="./nph-fix-block"
DIFF_DIR="./nph-diff"
CONFIG_DIR="./nph-config"
TESTS_DIR="./nph-tests"
PRECOMMIT_DIR="./nph-precommit"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "BRANCH TOPOLOGY ANALYSIS"
echo "=========================================="
echo ""
echo "Branch Dependencies:"
echo "  - feature/fix-block-comment-formatting (independent)"
echo "  - feature/diff-flag (independent)"
echo "    └─ feature/test-suite-modernization (child)"
echo "  - feature/config-filtering (independent)"
echo "    └─ feature/pre-commit-integration (child)"
echo ""
echo "Coverage Rules:"
echo "  - Changes in diff-flag automatically covered by test-suite"
echo "  - Changes in config-filtering automatically covered by pre-commit"
echo ""

echo "=========================================="
echo "FILE CONTENT COVERAGE ANALYSIS"
echo "=========================================="
echo ""

# Get list of changed files
CHANGED_FILES=$(git diff --name-only '46ccc3c^..master-backup')

total_files=0
covered_files=0
orphaned_files=0
declare -a orphaned_list

for file in $CHANGED_FILES; do
    total_files=$((total_files + 1))

    # Check if file exists in master-backup
    if [ ! -f "$BACKUP_DIR/$file" ]; then
        continue
    fi

    # Get master-backup file hash
    backup_hash=$(sha256sum "$BACKUP_DIR/$file" 2>/dev/null | awk '{print $1}')

    # Check each feature branch (only check independent + child tips)
    found_in=""

    # Check fix-block-comment (independent)
    if [ -f "$FIX_BLOCK_DIR/$file" ]; then
        hash=$(sha256sum "$FIX_BLOCK_DIR/$file" 2>/dev/null | awk '{print $1}')
        if [ "$hash" = "$backup_hash" ]; then
            found_in="$found_in fix-block"
        fi
    fi

    # Check diff-flag (independent, parent of test-suite)
    if [ -f "$DIFF_DIR/$file" ]; then
        hash=$(sha256sum "$DIFF_DIR/$file" 2>/dev/null | awk '{print $1}')
        if [ "$hash" = "$backup_hash" ]; then
            found_in="$found_in diff-flag"
        fi
    fi

    # Check test-suite (child of diff-flag)
    if [ -f "$TESTS_DIR/$file" ]; then
        hash=$(sha256sum "$TESTS_DIR/$file" 2>/dev/null | awk '{print $1}')
        if [ "$hash" = "$backup_hash" ]; then
            found_in="$found_in test-suite"
        fi
    fi

    # Check config-filtering (independent, parent of pre-commit)
    if [ -f "$CONFIG_DIR/$file" ]; then
        hash=$(sha256sum "$CONFIG_DIR/$file" 2>/dev/null | awk '{print $1}')
        if [ "$hash" = "$backup_hash" ]; then
            found_in="$found_in config-filtering"
        fi
    fi

    # Check pre-commit (child of config-filtering)
    if [ -f "$PRECOMMIT_DIR/$file" ]; then
        hash=$(sha256sum "$PRECOMMIT_DIR/$file" 2>/dev/null | awk '{print $1}')
        if [ "$hash" = "$backup_hash" ]; then
            found_in="$found_in pre-commit"
        fi
    fi

    # Report
    if [ -z "$found_in" ]; then
        echo -e "${RED}✗ ORPHANED${NC}: $file"
        echo "  Not found in any feature branch"
        orphaned_files=$((orphaned_files + 1))
        orphaned_list+=("$file")
    else
        echo -e "${GREEN}✓ COVERED${NC}: $file"
        echo "  Found in:$found_in"
        covered_files=$((covered_files + 1))
    fi
    echo ""
done

echo "=========================================="
echo "SUMMARY"
echo "=========================================="
echo ""
echo "Total files changed: $total_files"
echo "Covered files: $covered_files"
echo "Orphaned files: $orphaned_files"
echo ""

if [ $orphaned_files -gt 0 ]; then
    echo -e "${RED}❌ COVERAGE INCOMPLETE!${NC}"
    echo ""
    echo "The following files are not in any feature branch:"
    for file in "${orphaned_list[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo "These files need to be added to appropriate feature branches."
    exit 1
else
    echo -e "${GREEN}✅ COMPLETE COVERAGE!${NC}"
    echo "All changes from master-backup are present in feature branches."
    exit 0
fi

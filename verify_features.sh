#!/bin/bash

# Feature-based verification instead of file hash comparison
# Verifies that each feature's key characteristics are present in the corresponding branch

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "FEATURE-BASED COVERAGE VERIFICATION"
echo "=========================================="
echo ""

failures=0

# Feature 1: Block Comment Fix
echo "Feature 1: Block Comment Fix (feature/fix-block-comment-formatting)"
echo "----------------------------------------------------------------"
if git show feature/fix-block-comment-formatting:src/phrenderer.nim | grep -q "preserves patterns like"; then
    echo -e "${GREEN}✓${NC} Block comment fix logic present in src/phrenderer.nim"
else
    echo -e "${RED}✗${NC} Block comment fix logic MISSING"
    failures=$((failures + 1))
fi

if git ls-tree -r feature/fix-block-comment-formatting --name-only | grep -q "tests/before/comments.nim"; then
    echo -e "${GREEN}✓${NC} Block comment test fixtures present"
else
    echo -e "${RED}✗${NC} Block comment test fixtures MISSING"
    failures=$((failures + 1))
fi
echo ""

# Feature 2: --diff and --color flags
echo "Feature 2: --diff and --color flags (feature/diff-flag)"
echo "----------------------------------------------------------------"
if git show feature/diff-flag:src/nph.nim | grep -q "\\-\\-diff"; then
    echo -e "${GREEN}✓${NC} --diff flag present in src/nph.nim"
else
    echo -e "${RED}✗${NC} --diff flag MISSING"
    failures=$((failures + 1))
fi

if git show feature/diff-flag:src/nph.nim | grep -q "\\-\\-color"; then
    echo -e "${GREEN}✓${NC} --color flag present in src/nph.nim"
else
    echo -e "${RED}✗${NC} --color flag MISSING"
    failures=$((failures + 1))
fi

if git show feature/diff-flag:src/nph.nim | grep -q "hldiffpkg"; then
    echo -e "${GREEN}✓${NC} hldiff import present for diff functionality"
else
    echo -e "${RED}✗${NC} hldiff import MISSING"
    failures=$((failures + 1))
fi
echo ""

# Feature 3: Test Suite Modernization
echo "Feature 3: Test Suite Modernization (feature/test-suite-modernization)"
echo "----------------------------------------------------------------"
if git show feature/test-suite-modernization:tests/test_formatter.nim | grep -q "compileTime.*test.*generation"; then
    echo -e "${GREEN}✓${NC} Compile-time test generation present"
elif git show feature/test-suite-modernization:tests/test_formatter.nim | grep -q "unittest"; then
    echo -e "${GREEN}✓${NC} Modern test suite structure present"
else
    echo -e "${RED}✗${NC} Test suite modernization MISSING"
    failures=$((failures + 1))
fi

if git ls-tree -r feature/test-suite-modernization --name-only | grep -q "tests/expected_output/diff"; then
    echo -e "${GREEN}✓${NC} Test expected output files present"
else
    echo -e "${RED}✗${NC} Test expected output files MISSING"
    failures=$((failures + 1))
fi
echo ""

# Feature 4: Configuration and Filtering
echo "Feature 4: Configuration and Filtering (feature/config-filtering)"
echo "----------------------------------------------------------------"
if git show feature/config-filtering:src/nph.nim | grep -q "NphConfig"; then
    echo -e "${GREEN}✓${NC} NphConfig type present in src/nph.nim"
else
    echo -e "${RED}✗${NC} NphConfig type MISSING"
    failures=$((failures + 1))
fi

if git show feature/config-filtering:src/nph.nim | grep -q "loadConfig"; then
    echo -e "${GREEN}✓${NC} loadConfig function present"
else
    echo -e "${RED}✗${NC} loadConfig function MISSING"
    failures=$((failures + 1))
fi

if git show feature/config-filtering:src/nph.nim | grep -q "\\-\\-exclude"; then
    echo -e "${GREEN}✓${NC} --exclude flag present"
else
    echo -e "${RED}✗${NC} --exclude flag MISSING"
    failures=$((failures + 1))
fi

if git ls-tree -r feature/config-filtering --name-only | grep -q ".nph.toml"; then
    echo -e "${GREEN}✓${NC} .nph.toml config file present"
else
    echo -e "${RED}✗${NC} .nph.toml config file MISSING"
    failures=$((failures + 1))
fi

if git show feature/config-filtering:src/nph.nim | grep -q "parsetoml"; then
    echo -e "${GREEN}✓${NC} parsetoml import present"
else
    echo -e "${RED}✗${NC} parsetoml import MISSING"
    failures=$((failures + 1))
fi
echo ""

# Feature 5: Pre-commit Integration
echo "Feature 5: Pre-commit Integration (feature/pre-commit-integration)"
echo "----------------------------------------------------------------"
if git ls-tree -r feature/pre-commit-integration --name-only | grep -q ".pre-commit-hooks.yaml"; then
    echo -e "${GREEN}✓${NC} .pre-commit-hooks.yaml present"
else
    echo -e "${RED}✗${NC} .pre-commit-hooks.yaml MISSING"
    failures=$((failures + 1))
fi

if git ls-tree -r feature/pre-commit-integration --name-only | grep -q ".pre-commit-config.yaml"; then
    echo -e "${GREEN}✓${NC} .pre-commit-config.yaml present"
else
    echo -e "${RED}✗${NC} .pre-commit-config.yaml MISSING"
    failures=$((failures + 1))
fi

if git show feature/pre-commit-integration:.github/workflows/ci.yml | grep -q "pre-commit"; then
    echo -e "${GREEN}✓${NC} Pre-commit CI job present in workflows"
else
    echo -e "${RED}✗${NC} Pre-commit CI job MISSING from workflows"
    failures=$((failures + 1))
fi
echo ""

echo "=========================================="
echo "SUMMARY"
echo "=========================================="
echo ""

if [ $failures -eq 0 ]; then
    echo -e "${GREEN}✅ ALL FEATURES VERIFIED!${NC}"
    echo "All feature branches contain their respective feature implementations."
    exit 0
else
    echo -e "${RED}❌ VERIFICATION FAILED!${NC}"
    echo "Found $failures missing features or components."
    echo "Please review the failures above and add missing content to the appropriate branches."
    exit 1
fi

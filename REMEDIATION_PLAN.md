# Remediation Plan for Branch Coverage Gaps

**Date**: 2025-10-27
**Status**: ❌ 33 orphaned files need remediation
**Priority**: HIGH - Critical source files missing from feature branches

---

## Overview

The branch coverage analysis revealed that 33 out of 56 changed files are not present in any feature branch. This is a serious issue that needs immediate remediation.

**Key Finding**: Most orphaned files fall into two categories:
1. **Formatting-only changes** (26 files) - Low priority, can be handled by pre-commit hooks
2. **Critical source/test files** (7 files) - High priority, contain actual feature logic

---

## Critical Files Requiring Immediate Action

### 🔴 Priority 1: Source Code Files (MUST FIX)

#### 1. `src/nph.nim` - Main source file
**Problem**: This file contains changes for MULTIPLE features but isn't in ANY branch.

**Required Actions**:
1. Analyze the diff from 46ccc3c^..master-backup
2. Identify which changes belong to which feature:
   - `--diff` flag implementation → feature/diff-flag
   - `--color` flag implementation → feature/diff-flag
   - Configuration file support (.nph.toml) → feature/config-filtering
   - File filtering logic → feature/config-filtering
3. **Decision needed**:
   - Option A: Cherry-pick specific hunks to each feature branch
   - Option B: Ensure changes are in at least ONE branch, then split later
   - Option C: Create patches and apply selectively

**Recommendation**: **Option B** - Verify ALL changes from master-backup are in at least one feature branch first (even if wrong branch), then reorganize if needed.

---

#### 2. `tests/test_formatter.nim` - Main test file
**Problem**: Contains tests for multiple features, not in any branch.

**Required Actions**:
1. Analyze diff to identify test additions/changes:
   - Tests for `--diff` flag → feature/diff-flag
   - Tests for `--color` flag → feature/diff-flag
   - Tests for config file → feature/config-filtering
   - Compile-time test generation → feature/test-suite-modernization
2. Same options as `src/nph.nim`

**Recommendation**: Same as above - ensure in at least ONE branch first.

---

#### 3. `nph.nimble` - Build configuration
**Problem**: May contain dependency or build script changes.

**Required Actions**:
1. Review changes carefully
2. Determine if changes are feature-specific or general
3. Add to appropriate branch(es)

---

### 🟡 Priority 2: Test Fixtures (Should Fix)

#### 4-7. Test fixture files for block comments
- `tests/before/comments.nim`
- `tests/before/comments.nim.nph.yaml`
- `tests/after/comments.nim`
- `tests/after/comments.nim.nph.yaml`

**Problem**: Test fixtures for block comment feature are missing.

**Required Actions**:
1. Add ALL these files to **feature/fix-block-comment-formatting**
2. Verify they're needed for the block comment fix

**Command**:
```bash
git checkout feature/fix-block-comment-formatting
git checkout master-backup -- tests/before/comments.nim*
git checkout master-backup -- tests/after/comments.nim*
```

---

#### 8-11. Test fixture files for fmton
- `tests/before/fmton.nim`
- `tests/before/fmton.nim.nph.yaml`
- `tests/after/fmton.nim`
- `tests/after/fmton.nim.nph.yaml`

**Problem**: Purpose unclear, need to investigate.

**Required Actions**:
1. Examine what "fmton" tests (format on/off?)
2. Determine appropriate branch
3. Add to that branch

---

### 🟢 Priority 3: Build/Config Files

#### 12. `.gitignore`
**Changes**:
- Added `*.dSYM/`
- Added `/tests/test_formatter`
- Added `*.nph.yaml` patterns

**Recommendation**: Add to **feature/test-suite-modernization** (test-related ignores)

**Command**:
```bash
git checkout feature/test-suite-modernization
git checkout master-backup -- .gitignore
```

---

## Formatting-Only Files (26 files) - Low Priority

### Strategy: Skip for Now

**Rationale**:
- These are purely formatting changes (YAML indentation, markdown wrapping, etc.)
- Will be automatically applied by pre-commit hooks when branches are merged
- Adding them now would create noise and merge conflicts

**Files** (26 total):
- `.github/workflows/*.yml` (3 files) - YAML indent changes
- Documentation files (8 files) - Markdown reformatting
- `vscode-nph/*` (7 files) - JSON/TS formatting
- `config.nims`, `format-git-repo.sh` (2 files) - Various formatting

**Action**: ✅ **SKIP** - Let pre-commit hooks handle during merge

---

## Implementation Plan

### Phase 1: Verify Critical Files (TODAY)

```bash
# 1. Check what's actually in src/nph.nim in master-backup vs feature branches
git diff feature/diff-flag..master-backup -- src/nph.nim | wc -l
git diff feature/config-filtering..master-backup -- src/nph.nim | wc -l
git diff feature/test-suite-modernization..master-backup -- src/nph.nim | wc -l

# 2. Same for tests/test_formatter.nim
git diff feature/test-suite-modernization..master-backup -- tests/test_formatter.nim | wc -l
git diff feature/diff-flag..master-backup -- tests/test_formatter.nim | wc -l

# 3. Check nph.nimble
git diff master..master-backup -- nph.nimble
```

### Phase 2: Add Test Fixtures (TODAY)

```bash
# Add block comment test fixtures
git checkout feature/fix-block-comment-formatting
git checkout master-backup -- \
  tests/before/comments.nim \
  tests/before/comments.nim.nph.yaml \
  tests/after/comments.nim \
  tests/after/comments.nim.nph.yaml
git add tests/before/comments.* tests/after/comments.*
git commit -m "fix: add missing block comment test fixtures"

# Investigate and add fmton fixtures
# (manual review first)
```

### Phase 3: Add .gitignore Changes

```bash
git checkout feature/test-suite-modernization
git checkout master-backup -- .gitignore
git add .gitignore
git commit -m "chore: add test-related gitignore patterns"
```

### Phase 4: Critical File Analysis

**Manual Process**:
1. Generate detailed diff for `src/nph.nim`
2. Identify feature boundaries in the code
3. Create plan to distribute or consolidate changes
4. Implement (may require rebasing or amending commits)

---

## Acceptance Criteria

✅ **Success** = All of the following:
1. Every line change from master-backup exists in at least one feature branch
2. Critical files (`src/nph.nim`, `tests/test_formatter.nim`) fully accounted for
3. Test fixtures in appropriate branches
4. Coverage verification script shows 0 orphaned files (excluding intentionally skipped formatting files)

❌ **Failure** = Any critical file content missing from feature branches

---

## Questions to Resolve

1. **src/nph.nim**: Can we verify that ALL logic from master-backup for each feature is actually in the corresponding feature branch?

2. **tests/test_formatter.nim**: Same question - are the tests actually there?

3. **If changes are missing**: What's the best way to add them?
   - Cherry-pick specific commits?
   - Create new commits with the missing changes?
   - Rebase the branches?

4. **Formatting files**: Confirm we can safely skip them?

---

## Next Steps

1. **Review this plan** with the team/user
2. **Execute Phase 1** to understand the scope of missing changes in critical files
3. **Based on Phase 1 findings**, decide on specific remediation approach
4. **Execute Phases 2-3** for straightforward additions
5. **Re-run verification** to confirm coverage
6. **Document final state**

---

### Phase 5: Re-run Verification (REQUIRED)

**Purpose**: Confirm that ALL changes from master-backup are now in appropriate feature branches.

```bash
# Re-run the coverage verification
./verify_coverage.sh

# Expected result:
# - "✅ COMPLETE COVERAGE!"
# - 0 orphaned files (all content from master-backup is in at least one feature branch)

# If any files still orphaned:
# - Review why they're missing
# - Add to appropriate branch
# - Re-run verification until clean
```

**Success Criteria**:
- ✅ verify_coverage.sh reports 0 orphaned files
- ✅ Every code change from 46ccc3c onwards is in at least one feature branch
- ✅ Each feature branch contains only relevant changes for that feature
- ✅ Branch dependencies are correctly maintained

**Note on Formatting**:
- Each branch should be formatted according to the formatting tools available on that branch
- If a branch has pre-commit integration, it should be formatted accordingly
- Branches can have dependency chains (e.g., test-suite built on diff-flag)

---

## Verification Command

After remediation:
```bash
./verify_coverage.sh
# Must show: "✅ COMPLETE COVERAGE!" with 0 orphaned files
```

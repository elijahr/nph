# PR Creation Guide

**Date**: 2025-10-27

---

## Branch Structure

```
master (c6e0316)
├── feature/fix-block-comment-formatting (1 commit)
├── feature/diff-flag (1 commit)
│   └── feature/test-suite-modernization (+1 commit = 2 total)
└── feature/config-filtering (1 commit)
    └── feature/pre-commit-integration (+1 commit = 2 total)
```

**Key observation**:
- `test-suite-modernization` contains the `diff-flag` commit in its history
- `pre-commit-integration` contains the `config-filtering` commit in its history

---

## Strategy 1: Stacked PRs (RECOMMENDED)

Create dependent PRs where child branches target their parent branches.

### PR Creation Order & Targets

#### Round 1: Independent Features (Create all 3 in parallel)

1. **PR: Block Comment Fix**
   - Branch: `feature/fix-block-comment-formatting`
   - **Target**: `master`
   - **Merge base**: `c6e0316`
   - Commits shown: 1 (cbb47a2)
   - Can merge independently

2. **PR: Add --diff and --color Flags**
   - Branch: `feature/diff-flag`
   - **Target**: `master`
   - **Merge base**: `c6e0316`
   - Commits shown: 1 (477dcf0)
   - Must merge BEFORE test-suite PR

3. **PR: Configuration File and Filtering**
   - Branch: `feature/config-filtering`
   - **Target**: `master`
   - **Merge base**: `c6e0316`
   - Commits shown: 1 (987762f)
   - Must merge BEFORE pre-commit PR

#### Round 2: Dependent Features (Create after parents are merged)

4. **PR: Modernize Test Suite**
   - Branch: `feature/test-suite-modernization`
   - **Target**: `feature/diff-flag` ⚠️ (NOT master)
   - **Merge base**: `477dcf0` (diff-flag HEAD)
   - Commits shown: 1 (41334f6) - Only the test suite changes
   - **Prerequisites**: PR #2 (diff-flag) must be merged to master first
   - **After diff-flag merges**: Rebase onto master, then create PR to master

5. **PR: Pre-commit Integration**
   - Branch: `feature/pre-commit-integration`
   - **Target**: `feature/config-filtering` ⚠️ (NOT master)
   - **Merge base**: `987762f` (config-filtering HEAD)
   - Commits shown: 1 (de64b5e) - Only the pre-commit changes
   - **Prerequisites**: PR #3 (config-filtering) must be merged to master first
   - **After config-filtering merges**: Rebase onto master, then create PR to master

### Merge Order

```
Step 1: Merge any of these (no dependencies):
  ✓ PR #1: fix-block-comment → master
  ✓ PR #2: diff-flag → master
  ✓ PR #3: config-filtering → master

Step 2: After PR #2 merged:
  ✓ Rebase test-suite onto master:
      git checkout feature/test-suite-modernization
      git rebase origin/master
      git push --force-with-lease
  ✓ Update PR #4 to target master (if needed, or create new PR)
  ✓ Merge PR #4: test-suite → master

Step 3: After PR #3 merged:
  ✓ Rebase pre-commit onto master:
      git checkout feature/pre-commit-integration
      git rebase origin/master
      git push --force-with-lease
  ✓ Update PR #5 to target master (if needed, or create new PR)
  ✓ Merge PR #5: pre-commit → master
```

### Advantages
- ✅ Each PR shows only relevant commits
- ✅ Clean review process (no duplicate commits)
- ✅ Easy to understand dependencies
- ✅ Can review/merge independent features in parallel

### Disadvantages
- ⚠️ Requires rebasing after parent merges
- ⚠️ More complex workflow

---

## Strategy 2: All Target Master (SIMPLER)

All PRs target master directly, accepting that dependent PRs will show parent commits.

### PR Creation Order & Targets

#### Create All 5 PRs (any order)

1. **PR: Block Comment Fix**
   - Branch: `feature/fix-block-comment-formatting`
   - **Target**: `master`
   - Commits shown: 1 (cbb47a2)

2. **PR: Add --diff and --color Flags**
   - Branch: `feature/diff-flag`
   - **Target**: `master`
   - Commits shown: 1 (477dcf0)

3. **PR: Configuration File and Filtering**
   - Branch: `feature/config-filtering`
   - **Target**: `master`
   - Commits shown: 1 (987762f)

4. **PR: Modernize Test Suite**
   - Branch: `feature/test-suite-modernization`
   - **Target**: `master`
   - **Commits shown**: 2 (41334f6 + 477dcf0) ⚠️
   - ⚠️ Will show diff-flag commit as well
   - **Note in PR description**: "Depends on PR #2"

5. **PR: Pre-commit Integration**
   - Branch: `feature/pre-commit-integration`
   - **Target**: `master`
   - **Commits shown**: 2 (de64b5e + 987762f) ⚠️
   - ⚠️ Will show config-filtering commit as well
   - **Note in PR description**: "Depends on PR #3"

### Merge Order

```
Step 1: Merge independent features first:
  ✓ PR #1: fix-block-comment → master
  ✓ PR #2: diff-flag → master
  ✓ PR #3: config-filtering → master

Step 2: After parents merged, dependent PRs will auto-update:
  - PR #4 will now show only 1 commit (GitHub auto-detects merged commits)
  - PR #5 will now show only 1 commit (GitHub auto-detects merged commits)

  ✓ PR #4: test-suite → master
  ✓ PR #5: pre-commit → master
```

### Advantages
- ✅ Simpler workflow (no rebasing needed)
- ✅ All PRs target master
- ✅ GitHub auto-detects merged commits and hides them
- ✅ Can create all PRs immediately

### Disadvantages
- ⚠️ Initial PR view shows "extra" commits
- ⚠️ Reviewers might be confused initially

---

## Recommended Approach

**Use Strategy 2 (All Target Master)** because:

1. GitHub automatically hides already-merged commits from PR diffs
2. Simpler workflow - no rebasing required
3. All PRs visible immediately for review
4. Just add "Depends on PR #X" notes in dependent PR descriptions

## PR Descriptions Template

### For Independent PRs (fix-block, diff-flag, config-filtering)

```markdown
## Summary
[Copy from commit message]

## Type
- [ ] Bug fix
- [x] New feature
- [ ] Breaking change

## Testing
- [ ] Tests pass locally
- [ ] Added new tests for this feature

## Dependencies
None - can be merged independently
```

### For Dependent PRs (test-suite, pre-commit)

```markdown
## Summary
[Copy from commit message]

## Type
- [ ] Bug fix
- [x] New feature
- [ ] Breaking change

## Testing
- [ ] Tests pass locally
- [ ] Added new tests for this feature

## Dependencies
⚠️ **Depends on PR #X** - Must merge PR #X first

**Note**: This PR initially shows 2 commits, but once PR #X is merged,
GitHub will automatically show only 1 commit (the actual changes from this PR).
```

---

## Quick Command Reference

### Create all PRs targeting master:
```bash
# Use GitHub CLI or web interface
gh pr create --base master --head feature/fix-block-comment-formatting --title "fix: preserve block comments followed by single-line comments"
gh pr create --base master --head feature/diff-flag --title "feat: add --diff and --color flags"
gh pr create --base master --head feature/config-filtering --title "feat: add configuration file and file filtering"
gh pr create --base master --head feature/test-suite-modernization --title "feat: modernize test suite"
gh pr create --base master --head feature/pre-commit-integration --title "feat: add pre-commit integration"
```

### Suggested PR numbers (for dependency notes):
- PR #1: fix-block-comment-formatting
- PR #2: diff-flag
- PR #3: config-filtering
- PR #4: test-suite-modernization (depends on #2)
- PR #5: pre-commit-integration (depends on #3)

---

## Final Checklist

Before creating PRs:
- [x] All branches pushed to remote
- [x] Commit messages are professional and concise
- [x] Branch dependencies understood
- [ ] Choose strategy (recommend Strategy 2)
- [ ] Create PRs in suggested order
- [ ] Add dependency notes to PRs #4 and #5
- [ ] Merge in correct order (independent first, then dependent)

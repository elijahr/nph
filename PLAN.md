# NPH Test Suite Improvements - TODO

## 1. Fix Weak/Broken Tests

### 1.1 --version test validation (HIGH PRIORITY)
**File:** `tests/test_formatter.nim:820-826`
**Issue:** Only checks output is non-empty, doesn't validate format
**Fix:**
- Verify output matches expected pattern (e.g., contains git hash, semver, or "prerelease")
- Check for specific version components
- Ensure no extra stderr output

### 1.2 Error recovery test completeness (MEDIUM)
**File:** `tests/test_formatter.nim:327-344`
**Issue:** Doesn't verify valid file was actually formatted
**Fix:**
- After checking `fileExists(tmpValidFile)`, read and verify it was formatted correctly
- Compare against expected formatted output
- Ensure error in one file doesn't affect formatting of others

### 1.3 File modification time test reliability (HIGH PRIORITY)
**File:** `tests/test_formatter.nim:525-564`
**Issue:** Uses `sleep(10)` which is fragile
**Fix:**
- Increase sleep to 100ms or use a more reliable method
- Consider using explicit timestamp manipulation if available
- Add comment explaining why sleep is necessary

### 1.4 Upward search root test accuracy (MEDIUM)
**File:** `tests/test_formatter.nim:802-817`
**Issue:** Doesn't actually test filesystem root boundary condition
**Fix:**
- Create a very deep temporary directory structure
- Or test from system root with known no-config path
- Verify it stops searching at appropriate boundary
- Currently redundant with "no config found" tests

## 2. Expand Insufficient Test Coverage

### 2.1 Color output environment tests (MEDIUM)
**Location:** After existing color tests (line 740)
**Add:**
- Test NO_COLOR environment variable behavior
  - `NO_COLOR=1` should disable color even without `--no-color`
  - Should override config `color=true`
  - Should work with both `--diff` modes
- Test TTY detection (may need mocking or different approach)

### 2.2 Malformed config file variations (HIGH PRIORITY)
**File:** `tests/test_formatter.nim:891-906`
**Current:** Only tests one malformed TOML syntax
**Expand with:**
- Missing closing bracket: `exclude = ["pattern"`
- Wrong type for field: `color = "yes"` (should be boolean)
- Unknown fields: `unknown_field = true`
- Empty file
- File with only comments
- Verify warning message content (not just that it continues)

### 2.3 --out:- edge cases (MEDIUM)
**Location:** In "--out:- (stdout) mode" suite
**Add:**
- Test `--out:- --check` combination (should it error or work?)
- Test `--out:- file.nim` where file.nim would be excluded (without --strict-filters)
  - Should it bypass filters like other explicit files?
- Test `--out:- file.nim --diff` (already errors, verify error message)

## 3. Add Missing Test Coverage

### 3.1 Multiple pattern tests (HIGH PRIORITY)
**Location:** New suite after "empty directory"
**Add:**
- Multiple `--include` patterns:
  ```nim
  --include="\.nim$" --include="\.nims$"
  ```
- Combined exclude + include:
  ```nim
  --exclude="build" --include="\.nim$"
  ```
- Config patterns + CLI patterns interaction:
  - Config has `exclude=["foo"]`, CLI has `--exclude="bar"` (CLI should replace)
  - Config has `extend-exclude=["foo"]`, CLI has `--extend-exclude="bar"` (should combine)
  - Config has `include=["\.nim$"]`, CLI has `--include="\.nims$"` (CLI should replace)

### 3.2 Invalid regex pattern handling (HIGH PRIORITY)
**Location:** New suite "invalid patterns"
**Add:**
- Test `--exclude="[invalid"` (unclosed bracket)
- Test `--include="(?P<invalid)"` (invalid named group)
- Test `--extend-exclude="*"` (invalid regex, though valid glob)
- Verify warning is shown but continues (or errors appropriately)
- Test multiple invalid patterns

### 3.3 --strict-filters with directories (HIGH PRIORITY)
**Location:** In "--strict-filters mode" suite
**Add:**
- Test `nph --strict-filters --check directory/`
  - Should filters apply to files in explicitly passed directory?
  - Current behavior: explicit directories bypass filters
  - Expected with --strict-filters: should still apply filters?
- Clarify and document expected behavior

### 3.4 Config file discovery edge cases (MEDIUM)
**Location:** In "config file upward search" suite
**Add:**
- Test explicit `--config=/dev/null` when `.nph.toml` exists in parent
  - Should truly ignore the found config
- Test `--config=relative/path/to/config.toml`
- Test config file with no permissions (unreadable)
- Test symlinked config file

### 3.5 File handling edge cases (LOW)
**Location:** New suite "edge case files"
**Add:**
- Binary file handling (should error gracefully)
- Non-UTF8 file (should error with clear message)
- File with no newline at EOF
- File with mixed line endings (CRLF/LF)
- Empty file
- File with only whitespace
- Very large file (>10MB) - performance test

### 3.6 Symlink handling (LOW)
**Location:** New suite "symlink handling"
**Add:**
- Symlinked file (should follow and format)
- Symlinked directory (should follow and recurse)
- Broken symlink (should skip gracefully)
- Circular symlink (should detect and skip)

### 3.7 Pattern matching specifics (MEDIUM)
**Location:** In "exclude/include patterns" or new suite
**Add:**
- Absolute path in exclude pattern
- Relative path in exclude pattern
- Pattern with wildcards: `--exclude="test_*.nim"`
- Case sensitivity of patterns
- Pattern matching on Windows paths (if applicable)

## 4. Improve Test Organization

### 4.1 Consolidate redundant bypass tests (LOW)
**Files:** Lines 567-688
**Issue:** 5 similar tests for "explicitly passed directories bypass X"
**Improvement:**
- Consider parameterized test helper
- Or combine into single test with subsections
- Document that this is intentional Black-like behavior

### 4.2 Document generated formatter tests (LOW)
**File:** Lines 1-94
**Improvement:**
- Add comment explaining what files in `tests/before/*.nim` test
- Consider adding a README in `tests/` explaining structure
- Make it clear what formatting aspects each test file covers

### 4.3 Audit expected output files (LOW)
**Files:** `tests/expected_output/*.txt`
**Improvement:**
- Review all expected output files for correctness
- Add comments in test explaining what makes output "correct"
- Consider generating some expected outputs programmatically

## 5. Test Implementation Helpers

### 5.1 Test utilities to add (OPTIONAL)
- Helper function for "run nph from directory" pattern
- Helper for creating test directory structures
- Helper for verifying pattern matching behavior
- Parameterized test helper for repeated test patterns

## Summary by Priority

### HIGH PRIORITY (Do First)
1. Fix --version test to validate version format
2. Fix file modification time test reliability (sleep issue)
3. Expand malformed config file tests
4. Add invalid regex pattern tests
5. Add --strict-filters with directory argument test
6. Add multiple pattern interaction tests

### MEDIUM PRIORITY (Do Second)
7. Fix error recovery test completeness
8. Add NO_COLOR environment variable tests
9. Improve upward search root test
10. Add --out:- edge case tests
11. Add config file discovery edge cases
12. Add pattern matching specifics tests

### LOW PRIORITY (Nice to Have)
13. Add file handling edge cases (binary, non-UTF8, etc.)
14. Add symlink handling tests
15. Consolidate redundant bypass tests
16. Document generated formatter tests
17. Audit expected output files
18. Add test helper utilities

**Total Tests to Add/Fix:** ~35-40 test cases
**Estimated Effort:** 4-6 hours of focused work

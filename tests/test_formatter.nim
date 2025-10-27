## nph test suite with compile-time test generation
##
## The "formatter tests" suite is generated at compile time based on files
## in tests/before/*.nim. When you add/remove test files, the const changes
## and Nim automatically recompiles.
##
## All other test suites are defined normally below.

import std/[unittest, os, osproc, strutils, sequtils, macros, times]

const
  nphBin = "./nph"
  testsDir = "tests"
  expectedOutputDir = testsDir / "expected_output"

  # Discover test files at compile time - cache busts when files change!
  testFileList = staticExec(
    "find " & currentSourcePath.parentDir() & "/before " &
      "-name '*.nim' -type f -exec basename {} \\; | sort"
  )

  testFiles = block:
    let files = testFileList.strip().splitLines()
    files.filterIt(it.len > 0)

# Show discovered tests at compile time
static:
  echo "\n=== Compile-time test discovery ==="
  echo "Found ", testFiles.len, " formatter test files:"
  for f in testFiles:
    echo "  ✓ ", f
  echo "===================================\n"

macro generateFormatterTests(): untyped =
  ## Generate a test case for each file in tests/before/*.nim
  result = newStmtList()

  var testCases = newStmtList()

  for testFile in testFiles:
    let
      testName = newLit(testFile)
      beforePath = newLit(testsDir / "before" / testFile)
      afterPath = newLit(testsDir / "after" / testFile)
      tmpPath = newLit("/tmp/nph_test_" & testFile)

    testCases.add(
      quote do:
        test `testName`:
          let
            beforeFile = `beforePath`
            afterFile = `afterPath`
            tmpFile = `tmpPath`

          check fileExists(afterFile)
          if not fileExists(afterFile):
            echo "Missing expected output file: " & afterFile
            skip()

          let (output, exitCode) =
            execCmdEx(nphBin & " " & beforeFile & " --out:" & tmpFile)

          check exitCode == 0
          if exitCode != 0:
            echo output
            skip()

          let
            formatted = readFile(tmpFile)
            expected = readFile(afterFile)

          if formatted != expected:
            let (diffOutput, _) =
              execCmdEx("diff -u " & afterFile & " " & tmpFile & " || true")
            echo "\n" & diffOutput

          check formatted == expected
          removeFile(tmpFile)
    )

  result = quote:
    suite "formatter tests":
      `testCases`

# Generate formatter tests at compile time
generateFormatterTests()

suite "--diff mode":
  test "--diff shows diff and exits 0 when formatting needed":
    let
      beforeFile = testsDir / "before/fmton.nim"
      (output, exitCode) = execCmdEx(nphBin & " --diff " & beforeFile & " 2>&1")
      expected = readFile(expectedOutputDir / "diff_formatting_needed.txt")

    check exitCode == 0
    check output == expected

  test "--diff exits 0 when no formatting needed":
    let
      afterFile = testsDir / "after/fmton.nim"
      (output, exitCode) = execCmdEx(nphBin & " --diff " & afterFile & " 2>&1")
      expected = readFile(expectedOutputDir / "diff_no_formatting_needed.txt")

    check exitCode == 0
    check output == expected

  test "--diff with multiple files shows all diffs":
    let
      beforeFile1 = testsDir / "before/fmton.nim"
      beforeFile2 = testsDir / "before/comments.nim"
      afterFile = testsDir / "after/fmton.nim"
      (output, exitCode) = execCmdEx(
        nphBin & " --diff " & beforeFile1 & " " & beforeFile2 & " " & afterFile & " 2>&1"
      )
      expected = readFile(expectedOutputDir / "diff_multiple_files.txt")

    check exitCode == 0
    check output == expected

  test "--diff rejects --out":
    let
      beforeFile = testsDir / "before/fmton.nim"
      (output, exitCode) =
        execCmdEx(nphBin & " --diff --out:/tmp/test.nim " & beforeFile & " 2>&1")
      expected = readFile(expectedOutputDir / "diff_rejects_out.txt")

    check exitCode == 3
    check output == expected

  test "--diff rejects --outDir":
    let
      beforeFile = testsDir / "before/fmton.nim"
      (output, exitCode) =
        execCmdEx(nphBin & " --diff --outDir:/tmp " & beforeFile & " 2>&1")
      expected = readFile(expectedOutputDir / "diff_rejects_outdir.txt")

    check exitCode == 3
    check output == expected

suite "--check mode":
  test "--check exits 1 when formatting needed":
    let
      beforeFile = testsDir / "before/fmton.nim"
      (output, exitCode) = execCmdEx(nphBin & " --check " & beforeFile & " 2>&1")
      expected = readFile(expectedOutputDir / "check_formatting_needed.txt")

    check exitCode == 1
    check output == expected

  test "--check exits 0 when no formatting needed":
    let
      afterFile = testsDir / "after/fmton.nim"
      (output, exitCode) = execCmdEx(nphBin & " --check " & afterFile & " 2>&1")
      expected = readFile(expectedOutputDir / "check_no_formatting_needed.txt")

    check exitCode == 0
    check output == expected

  test "--check with multiple files shows all files needing formatting":
    let
      beforeFile1 = testsDir / "before/fmton.nim"
      beforeFile2 = testsDir / "before/comments.nim"
      afterFile = testsDir / "after/fmton.nim"
      (output, exitCode) = execCmdEx(
        nphBin & " --check " & beforeFile1 & " " & beforeFile2 & " " & afterFile &
          " 2>&1"
      )
      expected = readFile(expectedOutputDir / "check_multiple_files.txt")

    check exitCode == 1
    check output == expected

  test "--check does not modify files":
    let
      beforeFile = testsDir / "before/fmton.nim"
      contentBefore = readFile(beforeFile)
      (_, exitCode) = execCmdEx(nphBin & " --check " & beforeFile & " 2>&1")
      contentAfter = readFile(beforeFile)

    check exitCode == 1
    check contentBefore == contentAfter

suite "--diff --check mode":
  test "--diff --check shows diff and exits 1 when formatting needed":
    let
      beforeFile = testsDir / "before/fmton.nim"
      (output, exitCode) = execCmdEx(nphBin & " --diff --check " & beforeFile & " 2>&1")
      expected = readFile(expectedOutputDir / "diff_check_formatting_needed.txt")

    check exitCode == 1
    check output == expected

  test "--diff --check exits 0 when no formatting needed":
    let
      afterFile = testsDir / "after/fmton.nim"
      (output, exitCode) = execCmdEx(nphBin & " --diff --check " & afterFile & " 2>&1")
      expected = readFile(expectedOutputDir / "diff_check_no_formatting_needed.txt")

    check exitCode == 0
    check output == expected

suite "write mode (default)":
  test "write mode exits 0 and writes file when formatting needed":
    let
      beforeFile = testsDir / "before/fmton.nim"
      tmpFile = "/tmp/nph_write_test.nim"
      afterFile = testsDir / "after/fmton.nim"

    copyFile(beforeFile, tmpFile)

    let
      (_, exitCode) = execCmdEx(nphBin & " " & tmpFile & " 2>&1")
      formatted = readFile(tmpFile)
      expected = readFile(afterFile)

    check exitCode == 0
    check formatted == expected
    removeFile(tmpFile)

  test "write mode exits 0 when no formatting needed":
    let
      afterFile = testsDir / "after/fmton.nim"
      tmpFile = "/tmp/nph_write_test2.nim"

    copyFile(afterFile, tmpFile)

    let
      (_, exitCode) = execCmdEx(nphBin & " " & tmpFile & " 2>&1")
      formatted = readFile(tmpFile)
      expected = readFile(afterFile)

    check exitCode == 0
    check formatted == expected
    removeFile(tmpFile)

  test "write mode with --out writes to different file":
    let
      beforeFile = testsDir / "before/fmton.nim"
      tmpFile = "/tmp/nph_out_test.nim"
      afterFile = testsDir / "after/fmton.nim"
      contentBefore = readFile(beforeFile)
      (_, exitCode) =
        execCmdEx(nphBin & " " & beforeFile & " --out:" & tmpFile & " 2>&1")
      formatted = readFile(tmpFile)
      expected = readFile(afterFile)
      contentAfter = readFile(beforeFile)

    check exitCode == 0
    check formatted == expected
    check contentBefore == contentAfter # Original file unchanged
    removeFile(tmpFile)

suite "error handling":
  test "invalid syntax exits with error code":
    let tmpFile = "/tmp/nph_invalid.nim"

    writeFile(tmpFile, "proc invalid syntax here")

    let (output, exitCode) = execCmdEx(nphBin & " " & tmpFile & " 2>&1")

    check exitCode == 3
    check "cannot be parsed" in output
    removeFile(tmpFile)

  test "error recovery with multiple files":
    let
      tmpInvalidFile = "/tmp/nph_invalid_multi.nim"
      tmpValidFile = "/tmp/nph_valid_multi.nim"
      beforeFile = testsDir / "before/fmton.nim"

    writeFile(tmpInvalidFile, "proc invalid syntax")
    copyFile(beforeFile, tmpValidFile)

    let (output, exitCode) =
      execCmdEx(nphBin & " " & tmpInvalidFile & " " & tmpValidFile & " 2>&1")

    check exitCode == 3
    check "cannot be parsed" in output
    check fileExists(tmpValidFile)

    removeFile(tmpInvalidFile)
    removeFile(tmpValidFile)

suite "summary messages":
  test "summary with only reformatted files":
    let
      beforeFile1 = testsDir / "before/fmton.nim"
      beforeFile2 = testsDir / "before/comments.nim"
      (output, exitCode) =
        execCmdEx(nphBin & " --check " & beforeFile1 & " " & beforeFile2 & " 2>&1")
      expected = readFile(expectedOutputDir / "summary_only_reformatted.txt")

    check exitCode == 1
    check output == expected

  test "summary with only unchanged files":
    let
      afterFile1 = testsDir / "after/fmton.nim"
      afterFile2 = testsDir / "after/comments.nim"
      (output, exitCode) =
        execCmdEx(nphBin & " --check " & afterFile1 & " " & afterFile2 & " 2>&1")
      expected = readFile(expectedOutputDir / "summary_only_unchanged.txt")

    check exitCode == 0
    check output == expected

  test "summary with mixed files":
    let
      beforeFile = testsDir / "before/fmton.nim"
      afterFile1 = testsDir / "after/comments.nim"
      afterFile2 = testsDir / "after/style.nim"
      (output, exitCode) = execCmdEx(
        nphBin & " --check " & beforeFile & " " & afterFile1 & " " & afterFile2 & " 2>&1"
      )
      expected = readFile(expectedOutputDir / "summary_mixed.txt")

    check exitCode == 1
    check output == expected

suite "stdin handling":
  test "read from stdin and write to stdout":
    let
      beforeFile = testsDir / "before/fmton.nim"
      afterFile = testsDir / "after/fmton.nim"
      input = readFile(beforeFile)
      expected = readFile(afterFile)
      (output, exitCode) =
        execCmdEx("echo '" & input & "' | " & nphBin & " - 2>/dev/null")

    check exitCode == 0
    check expected in output

  test "stdin with --diff":
    let
      beforeFile = testsDir / "before/fmton.nim"
      input = readFile(beforeFile)
      (output, exitCode) =
        execCmdEx("cat " & beforeFile & " | " & nphBin & " --diff - 2>&1")
      expected = readFile(expectedOutputDir / "stdin_diff.txt")

    check exitCode == 0
    check output == expected

  test "stdin with --check":
    let
      beforeFile = testsDir / "before/fmton.nim"
      input = readFile(beforeFile)
      (output, exitCode) =
        execCmdEx("cat " & beforeFile & " | " & nphBin & " --check - 2>&1")
      expected = readFile(expectedOutputDir / "stdin_check.txt")

    check exitCode == 1
    check output == expected

suite "--outDir option":
  test "--outDir writes to different directory":
    let
      beforeFile = testsDir / "before/fmton.nim"
      tmpDir = "/tmp/nph_outdir_test"
      outFile = tmpDir / testsDir / "before/fmton.nim"
      afterFile = testsDir / "after/fmton.nim"
      contentBefore = readFile(beforeFile)

    createDir(tmpDir)

    let
      (_, exitCode) =
        execCmdEx(nphBin & " " & beforeFile & " --outDir:" & tmpDir & " 2>&1")
      formatted = readFile(outFile)
      expected = readFile(afterFile)
      contentAfter = readFile(beforeFile)

    check exitCode == 0
    check formatted == expected
    check contentBefore == contentAfter
    removeDir(tmpDir)

  test "--outDir with multiple files":
    let
      beforeFile1 = testsDir / "before/fmton.nim"
      beforeFile2 = testsDir / "before/comments.nim"
      tmpDir = "/tmp/nph_outdir_multi"
      outFile1 = tmpDir / testsDir / "before/fmton.nim"
      outFile2 = tmpDir / testsDir / "before/comments.nim"

    createDir(tmpDir)

    let (_, exitCode) = execCmdEx(
      nphBin & " " & beforeFile1 & " " & beforeFile2 & " --outDir:" & tmpDir & " 2>&1"
    )

    check exitCode == 0
    check fileExists(outFile1)
    check fileExists(outFile2)
    removeDir(tmpDir)

  test "--outDir rejects --out":
    let
      beforeFile = testsDir / "before/fmton.nim"
      (output, exitCode) =
        execCmdEx(nphBin & " " & beforeFile & " --outDir:/tmp --out:/tmp/test.nim 2>&1")

    check exitCode == 3
    check "out and outDir cannot both be specified" in output

suite "directory recursion":
  test "format entire directory":
    let
      tmpDir = "/tmp/nph_dir_test"
      subDir = tmpDir / "sub"
      file1 = tmpDir / "test1.nim"
      file2 = subDir / "test2.nim"
      beforeFile = testsDir / "before/fmton.nim"
      afterFile = testsDir / "after/fmton.nim"

    createDir(tmpDir)
    createDir(subDir)
    copyFile(beforeFile, file1)
    copyFile(beforeFile, file2)

    let
      (_, exitCode) = execCmdEx(nphBin & " " & tmpDir & " 2>&1")
      formatted1 = readFile(file1)
      formatted2 = readFile(file2)
      expected = readFile(afterFile)

    check exitCode == 0
    check formatted1 == expected
    check formatted2 == expected
    removeDir(tmpDir)

  test "directory with --check shows all files":
    let
      tmpDir = "/tmp/nph_dir_check"
      file1 = tmpDir / "test1.nim"
      file2 = tmpDir / "test2.nim"
      beforeFile = testsDir / "before/fmton.nim"

    createDir(tmpDir)
    copyFile(beforeFile, file1)
    copyFile(beforeFile, file2)

    let (output, exitCode) = execCmdEx(nphBin & " --check " & tmpDir & " 2>&1")

    check exitCode == 1
    check "would reformat" in output
    check "2 files would be reformatted" in output
    removeDir(tmpDir)

  test "--out rejects directory":
    let
      tmpDir = "/tmp/nph_dir_out_reject"
      tmpFile = tmpDir / "test.nim"

    createDir(tmpDir)
    writeFile(tmpFile, "proc test() = discard\n")

    let
      (output, exitCode) =
        execCmdEx(nphBin & " " & tmpDir & " --out:/tmp/test.nim 2>&1")
      expected = readFile(expectedOutputDir / "out_rejects_directory.txt")

    check exitCode == 3
    check output == expected
    removeDir(tmpDir)

suite "file modification time":
  test "file modification time unchanged when already formatted":
    let
      afterFile = testsDir / "after/fmton.nim"
      tmpFile = "/tmp/nph_mtime_test.nim"

    copyFile(afterFile, tmpFile)

    let mtimeBefore = getLastModificationTime(tmpFile)

    # Wait a tiny bit to ensure time difference would be detectable
    sleep(10)

    let (_, exitCode) = execCmdEx(nphBin & " " & tmpFile & " 2>&1")

    let mtimeAfter = getLastModificationTime(tmpFile)

    check exitCode == 0
    check mtimeBefore == mtimeAfter
    removeFile(tmpFile)

  test "file modification time updated when reformatted":
    let
      beforeFile = testsDir / "before/fmton.nim"
      tmpFile = "/tmp/nph_mtime_test2.nim"

    copyFile(beforeFile, tmpFile)

    let mtimeBefore = getLastModificationTime(tmpFile)

    # Wait to ensure time difference
    sleep(10)

    let (_, exitCode) = execCmdEx(nphBin & " " & tmpFile & " 2>&1")

    let mtimeAfter = getLastModificationTime(tmpFile)

    check exitCode == 0
    check mtimeBefore != mtimeAfter
    removeFile(tmpFile)

suite "exclude/include patterns":
  test "--exclude filters files from directory":
    let
      tmpDir = "/tmp/nph_exclude_test"
      file1 = tmpDir / "src/test.nim"
      file2 = tmpDir / "build/test.nim"

    createDir(tmpDir / "src")
    createDir(tmpDir / "build")
    writeFile(file1, "proc test() = discard\n")
    writeFile(file2, "proc test() = discard\n")

    let (output, exitCode) = execCmdEx(
      nphBin & " --check --exclude='build' --config=/dev/null " & tmpDir & " 2>&1"
    )

    check exitCode == 1
    check "would reformat" in output
    check "src/test.nim" in output
    check "build/test.nim" notin output
    removeDir(tmpDir)

  test "--extend-exclude adds to default exclusions":
    let
      tmpDir = "/tmp/nph_extend_exclude_test"
      file1 = tmpDir / "src/test.nim"
      file2 = tmpDir / "custom/test.nim"

    createDir(tmpDir / "src")
    createDir(tmpDir / "custom")
    writeFile(file1, "proc test() = discard\n")
    writeFile(file2, "proc test() = discard\n")

    let (output, exitCode) = execCmdEx(
      nphBin & " --check --extend-exclude='custom' --config=/dev/null " & tmpDir &
        " 2>&1"
    )

    check exitCode == 1
    check "src/test.nim" in output
    check "custom/test.nim" notin output
    removeDir(tmpDir)

  test "--include filters which files to format":
    let
      tmpDir = "/tmp/nph_include_test"
      file1 = tmpDir / "foo.nim"
      file2 = tmpDir / "bar.nims"

    createDir(tmpDir)
    writeFile(file1, "proc test() = discard\n")
    writeFile(file2, "proc test() = discard\n")

    let (output, exitCode) = execCmdEx(
      nphBin & " --check --include='\\.nims$' --config=/dev/null " & tmpDir & " 2>&1"
    )

    check exitCode == 1
    check "bar.nims" in output
    check "foo.nim" notin output
    removeDir(tmpDir)

  test "explicitly passed files bypass exclude filters":
    let
      tmpDir = "/tmp/nph_explicit_test"
      file1 = tmpDir / "excluded/test.nim"
      configFile = tmpDir / ".nph.toml"

    createDir(tmpDir / "excluded")
    writeFile(file1, "proc test() = discard\n")
    writeFile(configFile, "extend-exclude = [\"excluded\"]\n")

    let (output, exitCode) =
      execCmdEx(nphBin & " --check --config:" & configFile & " " & file1 & " 2>&1")

    check exitCode == 1
    check "would reformat" in output
    removeDir(tmpDir)

suite "config file":
  test "loads exclude patterns from .nph.toml":
    let
      tmpDir = "/tmp/nph_config_exclude_test"
      file1 = tmpDir / "src/test.nim"
      file2 = tmpDir / "build/test.nim"
      configFile = tmpDir / ".nph.toml"

    createDir(tmpDir / "src")
    createDir(tmpDir / "build")
    writeFile(file1, "proc test() = discard\n")
    writeFile(file2, "proc test() = discard\n")
    writeFile(configFile, "extend-exclude = [\"build\"]\n")

    let (output, _) =
      execCmdEx(nphBin & " --check --config:" & configFile & " " & tmpDir & " 2>&1")

    check "src/test.nim" in output
    check "build/test.nim" notin output
    removeDir(tmpDir)

  test "CLI extend-exclude adds to config extend-exclude":
    let
      tmpDir = "/tmp/nph_config_override_test"
      file1 = tmpDir / "src/test.nim"
      file2 = tmpDir / "build/test.nim"
      file3 = tmpDir / "lib/test.nim"
      configFile = tmpDir / ".nph.toml"

    createDir(tmpDir / "src")
    createDir(tmpDir / "build")
    createDir(tmpDir / "lib")
    writeFile(file1, "proc test() = discard\n")
    writeFile(file2, "proc test() = discard\n")
    writeFile(file3, "proc test() = discard\n")
    writeFile(configFile, "extend-exclude = [\"src\"]\n")

    let (output, _) = execCmdEx(
      nphBin & " --check --config:" & configFile & " --extend-exclude='build' " & tmpDir &
        " 2>&1"
    )

    # Both src (from config) and build (from CLI) should be excluded
    # Only lib should be included
    check "src/test.nim" notin output
    check "build/test.nim" notin output
    check "lib/test.nim" in output
    removeDir(tmpDir)

  test "nonexistent config file doesn't error":
    let
      tmpDir = "/tmp/nph_no_config_test"
      file1 = tmpDir / "test.nim"

    createDir(tmpDir)
    writeFile(file1, "proc test() = discard\n")

    let (output, exitCode) =
      execCmdEx(nphBin & " --check --config:/nonexistent.toml " & tmpDir & " 2>&1")

    check exitCode == 1
    check "test.nim" in output
    removeDir(tmpDir)

suite "color output":
  test "--color without --diff errors":
    let
      beforeFile = testsDir / "before/fmton.nim"
      (output, exitCode) = execCmdEx(nphBin & " --color " & beforeFile & " 2>&1")
      expected = readFile(expectedOutputDir / "color_without_diff.txt")

    check exitCode == 3
    check output == expected

  test "--diff --color produces ANSI codes":
    let
      beforeFile = testsDir / "before/fmton.nim"
      (output, exitCode) = execCmdEx(nphBin & " --diff --color " & beforeFile & " 2>&1")
      expected = readFile(expectedOutputDir / "diff_color.txt")

    check exitCode == 0
    check output == expected

  test "--diff without --color has no ANSI codes":
    let
      beforeFile = testsDir / "before/fmton.nim"
      (output, exitCode) = execCmdEx(nphBin & " --diff " & beforeFile & " 2>&1")

    check exitCode == 0
    # Should NOT have ANSI escape codes
    check "\x1B[" notin output

  test "--no-color explicitly disables color":
    let
      beforeFile = testsDir / "before/fmton.nim"
      (output, exitCode) =
        execCmdEx(nphBin & " --diff --no-color " & beforeFile & " 2>&1")

    check exitCode == 0
    check "\x1B[" notin output

  test "--diff --color shows colored headers":
    # This test is redundant with "--diff --color produces ANSI codes"
    # which already checks the full output
    skip()

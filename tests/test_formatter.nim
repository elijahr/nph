import std/[unittest, os, osproc, strutils, algorithm]

const
  nphBin = "./nph"
  testsDir = "tests"

proc getTestFiles(): seq[string] =
  let beforeDir = testsDir / "before"
  for file in walkDir(beforeDir):
    if file.kind == pcFile and file.path.endsWith(".nim"):
      result.add(file.path.extractFilename())
  result.sort()

suite "formatter tests":
  let testFiles = getTestFiles()

  for testFile in testFiles:
    test testFile:
      let
        beforeFile = testsDir / "before" / testFile
        afterFile = testsDir / "after" / testFile
        tmpFile = "/tmp/nph_test_" & testFile

      check fileExists(afterFile)
      if not fileExists(afterFile):
        echo "Missing expected output file: " & afterFile
        skip()

      # Format the before file
      let (output, exitCode) = execCmdEx(nphBin & " " & beforeFile & " --out:" & tmpFile)

      check exitCode == 0
      if exitCode != 0:
        echo output
        skip()

      let
        formatted = readFile(tmpFile)
        expected = readFile(afterFile)

      if formatted != expected:
        # Show diff for nice output
        let (diffOutput, _) = execCmdEx(
          "diff -u " & afterFile & " " & tmpFile & " || true"
        )
        echo "\n" & diffOutput

      check formatted == expected
      removeFile(tmpFile)

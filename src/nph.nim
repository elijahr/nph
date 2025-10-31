#           nph
#        (c) Copyright 2023 Jacek Sieka
## Opinionated source code formatter

import
  "."/[
    astcmp, astyaml, phast, phastyaml, phmsgs, phlineinfos, phoptions, phparser,
    phrenderer,
  ]

import "$nim"/compiler/idents

import std/[parseopt, strutils, os, sequtils, terminal]
import pkg/hldiffpkg/edits
import pkg/adix/lptabz

static:
  doAssert NimMajor == 2 and NimMinor == 2, "nph needs a specific version of Nim"

const
  Version = gorge("git describe --long --dirty --always --tags")
  Usage =
    "nph - Nim formatter " & Version &
    """
Usage:
  nph [options] nimfiles...
Options:
  --check               check the formatting instead of performing it
  --diff                show diff of formatting changes without writing files
  --out:file            set the output file (default: overwrite the input file)
  --outDir:dir          set the output dir (default: overwrite the input files)
  --color               force colored diff output (only applies when --diff is given)
  --no-color            disable colored diff output
  --version             show the version
  --help                show this help
"""
  ErrCheckFailed = 1
  ErrDiffChanges = 2 # --diff mode: changes found (but exit 0)
  ErrParseInputFailed = 3
  ErrParseOutputFailed = 4
  ErrEqFailed = 5

proc writeHelp() =
  stdout.write(Usage)
  stdout.flushFile()
  quit(0)

proc writeVersion() =
  stdout.write(Version & "\n")
  stdout.flushFile()
  quit(0)

proc parse(input, filename: string, printTokens: bool, conf: ConfigRef): PNode =
  let fn = if filename == "-": "stdin" else: filename

  parseString(input, newIdentCache(), conf, fn, printTokens = printTokens)

func isNimFile(file: string): bool =
  ## Check if a file is a Nim file (i.e. ends in .nim/nims/nimble)
  let (_, _, ext) = file.splitFile()
  ext in [".nim", ".nims", ".nimble"]

proc makeConfigRef(): ConfigRef =
  let conf = newConfigRef()
  conf.errorMax = int.high
  conf

proc printDiff(input, output, infile: string, color: bool) =
  ## Print unified diff between input and output
  let
    inputLines = input.split('\n')
    outputLines = output.split('\n')
    sm = sames(inputLines, outputLines)

  var begun = false
  for eds in grouped(sm, 3):
    if not begun:
      begun = true
      if color:
        stdout.styledWriteLine(styleBright, "--- " & infile)
        stdout.styledWriteLine(styleBright, "+++ " & infile & " (formatted)")
      else:
        stdout.writeLine("--- " & infile)
        stdout.writeLine("+++ " & infile & " (formatted)")

    let marker =
      "@@ -" & rangeUni(eds[0].s.a, eds[^1].s.b + 1) & " +" &
      rangeUni(eds[0].t.a, eds[^1].t.b + 1) & " @@"

    if color:
      stdout.styledWriteLine(fgCyan, marker)
    else:
      stdout.writeLine(marker)

    for ed in eds:
      case ed.ek
      of ekEql:
        for ln in inputLines[ed.s]:
          stdout.writeLine(" " & ln)
      of ekDel:
        for ln in inputLines[ed.s]:
          if color:
            stdout.styledWriteLine(fgRed, "-" & ln)
          else:
            stdout.writeLine("-" & ln)
      of ekIns:
        for ln in outputLines[ed.t]:
          if color:
            stdout.styledWriteLine(fgGreen, "+" & ln)
          else:
            stdout.writeLine("+" & ln)
      of ekSub:
        for ln in inputLines[ed.s]:
          if color:
            stdout.styledWriteLine(fgRed, "-" & ln)
          else:
            stdout.writeLine("-" & ln)
        for ln in outputLines[ed.t]:
          if color:
            stdout.styledWriteLine(fgGreen, "+" & ln)
          else:
            stdout.writeLine("+" & ln)

proc prettyPrint(
    infile, outfile: string, debug, check, diff, printTokens, color: bool
): int =
  let
    conf = makeConfigRef()
    input =
      if infile == "-":
        readAll(stdin)
      else:
        readFile(infile)
    node = parse(input, infile, printTokens, conf)

  if conf.errorCounter > 0:
    localError(
      conf, TLineInfo(fileIndex: FileIndex(0)), "Skipped file, input cannot be parsed"
    )

    return ErrParseInputFailed

  var output = renderTree(node, conf)
  if not output.endsWith("\n"):
    output.add "\n"

  if conf.errorCounter > 0:
    return ErrParseOutputFailed

  # Handle --diff mode: print diff and exit early
  if diff:
    if input != output:
      printDiff(input, output, infile, color)
      # --diff alone is informational (exit 0), --diff --check fails (exit 1)
      return if check: ErrCheckFailed else: ErrDiffChanges
    else:
      return QuitSuccess # No changes needed

  if infile != "-":
    if debug:
      # Always write file in debug mode
      writeFile(infile & ".nph.yaml", treeToYaml(nil, node) & "\n")
      if infile != outfile:
        writeFile(outfile, output)
        writeFile(
          outfile & ".nph.yaml",
          treeToYaml(nil, parse(output, outfile, printTokens, newConfigRef())) & "\n",
        )
    elif fileExists(outfile) and output == readFile(outfile):
      # No formatting difference - don't touch file modificuation date
      return QuitSuccess

  let eq = equivalent(input, infile, output, if infile == "-": "stdout" else: outfile)

  template writeUnformatted() =
    if not debug and (infile != outfile or infile == "-"):
      # Write unformatted content
      if not check:
        if infile == "-":
          write(stdout, input)
        else:
          writeFile(outfile, input)

  case eq.kind
  of Same:
    if check:
      # Print which file would be reformatted (like Black)
      if input != output:
        stderr.writeLine("would reformat " & infile)
      ErrCheckFailed # We failed the equivalence check above
    else:
      # Formatting changed the file
      if not debug or infile == "-":
        if infile == "-":
          write(stdout, output)
        else:
          writeFile(outfile, output)

      QuitSuccess
  of ParseError:
    writeUnformatted()

    localError(
      conf,
      TLineInfo(fileIndex: FileIndex(0)),
      "Skipped file, formatted output cannot be parsed (bug! " & Version & ")",
    )

    ErrEqFailed
  of Different:
    writeUnformatted()

    stderr.writeLine "--- Input ---"
    stderr.writeLine input
    stderr.writeLine "--- Formatted ---"
    stderr.writeLine output
    stderr.writeLine "--- PRE ---"
    stderr.writeLine treeToYaml(nil, eq.a)
    stderr.writeLine "--- POST ---"
    stderr.writeLine treeToYaml(nil, eq.b)

    localError(
      conf,
      TLineInfo(fileIndex: FileIndex(0)),
      "Skipped file, formatted output does not match input (bug! " & Version & ")",
    )

    ErrEqFailed

proc main() =
  var
    outfile, outdir: string
    infiles = newSeq[string]()
    outfiles = newSeq[string]()
    debug = false
    check = false
    diff = false
    printTokens = false
    usesDir = false
    cliColorSet = false
    # Default to color if stdout is a TTY and NO_COLOR is not set or empty
    cliColor = getEnv("NO_COLOR") == "" and isatty(stdout)

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      if dirExists(key):
        usesDir = true
        for file in walkDirRec(key):
          if file.isNimFile:
            infiles &= file
      else:
        infiles.add(key.addFileExt(".nim"))
    of cmdLongOption, cmdShortOption:
      case normalize(key)
      of "help", "h":
        writeHelp()
      of "version", "v":
        writeVersion()
      of "debug":
        debug = true
      of "print-tokens":
        printTokens = true
      of "check":
        check = true
      of "diff":
        diff = true
      of "output", "o", "out":
        outfile = val
      of "outDir", "outdir":
        outdir = val
      of "color":
        cliColorSet = true
        cliColor = true
      of "no-color", "nocolor":
        cliColorSet = true
        cliColor = false
      of "":
        infiles.add("-")
      else:
        writeHelp()
    of cmdEnd:
      assert(false) # cannot happen

  if infiles.len == 0:
    quit "[Error] no input file.", 3

  if outfile.len != 0 and outdir.len != 0:
    quit "[Error] out and outDir cannot both be specified", 3

  if outfile.len != 0 and usesDir:
    quit "[Error] out cannot be used alongside directories", 3

  if diff and (outfile.len != 0 or outdir.len != 0):
    quit "[Error] diff cannot be used with out or outDir", 3

  # Validate --color requires --diff
  if cliColorSet and cliColor and not diff:
    quit "[Error] --color can only be used with --diff", 3

  if outfile.len == 0 and outdir.len == 0:
    outfiles = infiles
  elif outfile.len != 0 and infiles.len > 1:
    # Take the last file to maintain backwards compatibility
    let infile = infiles[^1]

    infiles = @[infile]
    outfiles = @[outfile]
  elif outfile.len != 0:
    outfiles = @[outfile]
  elif outdir.len != 0:
    outfiles = infiles.mapIt($(joinPath(outdir, it)))

  var
    res = QuitSuccess
    filesReformatted = 0
    filesUnchanged = 0
    filesErrored = 0

  for (infile, outfile) in zip(infiles, outfiles):
    let (dir, _, _) = splitFile(outfile)

    createDir(dir)
    let err = prettyPrint(infile, outfile, debug, check, diff, printTokens, cliColor)

    # Track statistics for summary
    case err
    of QuitSuccess: filesUnchanged.inc
    of ErrCheckFailed, ErrDiffChanges: filesReformatted.inc
    else: filesErrored.inc

    # Keep going to show all diffs/errors instead of failing fast
    res = max(res, err)

  # Print summary for --check or --diff (like Black)
  if (check or diff) and infiles.len > 0:
    if filesReformatted > 0 or filesUnchanged > 0:
      var parts: seq[string]
      if filesReformatted > 0:
        let s = if filesReformatted == 1: "file" else: "files"
        parts.add $filesReformatted & " " & s & " would be reformatted"
      if filesUnchanged > 0:
        let s = if filesUnchanged == 1: "file" else: "files"
        parts.add $filesUnchanged & " " & s & " would be left unchanged"

      if check and filesReformatted > 0:
        stderr.writeLine "\nOh no! 💥 💔 💥"
      elif not check:
        stderr.writeLine "\nAll done! ✨ 👑 ✨"

      stderr.writeLine parts.join(", ") & "."

  # --diff alone exits 0 even with changes (informational)
  # --check or --diff --check exits 1 with changes (for CI)
  if res == ErrDiffChanges and not check:
    quit QuitSuccess
  else:
    quit res

when isMainModule:
  main()

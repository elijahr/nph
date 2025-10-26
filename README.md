# nph

`nph` is an opinionated source code formatter for the Nim language, aiming to
take the drudgery of manual formatting out of your coding day.

Following the great tradition of [`black`](https://github.com/psf/black/),
[`prettier`](https://prettier.io/),
[`clang-format`](https://clang.llvm.org/docs/ClangFormat.html) and other
AST-based formatters, it discards existing styling to create a consistent and
beautiful codebase.

## Documentation

Documentation is available [here](https://arnetheduck.github.io/nph/).

## Quickstart

Install `nph`, then run it on some files:

```sh
# Format the given files in-place
nph file0.nim file1.nim

# Format the given files, writing the formatted code to /tmp
nph file0.nim file1.nim --outdir:/tmp

# Format an entire directory
nph src/

# Use --check to verify that a file is formatted as `nph` would - useful in CI
nph --check somefile.nim || echo "Not formatted!"

# Show a diff of what would change without modifying files
nph --diff somefile.nim

# Show a colored diff (requires --diff)
nph --diff --color somefile.nim

# You can format stuff as part of a pipe using `-` as input:
echo "echo 1" | nph -
```

## Configuration

You can configure `nph` using a `.nph.toml` file in your project root:

```toml
# Completely replace default exclusions
exclude = [
  "build",
  "dist",
]

# Add to default exclusions (more common)
extend-exclude = [
  "tests/fixtures",
  "vendor",
]

# Customize which files to include (default: \.nim(s|ble)?$)
include = [
  "\.nim$",
  "\.nims$",
]
```

CLI options override config file settings. See the
[documentation](https://arnetheduck.github.io/nph/usage.html) for more details.

More information about features and style available from the
[documentation](https://arnetheduck.github.io/nph/)

## Installation

Binaries are available from the
[releases page](https://github.com/arnetheduck/nph/releases/tag/latest) on
Github.

`nph` can be also compiled or installed using `nimble` v0.16.4+:

```sh
# Install globally
nimble install nph

# Alternatively, build in source folder:
nimble setup -l
nimble build
```

See the
[installation instructions](https://arnetheduck.github.io/nph/installation.html)
in the manual for more details.

## Editor integration

Editor integrations are described
[in the manual](https://arnetheduck.github.io/nph/installation.html#editor-integration).

## Continuous integration

Check out the
[companion Github Action](https://github.com/arnetheduck/nph-action) for a
convenient CI option!

## pre-commit support

`nph` can be used with [pre-commit](https://pre-commit.com/). Add this to your
`.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/arnetheduck/nph
    rev: v0.6.1  # Use the ref you want to point at
    hooks:
      - id: nph
```

This will automatically format your Nim files on commit. For check-only mode
that shows diffs without modifying files (useful in CI), use:

```yaml
repos:
  - repo: https://github.com/arnetheduck/nph
    rev: v0.6.1
    hooks:
      - id: nph-check  # Shows --check --diff output
```

**Note**: This requires `nph` to be installed on your system. See
[installation instructions](https://arnetheduck.github.io/nph/installation.html).

### For nph developers

The nph repository itself uses pre-commit with multiple hooks. To set it up:

```sh
# Install pre-commit hooks
pre-commit install

# Run on all files (optional)
pre-commit run --all-files
```

This will automatically run nph on Nim files, plus format/lint checks for YAML,
TOML, Markdown, and shell scripts.

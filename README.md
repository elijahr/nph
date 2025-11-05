# nph

`nph` is an opinionated source code formatter for the Nim language, aiming to
take the drudgery of manual formatting out of your coding day.

Following the great tradition of [`black`](https://github.com/psf/black/),
[`prettier`](https://prettier.io/), [`clang-format`](https://clang.llvm.org/docs/ClangFormat.html)
and other AST-based formatters, it discards existing styling to create a
consistent and beautiful codebase.

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

Binaries are available from the [releases page](https://github.com/arnetheduck/nph/releases/tag/latest) on Github.

`nph` can be also compiled or installed using `nimble` v0.16.4+:

```sh
# Install globally
nimble install nph

# Alternatively, build in source folder:
nimble setup -l
nimble build
```

See the [installation instructions](https://arnetheduck.github.io/nph/installation.html) in the manual for more details.

## Editor integration

Editor integrations are described [in the manual](https://arnetheduck.github.io/nph/installation.html#editor-integration).

## Pre-commit hook

A simple pre-commit hook is available to automatically format your Nim code before committing. To install:

```sh
# Copy the pre-commit hook to your .git/hooks directory
cp .git/hooks/pre-commit.sample .git/hooks/pre-commit
```

Or create it manually:

```sh
cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
# Simple pre-commit hook for nph (Nim code formatter)

set -e

# Get list of staged Nim files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.nim$' || true)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

echo "nph (Nim formatter)....................................................."

# Run nph on staged files
./nph $STAGED_FILES 2>&1

# Check if any files were modified
if ! git diff --quiet $STAGED_FILES; then
    echo "Failed"
    echo ""
    echo "Files were modified by this hook. Please review changes and commit again."
    echo ""
    echo "Modified files:"
    git diff --name-only $STAGED_FILES | sed 's/^/  - /'
    exit 1
fi

echo "Passed"
exit 0
EOF

chmod +x .git/hooks/pre-commit
```

The hook will automatically format staged Nim files and prevent commits if formatting changes were made, allowing you to review the changes first.

## Continuous integration

Check out the [companion Github Action](https://github.com/arnetheduck/nph-action) for a convenient CI option!



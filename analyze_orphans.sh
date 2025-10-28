#!/bin/bash

# Detailed analysis of orphaned files

set -euo pipefail

echo "=========================================="
echo "DETAILED ORPHAN ANALYSIS"
echo "=========================================="
echo ""

# List of orphaned files
ORPHANS=(
  ".github/workflows/ci.yml"
  ".github/workflows/gh-pages.yml"
  ".github/workflows/release.yml"
  ".gitignore"
  "CHANGELOG.md"
  "CONTRIBUTING.md"
  "README.md"
  "config.nims"
  "docs/open-in.css"
  "docs/src/book.md"
  "docs/src/faq.md"
  "docs/src/installation.md"
  "docs/src/introduction.md"
  "docs/src/style.md"
  "docs/src/usage.md"
  "format-git-repo.sh"
  "nph.nimble"
  "src/nph.nim"
  "tests/after/comments.nim"
  "tests/after/comments.nim.nph.yaml"
  "tests/after/fmton.nim"
  "tests/after/fmton.nim.nph.yaml"
  "tests/before/comments.nim"
  "tests/before/comments.nim.nph.yaml"
  "tests/before/fmton.nim"
  "tests/before/fmton.nim.nph.yaml"
  "tests/test_formatter.nim"
  "vscode-nph/.eslintrc.json"
  "vscode-nph/.vscode/settings.json"
  "vscode-nph/.yarnrc"
  "vscode-nph/README.md"
  "vscode-nph/src/extension.ts"
  "vscode-nph/vsc-extension-quickstart.md"
)

for file in "${ORPHANS[@]}"; do
    echo "----------------------------------------"
    echo "FILE: $file"
    echo "----------------------------------------"

    # Show the diff from base commit to master-backup
    echo "Changes made (46ccc3c^..master-backup):"
    git diff '46ccc3c^..master-backup' -- "$file" | head -50
    echo ""
    echo "..."
    echo ""
done

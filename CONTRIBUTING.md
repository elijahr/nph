# Contributing to nph

Thank you for your interest in contributing to nph!

## Development Setup

```sh
# Clone the repository
git clone https://github.com/arnetheduck/nph.git
cd nph

# Install dependencies (requires Nim 2.2.x)
nimble setup -l
nimble build

# Install pre-commit hooks (optional but recommended)
pre-commit install
```

## Running Tests

```sh
# Run all tests
nimble test

# Run specific test file
nim c -r tests/test_formatter.nim
```

### Adding New Formatter Tests

Tests are automatically discovered from the `tests/before/` directory. To add a
new test:

1. **Create the input file**: `tests/before/my_test.nim`

   - This is the unformatted Nim code you want to test

2. **Create the expected output**: `tests/after/my_test.nim`

   - This is what nph should produce after formatting

3. **Run tests**: The test will be automatically picked up and run

The test framework automatically:

- Discovers all `*.nim` files in `tests/before/`
- Formats each file with nph
- Compares the output to the corresponding file in `tests/after/`
- Shows diffs when there are mismatches

**Important**: Both files must have the exact same name. If you add
`tests/before/foo.nim`, you must also add `tests/after/foo.nim`.

### Test Naming Conventions

- Use descriptive names that explain what's being tested
- Examples:
  - `comments.nim` - Tests comment handling
  - `exprs.nim` - Tests expression formatting
  - `fmton.nim` - Tests `#!fmt: on/off` directives

### Compile-time vs Runtime Test Discovery

nph has two test approaches:

1. **Runtime discovery** (`test_formatter.nim` - current default)

   - Scans directory at runtime
   - Easier to debug
   - Used in CI

2. **Compile-time discovery** (`test_formatter_static.nim` - example)

   - Uses `staticExec` + macros to generate tests at compile time
   - Automatically busts Nim's cache when files are added/removed
   - Faster execution (no runtime scanning)
   - See file for detailed explanation

## Code Style

nph is self-formatting! Before committing:

```sh
# Format nph's own code
./nph src/

# Or use pre-commit (formats automatically)
pre-commit run --all-files
```

## Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`nimble test`)
6. Format code (`./nph src/` or `pre-commit run --all-files`)
7. Commit your changes
8. Push to your fork
9. Open a Pull Request

## Questions?

Feel free to open an issue for questions or discussions!

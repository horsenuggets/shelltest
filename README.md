# shelltest

A shell testing framework inspired by Testable. Provides a familiar `describe` / `it` API with rich assertions and clean colored output for bash test suites.

## Usage

Add `shelltest` as a submodule:

```bash
git submodule add git@github.com:horsenuggets/shelltest.git submodules/shelltest
```

Write a test file at `tests/example.test.sh`:

```bash
#!/usr/bin/env bash

source "$(dirname "$0")/../submodules/shelltest/src/shelltest.sh"

describe "Example Test Suite"

test_basic_math() {
    assert_equals "2" "$((1 + 1))"
}

it "should add numbers correctly" test_basic_math

write_results
```

Then run all tests with the bundled runner:

```bash
./submodules/shelltest/tools/test.sh tests
```

## Assertions

- `assert_equals expected actual`
- `assert_not_equals expected actual`
- `assert_contains haystack needle`
- `assert_not_contains haystack needle`
- `assert_matches regex actual`
- `assert_file_exists path`
- `assert_file_not_exists path`
- `assert_dir_exists path`
- `assert_dir_not_exists path`
- `assert_file_contains path pattern`
- `assert_exit_code expected actual`
- `assert_command_succeeds cmd`
- `assert_command_fails cmd`
- `assert_output_equals expected cmd`
- `assert_output_contains expected cmd`
- `assert_pwd_equals expected`
- `assert_pwd_ends_with suffix`

## Suite Structure

- `describe "Suite Name"` starts a suite and resets per-suite state.
- `it "test description" test_function_name [args...]` runs a test function.
- `skip "test description"` records a skipped test.
- `write_results` prints the suite header and writes counts to `$TEST_RESULTS_FILE`.

## License

MIT

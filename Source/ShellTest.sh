#!/usr/bin/env bash
#
# ShellTest.sh
#
# Shell testing framework inspired by Testable. Source this file from a test
# script to get the `describe`, `it`, `skip`, and `assert_*` helpers, then call
# `write_results` at the end to print the suite and emit counts.

# ANSI color codes (matching Testable's bright versions).
export BRIGHT_GREEN="\033[92m"
export BRIGHT_RED="\033[91m"
export BRIGHT_YELLOW="\033[93m"
export RESET="\033[0m"

# Per-runner state.
export PASS_COUNT=0
export FAIL_COUNT=0
export SKIP_COUNT=0

# Per-suite state.
export CURRENT_SUITE=""
export SUITE_PASS_COUNT=0
export SUITE_FAIL_COUNT=0
export SUITE_SKIP_COUNT=0
export INDENT="   "

# Output buffer for the current suite. Suites are printed all at once at the
# end so the header can reflect the final pass or fail status.
declare -a SUITE_OUTPUT=()

# Optional results file consumed by the test runner. If set, `write_results`
# appends a "PASS:FAIL:SKIP" line per suite.
export TEST_RESULTS_FILE="${TEST_RESULTS_FILE:-}"

# Start a new test suite.
describe() {
    CURRENT_SUITE="$1"
    SUITE_PASS_COUNT=0
    SUITE_FAIL_COUNT=0
    SUITE_SKIP_COUNT=0
    SUITE_OUTPUT=()
}

# Run a single test. The test passes when its function exits 0 and fails
# otherwise. Captured stdout/stderr from a failing test is printed indented
# under the test line.
#
# Usage: it "test description" test_function_name [args...]
it() {
    local test_name="$1"
    shift

    local exit_code=0
    local output=""

    if [[ $# -gt 0 ]]; then
        output=$("$@" 2>&1) || exit_code=$?
    else
        output=$(bash 2>&1) || exit_code=$?
    fi

    if [[ $exit_code -eq 0 ]]; then
        SUITE_OUTPUT+=("${INDENT}${BRIGHT_GREEN}[+] ${test_name}${RESET}")
        PASS_COUNT=$((PASS_COUNT + 1))
        SUITE_PASS_COUNT=$((SUITE_PASS_COUNT + 1))
    else
        SUITE_OUTPUT+=("${INDENT}${BRIGHT_RED}[-] ${test_name}${RESET}")
        FAIL_COUNT=$((FAIL_COUNT + 1))
        SUITE_FAIL_COUNT=$((SUITE_FAIL_COUNT + 1))
        if [[ -n "$output" ]]; then
            while IFS= read -r line; do
                SUITE_OUTPUT+=("${INDENT}${INDENT}${BRIGHT_RED}${line}${RESET}")
            done <<<"$output"
        fi
    fi
}

# Record a skipped test.
skip() {
    local test_name="$1"
    SUITE_OUTPUT+=("${INDENT}${BRIGHT_YELLOW}[~] ${test_name}${RESET}")
    SKIP_COUNT=$((SKIP_COUNT + 1))
    SUITE_SKIP_COUNT=$((SUITE_SKIP_COUNT + 1))
}

# Print the current suite header and all buffered test lines.
print_suite() {
    if [[ -z "$CURRENT_SUITE" ]]; then
        return
    fi

    if [[ $SUITE_FAIL_COUNT -eq 0 ]]; then
        echo -e "${BRIGHT_GREEN}[+] ${CURRENT_SUITE}${RESET}"
    else
        echo -e "${BRIGHT_RED}[-] ${CURRENT_SUITE}${RESET}"
    fi

    local line
    for line in "${SUITE_OUTPUT[@]}"; do
        echo -e "$line"
    done
}

# Print the suite and append counts to TEST_RESULTS_FILE if set.
write_results() {
    print_suite

    if [[ -n "$TEST_RESULTS_FILE" ]]; then
        echo "${PASS_COUNT}:${FAIL_COUNT}:${SKIP_COUNT}" >>"$TEST_RESULTS_FILE"
    fi
}

# Assertions return 0 for pass and 1 for fail, printing a clear error message
# to stdout on failure (which `it` then captures and displays under the
# failing test line).

assert_equals() {
    local expected="$1"
    local actual="$2"
    if [[ "$expected" == "$actual" ]]; then
        return 0
    fi
    echo "Expected '$expected' but got '$actual'."
    return 1
}

assert_not_equals() {
    local expected="$1"
    local actual="$2"
    if [[ "$expected" != "$actual" ]]; then
        return 0
    fi
    echo "Expected value to differ from '$expected' but got the same."
    return 1
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    fi
    echo "Expected '$haystack' to contain '$needle'."
    return 1
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    if [[ "$haystack" != *"$needle"* ]]; then
        return 0
    fi
    echo "Expected '$haystack' to not contain '$needle'."
    return 1
}

assert_matches() {
    local regex="$1"
    local actual="$2"
    if [[ "$actual" =~ $regex ]]; then
        return 0
    fi
    echo "Expected '$actual' to match regex '$regex'."
    return 1
}

assert_file_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        return 0
    fi
    echo "Expected file '$file' to exist."
    return 1
}

assert_file_not_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        return 0
    fi
    echo "Expected file '$file' to not exist."
    return 1
}

assert_dir_exists() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        return 0
    fi
    echo "Expected directory '$dir' to exist."
    return 1
}

assert_dir_not_exists() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        return 0
    fi
    echo "Expected directory '$dir' to not exist."
    return 1
}

assert_file_contains() {
    local file="$1"
    local pattern="$2"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        return 0
    fi
    echo "Expected file '$file' to contain '$pattern'."
    return 1
}

assert_exit_code() {
    local expected="$1"
    local actual="$2"
    if [[ "$expected" -eq "$actual" ]]; then
        return 0
    fi
    echo "Expected exit code $expected but got $actual."
    return 1
}

assert_command_succeeds() {
    local cmd="$1"
    if eval "$cmd" >/dev/null 2>&1; then
        return 0
    fi
    echo "Expected command '$cmd' to succeed."
    return 1
}

assert_command_fails() {
    local cmd="$1"
    if ! eval "$cmd" >/dev/null 2>&1; then
        return 0
    fi
    echo "Expected command '$cmd' to fail."
    return 1
}

assert_output_equals() {
    local expected="$1"
    local cmd="$2"
    local actual
    actual=$(eval "$cmd" 2>&1)
    if [[ "$actual" == "$expected" ]]; then
        return 0
    fi
    echo "Expected output '$expected' but got '$actual'."
    return 1
}

assert_output_contains() {
    local expected="$1"
    local cmd="$2"
    local actual
    actual=$(eval "$cmd" 2>&1)
    if [[ "$actual" == *"$expected"* ]]; then
        return 0
    fi
    echo "Expected output to contain '$expected' but got '$actual'."
    return 1
}

assert_pwd_equals() {
    local expected="$1"
    if [[ "$PWD" == "$expected" ]]; then
        return 0
    fi
    echo "Expected pwd to be '$expected' but got '$PWD'."
    return 1
}

assert_pwd_ends_with() {
    local suffix="$1"
    if [[ "$PWD" == *"$suffix" ]]; then
        return 0
    fi
    echo "Expected pwd to end with '$suffix' but got '$PWD'."
    return 1
}

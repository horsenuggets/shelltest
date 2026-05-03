#!/usr/bin/env bash
#
# assertion.test.sh
#
# Verifies the behavior of every assertion helper exposed by shelltest.sh.

source "${SHELLTEST_LIB:-$(dirname "$0")/../src/shelltest.sh}"

describe "Assertions"

test_assert_equals_pass() {
    assert_equals "abc" "abc"
}
test_assert_equals_fail() {
    ! assert_equals "abc" "xyz" >/dev/null
}
test_assert_not_equals_pass() {
    assert_not_equals "abc" "xyz"
}
test_assert_contains() {
    assert_contains "hello world" "world"
}
test_assert_not_contains() {
    assert_not_contains "hello" "world"
}
test_assert_matches() {
    assert_matches "^h.*o$" "hello"
}
test_assert_file_exists() {
    local tmp
    tmp="$(mktemp)"
    assert_file_exists "$tmp"
    local result=$?
    rm -f "$tmp"
    return $result
}
test_assert_dir_exists() {
    local tmp
    tmp="$(mktemp -d)"
    assert_dir_exists "$tmp"
    local result=$?
    rm -rf "$tmp"
    return $result
}
test_assert_exit_code() {
    assert_exit_code 0 0
}
test_assert_command_succeeds() {
    assert_command_succeeds "true"
}
test_assert_command_fails() {
    assert_command_fails "false"
}
test_assert_output_equals() {
    assert_output_equals "hi" "echo -n hi"
}
test_assert_output_contains() {
    assert_output_contains "lo" "echo hello"
}

it "passes when values match" test_assert_equals_pass
it "fails when values differ" test_assert_equals_fail
it "passes when values differ" test_assert_not_equals_pass
it "detects substrings" test_assert_contains
it "detects missing substrings" test_assert_not_contains
it "matches regex patterns" test_assert_matches
it "detects existing files" test_assert_file_exists
it "detects existing directories" test_assert_dir_exists
it "compares exit codes" test_assert_exit_code
it "checks succeeding commands" test_assert_command_succeeds
it "checks failing commands" test_assert_command_fails
it "compares command output" test_assert_output_equals
it "checks command output substrings" test_assert_output_contains

write_results

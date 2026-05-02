#!/usr/bin/env bash
#
# SuiteTest.test.sh
#
# Verifies suite-level behavior: describe, skip, and pass/fail counting.

source "${SHELLTEST_LIB:-$(dirname "$0")/../Source/ShellTest.sh}"

describe "Suite Behavior"

test_passes() {
    return 0
}
test_skip_records_count() {
    local before=$SKIP_COUNT
    skip "fake skipped test"
    [[ $SKIP_COUNT -eq $((before + 1)) ]]
    # Undo the skip so the suite count reflects only real tests.
    SKIP_COUNT=$before
    SUITE_SKIP_COUNT=$((SUITE_SKIP_COUNT - 1))
}

it "runs a passing test" test_passes
it "increments skip counter on skip" test_skip_records_count

write_results

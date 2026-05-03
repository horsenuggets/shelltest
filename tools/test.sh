#!/usr/bin/env bash
#
# test.sh
#
# Discovers and runs every `*.test.sh` file in the given tests directory (or
# `tests/` by default), aggregates their results, and prints a colored
# summary. Exits non-zero if any test failed.

set -u

BRIGHT_GREEN="\033[92m"
BRIGHT_RED="\033[91m"
BRIGHT_YELLOW="\033[93m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
SHELLTEST_ROOT="$(dirname "$SCRIPT_DIR")"
export SHELLTEST_LIB="$SHELLTEST_ROOT/src/shelltest.sh"

tests_dir="${1:-tests}"
if [[ ! -d "$tests_dir" ]]; then
    echo "Tests directory '$tests_dir' does not exist." >&2
    exit 1
fi
tests_dir="$(cd "$tests_dir" && pwd -P)"

shopt -s nullglob
test_files=("$tests_dir"/*.test.sh)
shopt -u nullglob

if [[ ${#test_files[@]} -eq 0 ]]; then
    echo "No tests found in '$tests_dir'." >&2
    exit 1
fi

temp_root="$(mktemp -d)"
trap 'rm -rf "$temp_root"' EXIT

export TEST_RESULTS_FILE="$temp_root/results.txt"
: >"$TEST_RESULTS_FILE"

for file in "${test_files[@]}"; do
    test_name="$(basename "$file" .test.sh)"
    test_dir="$temp_root/$test_name"
    mkdir -p "$test_dir"
    pushd "$test_dir" >/dev/null
    bash "$file" || true
    popd >/dev/null
done

total_pass=0
total_fail=0
total_skip=0
while IFS=: read -r p f s; do
    total_pass=$((total_pass + p))
    total_fail=$((total_fail + f))
    total_skip=$((total_skip + s))
done <"$TEST_RESULTS_FILE"

echo ""
passed_part="${BRIGHT_GREEN}${total_pass} passed${RESET}"
failed_part="${BRIGHT_RED}${total_fail} failed${RESET}"
if [[ $total_skip -gt 0 ]]; then
    skipped_part="${BRIGHT_YELLOW}${total_skip} skipped${RESET}"
    echo -e "${passed_part}, ${failed_part}, ${skipped_part}."
else
    echo -e "${passed_part}, ${failed_part}."
fi

[[ $total_fail -eq 0 ]]

#!/usr/bin/env bash

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: path to solution folder
# $3: path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer path/to/solution/folder/ path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug path/to/solution/folder/ path/to/output/directory/"
    exit 1
fi

runner_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

slug="$1"
solution_dir=$(realpath "${2%/}")
mkdir -p "${3%/}"
output_dir=$(realpath "${3%/}")
results_file="${output_dir}/results.json"

echo "${slug}: testing..."

# Run the tests for the provided implementation file and capture the compiler
# version, stdout, and stderr.

test_file="${solution_dir%/}/${slug}-test.roc"
# Capture output without a subshell so the test status stays in this shell.
test_status=-1  # Tests did not run (for example, compilation failed).
platform_test=false
{
    esc=$(printf '\033')
    roc version \
        | sed -E "s/^(Roc compiler version )(.*)$/${esc}[90m\\1${esc}[36m\\2${esc}[0m/"

    if "$runner_dir/is-platform-test" "$test_file"; then
        platform_test=true
        # Build separately so compiler errors are not mistaken for failed assertions.
        if ! build_output=$(FORCE_COLOR=1 roc build --opt=speed --no-cache "$test_file" --output="$work/tests" 2>&1); then
            printf '%s\n' "$build_output"
        else
            "$work/tests"
            test_status=$?
        fi
    else
        FORCE_COLOR=1 roc test --no-cache "$test_file"
        test_status=$?
    fi
} > "$work/output" 2>&1
test_output=$(cat "$work/output")

# Write the results.json file based on the exit code of the command that was
# just executed that tested the implementation file
if [ "$test_status" -eq 0 ]; then
    jq -n '{version: 1, status: "pass"}' > "${results_file}"
else
    # OPTIONAL: Sanitize the output
    # In some cases, the test output might be overly verbose, in which case stripping
    # the unneeded information can be very helpful to the student
    # Strip the nondeterministic timings, e.g. "Ran 2 tests in 4.8 ms.:" -> "Ran 2 tests:"
    # and "All (2) tests passed in 4.8 ms." -> "All (2) tests passed."
    sanitized_test_output=$(printf "%s\n" "${test_output}" \
        | sed -E -e 's/( \(cached\))? in [0-9.]+ ?ms\.:$/:/' \
                 -e 's/( \(cached\))? in [0-9.]+ ?ms([.:]?)$/\2/' \
                 -e 's/(found) in [0-9.]+ ?(ms|s) while/\1 while/' \
                 -e "s|$work/tests|<test executable>|g")

    # OPTIONAL: Manually add colors to the output to help scanning the output for errors
    # If the test output does not contain colors to help identify failing (or passing)
    # tests, it can be helpful to manually add colors to the output
    # colorized_test_output=$(echo "${sanitized_test_output}" \
    #      | GREP_COLOR='01;31' grep --color=always -E -e '^(ERROR:.*|.*failed)$|$' \
    #      | GREP_COLOR='01;32' grep --color=always -E -e '^.*passed$|$')

    if { "$platform_test" && [ "$test_status" -eq 1 ]; } ||
       { ! "$platform_test" && printf "%s\n" "$sanitized_test_output" | grep -q -E '^Ran [0-9]+ tests'; }; then
        roc_status="fail"
    else
        roc_status="error"
    fi
    jq -n --arg output "${sanitized_test_output}" --arg status "${roc_status}" '
        {version: 1, status: $status, message: $output}
    ' > "${results_file}"
fi

echo "${slug}: done"

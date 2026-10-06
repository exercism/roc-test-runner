#!/usr/bin/env sh

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
trap 'rm -rf "$work"' EXIT HUP INT TERM

slug="$1"
solution_dir=$(realpath "${2%/}")
mkdir -p "${3%/}"
output_dir=$(realpath "${3%/}")
results_file="${output_dir}/results.json"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

echo "${slug}: testing..."

# Run the tests for the provided implementation file and capture the compiler
# version, stdout, and stderr.

test_file="${solution_dir%/}/${slug}-test.roc"
test_output=$(
    esc=$(printf '\033')
    {
        roc version \
            | sed -E "s/^(Roc compiler version )(.*)$/${esc}[90m\\1${esc}[36m\\2${esc}[0m/"

        if "$runner_dir/is-platform-test" "$test_file"; then
            # Build separately so compiler errors are not mistaken for failed assertions.
            build_output=$(FORCE_COLOR=1 roc build --opt=speed --no-cache "$test_file" --output="$work/tests" 2>&1)
            status=$?
            if [ "$status" -ne 0 ]; then
                printf '%s\n' "$build_output"
                exit "$status"
            fi
            "$work/tests"
            status=$?
            printf '%s\n' "$status" > "$work/runtime-status"
            exit "$status"
        else
            FORCE_COLOR=1 roc test --no-cache "$test_file"
        fi
    } 2>&1
)

# Write the results.json file based on the exit code of the command that was
# just executed that tested the implementation file
if [ $? -eq 0 ]; then
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

    if { [ -f "$work/runtime-status" ] && [ "$(cat "$work/runtime-status")" = 1 ]; } ||
       { [ ! -f "$work/runtime-status" ] && printf "%s\n" "$sanitized_test_output" | grep -q -E '^Ran [0-9]+ tests'; }; then
        roc_status="fail"
    else
        roc_status="error"
    fi
    jq -n --arg output "${sanitized_test_output}" "{version: 1, status: \"$roc_status\", message: \$output}" > "${results_file}"
fi

echo "${slug}: done"

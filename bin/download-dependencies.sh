#!/usr/bin/env sh
# Cache libraries and build/run every platform smoke test while online.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

for source in "$root"/dependencies/*.roc; do
    echo "Preparing $(basename "$source")..."
    if "$root/bin/is-platform-test" "$source"; then
        roc build --opt=speed --no-cache "$source" --output="$work/check"
        "$work/check"
    else
        roc test --no-cache "$source"
    fi
done

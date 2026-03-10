#!/usr/bin/env bash
#
# Collect bufo images added in the last N commits into a new folder.
#
# Usage: ./scripts/collect-newest-bufo.sh [N] [OUTPUT_DIR]
#   N          - Number of (first-parent) commits to look back (default: 6)
#   OUTPUT_DIR - Destination folder (default: newest-bufo)

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

N="${1:-6}"
OUTPUT_DIR="${2:-newest-bufo}"

# Get the commit to diff against (N first-parent commits back)
BASE_COMMIT=$(git log --first-parent --format="%H" --skip="$N" -1)

if [ -z "$BASE_COMMIT" ]; then
  echo "Error: Not enough commits in history (requested $N)" >&2
  exit 1
fi

# Find bufo files added since that commit
NEW_FILES=$(git diff --name-only --diff-filter=A "$BASE_COMMIT"..HEAD -- 'all-the-bufo/')

if [ -z "$NEW_FILES" ]; then
  echo "No new bufo found in the last $N commits."
  exit 0
fi

mkdir -p "$OUTPUT_DIR"

COUNT=0
while IFS= read -r f; do
  cp "$f" "$OUTPUT_DIR/"
  COUNT=$((COUNT + 1))
done <<< "$NEW_FILES"

echo "Copied $COUNT bufo to $OUTPUT_DIR/"

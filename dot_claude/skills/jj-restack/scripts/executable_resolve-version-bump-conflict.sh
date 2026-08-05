#!/usr/bin/env bash
# Checks whether a jj conflict on REV is *only* a CI-generated version-bump
# commit colliding with itself (e.g. package.json's "version" field disagreeing
# after a rebase), and if so, abandons the commit so a future push lets CI
# regenerate a fresh version bump. Refuses (exit 1) and prints the conflicted
# paths if anything else is involved — that's a real conflict and must be
# resolved by hand, never auto-dropped.
#
# Usage: resolve-version-bump-conflict.sh <conflicted-revision> [manifest-file ...]
#   manifest-file defaults to: package.json package-lock.json
#
# Exit 0  = recognized as a pure version-bump conflict and abandoned.
# Exit 1  = not safe to auto-resolve; message on stderr explains why.
set -euo pipefail

REV="${1:?usage: resolve-version-bump-conflict.sh <conflicted-revision> [manifest-file ...]}"
shift
MANIFEST_FILES=("$@")
if [[ ${#MANIFEST_FILES[@]} -eq 0 ]]; then
  MANIFEST_FILES=(package.json package-lock.json)
fi

DESC=$(jj log -r "$REV" --no-graph -T 'description.first_line()' 2>/dev/null || true)
if [[ -z "$DESC" ]]; then
  echo "could not resolve revision '$REV' — is this the right commit id / change id?" >&2
  exit 1
fi

if [[ ! "$DESC" =~ ^Updating\ version\ to ]]; then
  echo "REAL COMMIT: '$REV' (\"$DESC\") is not a version-bump commit — resolve by hand, do not abandon it" >&2
  exit 1
fi

CONFLICTED_PATHS=$(jj resolve --list -r "$REV" 2>/dev/null | awk '{print $1}' || true)
if [[ -z "$CONFLICTED_PATHS" ]]; then
  echo "no conflicts found on '$REV' — nothing to do" >&2
  exit 1
fi

NON_MANIFEST=()
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  is_manifest=0
  for m in "${MANIFEST_FILES[@]}"; do
    [[ "$path" == "$m" ]] && is_manifest=1 && break
  done
  [[ "$is_manifest" -eq 0 ]] && NON_MANIFEST+=("$path")
done <<< "$CONFLICTED_PATHS"

if [[ ${#NON_MANIFEST[@]} -gt 0 ]]; then
  echo "REAL CONFLICT: '$REV' touches non-manifest paths, resolve by hand:" >&2
  printf '  %s\n' "${NON_MANIFEST[@]}" >&2
  exit 1
fi

echo "'$REV' (\"$DESC\") only conflicts in version-manifest files:"
echo "$CONFLICTED_PATHS" | sed 's/^/  /'
echo "abandoning it — CI will regenerate a version bump on the next push."
jj abandon "$REV"

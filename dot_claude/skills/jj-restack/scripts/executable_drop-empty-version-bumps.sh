#!/usr/bin/env bash
# After a clean rebase (jj reports zero conflicts), a CI-generated
# version-bump commit can still be stale: if the branch's target version
# already exists in the new destination, the bump commit's diff becomes
# empty (jj marks it "(empty) Updating version to X.Y.Z." in its own log
# output) even though nothing conflicted. jj gives no warning for this —
# "Rebased N commits" reads identically whether or not a stray no-op commit
# is still sitting in the history — so this has to be checked explicitly
# after every rebase, not just when Step 4 reports a conflict. Left in
# place, these no-op commits cause version drift the next time someone
# builds on the branch.
#
# For each bookmark given, if its tip commit is an empty "Updating version
# to X.Y.Z." commit, abandons it and re-points the bookmark to the real
# content tip underneath. Leaves the bookmark untouched (and explains why on
# stderr) if the tip isn't a version-bump commit, or if it has a nonempty
# diff (a real, distinct version bump — not safe to drop automatically).
#
# Usage: drop-empty-version-bumps.sh <bookmark> [<bookmark> ...]
#   Pass every bookmark in the stack (bottom to top) in one call — bookmarks
#   are abandoned together in a single `jj abandon`, which is what lets a
#   drop at the bottom of the stack cascade cleanly through the rest.
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: drop-empty-version-bumps.sh <bookmark> [<bookmark> ...]" >&2
  exit 1
fi

commits_to_abandon=()
bookmarks_to_set=()
tips_to_set=()

for bookmark in "$@"; do
  commit_id=$(jj log -r "$bookmark" --no-graph -T 'commit_id' 2>/dev/null || true)
  if [[ -z "$commit_id" ]]; then
    echo "skip '$bookmark': could not resolve bookmark" >&2
    continue
  fi

  desc=$(jj log -r "$bookmark" --no-graph -T 'description.first_line()' 2>/dev/null || true)
  if [[ ! "$desc" =~ ^Updating\ version\ to ]]; then
    echo "skip '$bookmark' ($commit_id, \"$desc\"): tip is not a version-bump commit" >&2
    continue
  fi

  stat=$(jj diff -r "$bookmark" --stat 2>/dev/null || true)
  if [[ "$stat" != "0 files changed"* ]]; then
    echo "skip '$bookmark' ($commit_id): version-bump commit has a real diff, not safe to auto-drop:" >&2
    echo "  $stat" >&2
    continue
  fi

  parent_id=$(jj log -r "${bookmark}-" --no-graph -T 'commit_id' 2>/dev/null || true)
  if [[ -z "$parent_id" ]]; then
    echo "skip '$bookmark': could not resolve parent commit" >&2
    continue
  fi

  echo "'$bookmark' ($commit_id, \"$desc\") is an empty no-op — will drop and re-point to $parent_id"
  commits_to_abandon+=("$commit_id")
  bookmarks_to_set+=("$bookmark")
  tips_to_set+=("$parent_id")
done

if [[ ${#commits_to_abandon[@]} -eq 0 ]]; then
  echo "nothing to drop" >&2
  exit 0
fi

jj abandon "${commits_to_abandon[@]}"

for i in "${!bookmarks_to_set[@]}"; do
  jj bookmark set "${bookmarks_to_set[$i]}" -r "${tips_to_set[$i]}"
done

echo "dropped ${#commits_to_abandon[@]} stale version-bump commit(s); CI will regenerate fresh ones on next push."

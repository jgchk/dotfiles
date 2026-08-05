#!/usr/bin/env bash
# Marks a GitLab MR discussion thread as resolved after its feedback has been
# addressed and committed. Optional close-the-loop step — only run this once
# the fix is actually committed, not just discussed.
#
# Usage: resolve-thread.sh <mr-iid> <discussion-id>
set -euo pipefail

MR_IID="${1:?usage: resolve-thread.sh <mr-iid> <discussion-id>}"
DISCUSSION_ID="${2:?usage: resolve-thread.sh <mr-iid> <discussion-id>}"

glab api -X PUT "merge_requests/${MR_IID}/discussions/${DISCUSSION_ID}" \
  -f "resolved=true" >/dev/null

echo "resolved thread ${DISCUSSION_ID} on MR !${MR_IID}"

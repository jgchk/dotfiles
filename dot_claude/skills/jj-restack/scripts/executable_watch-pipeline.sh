#!/usr/bin/env bash
# Polls a GitLab MR's latest pipeline until it reaches a terminal state, instead
# of hand-rolling a `for i in 1..N; do sleep 5; glab api ...; done` loop every
# time. Prints one line per status change (not one line per poll) so long runs
# don't spam the transcript, and gives up after a bounded number of polls
# rather than looping forever if something is stuck.
#
# Usage: watch-pipeline.sh <mr-iid> [max-poll-seconds] [interval-seconds]
#   max-poll-seconds defaults to 900 (15 min), interval-seconds defaults to 15.
#
# Exit 0  = pipeline reached "success".
# Exit 1  = pipeline reached "failed"/"canceled"/"skipped", or no pipeline found.
# Exit 2  = timed out before reaching a terminal state.
set -euo pipefail

MR_IID="${1:?usage: watch-pipeline.sh <mr-iid> [max-poll-seconds] [interval-seconds]}"
MAX_SECONDS="${2:-900}"
INTERVAL="${3:-15}"

TERMINAL_STATES="success failed canceled skipped"

elapsed=0
last_status=""

while true; do
  pipeline_json=$(glab api "merge_requests/${MR_IID}/pipelines" 2>/dev/null | python3 -c "
import json, sys
pipelines = json.load(sys.stdin)
print(json.dumps(pipelines[0]) if pipelines else '')
" 2>/dev/null || true)

  if [[ -z "$pipeline_json" ]]; then
    echo "no pipeline found for MR !${MR_IID} yet (elapsed ${elapsed}s)" >&2
  else
    status=$(echo "$pipeline_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('status',''))")
    web_url=$(echo "$pipeline_json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('web_url',''))")

    if [[ "$status" != "$last_status" ]]; then
      echo "MR !${MR_IID} pipeline: ${status} (${web_url}) [${elapsed}s elapsed]"
      last_status="$status"
    fi

    for terminal in $TERMINAL_STATES; do
      if [[ "$status" == "$terminal" ]]; then
        if [[ "$status" == "success" ]]; then
          exit 0
        else
          exit 1
        fi
      fi
    done
  fi

  if (( elapsed >= MAX_SECONDS )); then
    echo "timed out after ${elapsed}s waiting for MR !${MR_IID} pipeline to finish" >&2
    exit 2
  fi

  sleep "$INTERVAL"
  elapsed=$(( elapsed + INTERVAL ))
done

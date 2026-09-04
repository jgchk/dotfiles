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
  raw=$(glab api "projects/:id/merge_requests/${MR_IID}/pipelines" 2>&1) && api_ok=1 || api_ok=0

  if [[ "$api_ok" -eq 0 ]]; then
    echo "glab api call failed for MR !${MR_IID}, aborting rather than looping silently:" >&2
    echo "$raw" >&2
    exit 1
  fi

  pipeline_json=$(echo "$raw" | python3 -c "
import json, sys
data = json.load(sys.stdin)
if isinstance(data, dict):
    # e.g. {\"error\": \"404 Not Found\"} — a real API error, not \"no pipelines yet\"
    print('__ERROR__' + json.dumps(data))
else:
    print(json.dumps(data[0]) if data else '')
" 2>&1) || { echo "could not parse glab api response for MR !${MR_IID}, aborting:" >&2; echo "$raw" >&2; exit 1; }

  if [[ "$pipeline_json" == __ERROR__* ]]; then
    echo "glab api returned an error for MR !${MR_IID}, aborting rather than looping silently:" >&2
    echo "${pipeline_json#__ERROR__}" >&2
    exit 1
  fi

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

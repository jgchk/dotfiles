#!/usr/bin/env bash
# Fetches every review-comment thread on a GitLab MR in one call, instead of
# pasting/fetching one glab api note URL at a time. Prints a numbered list:
# thread id, resolved state, file:line (for diff notes), author, and body.
#
# Usage: fetch-review-threads.sh <mr-iid> [--unresolved-only]
set -euo pipefail

MR_IID="${1:?usage: fetch-review-threads.sh <mr-iid> [--unresolved-only]}"
UNRESOLVED_ONLY=0
[[ "${2:-}" == "--unresolved-only" ]] && UNRESOLVED_ONLY=1

glab api "merge_requests/${MR_IID}/discussions?per_page=100" --paginate 2>/dev/null | python3 -c "
import json, sys

unresolved_only = $UNRESOLVED_ONLY
raw = sys.stdin.read().strip()
discussions = []
# --paginate concatenates one JSON array per page; each may itself be a list.
decoder = json.JSONDecoder()
idx = 0
while idx < len(raw):
    while idx < len(raw) and raw[idx].isspace():
        idx += 1
    if idx >= len(raw):
        break
    obj, end = decoder.raw_decode(raw, idx)
    discussions.extend(obj if isinstance(obj, list) else [obj])
    idx = end

count = 0
for d in discussions:
    notes = d.get('notes', [])
    if not notes:
        continue
    first = notes[0]
    if first.get('system'):
        continue  # skip system notes (e.g. 'changed the description')
    resolved = first.get('resolvable') and first.get('resolved')
    if unresolved_only and resolved:
        continue

    count += 1
    pos = first.get('position') or {}
    loc = ''
    if pos.get('new_path'):
        loc = f\"{pos['new_path']}:{pos.get('new_line') or pos.get('old_line') or '?'}\"

    status = 'RESOLVED' if resolved else ('UNRESOLVED' if first.get('resolvable') else 'COMMENT')
    print(f\"--- thread {d.get('id')} [{status}]\" + (f\" @ {loc}\" if loc else ''))
    for note in notes:
        if note.get('system'):
            continue
        author = note.get('author', {}).get('username', '?')
        body = note.get('body', '').strip()
        print(f\"  {author}: {body}\")
    print()

if count == 0:
    print('no review threads found' + (' (unresolved only)' if unresolved_only else ''), file=sys.stderr)
"

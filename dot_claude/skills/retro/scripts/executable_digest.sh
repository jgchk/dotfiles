#!/usr/bin/env bash
# Digest a Claude Code session transcript (JSONL) into a bounded, retro-ready summary.
#
# Usage: digest.sh <transcript.jsonl>
#
# Transcripts live at ~/.claude/projects/<munged-cwd>/<session-uuid>.jsonl
# (munged-cwd = the project path with '/' replaced by '-'). Subagent transcripts
# live in a sibling directory <session-uuid>/subagents/ and are NOT digested here.
#
# Output is markdown, bounded (~a few hundred lines) regardless of transcript size,
# so it can be read directly into context. It surfaces retro signals: what the user
# asked for and pushed back on, what tooling failed, what got repeated.
set -euo pipefail

F="${1:?usage: digest.sh <transcript.jsonl>}"
[ -f "$F" ] || { echo "no such file: $F" >&2; exit 1; }

section() { printf '\n## %s\n\n' "$1"; }

printf '# Transcript digest: %s\n' "$(basename "$F")"

section "Session shape"
jq -rs '
  def ts(t): t.timestamp // empty;
  def epoch(t): ts(t) | if . == null then null else (sub("\\.[0-9]+Z$"; "Z") | (fromdateiso8601? // null)) end;
  (map(select(.type=="user" or .type=="assistant"))) as $msgs |
  (epoch($msgs[0])) as $t0 | (epoch($msgs[-1])) as $t1 |
  "- entries: \(length) (\(map(select(.type=="user")) | length) user, \(map(select(.type=="assistant")) | length) assistant)",
  "- first: \(ts($msgs[0]) // "?")   last: \(ts($msgs[-1]) // "?")",
  (if $t0 != null and $t1 != null then "- duration: \((($t1 - $t0) / 60) | round) minutes" else "- duration: ?" end),
  "- sidechain (subagent) entries inline: \(map(select(.isSidechain==true)) | length)",
  "- client version: \(map(.version // empty) | last // "?")"
' "$F"

section "Tool usage (by tool, count)"
jq -r '
  select(.type=="assistant" and (.isSidechain != true)) |
  .message.content // [] | if type=="array" then .[] else empty end |
  select(.type=="tool_use") | .name
' "$F" | sort | uniq -c | sort -rn | head -25 | sed 's/^/    /'

section "Skills/commands attributed on assistant turns"
jq -r 'select(.type=="assistant") | .attributionSkill // empty' "$F" \
  | sort | uniq -c | sort -rn | head -15 | sed 's/^/    /'
jq -r '
  select(.type=="user") | .message.content // empty |
  if type=="string" then . else (map(select(.type=="text") | .text // "") | join(" ")) end
' "$F" | grep -o '<command-name>[^<]*</command-name>' | sort | uniq -c | sort -rn | head -15 | sed 's/^/    /' || true

section "User messages (chronological, truncated; corrections and frustration live here)"
jq -r '
  select(.type=="user" and (.isMeta != true) and (.isSidechain != true)) |
  .message.content // empty |
  if type=="string" then . else (map(select(.type=="text") | .text // "") | join(" ")) end |
  select(length > 0) |
  select(startswith("<") | not) |
  gsub("\\s+"; " ") | .[0:400]
' "$F" | grep -vE '^\[Request interrupted' | nl -w3 -s'. ' | head -80

section "User steering via slash commands and question dialogs (also user voice — do not skip)"
jq -r '
  select(.type=="user") | .message.content // empty |
  if type=="string" then . else (map(select(.type=="text") | .text // "") | join("\n")) end |
  select(test("<command-message>")) |
  ((try (capture("<command-name>(?<n>[^<]+)</command-name>").n) catch "?") // "?") as $cmd |
  ((try (capture("<command-args>(?<a>.*)"; "s").a | sub("</command-args>.*$"; ""; "s")) catch "") // "") as $args |
  "- \($cmd) :: \($args | gsub("\\s+"; " ") | .[0:300])"
' "$F" | head -20
jq -r '
  select(.type=="user") |
  .message.content // [] | if type=="array" then .[] else empty end |
  select(.type=="tool_result") |
  .content | (if type=="string" then . elif type=="array" then (map(.text // "") | join(" ")) else "" end) |
  select(test("^(The user answered|Your questions have been answered)")) |
  gsub("\\s+"; " ") | "- [dialog] " + .[0:400]
' "$F" | head -20

section "Interruptions (user hit escape mid-turn)"
jq -r '
  select(.type=="user") | .message.content // empty |
  if type=="string" then . else (map(select(.type=="text") | .text // "") | join(" ")) end
' "$F" | grep -c '^\[Request interrupted' | sed 's/^/    count: /' || true

section "Failed tool calls (deduped by first line, with counts)"
jq -r '
  select(.type=="user") |
  .message.content // [] | if type=="array" then .[] else empty end |
  select(.type=="tool_result" and .is_error==true) |
  .content |
  (if type=="string" then . elif type=="array" then (map(.text // "") | join(" ")) else tostring end) |
  gsub("\\s+"; " ") | .[0:160]
' "$F" | sort | uniq -c | sort -rn | head -40 | sed 's/^/    /'

section "Repeated Bash commands (possible toil; count >= 2)"
jq -r '
  select(.type=="assistant" and (.isSidechain != true)) |
  .message.content // [] | if type=="array" then .[] else empty end |
  select(.type=="tool_use" and .name=="Bash") |
  .input.command // "" | gsub("\\s+"; " ") | .[0:120]
' "$F" | sort | uniq -c | sort -rn | awk '$1 >= 2' | head -25 | sed 's/^/    /'

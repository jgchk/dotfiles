---
name: retro
description: Hold a sprint-style retrospective on a Claude Code session — either the current session at its end, or a past session by mining its transcript. Surfaces process improvements (repeated pain points, toil, practices worth expanding) and turns them into concrete action items - new/updated skills, automation scripts, doc fixes, rules promoted into docs/reviewer-agents/lint-rules. Use when the user says "retro", "retrospective", "post-mortem the session", "what should we improve about how we worked", "any friction this session?", or points at a previous session and asks what can be learned from it.
---

# Session retro

A retro is about **process, not blame and not code review**. The question is never "what did we get wrong" but "what about how we work made that likely, and what change to the system — tooling, docs, automation, enforcement — makes it not happen again." One-off mishaps are usually noise; **repeated** pain is signal. Rank findings by frequency × cost.

The other half of a retro is the positive: which practices worked well enough that they should be named, kept, and expanded.

## Two modes

**In-session** (invoked at the end of a working session): reflect on the conversation you just had. You were there — report the friction you actually experienced: failed tool calls and their causes, docs or prompts you had to puzzle out, work you did twice, permission stops, things you'd want a script for. Be honest in both directions: don't soften real friction to be polite, and don't invent grievances to seem useful — "nothing major, this session ran clean" is a perfectly good retro finding. If the session was long enough that early context was summarized away, recover the ground truth by digesting your own transcript (below).

**Transcript mode** (pointed at a past session): find the transcript and mine it. Transcripts live at `~/.claude/projects/<munged-cwd>/<session-uuid>.jsonl` where munged-cwd is the project path with `/` replaced by `-`; subagent transcripts sit in a sibling `<session-uuid>/subagents/` directory. If the user gives a description rather than an id ("yesterday's session about the deploy"), locate it by `ls -t` and grepping candidates for distinctive terms.

## Mining a transcript

Transcripts are multi-megabyte JSONL — never read one raw. Run the bundled digest first:

```bash
<skill-dir>/scripts/digest.sh <transcript.jsonl>
```

It emits a bounded markdown summary: session shape, tool usage, skills invoked, every real user message (corrections and frustration live here — a terse "no, I meant…" or a repeated instruction is a process smell), interruption count, failed tool calls deduped with counts, and repeated Bash commands (toil candidates). Read the digest, then follow up with targeted `jq` queries on the transcript only where the digest points somewhere interesting.

Signals worth chasing in the digest:

- **The same instruction given twice** — by the user in one session, or across sessions. A rule that has to be said is a rule that isn't yet written down; a rule that's written down and still violated needs stronger enforcement (see the ladder below).
- **Failed tool calls with the same shape** — each cluster is either a missing guard, a doc gap, or tooling worth fixing.
- **Repeated near-identical Bash commands** — a poll loop, a rebuild incantation, a status check. Each is a script or skill waiting to be written.
- **User interruptions and corrections** — where did the user have to steer? What would have let the work proceed without steering?
- **What went smoothly** — a skill or workflow that carried real weight this session is worth noting and possibly extending to neighboring toil.

## Action items

Aim for a handful of high-leverage items, not a laundry list. Every item must **change the system**; "be more careful next time" is not a retro outcome. The usual shapes:

- **New skill/command** — repeated multi-step work becomes a skill so it's one word next time.
- **Update an existing skill/command** — this session revealed a pain point, gap, or wrong assumption in one.
- **Automation script** — a bash script for a process done by hand (or by repeated ad-hoc commands) this session.
- **Doc fix** — out-of-date, vague, or missing documentation that tripped up the work. Fix it so nobody trips on it again.
- **Promote an implicit rule up the enforcement ladder.** Development standards that get repeated in conversation should climb: *spoken in chat* → *written* (CLAUDE.md or the project's development docs) → *reviewed* (a dedicated reviewer subagent for a commonly-violated standard, e.g. `.claude/agents/`) → *enforced* (a deterministic lint rule). Prefer the highest rung the rule can reach: a linter catches every violation forever; an LLM reviewer catches most; a doc catches those who read it. Each retro, ask which repeated rules are ready to move up a rung.
- **CLAUDE.md entry** — a durable insight about how the user works or what the project needs, written into the project's CLAUDE.md (or a doc it links). Prefer this over assistant auto-memory: CLAUDE.md is user-controlled, versioned, and visible — do not propose memory entries as retro outcomes.
- **Repo code changes — sparingly.** Only the kind that would come up in a real sprint retro (a flaky test that wasted everyone's time, a build step that needs caching), never code-review findings (bugs, style, design nits). If you notice those, mention them in one line and move on.

## Closing the loop

Present the retro in the classic shape — what went well / what was painful / proposed action items — with each action item sized (small/medium/large) and placed (which file, which repo). Then let the user pick which to adopt, and implement the chosen ones in this session where feasible. An unimplemented retro is a meeting; an implemented one is an improvement.

If a new or updated skill is universal (not project-specific), put it in the user-level skills directory and follow whatever convention manages that directory (e.g. a dotfiles repo) so it propagates to other machines.

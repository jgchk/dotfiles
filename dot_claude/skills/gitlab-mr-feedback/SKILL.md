---
name: gitlab-mr-feedback
description: Work through a GitLab MR's review comments end to end — fetch every open thread in one shot, explain each finding in plain language, fix and commit once the user agrees, then optionally mark the thread resolved. Use whenever the user asks to "go through the review feedback on this MR", "address the review comments", pastes one or more glab/GitLab note or discussion URLs and asks what they mean, or says things like "can you explain this review comment" / "help me understand this feedback" about an open MR. Trigger even if the user only pastes a single note URL — that is the entry point into the same loop, but fetch the *whole* thread list up front rather than fetching one note at a time as more come up, since MRs almost always have more than one open comment.
version: 0.1.0
---

# GitLab MR Feedback Loop

Drives the "explain the finding → confirm → fix → commit" loop that already
happens on nearly every MR review pass on this team, but starting from a
single bulk fetch of the MR's review threads instead of pasting or fetching
individual `glab api .../notes/<id>` URLs one at a time as the conversation
goes.

## Step 0 — Confirm you're on jj

```bash
if jj root >/dev/null 2>&1; then echo "jj"; elif git rev-parse --git-dir >/dev/null 2>&1; then echo "git"; else echo "none"; fi
```

This skill's commit step assumes `jj-commit` is available (this team uses jj,
not raw git). If this prints `git`, ask before proceeding — the fetch/explain
steps below still work, but the commit step needs adjusting.

## Step 1 — Fetch every thread in one call

Run from inside the repo so `glab` auto-detects the project — no need to look
up the project id or MR URL by hand:

```bash
~/.claude/skills/gitlab-mr-feedback/scripts/fetch-review-threads.sh <mr-iid> --unresolved-only
```

Drop `--unresolved-only` if the user wants to see already-resolved threads
too (e.g. to double check something was actually addressed). This gives you
the full list up front — thread id, file:line for diff comments, and the
comment body — so you're not rediscovering threads one at a time as the
conversation progresses.

If the user pasted a specific note/discussion URL instead of an MR number,
still run this against the MR it belongs to (the iid is in the URL) rather
than fetching just that one note — there are almost always other open
threads on the same MR worth surfacing now rather than later.

## Step 2 — Work through the list, one thread at a time

For each unresolved thread, in whatever order the user wants to tackle them
(default to the order they appear, top of file to bottom, unless the user
has a reason to reorder):

1. **Explain the finding in plain language before touching code.** State what
   the reviewer is flagging, why it's a real issue (or, if it's not, say so
   and explain why you think it's a false positive rather than silently
   ignoring it), and what the fix would look like. Don't jump straight to an
   edit — this team's reviewers surface real defects often enough that a
   quick "yes please" confirmation loop is the norm, not friction to skip.
2. Wait for the user's go-ahead. If they want a different fix than the
   reviewer suggested, that's fine — the reviewer comment is a prompt, not a
   spec.
3. Make the fix. If it's the kind of change with edge cases or clearly
   testable behavior, write or update a test per this repo's TDD norms.
4. Commit with `/jj-commit` before moving to the next thread — one thread's
   fix per commit keeps the eventual diff reviewable, and matches the
   "atomic commits" rule in this repo's CLAUDE.md.
5. Optionally close the loop on GitLab itself:

   ```bash
   ~/.claude/skills/gitlab-mr-feedback/scripts/resolve-thread.sh <mr-iid> <discussion-id>
   ```

   Only do this after the fix is actually committed — resolving a thread
   before the fix lands just hides feedback that hasn't been addressed yet.

## Step 3 — Report back

Once the requested threads are handled, summarize: how many threads were
fixed vs. left open (and why, if any were left open deliberately — e.g. "not
in scope for this MR" or "reviewer and I disagreed, flagging for a human
call"), and whether you pushed. Don't push automatically — GitLab MR pushes
are visible to reviewers, confirm before pushing unless the user already gave
a blanket go-ahead for this pass.

If the branch needed rebasing at any point in this process (stale base,
conflicting version bump), that's `jj-restack`'s job, not this skill's —
hand off rather than improvising a rebase here.

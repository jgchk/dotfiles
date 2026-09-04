---
name: jj-restack
description: Rebase a GitLab merge request — or a whole stack of dependent MRs — that has fallen behind its target branch, using jj (Jujutsu). Use this whenever an MR shows "N commits behind" on GitLab, whenever a rebase or merge conflict shows up in package.json/package-lock.json's "version" field (that almost always means a CI-generated "Updating version to X.Y.Z." commit collided with another one — it should be dropped, not hand-resolved), or whenever the user asks to "rebase this MR", "restack", "fix up this stacked diff", "rebase the stack", or mentions multiple MRs that build on each other (one MR's source branch is another MR's target branch). Also trigger on messier phrasing that still means "the branch history is wrong and needs restacking onto the right base": "someone merged master into their branch instead of rebasing", "I think our work got reversed/undone", "this branch's history looks wrong", "bookmarks point at the wrong commits", or any report of unexpected/duplicated/missing commits on a branch that should sit cleanly on top of another. Trigger even if the user only pastes MR URLs and says "these need rebasing" or "fix the conflict on this MR" — this is a routine, repeatable operation on this team because every repo's CI pipeline pushes its own version-bump commit, and that conflicts the moment a sibling MR merges first.
version: 0.4.0
---

# jj Restack

Rebases one GitLab MR branch, or a whole chain of stacked MR branches, onto
up-to-date targets using `jj`. Written for teams where CI auto-commits a
version bump (`package.json`/`package-lock.json`, or whatever the repo's
manifest is) directly onto every pushed branch. That bump has no meaning
before merge — it's a snapshot of "what version this would be if merged right
now" — so the moment any sibling MR merges to `master` first, every other open
MR's bump commit is now computed from a stale base and conflicts on rebase.
This is not a real conflict about code; treat it as noise to clear, not a
puzzle to solve.

The one thing this skill is emphatically *not* for: guessing a "correct"
version number by hand-merging `2.5.0` vs `2.4.1` vs `2.4.2` in a conflict
marker. Drop the commit. CI will make a new one, computed correctly against
wherever the branch actually landed, on the next push.

## Step 0 — Confirm you're on jj

```bash
if jj root >/dev/null 2>&1; then echo "jj"; elif git rev-parse --git-dir >/dev/null 2>&1; then echo "git"; else echo "none"; fi
```

Must print `jj`. If it's `git`, stop and ask — this skill's conflict-resolution
and bookmark model don't map cleanly onto raw git, and mixing the two mid-task
is how history gets tangled.

Everything below rebases, abandons, and squashes commits — all reversible
locally as long as you haven't pushed yet. If a step produces a state you
didn't expect, `jj op log` shows every operation and `jj undo` reverts the
last one; that's a cheaper way out than trying to manually patch a mistake.

## Step 1 — Scope it: one MR, or a stack?

If the user names exactly one MR/branch and nothing suggests it depends on
other in-flight work, treat it as a single rebase (skip straight to Step 3
with a chain of length one).

Otherwise — the user says "stack"/"chain"/"restack everything", names two or
more MRs, or the MR's target branch turns out to be another feature branch
rather than `master`/`main` — you're dealing with a stack. Find every open MR
and its source/target branches so you can see how they link together. Run
this from inside the repo so `glab` can auto-detect the project — no need to
figure out the project path or URL-encode anything:

```bash
glab mr list --author <username> -F json --per-page 100 \
  | python3 -c "
import json, sys
for mr in json.load(sys.stdin):
    print(mr['iid'], '| src:', mr['source_branch'], '| target:', mr['target_branch'], '|', mr['title'])
"
```

A stack shows up as a chain: MR A's `target_branch` is `master`; MR B's
`target_branch` equals MR A's `source_branch`; MR C's `target_branch` equals
MR B's `source_branch`; and so on. Order the chain from the branch closest to
`master` (rebase first) to the one furthest out (rebase last) — each one
needs its parent's *new* tip before it can be correctly restacked, so doing
them out of order just recreates the same conflict twice.

If ownership is ambiguous (MRs from multiple authors, or you're not sure
which MRs belong to this particular stack vs. unrelated work), ask rather
than guessing — restacking the wrong branch onto the wrong parent is exactly
the kind of mistake that's annoying to unwind.

## Step 2 — Fetch, then check the *actual* shape before touching anything

```bash
jj git fetch
```

**Before trusting any bare branch name (`master`, `main`, or a parent branch
you don't own), confirm its local bookmark actually tracks the remote.**
`jj git fetch` always updates the remote-tracking ref (`master@origin`), but
it only fast-forwards the plain local bookmark (`master`) if that bookmark is
set up to track it — and in plenty of colocated jj repos it isn't (leftover
from an old `git clone`, never explicitly tracked, or last moved by hand
weeks ago). When it's untracked, `jj git fetch` reports `Nothing changed`
even while `master@origin` has moved by dozens of commits, and it fails
silently: no error, no conflict, just every downstream revset quietly
comparing against a stale snapshot instead of reality. This is exactly how a
restack can look clean, get pushed, and still show "N commits behind" on
GitLab afterward — not because something merged mid-task, but because the
"before" comparison was already wrong before the first rebase ran. Check
before you rely on either:

```bash
jj log -r 'master | master@origin' --no-graph -T 'bookmarks ++ " " ++ commit_id.short() ++ "\n"'
```

If the two rows show different commit ids, don't fix the local bookmark and
don't assume fetch will catch it up next time — just use `master@origin`
(never the bare `master`) for every comparison, rebase destination, and
re-verify below, for `master`/`main` and for any parent branch in a stack
that you aren't actively restacking yourself. The bare local name is only
trustworthy for the branch you *are* restacking right now (the one whose
bookmark you're about to move and push) — that one is supposed to diverge
from its own remote-tracking ref mid-task; that's the whole point.

Don't trust bookmark names alone to tell you the branch hierarchy either —
verify it in the local commit graph. For each branch in the chain, in order
(substituting `master@origin` for `master` per the check above if they
diverged):

```bash
jj log -r '::master@origin & ~::<branch>'              # what master has that <branch> doesn't (branch is behind by this many)
jj log -r '::<branch> & ~::master@origin'              # what <branch> has that master doesn't (branch is ahead by this many)
jj log -r '::<parent-branch> & ~::<branch>'            # what <parent-branch> has that <branch> doesn't
```

`::A & ~::B` reads as "ancestors of A that aren't ancestors of B" — i.e. what
A has that B lacks. It is easy to read these backwards under time pressure;
if you get the two directions swapped, you'll misdiagnose which side is
behind. Anchor on GitLab's own "N commits behind" number for the branch —
compute both directions above and check which one's count matches, and treat
a mismatch as a sign you're comparing against a stale ref (see the bookmark
check above) before you assume GitLab is wrong. **If
`::master@origin & ~::<branch>` is empty, `<branch>` is not behind `master`
at all — it already contains master fully (possibly with unmerged commits
ahead of it). Do not rebase it just because it appears in a stack; only
rebase the links that are actually behind their target.** This came up for a
real 2-level stack where the bottom branch had 0 commits behind master
(nothing to do) while the top branch was 16 commits behind the bottom branch
(the actual rebase needed) — treating both as "needs a master rebase"
because the chain mapping suggested it would have been wrong.

The commit counts here should match what GitLab's "N commits behind" shows.
If they don't, or if a graphed `jj log -r '(::<branch-A> | ::<branch-B>) & ~::master@origin'`
shows the two branches as *siblings* off a shared ancestor rather than one
sitting cleanly on top of the other, that's a real finding worth surfacing:
it usually means the two branches were properly stacked at some point, but
further local work continued on one line without the other picking it up.
Rebasing onto `master` alone won't fix that — you'll need an *extra*
`jj rebase -b <child-branch> -d <parent-tip>` afterward to actually stack them
(see Step 3).

## Step 3 — Rebase each branch onto its (possibly just-rebased) parent

**Never run `jj rebase -s <bookmark-name> -d <destination>`.** `-s` rebases
*only* the given revision and its descendants — it does not pull along that
revision's ancestors. A bookmark almost always points at the branch's *tip*,
and on this team the tip is almost always the CI-generated version-bump
commit sitting on top of the real work (that's the whole premise of this
skill). So `-s <bookmark>` silently reparents just that tip commit onto the
destination and orphans everything between the fork point and the tip's old
parent — jj reports success ("Rebased 1 commits to destination") with no
warning that it just dropped the branch's actual content. This is not
theoretical: it happened twice in one session before being caught, once on a
bottom-of-stack branch and once on the branch above it.

Use `-b` (whole branch) instead — it finds the real fork point (the branch's
ancestors that aren't already ancestors of the destination) and moves all of
them, tip included, in one shot:

```bash
jj rebase -b <branch> -d master@origin   # bottom of the stack, targets master directly — @origin, not the bare name (see Step 2)
jj rebase -b <child-branch> -d <parent-branch>   # every subsequent branch, onto the parent's new tip
```

If Step 2 found two branches were siblings rather than properly stacked,
this is also the command that fixes that — same syntax, it's just doing
double duty.

If you want to see the exact commit list before moving anything (useful when
you don't yet trust the branch shape), compute the fork point explicitly and
rebase with `-s <fork-point>` — this is equivalent to `-b` but lets you
eyeball the list first:

```bash
jj log -r '::<branch> & ~::<destination>' --no-graph -T 'commit_id.short() ++ " " ++ description.first_line() ++ "\n"'
# oldest line printed = the fork point
jj rebase -s <fork-point> -d <destination>
```

**Sanity check after every rebase, before moving to conflict resolution:**
the number of commits unique to `<branch>` (`jj log -r '::<branch> &
~::<destination>'`) should be the same before and after the rebase (same
descriptions, new hashes). If it dropped to fewer than before — especially
if it dropped to just the version-bump commit — you just hit the `-s`
footgun above; `jj undo` and redo with `-b`.

## Step 4 — Resolve conflicts, and drop stale version bumps even without one

A version-bump commit can go stale two different ways, and only one of them
shows up as a conflict. `jj rebase` reports textual conflicts inline and
tells you which commits and paths are affected — but the *other* case is
silent: if the branch's target version already exists in the destination by
the time you rebase, the bump commit's diff collapses to empty (jj's own log
marks it `(empty) Updating version to X.Y.Z.`) with zero conflict reported.
`jj rebase -b ... -d ...` printing a clean "Rebased N commits" does not mean
there's nothing to clean up — it means only that nothing *conflicted*. Check
for the empty case on every branch right after rebasing, before you even get
to Step 6 validation, using the bundled script (safe to run across the whole
stack in one call — pass every bookmark in the chain, bottom to top; it only
touches tips that are actually empty version-bump commits and leaves
everything else untouched):

```bash
~/.claude/skills/jj-restack/scripts/drop-empty-version-bumps.sh <branch1> <branch2> ...
```

This re-points each affected bookmark to its real content tip for you, the
same way Step 4A's conflict script requires you to after abandoning. Re-run
Step 2's ahead/behind check afterward if anything was dropped — abandoning a
commit changes hashes for every descendant above it.

Textual conflicts are handled separately, once you're past that check. Two
very different kinds show up; tell them apart before touching either:

### A) Version-bump conflicts (the common case)

Recognize these by: the conflicted commit's description matches `Updating
version to X.Y.Z.` (author is typically a CI bot, e.g. `GitLab CI
<noreply@...>`), and every conflicted path is a version manifest
(`package.json`, `package-lock.json`, or the repo's equivalent). Use the
bundled script rather than eyeballing the conflict markers — it double-checks
both conditions and refuses if anything looks like a real conflict, which is
a cheaper mistake to catch in a script than to make by hand:

```bash
~/.claude/skills/jj-restack/scripts/resolve-version-bump-conflict.sh <conflicted-revision>
```

This defaults to treating `package.json`/`package-lock.json` as the version
manifest. If the repo bumps something else instead (a `VERSION` file,
`pyproject.toml`, `Cargo.toml`, ...), pass the actual file(s) as extra
arguments — the script only abandons the commit if *every* conflicted path is
one you told it is safe.

Abandoning the commit may delete its bookmark entirely if it had no other
descendants (jj drops bookmarks that no longer point anywhere meaningful).
Re-point it at the real content tip:

```bash
jj bookmark set <branch-name> -r <new-tip-commit>
```

### B) Real conflicts

If the conflict touches actual source files, don't force a resolution —
understand what each side actually intends first:

1. `jj new <conflicted-commit>` to materialize the conflict markers into the
   working copy where you can edit them directly.
2. Read `jj file show -r <destination> -- <path>` to see what the
   *destination* branch's clean, non-conflicted version of the file already
   looks like. This matters especially when the destination branch has
   refactored, moved, or deleted things the original commit touched — e.g. if
   a later commit consolidated duplicate files into a shared location, the
   destination may have already deleted the file your conflicted commit is
   trying to edit. In that case the fix isn't to resurrect the old file; it's
   to reapply the *same edit's intent* wherever that logic now actually lives.
3. Recover the original commit's clean, intended diff for context — if the
   rebase already conflicted, the commit's materialized content is conflict
   markers, not its real diff. jj keeps the pre-rebase revision reachable by
   commit id (shown in the conflict markers themselves, e.g. "(rebased
   revision)"), so `jj diff -r <that-commit-id> -- <path>` gets you the real,
   un-conflicted change to reapply by hand. If the branch went through more
   than one rebase (e.g. you rebased onto `master` and then onto a parent
   branch), the id shown may itself be an intermediate, already-conflicted
   state rather than the true original — `jj obslog -r <commit-id>` shows the
   full history of a change across rebases so you can find the last clean one.
4. Edit the file(s) to the resolved state, matching the destination's current
   reality plus the original commit's intent. Delete files the destination
   legitimately removed rather than keeping stale duplicates around.
5. `jj squash -m "<original commit's message>"` to fold the resolution back
   into the conflicted commit. Passing `-m` explicitly avoids `jj squash`
   dropping you into an interactive editor to combine descriptions (which
   hangs in a non-interactive environment) — reuse the original commit's
   message since the squash is just completing that same commit's rebase,
   not adding new content.
6. Re-run `jj log -r <branch>` and confirm the `(conflict)` marker is gone.

## Step 5 — Bookmark divergence

Two situations that look alarming but are routine:

**A bookmark shows `(conflicted)` with multiple candidate revisions** after
abandoning a version-bump commit and fetching — this usually means the local
change-id has a stale, now-superseded revision alongside your resolved one.
Check with `jj log -r 'change_id(<bookmark-name>)'`; if one revision is
clearly superseded by the other (same description, older), abandon the stale
one, then set the bookmark explicitly:

```bash
jj abandon <stale-commit-id>
jj bookmark set <branch-name> -r <good-commit-id>
```

## Step 6 — Validate

Before pushing anything, validate each branch's tip individually — a stacked
MR still needs to pass on its own, not just as part of the combined diff:

```bash
jj new <branch-tip> -m temp-validate
npm run validate   # or whatever this repo's CLAUDE.md specifies
jj abandon @
```

If validation fails, figure out whether it's a genuine problem with the
rebase (something didn't merge as cleanly as the conflict resolution assumed)
versus something pre-existing and unrelated. Don't push a branch that fails
its own validation just to move on to the next one.

One failure mode worth specifically watching for: the rebase reports *no*
conflicts, but validation (lint/typecheck/test) fails anyway, because the
destination branch added new code that uses a pattern your branch's commit
is in the middle of changing everywhere else — e.g. your commit changes a
function's return type and updates every call site that existed when it was
written, but the destination added one more call site afterward that never
got the same treatment. jj won't flag this as a conflict because the edits
don't touch the same lines; it only shows up as a lint/type/test failure
after the fact.

To tell this apart from a pre-existing, unrelated failure: find the original
pre-rebase revision (`jj obslog -r <branch>` if it's already been rebased
once, or the commit id from before you started) and check whether its diff
already had the same shape at the failing location
(`jj diff -r <original-commit-id> -- <path>`). If the pre-rebase diff is
clean there, the failure is new and rebase-induced — fix it to match the
exact pattern the commit already applies at its other call sites (grep the
same file/commit for how it handled the others), then `jj squash --into
<branch> -m "<original commit's message>"` to fold the fix into the same
commit rather than leaving it as a separate one, and re-validate. If the
pre-rebase diff already had the same shape, it's pre-existing and out of
scope — report it, don't fix it as a side effect of the restack.

## Step 7 — Push

```bash
jj git push -b <branch1> -b <branch2> ...
```

Pushing rewrites a shared remote branch — confirm with the user first unless
they've already given a clear go-ahead for the whole stack (e.g. "let's fix
up this whole chain" covers all the pushes that follow from it; you don't
need to re-ask before each one).

If you dropped a stale version-bump commit in Step 4, `jj git push` will
print `[move backward from ... to ...]` for that bookmark instead of the
usual `[move sideways ...]` — that's expected (the new tip is an ancestor of
what's on the remote, since you removed a commit rather than replacing it)
and `jj git push` does it without needing a force flag. Don't mistake it for
the "unexpectedly moved on the remote" case below, which is the opposite
direction (the remote moved out from under you, not the other way around).

**"The following references unexpectedly moved on the remote"** — this is
CI doing exactly what it's supposed to: it added a fresh version-bump commit
to the branch after your last push (or another commit landed there some other
way). It is not a real problem, but you can't push through it blind:

```bash
jj git fetch
jj bookmark list <branch-name>     # see what changed and how
```

If the divergence is just CI's new version-bump commit sitting where your
resolved commit used to be, this is the same situation as Step 5 — abandon
whichever local revision is now superseded, re-point the bookmark at your
correct commit, and push again:

```bash
jj bookmark set <branch-name> -r <good-commit-id>
jj git push -b <branch-name>
```

## Step 8 — Watch the pipeline, don't hand-roll a poll loop

After pushing, CI kicks off a new pipeline. Don't write an ad-hoc
`for i in 1..N; do sleep 5; glab api ...; done` — use the bundled script,
which polls until the pipeline hits a terminal state and only prints on
status changes:

```bash
~/.claude/skills/jj-restack/scripts/watch-pipeline.sh <mr-iid>
```

This can run for several minutes, longer than the Bash tool's default
foreground timeout — run it with `run_in_background: true` and use the
Monitor tool (or just wait for the background-task notification) rather than
polling it yourself in a loop. Exit 0 means success; exit 1 means the
pipeline failed (go look at why before reporting the restack as done); exit 2
means it timed out (check manually — don't assume either outcome).

## Step 9 — Re-verify before declaring done

Don't report an MR as caught up just because the push succeeded. Re-run the
same "commits behind" check from Step 2 against the *current* remote state:

```bash
jj git fetch
jj log -r '::master@origin & ~::<branch>'   # should now be empty for a branch rebased directly onto master — @origin, not the bare name
```

If this is non-empty, the branch is still behind — something landed on the
target after your fetch-rebase-push cycle started, or the push didn't move
what you expected. Do not report the restack finished until this actually
shows 0; if it doesn't, loop back to Step 2 rather than reporting partial
progress as done. This matters most for stacks: verify every branch in the
chain individually, not just the last one you touched.

Cross-check against GitLab's own number too, not just your local repo's
view of it — `glab api "projects/:id/merge_requests/<iid>" -F json` includes
a `diverged_commits_count` field, and it should read `0`. Your local jj
comparison and GitLab's number are computed from two different clones; if
they agree, that's real confirmation, not just self-consistency.

## Step 10 — Report back

For each MR in the chain: link, what it was behind before (in commits) and
after (confirmed 0 via Step 9, relative to its direct target), and call out
anything you had to hand-resolve as a real conflict versus what you dropped
as a stale version bump. If you dropped any version-bump commits, mention
that CI will push a fresh one on this push — that's expected, not something
to fix.

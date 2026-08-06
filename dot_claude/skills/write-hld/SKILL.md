---
name: write-hld
description: Turn a settled set of design decisions into a finished, high-level design document (HLD) — or a similar long-form structured doc like an RFC or spec — drafted one section at a time, with the user reviewing and redlining each section before it's written, and each written section checkpointed in version control before the next begins. Use whenever the user wants to "write the real HLD now," "draft this design doc section by section," says "we're done grilling, let's write it up," asks to turn a decision outline or set of notes into an actual document, or references an HLD/RFC/design doc/spec they want produced. Also trigger on "write an Itential HLD" or anything implying Itential's official HLD template applies — this skill has that template cached. Do not use this for quick edits to an existing short doc, a README, or any writing task where the user isn't producing a structured, multi-section design document from a body of decisions.
---

# Writing an HLD (or similar long-form design document)

This skill turns a pile of already-settled decisions into a finished document that a stranger could
read cold. It assumes the *hard thinking* — the decisions, the trade-offs, the "why" — has already
happened, usually via the **grilling** skill (interview the user, settle a decision tree) or a prior
conversation. This skill's job is the second half: getting those decisions onto the page, at the
right altitude, in the right structure, reviewed a piece at a time, with nothing lost if the session
ends partway through.

If decisions *haven't* been settled yet — the user wants to figure out what to decide, not how to
write it up — hand off to **grilling** first, or grill inline, before drafting anything. If a design
choice inside a section needs outside validation (which platform to pick, what best practice says),
that's a job for the **research** skill, run as a background agent so drafting doesn't stall on it.

## The workflow

### 1. Establish the template

Figure out what kind of document this is and what structure it must follow.

- **If it's an Itential HLD** (or the user doesn't specify a template and Itential's process
  clearly applies), use the cached template in `references/itential-hld-template.md` — read it now.
  It's a faithful copy of Itential's official HLD template (Confluence, space PO), cached so this
  doesn't need a live fetch every time. If a lot of time has passed since that file's cache date, or
  something about it feels stale, re-fetch the live Confluence page and refresh the cached copy
  rather than trusting it forever.
- **If the user has a different template or house style**, use that instead — ask for it if it
  isn't already in the conversation.
- **If there's no template at all**, ask the user, or propose a sensible generic structure (problem
  → background → options considered → chosen approach → risks → rollout) and confirm it before
  proceeding. Don't invent structure silently for a document this consequential.

The same workflow below applies to a companion low-level design (LLD), an RFC, or any structured
spec — the template changes, the drafting discipline doesn't.

### 2. Build the section plan

Before writing a word of prose, map the settled decisions onto the template's required sections and
write that map down as its own file (e.g. `<doc-name>-section-plan.md`, sitting alongside the real
document). This is where structural questions get resolved once, instead of being re-litigated
mid-draft: which section does each decision land in, what gets pushed to an appendix or a companion
document instead of the main body, what order the sections draft in.

Show the user this plan and get their sign-off before drafting starts. It's cheap to reorganize a
bullet list; it's expensive to reorganize four already-written sections. The section plan is also
what makes a resumed session (or a different person) able to pick the work back up without
re-deriving the structure from scratch.

While building the plan, you'll sometimes find a section that needs content no settled decision
covers, or two settled decisions that don't quite reconcile. Don't paper over either one — invented
specifics and silently-resolved contradictions are exactly the kind of thing that looks fine in the
moment and turns out wrong in a document people will act on. Flag the gap or the conflict as an open
item in the plan and get it resolved (or explicitly deferred, named as such) before drafting starts,
the same way you'd treat any other unsettled decision.

Once the user signs off on the plan, checkpoint it — commit the section-plan file on its own,
before drafting the first section. It's a reviewed artifact like any section of the document itself,
and it's what lets a resumed session trust the plan instead of re-deriving it. Use the same
detect-the-VCS-and-commit discipline described in step 4, just applied to this one file first.

### 3. Draft one section at a time

For each section, in the order the plan sets out:

1. **Write the full prose** for that section only and present it in the conversation. Don't write
   it into the target file yet, and don't draft ahead into later sections — the user needs to react
   to what's on the page now, and later sections may need to change based on that reaction.
2. **Wait for redline feedback.** Treat every response as real feedback to incorporate, not a
   rubber stamp to get past. A section that needs another pass is normal; keep revising it in the
   conversation until the user is satisfied.
3. **Only once approved, write it into the target file.**
4. **Checkpoint it before moving on** (step 4, below) — then return to step 1 for the next section.

Never present two sections at once, and never write an unapproved section into the file. The point
of going section-by-section is that each piece gets real scrutiny; batching defeats that.

### 4. Checkpoint each section before starting the next

Once a section is written into the file, commit it as its own, scoped version-control checkpoint
before drafting the next one. This means every commit/change in the history corresponds to exactly
one reviewed section — easy to navigate, easy to resume, and nothing is ever lost to a crash or a
context reset mid-draft.

- Detect whether the repo uses `jj` or `git` (or another VCS) the way you normally would for any
  VCS operation in this environment — don't assume.
- **jj:** describe the current change with a message naming the section just added, then start a
  fresh empty change (`jj new`) before drafting the next section, so the next section's edit can't
  land in the same change as this one.
- **git:** stage and commit just the section's edit with a descriptive message before drafting the
  next section.
- **No VCS at all** (e.g. drafting straight into a Confluence page or a Google Doc): there's no
  checkpoint to make, but keep the same discipline — confirm each section is genuinely final before
  moving to the next, since there's no cheap way to isolate a later revert. Without commits, there's
  also no record for a resumed session (or a different person) to check what's approved versus still
  draft — so carry that status in the document itself: a status line at the top of the section plan
  and the target document (e.g. "Draft — sections 1-2 approved, section 3 in review") that you update
  as sections land. The file's own content becomes the durable record that a commit history would
  otherwise provide.

If you ever notice a change already contains more than one section's edits (for instance, because a
fresh change wasn't opened after the last checkpoint), stop and split it into one change per section
before continuing — don't let it compound. Bundling sections together is the single easiest mistake
to make in this workflow and the easiest to avoid by just checking before you draft the next one.

### 5. Write as if the reader has zero visibility into how this was produced

This is the rule most worth internalizing, because it's easy to violate by accident and it's the
kind of mistake that's obvious to a reader but invisible to the writer who lived through the process.

A finished HLD (or RFC, or spec) is read by people who were never in the room: an executive skimming
the summary, an engineer picking up the project a year later, a reviewer who's never heard of the
POC or the research notes or the whiteboard session that led here. Every one of them needs the
document to be **self-contained**. That means never referencing:

- a proof-of-concept or prototype that was built to *validate* a decision, unless the POC itself is
  part of the actual system being proposed (in which case describe what it does, not that it was a
  "POC" you built along the way);
- earlier drafts, internal research notes, or scratch documents used to reach a conclusion — fold
  the conclusion into the document; don't cite the homework;
- the methodology or tooling used to produce an artifact in the document — e.g. a diagram should
  just be a diagram; don't tell the reader "this follows the C4 model" or "we used tool X to
  generate this." Show the content, not the process that made it.

The test: could someone with zero knowledge of this conversation, this repo, or any companion
document read this section and understand it completely? If a sentence only makes sense to someone
who was there, rewrite it.

**Altitude matters the same way.** Early on — ideally while building the section plan — pin down who
this document is for (an HLD is usually general-technical, readable by someone unfamiliar with the
specific subsystem; an LLD is for the engineers who'll build it). Hold every section to that
altitude. When something wants to go deeper than the intended reader needs, that's a signal to push
it to a companion document (an LLD, a deployment doc, an appendix) and *reference* it rather than
inline it — the same way the Proposed Solution section stays high-level while implementation detail
moves to the LLD.

### 6. Wrap up

Once every section is drafted, approved, and checkpointed, the document is functionally done — but
give it one more pass before calling it finished:

- **A full read-through for flow and consistency** — sections drafted independently, possibly days
  apart, can drift in tone or repeat themselves; read it start to finish once as a whole and fix
  anything that doesn't hold together.
- **Run the `humanize-writing` skill on the finished document.** Every section up to this point was
  drafted one piece at a time, reviewed for content and accuracy — not for how it reads end to end,
  and drafted prose defaults to a certain stiffness that's easy to stop noticing after you've been
  staring at it section by section. `humanize-writing` is built specifically for this: it de-stiffens
  dry technical documents like this one without hollowing out the content, and it has its own review
  loop for anything ambiguous, so it's safer than an ad-hoc rewrite for a document this consequential.
  Treat this as a default last step, not an optional suggestion — invoke it once the document is
  complete, the same way you'd run a linter before calling code finished. If the user would rather
  skip it for a given document, that's their call, but don't let it go unmentioned.

## Reference

- `references/itential-hld-template.md` — Itential's official HLD template, cached from Confluence.
  Read it in step 1 whenever the target document is an Itential HLD (or nothing else applies).

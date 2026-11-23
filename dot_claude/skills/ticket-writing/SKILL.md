---
name: ticket-writing
description: Write, groom, flesh out, or update a Jira/engineering ticket's description and acceptance criteria — including when responding to an automated ticket-reviewer bot's feedback or open questions on a ticket. Use this whenever the user asks to groom a ticket, write up a story/ticket, flesh out acceptance criteria, tighten up a ticket before a sprint, or update a ticket after review feedback (a "Ticket Reviewer" comment, a PM/QA request for more detail, a ticket bounced back to Open, etc.) — even if they just paste a ticket URL or key and say something like "clean this up" or "this got sent back to me, can you fix it."
---

# Ticket Writing

A ticket has two audiences who need almost opposite things from it: a human deciding whether the work is well-scoped and worth doing, and whoever — human or agent — actually implements it. A ticket that serves only the second audience reads as an impenetrable wall of file paths to the person trying to groom it. A ticket that serves only the first is useless to whoever has to build the thing. The structure below exists to serve both without making either wade through the other's section.

The other theme running through all of this: don't write anything technical you haven't checked. A ticket full of confident, specific-sounding claims that turn out to be wrong is worse than one that's vague, because it actively misleads whoever implements it.

## The description: progressive disclosure

Structure the description in this order, and skip a section outright if it has nothing real to say — a forced "Background" that just restates the summary is worse than no section at all.

**`## Summary`** — always include this. One short paragraph, in plain language, answering "what are we asking for?" for someone who is deciding whether to prioritize or approve this ticket, not for the person who'll build it. No file paths, no function names, no code in this section — if you find yourself wanting to name a file here, that content belongs in Implementation details instead.

**`## Background`** — optional. Include it only when there's a real "why": a constraint being worked around, a cross-team dependency, the reason an unusual approach was chosen over an obvious one. If the summary already fully explains the motivation, or the ticket is a simple, self-evident task, leave this section out entirely rather than padding it.

**`## Implementation details`** — the lower-level content: exact file paths, function/type names, the mechanism to use, explicit scope boundaries, edge cases, test expectations. Written for whoever implements the ticket. This is where the research you did (see below) shows up as concrete, checkable claims.

## Acceptance criteria must be checkable, not prose

Each AC bullet should be a concrete, verifiable completion condition — a specific behavior, a specific test, a specific system state — never a bullet-formatted restatement of the description. "The feature works as described" is not an acceptance criterion; "a request missing the required field returns a 400 with a specific error code" is.

Calibrate how much AC a ticket needs against its neighbors. Before finalizing AC, check the tickets this one blocks or is blocked by (same epic, same feature) — if siblings carry 8–10 detailed bullets with an explicit test list and this one has a single vague bullet, that's a real gap, not a style difference. Match the bar the team is already holding elsewhere, don't invent a lighter one for this ticket alone.

## Verify before you claim

Before writing an AC bullet or a description sentence that makes a factual claim about the codebase, go check it — don't answer from assumption, memory, or "this is usually how it works." Concretely:

- Grep and read the actual source for the behavior you're about to describe (how config loads, what a function actually returns, whether a mechanism already exists).
- Look for existing precedent before proposing something new — see the next section.
- When the claim is about how a library or framework behaves and you're not certain, test it empirically (write and run a two-line script) rather than trusting training data. A library's behavior in a minor version can differ from what you remember, and a wrong claim in a ticket propagates into the implementation.
- For anything non-trivial, delegate the investigation to a research subagent so the exploration noise doesn't clutter the main conversation — bring back findings, not transcripts.

This matters most when you're resolving open questions left by an automated ticket-reviewer or a human reviewer's comment: answer those with facts you just checked, not with your best guess at what's probably true.

## Prefer the codebase's existing idioms over a new mechanism

When a ticket needs some capability that doesn't obviously exist yet, ask "does this codebase already have a pattern for this kind of problem?" before inventing one. Grep for similarly-shaped utilities, naming conventions, or annotation/metadata patterns nearby — a sibling module or script that already solved an adjacent problem. Reusing or extending that pattern is almost always better than a bespoke one-off (a hardcoded list, a special-cased branch) because it generalizes to the next case for free and reads as consistent with the rest of the codebase to the next person who touches it.

## State explicit scope boundaries

When a ticket is one of a family of related tickets (blocks / is blocked by / same epic), say in Implementation details what this ticket does *not* do — especially anywhere an implementing agent could plausibly wander into a sibling ticket's territory. "This ticket adds the schema field and a single read point; it does not implement the gating checks — `ENG-XXXX` owns that, and it isn't implemented yet" prevents wasted work and scope creep in both directions.

## Surface real decisions; don't invent answers to judgment calls

Some open questions have a technical answer you can just go find (see "Verify before you claim"). Others are genuine judgment calls — a product tradeoff, a naming preference, an acceptable-risk decision — that only the human can make. Tell these apart:

- If research shows the answer is factually forced ("there's no existing mechanism for X, and building one would violate the ticket's own stated constraint"), present that finding and your resulting recommendation concisely. Don't dress up a forced conclusion as an open question.
- If it's a real judgment call with no clear technical answer, ask — but don't over-ask. Bundle it into one clear question with your recommendation as the first option, rather than a running series of small asks.
- If the human answers with a direct instruction instead of picking from your framing, take the instruction and move on. Don't insist on re-litigating in the original question's shape.

## Put operationally-relevant facts in the ticket, not just your notes

If something you learned while researching changes how the work should be verified or rolled out, it belongs in the ticket text, not just in your own scratch reasoning. A fact like "this value is only re-read on restart, not live" or "this runs in a background job, not inline with the request" is exactly the kind of thing that determines how someone tests the change in production — write it down.

## Always cite exact references

File paths, function/type names, and line numbers, wherever you know them — in both the description and the AC. Naming the exact file and symbol you already found is useful; a vague pointer like "the config schema" sends the implementer hunting for something you already located. Use inline code formatting (backticks) for identifiers, file paths, and ticket keys throughout.

## Name cleanup affordances for temporary code

When a ticket introduces a shim, flag, or other code with a known expiration (a follow-up ticket removes it later), call out in Implementation details how to keep its footprint mechanically removable — e.g. "keep the gating checks behind one named, greppable helper so `ENG-YYYY` (the removal ticket) is a mechanical deletion, not an archaeology exercise." This costs a sentence now and saves real time on the removal ticket.

## Review before you write to Jira

Draft the description and AC as plain text/markdown and show them to the human before writing anything into the actual ticket. Ticket edits are visible, shared state — other people and any reviewer bots watching the ticket see them — so don't push a draft you haven't gotten a read on, unless the human has already explicitly told you to just go ahead and write it.

## Jira mechanics

Jira's API has a couple of sharp edges worth knowing before you edit fields — see `references/jira-adf-fields.md` for the concrete gotcha (markdown works for `description` but not for most custom fields, which need raw Atlassian Document Format) and a ready-to-adapt ADF template for a bulleted, inline-code-annotated acceptance-criteria field.

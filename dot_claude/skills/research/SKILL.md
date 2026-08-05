---
name: research
description: Spin out a background research agent to find how a problem has already been solved — literature, books, named patterns, prior art in mature systems, expert opinions, industry best practices — and capture the findings in a cited Markdown doc in the repo so it never needs re-researching. Use whenever the user asks what the literature/experts/prior art say, asks "is this standard practice?", says something is "likely a solved problem" or they "don't want to reinvent the wheel", asks to "spin out a research subagent/agent", asks "what do UX/security/event-sourcing/etc. experts say", or — even unprompted — whenever a non-trivial design decision is about to be made on gut feel in a space where established practice almost certainly exists. When one of these asks appears, use this skill rather than answering from general knowledge, even if the question looks directly answerable — the point is cited, persisted findings, not a from-memory summary.
---

# Prior-art research

The operating premise: **many smart people have likely solved this exact problem before.** The job is not to invent an answer — it is to find the existing, battle-tested answers, weigh them against this project's constraints, and stand on their shoulders instead of reinventing the wheel. A design element that maps to a documented, named pattern with a canonical reference is load-bearing; one that maps to nothing is either genuinely novel (rare, and worth flagging as a risk) or a reinvention (common, and worth replacing).

## How to run it

Spawn a **background research agent** (general-purpose subagent) so the main conversation keeps moving — the user often continues designing or asks the next question while research runs. Report the findings back into the conversation when the agent finishes, and apply them to the live decision.

If the question has several genuinely separable sub-questions, it is fine to give one agent a multi-part brief; only split into parallel agents when the source territories don't overlap.

## The research brief

Prompt the agent with all of the following. The quality of the brief determines the quality of the research — a vague "research best practices for X" yields blog-post mush; a sharp brief yields named patterns and verdicts.

1. **The decision, stated neutrally.** What is being decided, the concrete context (system, constraints, scale), and every option already on the table. If the team currently leans one way, say so but mark it as a leaning — the agent's job is **unbiased** comparison, steelmanning each option, not confirming the favorite. An answer of "your leaning is wrong, here's what the field does instead" is a success, not a failure.

2. **The house constraints to weigh against.** The project's own design principles, architecture rules, or stated goals that any recommendation must be compatible with — wherever the project records them (development docs, CLAUDE.md, ADRs, a written constitution). Prior art that violates a house non-negotiable should be reported as such, not silently recommended.

3. **Where to look — sweep every source class that applies:**
   - **Canonical literature and books** — the recognized texts of whatever field the problem lives in (the EIP / DDIA / Vernon / Nielsen tier, whatever applies).
   - **Named patterns** — documented patterns with names, from the pattern authors' own sites/docs.
   - **Expert practitioners** — published opinions of people who have built and operated similar systems, from their own writing.
   - **Mature systems that faced this exact problem** — find the directly comparable products and read their **actual source code**, not their marketing (e.g. "how does Sonarr track download clients" beats any blog post about polling).
   - **Adjacent domains with the same problem shape** — the same problem often has independent solutions in other fields (queueing, actor supervision, control loops, CRDTs, …); convergence across unrelated domains is the strongest evidence there is.

4. **Primary sources only, every claim cited.** Follow every claim back to the source that owns it — official docs, source code, specs, the author's own site. Mark anything only verifiable second-hand as **[secondary]**, and say when a source was unreachable rather than paraphrasing it from memory.

5. **The deliverable:** the findings document (below) plus a **verdict applied back to the live decision** — not a literature survey that ends where the interesting part begins.

## What good output looks like

- **Every design element maps to a named pattern with a canonical reference** — or is explicitly flagged as unattested. "Nothing here is exotic; every element has a name" and "this part exists nowhere in the field" are both valuable findings.
- **Convergence and divergence are called out.** "Unanimous across five independent primary sources" settles a question; "the field splits, and here is the axis it splits on" reframes one.
- **A verdict**: keep / change / choose option N, which parts of the current design are attested where, plus the pitfall checklist and action items the sources warn about.
- **Honesty about thin coverage.** If prior art is sparse or the problem really is novel, say so — don't pad with tangents.

## Persist the findings

Write the findings to a Markdown file in the repo so no future session has to re-research this. If the repo already keeps research notes somewhere, that convention wins — match its location and shape. Otherwise default to `docs/research/<question-slug>.md`, and say in the conversation where the doc landed. Give the doc this shape (deferring to the house shape where existing research docs differ):

- Title is the question; open with **Question** and **Method** (what source classes were swept, the citation policy).
- Date the research and its URL accesses — findings age.
- Cite each claim inline with a link to the owning source; collect sources at the end.
- Cross-reference sibling research docs instead of re-arguing what they already established.
- Note that findings are input to a decision, not normative until adopted through whatever decision process the repo uses (a spec change, an ADR, a PR).

Before spawning the agent, check the research-notes directory for existing coverage — and check it properly, not by eyeballing filenames. Grep the existing docs for the question's key terms and skim their headings and action items: **adjacent coverage counts**. A doc on a neighboring question often already establishes part of the answer (a retry-policy question may be half-answered by an observation-architecture doc's action items). Point the agent at every doc whose territory borders the question so the new doc extends and cross-references it instead of re-arguing it.

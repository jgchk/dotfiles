# Itential's HLD Template (cached)

**Source:** [Confluence: High Level Design Documents](https://itential.atlassian.net/wiki/spaces/PO/pages/4426301457/High+Level+Design+Documents) (space PO)
**Source last modified (as fetched):** Dec 15, 2025
**Cached into this skill:** 2026-08-05

> This is a cached copy so drafting sessions don't need to re-fetch Confluence every time.
> Itential's process/template pages change occasionally — if a lot of time has passed since the
> cache date above, or something in a draft feels off against this template, re-fetch the live page
> and update this file rather than trusting a stale cache indefinitely.

## Purpose of HLDs

The purpose of a high level design (HLD) document is to capture the design decisions that will be
required for executing the work to build a product, service or feature. An HLD covers:

- background of how the system operates today
- a clear problem statement that requires a solution
- discussion of possible solutions to the problem
- a conclusive proposed solution with a defense of why it is the best option against both the
  problem statement and the other possible solutions
- a plan for the execution of the design
- supporting appendices

HLDs are intended to provide enough detail so that an implementation can be done based on it by any
level of engineer within the engineering staff. **It does not go down to the level of code** unless
there is a specific proposed algorithm that is part of the solution.

Other open questions can be referenced via other documents or appendices. If decisions exist from
other documents or appendices they can be referenced where needed within the document.

## Template structure

Each top-level section is an `H2` (the page title is the document's `H1`). Sections marked
*(optional)* can be omitted when they don't add value — see the guidance under each.

### Executive Summary (H2)

A high-level overview of the project/product (can be copied directly from a BRD or vision document
if one exists), including:

- Summary of the technical problem being solved by this document.
- High-level mention of what is in scope versus out of scope.
- Relevant material via links to higher-level or related documents (BRDs, vision documents, etc.) —
  these also get added to a Related Materials appendix at the end of the document.

### Background (H2)

An overview of any relevant background information — project history as well as current
implementation details that will help the reader understand the problem statement in context.

### Problem Statement (H2)

A detailed description of the problem being solved or the questions being answered. This is where
the requirements to be met are discussed, along with technical challenges. It includes:

- Assumptions or constraints that impact the system design.
- Identified limitations, dependencies, or architectural decisions based on specific constraints or
  requirements.
- Discussion of the scope of the problem — what is in or out of scope, specifically.
- Any technical dependencies that fall outside the scope of the team that owns execution of the
  design.

The possible and proposed solutions refer back to these problems to measure pros and cons and
justify the proposed decisions.

### Possible Solutions (H2) — *(optional)*

Each possible solution is a subheading at `H3`, with a full narrative including its pros and cons.
This section is optional only if the HLD isn't answering a question with multiple possible
solutions and is instead outlining one specific implementation — in that case, make it obvious in
the Proposed Solution section that no other solution was viable.

### Proposed Solution (H2)

- Evaluation of pros/cons for each solution proposed — can be a decision matrix or narrative prose.
- Diagram of the component architecture.
- Narrative description of why this design was chosen and how it addresses the problems described
  in the Problem Statement.
- **New Technology** *(optional)* — justification for any new technology being introduced,
  including its costs and benefits and how it solves a problem identified in the Problem Statement.
- **Security** — any security considerations this project introduces and how the risk will be
  mitigated. Depending on the risk, a threat model might be appropriate here.

### Implementation Plan (H2)

Breaks the proposed solution down into an implementation plan that supports continuous integration
with the code repository, either via additive abstractions defined first and/or feature toggles that
allow code changes to be released while not yet in use. Includes:

- **Failure Modes** — possible failure conditions for the architecture, including normal exception
  cases as well as concerns around availability and scalability.
- **Monitoring and alerting.**
- **Testing Plan.**

### Appendices A–Z (H2) — *(optional)*

Related work materials are typically referenced in an HLD — if so, there is at least one appendix
for related materials. Appendices each get an associated letter and a title, e.g. "Appendix A:
Related Materials." Other appendices can include:

- Supplementary technical information — typically added as an appendix when no other document
  exists and it doesn't need the full depth of another HLD or document.
- Hotly debated topics (HDT) with proposed answers, for reference in the larger document.
- FAQ (question & answer).

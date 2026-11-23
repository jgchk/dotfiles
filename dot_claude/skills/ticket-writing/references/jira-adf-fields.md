# Jira field formats: markdown vs. ADF

Jira Cloud's issue fields don't all accept the same content format, and the failure mode when you get it wrong is easy to misdiagnose.

## What actually happens

- The main `description` field (and comments) accept a markdown string when you pass `contentFormat: "markdown"` to an edit/comment call — it gets converted to Atlassian Document Format (ADF) server-side.
- Many custom fields — including a "textarea"-typed custom field like an "Acceptance Criteria" field — reject a markdown string outright. The API error looks like:

  ```
  "Operation value must be an Atlassian Document (see the Atlassian Document Format)"
  ```

  This means the field's underlying type stores rich text as ADF and there is no markdown-to-ADF conversion path for it via this call — you must hand-build and pass the ADF JSON object directly as the field value.

- **A single edit call with multiple fields fails atomically.** If one field in the request has the wrong format, *none* of the fields in that call get saved — not just the bad one. Symptom: you get an error, then re-fetch the issue and find your good field (e.g. `description`) wasn't updated either, even though the error only mentioned the other field.

**Practical approach:** when you don't already know a custom field's expected shape, split the edit into separate calls per field — one call for markdown-accepting fields (`description`, comments), a separate call for fields that need raw ADF. That way a format mismatch on one field doesn't silently roll back a field you got right.

## Building ADF by hand

An ADF document is a tree: `doc` → block nodes (`bulletList`, `orderedList`, `paragraph`, `heading`, `rule`, ...) → inline nodes (`text`, with optional `marks` like `code`, `strong`, `em`, `link`). For a bulleted acceptance-criteria field with inline code spans, the shape is:

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                { "type": "text", "text": "retryCount", "marks": [{ "type": "code" }] },
                { "type": "text", "text": " defaults to " },
                { "type": "text", "text": "3", "marks": [{ "type": "code" }] },
                { "type": "text", "text": " when omitted from the request payload." }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

Notes:

- Each bullet is a `listItem` containing one (or more) `paragraph` nodes — not a bare string.
- Every run of inline code gets its own `text` node with `marks: [{ "type": "code" }]`; plain prose is a separate `text` node with no `marks` key at all (omit it rather than passing an empty array).
- You don't need to supply `localId` attributes — Jira will generate them; existing content you read back from the API will have them, but you don't need to reproduce that when writing.
- For a heading (e.g. a "Suggested AC" section inside a comment), use `{ "type": "heading", "attrs": { "level": 3 }, "content": [...] }` with the same inline-text-node shape inside.
- `orderedList` mirrors `bulletList` (add `"attrs": { "order": 1 }` on the list node).

If a field's expected shape is unclear, fetch the current issue with that field included in the response first — the existing value (even if it's a single unremarkable bullet) shows you the exact ADF shape that field's renderer expects, which is more reliable than guessing from the general ADF spec.

## Itential site facts (verified 2026-11-23, project `ENG`)

- cloudId `2ece816a-62e4-4222-8518-b5507d198470` (itential.atlassian.net).
- **Acceptance Criteria** is a separate field, `customfield_11909` (string, optional, needs ADF), on Story, Sub-task, Bug, Chore and Epic. Put AC there, not in `description`. Not checked: Security, Change request, Objective, Defect, COE, COE-Action, Approved CR, and any other project.
- **Team Ownership** `customfield_11900` is required on create for Story, Bug and Chore (optional on Sub-task). "AI Builder Tools" = option id `33977`.
- Story optionals: Release Note `customfield_10900`, Change in Functionality `customfield_19237`, Target Release `customfield_11994`, Story Points `customfield_10005`. Components has no playtime entry; leave empty.
- Bug also requires Steps to Reproduce `11867`, Actual Result `11868`, Expected Result `11869`, Business Impact `12290`.
- Re-check with `getJiraIssueTypeMetaWithFields` (`requiredFieldsOnly: false`) only for a type or project not listed here. Its output is huge (version lists), so don't run it per ticket.

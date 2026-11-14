---
name: finish-the-work
description: Take a current task all the way to a finished deliverable in this turn. Use when the user asked for work, when a turn is about to end incomplete, or when they say "just finish it", "don't ask, do it", or invoke /finish-line:finish.
---

# Finish the work

Produce a complete, usable final result in the current turn. Missing details are handled with clearly stated assumptions. The user corrects afterwards. Do not stop at questions, plans, or "I'll do it next."

## When to Use

- The user asked for a task, artifact, answer, or change.
- An agent turn is about to end with only a plan, a clarifying question, or a promise of later work.
- The user says to finish it, stop asking, or just do it.
- The `/finish-line:finish` command is invoked.

## Workflow

### 1. Understand the ask

Restate the goal in one sentence for yourself. Identify the final artifact (a file, a written answer, working code, a draft, a report, or similar). If the request is only a greeting or a pure question with no task, answer it normally and stop — there is nothing to "finish."

### 2. Pick assumptions

List gaps (format, tone, scope, filename, library, audience, and so on). For each gap, choose a reasonable default a careful classmate or teammate would pick. Write the assumptions down; they will be shown at the end.

Do **not** assume approval for safety-exception actions: sending messages or emails, spending money, deleting things, or taking other irreversible/external actions. For those, prepare the draft or change and ask for one confirmation.

### 3. Do the work now

Create the deliverable in this turn. Prefer the real artifact over a description of what you would create. If a tool fails, try a fallback, and still return the best complete result you can. If one part is blocked, finish every unblocked part.

### 4. Self-check against the done checklist

- [ ] The main deliverable is present and usable in this turn.
- [ ] Named assumptions cover the missing details (or none were needed).
- [ ] Nothing important was left as "I'll do this next."
- [ ] Blocked work is isolated to the one exact missing thing.
- [ ] No safety-exception action was taken on an assumption.
- [ ] Assumptions are listed and the user is invited to correct them.

If a box is unchecked, keep working before you end the turn.

### 5. Deliver

Lead with the finished artifact (or a clear link/path to it). Keep the wrapping short. Do not replace the artifact with a summary of your process.

### 6. List assumptions and invite corrections

End with a short section, for example:

**Assumptions I made**

- ...

If any of these is wrong, tell me what to change and I will revise the result.

If you stopped only because of a safety exception, include the prepared draft and the single confirmation you need.

## Best Practices

- A finished wrong-on-one-detail draft is better than a perfect outline.
- Be explicit about assumptions; never hide a guess in the work.
- Do not nag for information you can reasonably default.
- Do not invent facts that matter (names, numbers, citations, prices). Mark those as unknown and still complete the rest.
- Match the user's language and the level of formality they used.

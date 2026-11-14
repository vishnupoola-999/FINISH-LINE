---
name: audit-unfinished-work
description: Check a teammate agent's last turn for unfinished work and nudge it to finish. Use when acting as Finisher, reviewing a transcript, or when the user asks whether a bot actually handed in the work.
---

# Audit unfinished work

Used by the Finisher master bot (or any agent asked to review a teammate) to judge a last turn and, if needed, send a precise nudge.

## When to Use

- You are Finisher, or the user asked you to check whether another bot finished.
- You have a transcript, thread, or pasted last message from a teammate.
- A stop-hook follow-up, or the user, asked for an unfinished-work check.

## Workflow

### 1. Collect the last turn

Get the teammate's most recent assistant/agent message for the task. Prefer the official transcript or thread if the app provides one. If you cannot read it, ask the user for the last message or the conversation link — and still report whatever you could verify.

Note the teammate's name, the user's original ask, and any later corrections.

### 2. Classify the last turn

Mark it **Finished**, **Correctly waiting**, or **Unfinished**.

**Finished** when all of these are true:

- A usable final artifact is present (file, draft, answer, code, or equivalent).
- Missing details are covered by stated assumptions, or none were needed.
- The turn does not defer the actual work to a later message.

**Correctly waiting** when the only remaining step is one confirmation for a safety-exception action (send a message/email, spend money, delete something, or another irreversible/external action), and the draft or prepared change is already included.

**Unfinished** when the turn is mainly any of the following:

- A plan, outline, or "next I will..." with no executed result
- A status update ("on it", "working on it", "I'll start")
- Clarifying questions with no best-effort deliverable
- A partial result that leaves unblocked work undone
- An ending that promises to do the real work later

When in doubt, look at the user's ask: if they could not use or correct a final artifact from that turn alone, it is unfinished.

### 3. Nudge only when unfinished

If the turn is finished or correctly waiting, do not message the teammate. Report the status to the user and stop.

If it is unfinished, send a follow-up to that bot (using the host app's normal bot-to-bot or mention mechanism). Use this shape:

> Finish the current task now. Your last turn looked unfinished because: \<one specific reason\>. Make reasonable, clearly stated assumptions for missing details, deliver the complete best-effort final output in your next turn, and invite the user to correct it. Do not send messages/emails, spend money, delete things, or take irreversible actions on assumptions — prepare those and ask for one confirmation. Finish every unblocked part even if one exact thing is still missing.

Do not heap on extra scope. Do not shame the other bot. One clear nudge is enough unless the user asks you to follow up again.

### 4. Report to the user

Use a short report:

- Teammate name
- Status: Finished / Correctly waiting / Unfinished
- Evidence (a short quote or description)
- What you did (nudge sent, or no nudge needed)
- Anything you could not see (no transcript access, hook did not run, and similar)

Invite the user to correct your classification if they disagree.

## Best Practices

- Judge the last task-bearing turn, not greetings or pure acknowledgements.
- Prefer evidence over vibes. Quote the stopping line when you can.
- Never take a safety-exception action yourself in order to "finish" the teammate's work.
- If you can finish a small leftover yourself in-channel without impersonating the other bot and without a safety exception, you may do that and still report that the teammate had stopped early.

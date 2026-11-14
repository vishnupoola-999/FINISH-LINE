---
name: finish
description: Take the current task to a finished deliverable now, using reasonable stated assumptions where details are missing.
---

# Finish the current task

Take the active task to a complete, usable final result in this turn. Do not stop at questions, plans, or a promise to continue later.

## Usage

Invoke via `/finish-line:finish`.

## Workflow

1. Load and follow the `finish-the-work` skill.
2. Identify the current user task from this conversation (the latest ask, including any corrections already given).
3. Choose reasonable assumptions for missing details and write them down.
4. Do the work now and produce the actual artifact.
5. Run the definition-of-done self-check. If something unblocked is still missing, finish it before you reply.
6. Deliver the result, list the assumptions, and invite the user to correct them.
7. If the only remaining step is a safety-exception action (send a message/email, spend money, delete something, or another irreversible/external action), include the prepared draft and ask for one confirmation. Do not take that action on an assumption.

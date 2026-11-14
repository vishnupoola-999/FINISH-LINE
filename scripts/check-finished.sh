#!/usr/bin/env bash
# Cursor (and compatible host) stop hook for Finish Line.
# Reads stop-hook JSON on stdin. If the last turn looks unfinished, prints
# {"followup_message":"..."} so the agent is asked to continue.
# Caps automatic follow-ups with hooks.json loop_limit: 2, and again in this
# script. Hook support in Grok Bot and other non-Cursor apps is not guaranteed.
set -euo pipefail

input="$(cat || true)"

if ! command -v python3 >/dev/null 2>&1; then
  echo "finish-line stop hook: python3 not found; skipping follow-up" >&2
  printf '%s\n' '{}'
  exit 0
fi

# Prefer the plugin root when the host sets it; fall back to this script's repo.
PLUGIN_ROOT="${CURSOR_PLUGIN_ROOT:-}"
export FINISH_LINE_PLUGIN_ROOT="${PLUGIN_ROOT}"
export CURSOR_TRANSCRIPT_PATH="${CURSOR_TRANSCRIPT_PATH:-}"

# Pass hook JSON as argv[1] so the program heredoc does not consume stdin.
python3 - "$input" <<'PY'
import json
import os
import re
import sys

LOOP_LIMIT = 2

FOLLOWUP = (
    "Finish Line check: your last turn looks unfinished (it stopped at a "
    "question, plan, promise, or partial result). Finish the current task now. "
    "If details are missing, make reasonable, clearly stated assumptions and "
    "deliver the complete best-effort final output, then invite the user to "
    "correct it. Do not send messages/emails, spend money, delete things, or "
    "take irreversible actions on assumptions — prepare those and ask for one "
    "confirmation. If this turn already delivered a finished result or correctly "
    "stopped for a safety confirmation, say so briefly and stop."
)

UNFINISHED_PATTERNS = [
    r"\bon it\b",
    r"\bworking on it\b",
    r"\bi['’]?ll get started\b",
    r"\bi['’]?ll start\b",
    r"\bi['’]?ll do (it|that|this) next\b",
    r"\bi will do (it|that|this) (next|later)\b",
    r"\bin my next (message|turn|step)\b",
    r"\bnext I['’]?ll\b",
    r"\bi['’]?ll (handle|do|finish|implement|write|create|build) that (next|later|in a moment)\b",
    r"\blet me know if you('d| would) like me to\b",
    r"\bwould you like me to\b",
    r"\bshould I (proceed|continue|start|go ahead)\b",
    r"\bwant me to (proceed|continue|start|go ahead)\b",
    r"\bI can (do|start|begin) that if you('d| would) like\b",
    r"\bonce you (confirm|clarify|tell me|provide)\b",
    r"\bi need (more )?(information|details|clarification) before I can\b",
    r"\bi['’]?ll wait (for|until)\b",
    r"\bwaiting for you to\b",
    r"\bto be continued\b",
    r"\bi haven['’]t finished\b",
    r"\bhere('s| is) (a |the )?(quick |high-level )?plan\b",
    r"\bnext steps I will take\b",
    r"\bi['’]?ll begin (by|once)\b",
    r"\bcould you (clarify|confirm|provide)\b",
    r"\bplease (provide|confirm|clarify)\b",
]

# Replies that look like a real handoff even if they also invite corrections.
FINISHED_HINTS = [
    r"\bassumptions I made\b",
    r"\bif any of these is wrong\b",
    r"\binvite(d)? (you )?to correct\b",
    r"\bcorrectly waiting\b",
    r"\bone confirmation\b",
    r"\bdefinition of done\b",
]

UNFINISHED_RE = re.compile("|".join(UNFINISHED_PATTERNS), re.IGNORECASE)
FINISHED_RE = re.compile("|".join(FINISHED_HINTS), re.IGNORECASE)


def out(obj):
    sys.stdout.write(json.dumps(obj, ensure_ascii=False) + "\n")


def load_input():
    if len(sys.argv) > 1 and sys.argv[1]:
        raw = sys.argv[1]
    else:
        raw = sys.stdin.read()
    if not raw or not raw.strip():
        return {}
    try:
        return json.loads(raw)
    except json.JSONDecodeError as exc:
        print(f"finish-line stop hook: invalid stdin JSON: {exc}", file=sys.stderr)
        return None


def collect_text(node, bucket):
    if node is None:
        return
    if isinstance(node, str):
        bucket.append(node)
        return
    if isinstance(node, list):
        for item in node:
            collect_text(item, bucket)
        return
    if not isinstance(node, dict):
        return
    # Common transcript shapes (Cursor JSONL and simple role/content logs).
    for key in ("text", "content", "message", "body", "output", "summary"):
        if key in node:
            collect_text(node[key], bucket)
    if "parts" in node:
        collect_text(node["parts"], bucket)


def role_of(obj):
    if not isinstance(obj, dict):
        return ""
    for key in ("role", "type", "author", "speaker", "kind"):
        val = obj.get(key)
        if isinstance(val, str) and val:
            return val.lower()
    msg = obj.get("message")
    if isinstance(msg, dict):
        val = msg.get("role") or msg.get("type") or ""
        if isinstance(val, str):
            return val.lower()
    return ""


def is_assistant(role):
    return any(token in role for token in ("assistant", "agent", "model", "bot"))


def is_user(role):
    return "user" in role or role in {"human", "prompt"}


def last_assistant_text(path):
    if not path or not os.path.isfile(path):
        return ""
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as handle:
            raw = handle.read()
    except OSError as exc:
        print(f"finish-line stop hook: cannot read transcript: {exc}", file=sys.stderr)
        return ""

    records = []
    stripped = raw.strip()
    if not stripped:
        return ""
    try:
        parsed = json.loads(stripped)
        if isinstance(parsed, list):
            records = parsed
        elif isinstance(parsed, dict):
            for key in ("messages", "items", "events", "turns"):
                if isinstance(parsed.get(key), list):
                    records = parsed[key]
                    break
            else:
                records = [parsed]
    except json.JSONDecodeError:
        for line in raw.splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                records.append(json.loads(line))
            except json.JSONDecodeError:
                records.append({"role": "unknown", "content": line})

    last = ""
    for rec in records:
        role = role_of(rec) if isinstance(rec, dict) else ""
        bucket = []
        collect_text(rec, bucket)
        text = "\n".join(part for part in bucket if part and part.strip())
        if not text.strip():
            continue
        if is_user(role):
            continue
        if is_assistant(role) or not role:
            last = text
    return last


def looks_unfinished(text):
    if not text or not text.strip():
        return False
    # Ignore very short empty/ack turns with no task signal.
    lowered = text.strip()
    if FINISHED_RE.search(lowered) and not UNFINISHED_RE.search(lowered):
        return False
    # A long deliverable that also invites corrections is finished even if
    # a leftover "let me know" appears at the end.
    if len(lowered) > 800 and FINISHED_RE.search(lowered):
        return False
    if UNFINISHED_RE.search(lowered):
        return True
    # Question-only ending with no substantial body.
    body = lowered.rstrip()
    if len(body) < 600 and body.endswith("?") and not FINISHED_RE.search(body):
        # Pure clarifying close.
        if re.search(r"\?(\s*$|\s*\n\s*$)", body):
            return True
    return False


def main():
    data = load_input()
    if data is None:
        out({})
        return

    status = str(data.get("status") or "").lower()
    try:
        loop_count = int(data.get("loop_count") or 0)
    except (TypeError, ValueError):
        loop_count = 0

    if status == "aborted":
        print("finish-line stop hook: aborted; no follow-up", file=sys.stderr)
        out({})
        return

    if loop_count >= LOOP_LIMIT:
        print(
            f"finish-line stop hook: loop_count {loop_count} reached cap {LOOP_LIMIT}",
            file=sys.stderr,
        )
        out({})
        return

    transcript = (
        data.get("transcript_path")
        or data.get("agent_transcript_path")
        or os.environ.get("CURSOR_TRANSCRIPT_PATH")
        or ""
    )

    if status == "error":
        print("finish-line stop hook: status=error; requesting finish follow-up", file=sys.stderr)
        out({"followup_message": FOLLOWUP})
        return

    if not transcript:
        # Without a transcript we cannot tell finished from unfinished.
        # Do not auto-continue every completed turn.
        print("finish-line stop hook: no transcript; skipping follow-up", file=sys.stderr)
        out({})
        return

    text = last_assistant_text(transcript)
    if looks_unfinished(text):
        print("finish-line stop hook: unfinished pattern; follow-up", file=sys.stderr)
        out({"followup_message": FOLLOWUP})
        return

    print("finish-line stop hook: looks finished or inconclusive; no follow-up", file=sys.stderr)
    out({})


if __name__ == "__main__":
    main()
PY

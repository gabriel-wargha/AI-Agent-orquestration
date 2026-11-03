#!/usr/bin/env bash
# Links your agent team into ~/.claude, so it shows up in every project on this computer.
# Run it again any time. Edits you make in this folder show up straight away.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$HOME/.claude/agents" "$HOME/.claude/commands" "$HOME/.claude/skills"

link() { # link <source> <target>
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    echo "  skipped $2 (a file you made yourself is already there)"
  else
    ln -sfn "$1" "$2"
    echo "  linked  $2"
  fi
}

for f in "$REPO"/agents/*.md;   do link "$f" "$HOME/.claude/agents/$(basename "$f")"; done
for f in "$REPO"/commands/*.md; do link "$f" "$HOME/.claude/commands/$(basename "$f")"; done
for d in "$REPO"/skills/*/;     do d="${d%/}"; link "$d" "$HOME/.claude/skills/$(basename "$d")"; done

echo "Done. Open Claude Code in any project and type /agents to see your team."

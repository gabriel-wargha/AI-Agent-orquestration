#!/usr/bin/env bash
# Copies the team into a project's .claude folder, so it also works on GitHub's
# computers during the night shift. Run it again to update a project's copy.
# Usage: ./scripts/add-to-project.sh ~/path/to/your/project
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="${1:-}"
if [ -z "$PROJECT" ] || [ ! -d "$PROJECT" ]; then
  echo "Usage: ./scripts/add-to-project.sh ~/path/to/your/project"
  exit 1
fi
PROJECT="$(cd "$PROJECT" && pwd)"

mkdir -p "$PROJECT/.claude/agents" "$PROJECT/.claude/commands" "$PROJECT/.claude/skills" "$PROJECT/.github/workflows"
cp "$REPO"/agents/*.md "$PROJECT/.claude/agents/"
cp "$REPO"/commands/*.md "$PROJECT/.claude/commands/"
cp -R "$REPO"/skills/. "$PROJECT/.claude/skills/"
echo "Copied the agents, /ship and the skills into $PROJECT/.claude"

if [ ! -f "$PROJECT/.github/workflows/nightly-ship.yml" ]; then
  cp "$REPO/templates/nightly-ship.yml" "$PROJECT/.github/workflows/nightly-ship.yml"
  echo "Added the night shift workflow"
fi

if [ ! -f "$PROJECT/CLAUDE.md" ]; then
  cp "$REPO/templates/CLAUDE.md" "$PROJECT/CLAUDE.md"
  echo "Added CLAUDE.md with the StudyRats brief. Edit it if this is a different project."
else
  echo "Kept your existing CLAUDE.md. Copy templates/CLAUDE.md into it if you want the StudyRats brief."
fi

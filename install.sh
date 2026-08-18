#!/usr/bin/env bash
# Install the session-handoff skill for Claude Code.
#
#   ./install.sh              -> ~/.claude/skills/session-handoff   (all projects)
#   ./install.sh --project    -> ./.claude/skills/session-handoff   (this repo only)
#   ./install.sh --force      -> overwrite an existing install
#
set -euo pipefail

SKILL="session-handoff"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${HOME}/.claude/skills"
SCOPE="user"
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --project) DEST="$(pwd)/.claude/skills"; SCOPE="project"; shift ;;
    --force)   FORCE=1; shift ;;
    -h|--help) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

if [ ! -f "${SRC}/SKILL.md" ]; then
  echo "  ! SKILL.md not found next to this script" >&2
  exit 1
fi

if [ -e "${DEST}/${SKILL}" ] && [ "$FORCE" -eq 0 ]; then
  echo "  = ${SKILL} already exists at ${DEST}/${SKILL} — use --force to overwrite"
  exit 0
fi

mkdir -p "${DEST}/${SKILL}"
cp "${SRC}/SKILL.md" "${DEST}/${SKILL}/SKILL.md"
echo "  + ${SKILL} -> ${DEST}/${SKILL}/SKILL.md"
echo
echo "Installed at ${SCOPE} scope. Start a new Claude Code session, then run"
echo "/${SKILL} to confirm it registered."
echo
echo "See the 'Adaptation points' section at the bottom of SKILL.md to tune it."

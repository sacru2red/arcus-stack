#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SOURCE="$REPO_ROOT/skills"

TARGET_BASES=(
  "$HOME/.agents/skills"
  "$HOME/.gemini/config/skills"
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.config/opencode/skills"
  "$HOME/.cursor/skills"
)

for target_base in "${TARGET_BASES[@]}"; do
  mkdir -p "$target_base"
  for skill_dir in "$SKILLS_SOURCE"/*/; do
    skill_name="$(basename "$skill_dir")"
    dest="$target_base/$skill_name"
    rm -rf "$dest"
    ln -s "$skill_dir" "$dest"
    echo "[OK] Linked $skill_name -> $dest"
  done
done

echo ""
echo "ARCUS-STACK skills are now linked globally for agy, Claude Code, Codex, Cursor, and OpenCode!"

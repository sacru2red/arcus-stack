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

# Auto-detect T3 Code isolated Antigravity provider config directories
if [ -d "$HOME/.t3/userdata/providers/antigravity" ]; then
  for instance_dir in "$HOME/.t3/userdata/providers/antigravity"/*/; do
    if [ -d "$instance_dir" ]; then
      TARGET_BASES+=("${instance_dir%/}/config/skills")
    fi
  done
fi

for target_base in "${TARGET_BASES[@]}"; do
  mkdir -p "$target_base"

  # Prune stale arcus-* skill links that were renamed or removed from skills/
  for existing in "$target_base"/arcus-*; do
    [ -e "$existing" ] || [ -L "$existing" ] || continue
    existing_name="$(basename "$existing")"
    if [ ! -d "$SKILLS_SOURCE/$existing_name" ]; then
      rm -rf "$existing"
      echo "[PRUNED] Removed stale skill link $existing"
    fi
  done

  for skill_dir in "$SKILLS_SOURCE"/*/; do
    skill_name="$(basename "$skill_dir")"
    dest="$target_base/$skill_name"
    rm -rf "$dest"
    ln -s "$skill_dir" "$dest"
    echo "[OK] Linked $skill_name -> $dest"
  done
done

echo ""
echo "ARCUS-STACK skills are now linked globally for agy (CLI + T3 Code), Claude Code, Codex, Cursor, and OpenCode!"

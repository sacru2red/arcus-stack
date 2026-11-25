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

# Auto-detect any other dot-directories in $HOME with a skills/ folder created by npx skills
for dot_dir in "$HOME"/.*; do
  [ -d "$dot_dir/skills" ] || continue
  candidate="$dot_dir/skills"
  already_added=0
  for existing_base in "${TARGET_BASES[@]}"; do
    if [ "$existing_base" = "$candidate" ]; then
      already_added=1
      break
    fi
  done
  if [ "$already_added" -eq 0 ]; then
    TARGET_BASES+=("$candidate")
  fi
done

# Auto-detect T3 Code isolated Antigravity provider config directories
if [ -d "$HOME/.t3/userdata/providers/antigravity" ]; then
  for instance_dir in "$HOME/.t3/userdata/providers/antigravity"/*/; do
    if [ -d "$instance_dir" ]; then
      candidate="${instance_dir%/}/config/skills"
      already_added=0
      for existing_base in "${TARGET_BASES[@]}"; do
        if [ "$existing_base" = "$candidate" ]; then
          already_added=1
          break
        fi
      done
      if [ "$already_added" -eq 0 ]; then
        TARGET_BASES+=("$candidate")
      fi
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
    ln -s "${skill_dir%/}" "$dest"
    echo "[OK] Linked $skill_name -> $dest"
  done
done

# Clean stale arcus-* entries from ~/.agents/.skill-lock.json if present
LOCK_FILE="$HOME/.agents/.skill-lock.json"
if [ -f "$LOCK_FILE" ]; then
  if command -v node >/dev/null 2>&1; then
    node -e '
      const fs = require("fs");
      const lockFile = process.argv[1];
      const skillsSource = process.argv[2];
      const data = JSON.parse(fs.readFileSync(lockFile, "utf8"));
      if (data && data.skills) {
        let changed = false;
        for (const key of Object.keys(data.skills)) {
          if (key.startsWith("arcus-") && !fs.existsSync(skillsSource + "/" + key)) {
            delete data.skills[key];
            changed = true;
            console.log("[PRUNED] Removed stale \x27" + key + "\x27 from " + lockFile);
          }
        }
        if (changed) {
          fs.writeFileSync(lockFile, JSON.stringify(data, null, 2) + "\n", "utf8");
        }
      }
    ' "$LOCK_FILE" "$SKILLS_SOURCE"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c '
import json, os, sys
lock_file, skills_source = sys.argv[1], sys.argv[2]
with open(lock_file, "r", encoding="utf-8") as f:
    data = json.load(f)
skills = data.get("skills", {})
changed = False
for k in list(skills.keys()):
    if k.startswith("arcus-") and not os.path.isdir(os.path.join(skills_source, k)):
        del skills[k]
        changed = True
        print(f"[PRUNED] Removed stale \x27{k}\x27 from {lock_file}")
if changed:
    with open(lock_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
' "$LOCK_FILE" "$SKILLS_SOURCE"
  fi
fi

echo ""
echo "ARCUS-STACK skills are now linked globally for agy (CLI + T3 Code), Claude Code, Codex, Cursor, and OpenCode!"

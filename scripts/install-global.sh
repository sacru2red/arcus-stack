#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SOURCE="$REPO_ROOT/skills"

# Explicit allowlist of agent skill folders; never auto-discover other tools' dot-directories.
TARGET_BASES=(
  "$HOME/.agents/skills"
  "$HOME/.gemini/config/skills"
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.config/opencode/skills"
  "$HOME/.cursor/skills"
)

# T3 Code isolated Antigravity provider config directories
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

# Only public arcus-* skill folders with a SKILL.md (skips tool state such as skills/.omc/)
SKILL_DIRS=()
for skill_dir in "$SKILLS_SOURCE"/arcus-*/; do
  [ -f "${skill_dir}SKILL.md" ] && SKILL_DIRS+=("${skill_dir%/}")
done

links_into_repo() {
  [ -L "$1" ] || return 1
  case "$(readlink "$1")" in
    "$SKILLS_SOURCE"/*) return 0 ;;
    *) return 1 ;;
  esac
}

for target_base in "${TARGET_BASES[@]}"; do
  mkdir -p "$target_base"

  # Prune stale arcus-* links that point into this repo's skills/ but whose skill was renamed or removed.
  # Real directories and links to anything else are left alone.
  for existing in "$target_base"/arcus-*; do
    [ -L "$existing" ] || continue
    existing_name="$(basename "$existing")"
    if [ ! -f "$SKILLS_SOURCE/$existing_name/SKILL.md" ] && links_into_repo "$existing"; then
      rm -f "$existing"
      echo "[PRUNED] Removed stale skill link $existing"
    fi
  done

  for skill_dir in "${SKILL_DIRS[@]}"; do
    skill_name="$(basename "$skill_dir")"
    dest="$target_base/$skill_name"
    if [ -L "$dest" ]; then
      rm -f "$dest"
    elif [ -d "$dest" ]; then
      if [ -f "$dest/SKILL.md" ]; then
        # A copied install of this same skill (e.g. from npx skills); replace it with the live link.
        rm -rf "$dest"
      else
        echo "[WARN] Skipped $dest because it is a directory without SKILL.md that this script did not create." >&2
        continue
      fi
    fi
    ln -s "$skill_dir" "$dest"
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
          if (key.startsWith("arcus-") && !fs.existsSync(skillsSource + "/" + key + "/SKILL.md")) {
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
    if k.startswith("arcus-") and not os.path.isfile(os.path.join(skills_source, k, "SKILL.md")):
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

#!/usr/bin/env bash
# Regression test for scripts/install-global.sh. Runs the installer from a throwaway repo copy against a
# throwaway HOME and checks every invariant. On Git Bash for Windows, run with MSYS=winsymlinks:nativestrict.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
COPY="$WORK/repo"
FAKE_HOME="$WORK/home"
fail=0
cleanup() {
  # Remove links first so rm -rf never walks through a link into the repo copy.
  find "$WORK" -type l -exec rm -f {} + 2>/dev/null || true
  rm -rf "$WORK"
}
trap cleanup EXIT

check() {
  if eval "$2"; then echo "[PASS] $1"; else echo "[FAIL] $1"; fail=1; fi
}

mkdir -p "$COPY"
(cd "$REPO_ROOT" && git ls-files -z | while IFS= read -r -d '' f; do mkdir -p "$COPY/$(dirname "$f")"; cp "$f" "$COPY/$f"; done)
COPY_SKILLS="$COPY/skills"
mkdir -p "$COPY_SKILLS/.omc/state"

CLAUDE="$FAKE_HOME/.claude/skills"
AGENTS="$FAKE_HOME/.agents/skills"
CODEX="$FAKE_HOME/.codex/skills"
CURSOR="$FAKE_HOME/.cursor/skills"
GEMINI="$FAKE_HOME/.gemini/config/skills"
OPENCODE="$FAKE_HOME/.config/opencode/skills"
HERMES="$FAKE_HOME/.hermes/skills"
mkdir -p "$CLAUDE" "$AGENTS" "$CODEX" "$CURSOR" "$GEMINI" "$HERMES" "$FAKE_HOME/skills" "$(dirname "$OPENCODE")"

mkdir -p "$CLAUDE/arcus-old" && echo "user data" > "$CLAUDE/arcus-old/notes.txt"
mkdir -p "$COPY_SKILLS/arcus-gone" && ln -s "$COPY_SKILLS/arcus-gone" "$CLAUDE/arcus-gone" && rm -rf "$COPY_SKILLS/arcus-gone"

# A user-modified copy, an unmodified copy, a copy with an extra hidden file, and a copy with an extra empty folder.
mkdir -p "$AGENTS/arcus-plan" && printf -- '---\nname: arcus-plan\n---\nuser edit\n' > "$AGENTS/arcus-plan/SKILL.md"
cp -R "$COPY_SKILLS/arcus-why" "$CODEX/arcus-why"
cp -R "$COPY_SKILLS/arcus-ketchup" "$CURSOR/arcus-ketchup" && echo "hidden user note" > "$CURSOR/arcus-ketchup/.user-notes"
cp -R "$COPY_SKILLS/arcus-correct" "$GEMINI/arcus-correct" && mkdir "$GEMINI/arcus-correct/extra"
# A copy that holds a link must be moved as is, never copied through the link.
mkdir -p "$WORK/outside" && echo "linked data" > "$WORK/outside/big.txt"
cp -R "$COPY_SKILLS/arcus-why" "$CLAUDE/arcus-why" && ln -s "$WORK/outside" "$CLAUDE/arcus-why/linked"

# An agent skills folder that is itself a link to the repo's skills/ must never lose the repo's files.
ln -s "$COPY_SKILLS" "$OPENCODE"
repo_files="$(find "$COPY_SKILLS" -type f | wc -l)"

printf '{"version":3,"skills":{"arcus-plan":{"source":"x"},"arcus-gone":{"source":"x"},"other":{"source":"y"}}}' > "$FAKE_HOME/.agents/.skill-lock.json"

check "installer exits 0" 'HOME="$FAKE_HOME" bash "$COPY/scripts/install-global.sh" > "$WORK/install.log" 2>&1'

is_repo_link() {
  [ -L "$1" ] || return 1
  case "$(readlink "$1")" in "$COPY_SKILLS"/*) return 0 ;; *) return 1 ;; esac
}

for base in .agents/skills .gemini/config/skills .claude/skills .codex/skills .cursor/skills; do
  count=0
  for entry in "$FAKE_HOME/$base"/*; do
    if is_repo_link "$entry"; then count=$((count + 1)); fi
  done
  check "$base has 15 links into the repo (got $count)" '[ "$count" -eq 15 ]'
  check "$base has no .omc tool-state link" '[ ! -e "$FAKE_HOME/$base/.omc" ]'
done
check "non-allowlisted ~/.hermes/skills untouched" '[ -z "$(ls -A "$HERMES")" ]'
check "~/skills (bash 3.2 dot-glob trap) untouched" '[ -z "$(ls -A "$FAKE_HOME/skills")" ]'
check "user's real arcus-old directory kept" '[ "$(cat "$CLAUDE/arcus-old/notes.txt" 2>/dev/null)" = "user data" ]'
check "stale arcus-gone link into the repo pruned" '[ ! -e "$CLAUDE/arcus-gone" ] && [ ! -L "$CLAUDE/arcus-gone" ]'

check "agent folder linked to the repo's skills/ keeps every repo file" '[ "$(find "$COPY_SKILLS" -type f | wc -l)" -eq "$repo_files" ]'
check "agent folder linked to the repo's skills/ is skipped with a warning" 'grep -q "this repo'"'"'s own skills/arcus-why" "$WORK/install.log"'

BACKUP_ROOT="$FAKE_HOME/.arcus-stack-backups"
runs() { find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' '; }
check "one backup folder for the run" '[ "$(runs)" -eq 1 ]'
run="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1 || true)"
run="${run:-$BACKUP_ROOT/missing}"
check "unmodified copy (codex arcus-why) replaced by a link" 'is_repo_link "$CODEX/arcus-why"'
check "unmodified copy (codex arcus-why) not backed up" '[ ! -e "$run/.codex_skills" ]'
check "modified copy (agents arcus-plan) replaced by a link" 'is_repo_link "$AGENTS/arcus-plan"'
check "modified copy (agents arcus-plan) backed up with the user's edit" 'grep -q "user edit" "$run/.agents_skills/arcus-plan/SKILL.md" 2>/dev/null'
check "copy with an extra hidden file (cursor arcus-ketchup) replaced by a link" 'is_repo_link "$CURSOR/arcus-ketchup"'
check "copy with an extra hidden file backed up with that file" '[ -f "$run/.cursor_skills/arcus-ketchup/.user-notes" ]'
check "copy with an extra empty folder (gemini arcus-correct) replaced by a link" 'is_repo_link "$GEMINI/arcus-correct"'
check "copy with an extra empty folder backed up with that folder" '[ -d "$run/.gemini_config_skills/arcus-correct/extra" ]'
check "copy holding a link (claude arcus-why) replaced by a link" 'is_repo_link "$CLAUDE/arcus-why"'
check "copy holding a link backed up with the link itself, not a copy of its target" '[ -L "$run/.claude_skills/arcus-why/linked" ]'
check "backups live outside every agent skills folder" 'case "$BACKUP_ROOT" in "$CLAUDE"*|"$AGENTS"*|"$CODEX"*|"$CURSOR"*|"$GEMINI"*|"$OPENCODE"*) false ;; *) true ;; esac'

check "second run exits 0" 'HOME="$FAKE_HOME" bash "$COPY/scripts/install-global.sh" > "$WORK/install-2.log" 2>&1'
check "second run makes no new backup" '[ "$(runs)" -eq 1 ]'

keys="$(node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(Object.keys(d.skills).sort().join(','))" "$FAKE_HOME/.agents/.skill-lock.json")"
check "lock file parses and keeps only live entries ($keys)" '[ "$keys" = "arcus-plan,other" ]'

if [ "$fail" -ne 0 ]; then echo "install-global.sh regression FAILED"; exit 1; fi
echo "All install-global.sh checks passed."

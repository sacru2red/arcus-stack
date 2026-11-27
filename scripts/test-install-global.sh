#!/usr/bin/env bash
# Regression test for scripts/install-global.sh. Runs the installer from a throwaway repo copy against a
# throwaway HOME and checks every invariant. On Git Bash for Windows, run with MSYS=winsymlinks:nativestrict.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
COPY="$WORK/repo"
FAKE_HOME="$WORK/home"
fail=0
trap 'rm -rf "$WORK"' EXIT

check() {
  if eval "$2"; then echo "[PASS] $1"; else echo "[FAIL] $1"; fail=1; fi
}

mkdir -p "$COPY"
(cd "$REPO_ROOT" && git ls-files -z | while IFS= read -r -d '' f; do mkdir -p "$COPY/$(dirname "$f")"; cp "$f" "$COPY/$f"; done)
COPY_SKILLS="$COPY/skills"
mkdir -p "$COPY_SKILLS/.omc/state"

CLAUDE="$FAKE_HOME/.claude/skills"
AGENTS="$FAKE_HOME/.agents/skills"
HERMES="$FAKE_HOME/.hermes/skills"
mkdir -p "$CLAUDE" "$AGENTS" "$HERMES" "$FAKE_HOME/skills"

mkdir -p "$CLAUDE/arcus-old" && echo "user data" > "$CLAUDE/arcus-old/notes.txt"
mkdir -p "$COPY_SKILLS/arcus-gone" && ln -s "$COPY_SKILLS/arcus-gone" "$CLAUDE/arcus-gone" && rm -rf "$COPY_SKILLS/arcus-gone"
mkdir -p "$AGENTS/arcus-plan" && printf -- '---\nname: arcus-plan\n---\n' > "$AGENTS/arcus-plan/SKILL.md"
printf '{"version":3,"skills":{"arcus-plan":{"source":"x"},"arcus-gone":{"source":"x"},"other":{"source":"y"}}}' > "$FAKE_HOME/.agents/.skill-lock.json"

check "installer exits 0" 'HOME="$FAKE_HOME" bash "$COPY/scripts/install-global.sh" > "$WORK/install.log" 2>&1'

for base in .agents/skills .gemini/config/skills .claude/skills .codex/skills .config/opencode/skills .cursor/skills; do
  count=0
  for entry in "$FAKE_HOME/$base"/*; do
    [ -L "$entry" ] || continue
    case "$(readlink "$entry")" in "$COPY_SKILLS"/*) count=$((count + 1)) ;; esac
  done
  check "$base has 15 links into the repo (got $count)" '[ "$count" -eq 15 ]'
done
check "no .omc tool-state link created" '[ -z "$(find "$FAKE_HOME" -name .omc -print -quit)" ]'
check "non-allowlisted ~/.hermes/skills untouched" '[ -z "$(ls -A "$HERMES")" ]'
check "~/skills (bash 3.2 dot-glob trap) untouched" '[ -z "$(ls -A "$FAKE_HOME/skills")" ]'
check "user's real arcus-old directory kept" '[ "$(cat "$CLAUDE/arcus-old/notes.txt" 2>/dev/null)" = "user data" ]'
check "stale arcus-gone link into the repo pruned" '[ ! -e "$CLAUDE/arcus-gone" ] && [ ! -L "$CLAUDE/arcus-gone" ]'
check "copied arcus-plan install replaced by a link" '[ -L "$AGENTS/arcus-plan" ]'
keys="$(node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(Object.keys(d.skills).sort().join(','))" "$FAKE_HOME/.agents/.skill-lock.json")"
check "lock file parses and keeps only live entries ($keys)" '[ "$keys" = "arcus-plan,other" ]'

if [ "$fail" -ne 0 ]; then echo "install-global.sh regression FAILED"; exit 1; fi
echo "All install-global.sh checks passed."

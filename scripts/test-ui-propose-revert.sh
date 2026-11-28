#!/usr/bin/env bash
# Regression test for the arcus-ui-propose revert cycle (skills/arcus-ui-propose/references/ui-proposal-protocol.md).
# Runs the documented git commands in throwaway repos and asserts that user edits and staging survive every revert,
# and that the baseline pin stops without touching the tree when git stash create cannot store the user's state.
set -euo pipefail

fail=0
check() {
  if [ "$2" = "$3" ]; then echo "[PASS] $1"; else echo "[FAIL] $1 (expected '$3', got '$2')"; fail=1; fi
}

new_repo() {
  local dir
  dir="$(mktemp -d)"
  git -C "$dir" init -q
  git -C "$dir" config user.email test@example.com
  git -C "$dir" config user.name test
  printf 'x-head\n' > "$dir/X.css"
  printf 'y-head\n' > "$dir/Y.css"
  printf 'd-head\n' > "$dir/D.css"
  git -C "$dir" add . && git -C "$dir" commit -qm base
  echo "$dir"
}

audit=".audit/ui-propose/t"

pin_baseline() {
  mkdir -p "$audit"
  git check-ignore -q .audit/ || echo ".audit/" >> "$(git rev-parse --git-path info/exclude)"
  git status --porcelain > "$audit/00-status.txt"
  BASE=$(git stash create 2>/dev/null) || { echo "STOP: intent-to-add, unmerged, or no commit yet" >&2; return 1; }
  if [ -n "$BASE" ]; then IDX="$BASE^2"
  elif [ -z "$(git status --porcelain -uno)" ]; then BASE=HEAD; IDX=HEAD
  else echo "STOP: tracked changes but no stash commit" >&2; return 1; fi
}

in_baseline() {
  { git cat-file -e "$BASE:./$1" || git cat-file -e "$IDX:./$1"; } 2>/dev/null
}

save_untracked() {
  local f
  for f in "$@"; do
    if [ -n "$(git ls-files --others --exclude-standard -- "$f")" ]; then mkdir -p "$audit/untracked-base/$(dirname "$f")" && cp "$f" "$audit/untracked-base/$f"; fi
  done
}

revert_files() {
  local f tracked=() created=()
  for f in "$@"; do
    if in_baseline "$f"; then tracked+=("$f")
    elif [ -e "$audit/untracked-base/$f" ]; then cp "$audit/untracked-base/$f" "$f"
    else created+=("$f"); fi
  done
  if [ "${#tracked[@]}" -gt 0 ]; then
    git restore --source="$BASE" --worktree -- "${tracked[@]}" &&
      git restore --source="$IDX" --staged -- "${tracked[@]}" || { echo "STOP: revert failed" >&2; return 1; }
  fi
  if [ "${#created[@]}" -gt 0 ]; then rm -f -- "${created[@]}"; fi
}

# Applies three variants to the given files plus one new file each, reverting after every variant.
# $LATE, when set, names one more file that only Option C edits.
run_cycle() {
  local x f targets
  pin_baseline
  save_untracked "$@"
  for x in a b c; do
    targets=("$@" "New-$x.css")
    if [ "$x" = c ] && [ -n "${LATE:-}" ]; then targets+=("$LATE"); fi
    for f in "${targets[@]}"; do printf '%s-option-%s\n' "$f" "$x" > "$f"; done
    git diff "$BASE" -- "${targets[@]}" > "$audit/option-$x.patch"
    mkdir -p "$audit/files-$x" && cp "New-$x.css" "$audit/files-$x/"
    revert_files "${targets[@]}"
  done
  git status --porcelain | diff -q - "$audit/00-status.txt" >/dev/null && echo same || echo differs
}

dirty="$(new_repo)"
(
  cd "$dirty"
  printf 'x-user\n' > X.css
  printf 'y-user\n' > Y.css
  printf 'u-user\n' > U.txt
  printf 'e-user\n' > E.css
  printf 'g-user\n' > G.local.css && echo "*.local.css" >> .git/info/exclude
  printf 'l-user\n' > L.css
  status="$(LATE=L.css run_cycle Y.css E.css G.local.css)"
  check "dirty tree: git status matches pre-proposal state" "$status" "same"
  check "dirty tree: untouched user edit kept (X.css)" "$(cat X.css)" "x-user"
  check "dirty tree: touched user edit restored (Y.css)" "$(cat Y.css)" "y-user"
  check "dirty tree: user untracked file kept (U.txt)" "$(cat U.txt)" "u-user"
  check "dirty tree: user untracked file a variant edited is restored, not removed (E.css)" "$(cat E.css 2>/dev/null || echo missing)" "e-user"
  check "dirty tree: user ignored file a variant edited is restored, not removed (G.local.css)" "$(cat G.local.css 2>/dev/null || echo missing)" "g-user"
  check "dirty tree: user untracked file only Option C edited is restored, not removed (L.css)" "$(cat L.css 2>/dev/null || echo missing)" "l-user"
  check "dirty tree: .audit/ hidden from status" "$(git status --porcelain | grep -c '\.audit' || true)" "0"
  git apply "$audit/option-b.patch" && cp -R "$audit/files-b/." .
  check "dirty tree: chosen option re-applies on top of user baseline" "$(cat Y.css)" "Y.css-option-b"
  check "dirty tree: chosen option re-applies its edit to a user untracked file (E.css)" "$(cat E.css)" "E.css-option-b"
  check "dirty tree: chosen option re-applies its edit to a user ignored file (G.local.css)" "$(cat G.local.css)" "G.local.css-option-b"
  check "dirty tree: chosen option re-applies its new file (New-b.css)" "$(cat New-b.css 2>/dev/null || echo missing)" "New-b.css-option-b"
  exit "$fail"
) || fail=1

clean="$(new_repo)"
(
  cd "$clean"
  status="$(run_cycle Y.css)"
  check "clean tree: git status matches pre-proposal state" "$status" "same"
  check "clean tree: Y.css back to HEAD" "$(cat Y.css)" "y-head"
  git apply "$audit/option-c.patch"
  check "clean tree: chosen option re-applies" "$(cat Y.css)" "Y.css-option-c"
  exit "$fail"
) || fail=1

staged="$(new_repo)"
(
  cd "$staged"
  printf 'n-staged\n' > N.css && git add N.css
  printf 'y-staged\n' > Y.css && git add Y.css && printf 'y-worktree\n' > Y.css
  git rm -q D.css
  before="$(git status --porcelain)"
  status="$(run_cycle N.css Y.css D.css)"
  check "staged tree: git status matches pre-proposal state ($(echo "$before" | tr '\n' ' '))" "$status" "same"
  check "staged tree: staged new file still staged (N.css)" "$(git show :N.css)" "n-staged"
  check "staged tree: partly staged file keeps its staged content (Y.css)" "$(git show :Y.css)" "y-staged"
  check "staged tree: partly staged file keeps its worktree content (Y.css)" "$(cat Y.css)" "y-worktree"
  check "staged tree: file recreated by a variant at a staged-deleted path is removed (D.css)" "$([ -e D.css ] && echo present || echo absent)" "absent"
  exit "$fail"
) || fail=1

# Run from a subfolder with paths relative to it, as an agent working inside one package of a monorepo would.
subdir="$(new_repo)"
(
  cd "$subdir"
  mkdir -p app/src && printf 's-head\n' > app/src/S.css && git add app && git commit -qm app
  printf 's-user\n' > app/src/S.css
  cd app
  status="$(run_cycle src/S.css)"
  check "subfolder: git status matches pre-proposal state" "$status" "same"
  check "subfolder: touched user edit restored, not removed (app/src/S.css)" "$(cat src/S.css 2>/dev/null || echo missing)" "s-user"
  exit "$fail"
) || fail=1

# Each blocked case must stop the pin and leave status and file contents exactly as they were.
blocked_case() {
  local name="$1" before contents
  before="$(git status --porcelain)"
  contents="$(cat ./*.css 2>/dev/null || true)"
  if pin_baseline 2>/dev/null; then check "$name: pin stops" "continued" "stopped"; else check "$name: pin stops" "stopped" "stopped"; fi
  check "$name: status untouched" "$(git status --porcelain)" "$before"
  check "$name: file contents untouched" "$(cat ./*.css 2>/dev/null || true)" "$contents"
}

ita="$(new_repo)"
(
  cd "$ita"
  printf 'i-user\n' > I.css && git add -N I.css
  printf 'y-user\n' > Y.css
  blocked_case "intent-to-add file"
  exit "$fail"
) || fail=1

unmerged="$(new_repo)"
(
  cd "$unmerged"
  git switch -qc other && printf 'y-other\n' > Y.css && git commit -qam other
  git switch -q - && printf 'y-main\n' > Y.css && git commit -qam main
  git merge -q other >/dev/null 2>&1 || true
  blocked_case "unmerged file"
  exit "$fail"
) || fail=1

unborn="$(mktemp -d)"
(
  cd "$unborn"
  git init -q
  printf 'a-user\n' > A.css && git add A.css
  blocked_case "no commit yet"
  exit "$fail"
) || fail=1

rm -rf "$dirty" "$clean" "$staged" "$subdir" "$ita" "$unmerged" "$unborn"
if [ "$fail" -ne 0 ]; then echo "ui-propose revert regression FAILED"; exit 1; fi
echo "All ui-propose revert cases passed."

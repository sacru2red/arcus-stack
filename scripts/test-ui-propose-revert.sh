#!/usr/bin/env bash
# Regression test for the arcus-ui-propose revert cycle (skills/arcus-ui-propose/references/ui-proposal-protocol.md).
# Runs the documented git commands in throwaway repos and asserts that user edits survive every revert.
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
  git -C "$dir" add . && git -C "$dir" commit -qm base
  echo "$dir"
}

run_cycle() {
  local slug=t audit=".audit/ui-propose/t"
  mkdir -p "$audit"
  git check-ignore -q .audit/ || echo ".audit/" >> .git/info/exclude
  git status --porcelain > "$audit/00-status.txt"
  BASE=$(git stash create); [ -n "$BASE" ] || BASE=HEAD

  for x in a b c; do
    printf 'y-option-%s\n' "$x" > Y.css
    printf 'new-%s\n' "$x" > "New-$x.css"
    git diff "$BASE" -- Y.css > "$audit/option-$x.patch"
    mkdir -p "$audit/files-$x" && cp "New-$x.css" "$audit/files-$x/"
    git checkout "$BASE" -- Y.css
    git reset -q -- Y.css
    rm "New-$x.css"
  done

  git status --porcelain | diff -q - "$audit/00-status.txt" >/dev/null && echo same || echo differs
}

dirty="$(new_repo)"
(
  cd "$dirty"
  printf 'x-user\n' > X.css
  printf 'y-user\n' > Y.css
  printf 'u-user\n' > U.txt
  status="$(run_cycle)"
  check "dirty tree: git status matches pre-proposal state" "$status" "same"
  check "dirty tree: untouched user edit kept (X.css)" "$(cat X.css)" "x-user"
  check "dirty tree: touched user edit restored (Y.css)" "$(cat Y.css)" "y-user"
  check "dirty tree: user untracked file kept (U.txt)" "$(cat U.txt)" "u-user"
  check "dirty tree: .audit/ hidden from status" "$(git status --porcelain | grep -c '\.audit' || true)" "0"
  git apply .audit/ui-propose/t/option-b.patch
  check "dirty tree: chosen option re-applies on top of user baseline" "$(cat Y.css)" "y-option-b"
  exit "$fail"
) || fail=1

clean="$(new_repo)"
(
  cd "$clean"
  status="$(run_cycle)"
  check "clean tree: git status matches pre-proposal state" "$status" "same"
  check "clean tree: Y.css back to HEAD" "$(cat Y.css)" "y-head"
  git apply .audit/ui-propose/t/option-c.patch
  check "clean tree: chosen option re-applies" "$(cat Y.css)" "y-option-c"
  exit "$fail"
) || fail=1

rm -rf "$dirty" "$clean"
if [ "$fail" -ne 0 ]; then echo "ui-propose revert regression FAILED"; exit 1; fi
echo "All ui-propose revert cases passed."

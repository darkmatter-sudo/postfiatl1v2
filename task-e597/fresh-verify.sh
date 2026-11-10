#!/usr/bin/env bash
# task_e597: fresh public clone verification of PR #201 (merged) for postfiatl1v2.
# Usage: bash e597-fresh-verify.sh  (stdout = log)
set -u
export TZ=UTC
MERGE=ab2150253ff80eca5d0c5eda8b0814c4f5dc5e1a
HEAD_PR=edc70f7b178e2389d7af122d6f254a92364777f2
x() { echo "\$ $*"; eval "$*"; rc=$?; echo "(exit $rc)"; return "$rc"; }

echo "# host: validator-host  date: $(date -u +%FT%TZ)"
echo "# OS: $(grep -oP "^PRETTY_NAME=\"\K[^\"]+" /etc/os-release)"
W="$(mktemp -d -p "$HOME/.cache" e597-fresh-XXXX)"; chmod 755 "$W"
cd "$W" || exit 1
echo "# workdir: <scratch>/$(basename "$W")"
x "git clone -q https://github.com/postfiatorg/postfiatl1v2.git src"
cd src || exit 1
MAIN="$(git rev-parse origin/main)"
x "git log -1 --format='%H %ad %s' --date=iso-strict origin/main"
x "git merge-base --is-ancestor $HEAD_PR $MERGE && echo 'PR head edc70f7b is in merge ab2150253'"
x "git merge-base --is-ancestor $MERGE origin/main && echo 'merge ab2150253 is an ancestor of origin/main'"
x "git log -1 --format='%H author=%an committer=%cn %ad' --date=iso-strict $HEAD_PR"
x "git show --stat --format='%H %s' $HEAD_PR | tail -9"
x "git diff --stat $HEAD_PR^ $HEAD_PR"
x "git diff --quiet $HEAD_PR $MERGE -- crates/privacy_orchard && echo 'privacy_orchard identical at PR head and merge commit'"

run_tests() {
  local rev="$1" label="$2"
  x "git checkout -q $rev && git rev-parse HEAD"
  x "sha256sum crates/privacy_orchard/src/asset_orchard_action_builders.rs crates/privacy_orchard/src/verify.rs crates/privacy_orchard/src/asset_orchard.rs Cargo.lock"
  local t0; t0=$(date +%s)
  echo "\$ docker run --rm --cpus 2 -v <clone>:/src -w /src rust:1.95.0-bookworm cargo test -p postfiat-privacy-orchard --locked   # $label"
  sudo -n nice -n 15 docker run --rm --cpus 2 -e CARGO_PROFILE_DEV_DEBUG=line-tables-only \
    -v "$PWD":/src -w /src rust:1.95.0-bookworm \
    bash -c 'cargo test -p postfiat-privacy-orchard --locked 2>&1; rc=$?; chown -R '"$(id -u):$(id -g)"' /src; exit $rc' </dev/null \
    | grep -vE '^\s+(Compiling|Downloaded|Downloading) '
  local rc=${PIPESTATUS[0]}
  echo "(exit $rc) # $label elapsed=$(( $(date +%s) - t0 ))s"
}
run_tests "$MERGE" "merge commit ab2150253 (PR #201 as merged)"
run_tests "$MAIN" "origin/main $MAIN (after maintainer review fixes)"
echo "# end: $(date -u +%FT%TZ)"

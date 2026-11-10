# Evidence branch: Task Node task_e597 (postfiatl1v2 #181 points 3 and 5)

This orphan branch holds only verification logs. It does not contain repository code.

- Pull request: https://github.com/postfiatorg/postfiatl1v2/pull/201 (author darkmatter-sudo, merged 2026-11-10T10:20:12Z
  as merge commit `ab2150253ff80eca5d0c5eda8b0814c4f5dc5e1a`, PR head `edc70f7b178e2389d7af122d6f254a92364777f2`).
- `task-e597/fresh-verify.sh`: the script that was run. It makes a fresh anonymous clone of postfiatorg/postfiatl1v2,
  checks ancestry (PR head in merge, merge in main), prints sha256 of the changed files, and runs
  `cargo test -p postfiat-privacy-orchard --locked` in `rust:1.95.0-bookworm` (2 CPUs), once at the merge commit and
  once at the then-current `origin/main`.
- `task-e597/fresh-verify.log`: the raw output of that run (Compiling/Downloading lines filtered by the script itself;
  the scratch directory name is shown as `<scratch>`).

#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/branch_merge_status.sh [<branch>] [--base <base-branch>] [--remote <remote>]

Description:
  Check whether <branch> has been merged into <remote>/<base-branch>.
  Prints a concise status and returns exit code:
    0 = merged/included (main contains branch)
    1 = not merged yet (branch has commits not in main)
    2 = error (e.g., ref not found)

Arguments:
  <branch>                Branch to check (default: current checked out branch)
  --base <base-branch>    Base branch name (default: main)
  --remote <remote>       Remote name (default: origin)

Examples:
  scripts/branch_merge_status.sh                   # check current branch vs origin/main
  scripts/branch_merge_status.sh my/feature        # check specific branch vs origin/main
  scripts/branch_merge_status.sh my/feature --base develop --remote upstream
EOF
}

# Defaults
BRANCH=""
BASE_BRANCH="main"
REMOTE="origin"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage; exit 0 ;;
    --base)
      BASE_BRANCH="${2:-}"; shift 2 ;;
    --remote)
      REMOTE="${2:-}"; shift 2 ;;
    --*)
      echo "Unknown option: $1" >&2; usage; exit 2 ;;
    *)
      if [[ -z "$BRANCH" ]]; then BRANCH="$1"; else echo "Unexpected arg: $1" >&2; usage; exit 2; fi
      shift 1 ;;
  esac
done

if [[ -z "$BRANCH" ]]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
fi

if [[ -z "$BRANCH" || "$BRANCH" == "HEAD" ]]; then
  echo "Error: cannot determine current branch name. Please specify <branch>." >&2
  exit 2
fi

# Ensure we can resolve refs
if ! git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  echo "Error: branch '$BRANCH' not found." >&2
  exit 2
fi

# Update remote base
git fetch "$REMOTE" "$BASE_BRANCH" --quiet || true

if ! git rev-parse --verify "$REMOTE/$BASE_BRANCH" >/dev/null 2>&1; then
  echo "Error: base ref '$REMOTE/$BASE_BRANCH' not found." >&2
  exit 2
fi

HEAD_SHA=$(git rev-parse "$BRANCH")
MAIN_SHA=$(git rev-parse "$REMOTE/$BASE_BRANCH")
BASE_SHA=$(git merge-base "$BRANCH" "$REMOTE/$BASE_BRANCH")

printf "Branch: %s\n" "$BRANCH"
printf "HEAD:   %s\n" "$HEAD_SHA"
printf "%s/%s: %s\n" "$REMOTE" "$BASE_BRANCH" "$MAIN_SHA"
printf "Base:   %s\n" "$BASE_SHA"

# Cases
if [[ "$HEAD_SHA" == "$MAIN_SHA" ]]; then
  echo "Status: identical to $REMOTE/$BASE_BRANCH (nothing to merge)."
  exit 0
elif [[ "$BASE_SHA" == "$HEAD_SHA" ]]; then
  echo "Status: already merged (main contains branch)."
  exit 0
elif [[ "$BASE_SHA" == "$MAIN_SHA" ]]; then
  echo "Status: branch is ahead of main but not merged (fast-forward possible)."
  echo "Commits in branch not in main:"
  git log --oneline "$REMOTE/$BASE_BRANCH".."$BRANCH"
  exit 1
else
  echo "Status: diverged (both sides have unique commits)."
  echo "Commits in branch not in main:"
  git log --oneline "$REMOTE/$BASE_BRANCH".."$BRANCH" || true
  echo "Commits in main not in branch:"
  git log --oneline "$BRANCH".."$REMOTE/$BASE_BRANCH" || true
  exit 1
fi

#!/usr/bin/env bash
# Push this demo to a new GitHub repository in one command.
# Needs Git and the GitHub CLI (https://cli.github.com), signed in once with: gh auth login
# Usage: ./push.sh [repo-name] [private|public]   (public also turns on a free GitHub Pages site)
set -euo pipefail
cd "$(dirname "$0")"
NAME="${1:-enquira-full-demo}"
VIS="${2:-private}"
command -v gh >/dev/null || { echo "Install the GitHub CLI first: https://cli.github.com"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Sign in first: gh auth login"; exit 1; }
[ -d .git ] || git init -q -b main
git add -A
git commit -q -m "Enquira Full package early-access demo" || echo "Nothing new to commit"
if git remote get-url origin >/dev/null 2>&1; then git push -u origin main; else gh repo create "$NAME" --"$VIS" --source=. --remote=origin --push; fi
if [ "$VIS" = "public" ]; then
  gh api -X POST "repos/{owner}/{repo}/pages" -f build_type=workflow >/dev/null 2>&1 || true
  echo "GitHub Pages: https://$(gh api user -q .login).github.io/$NAME/ (live in about a minute)"
fi
echo "Repository: $(gh repo view --json url -q .url)"

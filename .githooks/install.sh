#!/usr/bin/env bash
# Run ONCE per machine (Windows + Mac) to activate the privacy pre-commit guard.
#   bash .githooks/install.sh
set -e
cd "$(git rev-parse --show-toplevel)"
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit .githooks/commit-msg 2>/dev/null || true
echo "✓ core.hooksPath set to .githooks (pre-commit privacy guard active)."
if [ ! -f .pii-denylist ]; then
  cp .pii-denylist.example .pii-denylist
  echo "✓ created local .pii-denylist (gitignored) from the example — edit it to list borrower terms to block."
else
  echo "• .pii-denylist already present (local, gitignored)."
fi

#!/usr/bin/env bash
# Canonical shared checks for every repo's .githooks/pre-commit.  SOURCE OF TRUTH.
#
# WHY THIS FILE EXISTS
# Measured 2026-07-28: the pre-commit guard had drifted into FIVE distinct variants across ten
# repos (md5 of .githooks/pre-commit), forming a lattice rather than a chain -- neither the Firm
# copy nor the MachineOps copy was a superset of the other.  The EIN check existed in 2 of 5.
# The credential check existed in 1 of 5.  A fix landed wherever the incident was found and never
# travelled.  This file is the part that must be identical everywhere; each repo's pre-commit
# sources it and then adds its OWN rules on top.
#
# WHAT STAYS IN THE REPO'S OWN HOOK, DELIBERATELY
# The variants differ for load-bearing reasons and flattening them would break real behaviour:
#   Firm      auto-reindexes wiki/INDEX.md and carves out Deliverable-Templates/*/output/*.pdf
#             (its CLAUDE.md item 4 requires that path shape to match in three places at once)
#   MachineOps is text-only, so it blocks ALL document binaries rather than only new adds
#   trcb-tools blocks the _local/ deal vault by path
# Repo-specific path rules therefore stay in the repo.  Only the content checks are shared.
#
# DISTRIBUTION
# Vendored, not sourced across repos: a git hook must work in a fresh clone on a machine that has
# no MachineOps checkout, so each repo carries a COPY at .githooks/lib/guard-common.sh.
# guard-audit.sh reports any copy whose md5 differs from this file; guard-sync.sh refreshes them.
# Vendoring is what makes the copies verifiable.  Sourcing across repos would make them fragile.
#
# USAGE, from a repo's .githooks/pre-commit:
#   . "$(git rev-parse --show-toplevel)/.githooks/lib/guard-common.sh"
#   guard_init                       # populates $g_added, $g_staged, $g_root
#   guard_check_ssn; guard_check_ein; guard_check_credentials
#   guard_check_denylist
#   guard_check_figures
#   guard_verdict                    # exits 1 if anything failed; returns 0 otherwise

# ---------------------------------------------------------------------------------------------
# state.  g_fail is the accumulator; every check sets it rather than exiting, so one commit
# reports EVERY problem instead of making the author re-run to find the next one.
# ---------------------------------------------------------------------------------------------
g_fail=0
g_root=""
g_staged=""
g_added=""

guard_init() {
  g_root="$(git rev-parse --show-toplevel)"
  g_staged="$(git diff --cached --name-only)"
  # -U0 so only changed lines are scanned, never surrounding context.  Scanning context would
  # block a commit for content that was already in the file and is not being added.
  g_added="$(git diff --cached --no-color -U0 | grep -E '^\+' | grep -vE '^\+\+\+' || true)"
}

guard_block() { echo "BLOCKED: $1" >&2; g_fail=1; }
guard_note()  { echo "note:    $1" >&2; }

# ---------------------------------------------------------------------------------------------
# structured identifiers.  Both were present in only some variants; both are cheap and neither
# has ever produced a false positive on this corpus.
# ---------------------------------------------------------------------------------------------
guard_check_ssn() {
  printf '%s\n' "$g_added" | grep -Eq '[0-9]{3}-[0-9]{2}-[0-9]{4}' \
    && guard_block "added content contains an SSN-like pattern (NNN-NN-NNNN)."
  return 0
}

guard_check_ein() {
  printf '%s\n' "$g_added" | grep -Eq '\b[0-9]{2}-[0-9]{7}\b' \
    && guard_block "added content contains an EIN-like pattern (NN-NNNNNNN)."
  return 0
}

# The hard rule across every pushed repo is "note WHERE a key lives, never the key itself."
guard_check_credentials() {
  if printf '%s\n' "$g_added" | grep -Eq '(-----BEGIN [A-Z ]*PRIVATE KEY-----|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,})'; then
    guard_block "added content looks like a credential (private key / API token)."
    echo "         Note WHERE the key lives, never the key itself." >&2
  fi
  return 0
}

# ---------------------------------------------------------------------------------------------
# borrower-term denylist.
#
# RESOLUTION ORDER, added 2026-07-28.  Previously every repo read its own $root/.pii-denylist,
# which is gitignored and per-machine, so the lists diverged silently and by one deal at a time.
# Measured that day: trcb-tools 59 terms, collateral-valuation 31 (a strict SUBSET), Career 0,
# BankingCaseStudies 0.  Twenty-eight borrower terms were armed in one pushed TRCB repo and
# absent from another whose entire subject is borrower collateral.
#   1. $PII_DENYLIST if set        (explicit override, used by tests and by the canary)
#   2. ~/.claude/pii-denylist      (shared CREDIT-DOMAIN list; only if this repo opts in, below)
#   3. $root/.pii-denylist         (the repo's own list; always read)
# Both 2 and 3 are read when both apply, because a repo may carry extra local terms.
#
# THE SHARED LIST IS OPT-IN, and that is a measured decision, not caution.  A blunt union of all
# seven lists was built and tested first: 233 terms, and it hit 72 places in ALREADY-TRACKED
# content across five repos, including MachineOps/HANDOFF.md, MachineOps/TODO.md,
# scripts/README.md, PinnSight's Loughran-McDonald sentiment lexicon and web/package-lock.json.
# Those are false positives -- borrower surnames that are also ordinary words, matched as bare
# substrings -- and arming them would have blocked edits to the highest-traffic files on the
# machine and taught `--no-verify` within a day.  The real gap the audit found was WITHIN the
# credit domain (collateral-valuation carried 31 terms, a strict subset of trcb-tools' 59, so 28
# borrower terms were armed in one pushed TRCB repo and absent from another whose entire subject
# is borrower collateral).  Scoping the shared list to the credit repos fixes exactly that and
# leaves a job-search file unarmed against a borrower's surname.
#
# Opt in by committing an empty marker file at .githooks/shared-denylist.  Tracked on purpose:
# whether a repo handles borrower work is a fact about the repo, and it belongs in review.
#
# Matching is a case-insensitive LITERAL SUBSTRING done in pure bash.  Not grep -q: MSYS on the
# Windows machine can SIGABRT on it.  Literal matching means the caller must list the hyphenated
# and concatenated variants of a name separately.
# ---------------------------------------------------------------------------------------------
guard_denylist_files() {
  [ -n "${PII_DENYLIST:-}" ] && [ -f "$PII_DENYLIST" ] && printf '%s\n' "$PII_DENYLIST"
  [ -f "$g_root/.githooks/shared-denylist" ] && [ -f "$HOME/.claude/pii-denylist" ] \
    && printf '%s\n' "$HOME/.claude/pii-denylist"
  [ -f "$g_root/.pii-denylist" ] && printf '%s\n' "$g_root/.pii-denylist"
  return 0
}

guard_check_denylist() {
  local added_lc term tl f
  added_lc="$(printf '%s' "$g_added" | tr 'A-Z' 'a-z')"
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    while IFS= read -r term || [ -n "$term" ]; do
      term="$(printf '%s' "$term" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      [ -z "$term" ] && continue
      case "$term" in \#*) continue ;; esac
      tl="$(printf '%s' "$term" | tr 'A-Z' 'a-z')"
      case "$added_lc" in
        *"$tl"*) guard_block "added content references a denylisted PII term (\"$term\")." ;;
      esac
    done < "$f"
  done < <(guard_denylist_files)
  return 0
}

# ---------------------------------------------------------------------------------------------
# FIGURE GUARD.  Added 2026-07-28.  This is the half of the firewall rule that had no code.
#
# ~/CLAUDE.md states the rule is "figure based, not just name based: a de-identified deal is
# still a leak if the figures are live."  Until now the guard enforced only the name half:
# a path block, an SSN regex, and the name denylist.  A commit carrying $487,312 and 74.9%
# with no borrower name attached passed clean.
#
# WHY IT IS NOT A NAIVE "figure + credit context" BLOCK
# That was measured first, reusing commit-msg's proven figrx/ctxrx against tracked content:
# 352 existing lines across the pushed repos would have blocked, 224 of them in
# PinnCredit/reviews alone.  Every sampled one was legitimate house method -- the credit-memo
# guidebook's fictional examples ("100 Broadway, Smithville KY", "Dr. Smith", "19XX"), the style
# profile's notation rules, and a de-identified sample memo.  Arming that would have fired on the
# exact de-identified method these repos exist to hold, and would have trained `git commit
# --no-verify`, which ALSO disarms the name denylist.  A guard that teaches bypass is worse than
# no guard.
#
# WHAT THE SIGNAL ACTUALLY IS
# Legitimate teaching figures are round ($120,000, $2,000M, 75%).  Live borrower figures are
# precise to the dollar ($487,312, $1,847,320).  Filtering to comma-grouped dollar amounts that
# are NOT house M/MM notation and whose last two digits are non-zero cut 352 lines to 38, and
# those 38 were concentrated in three known path clusters.  Hence: precision test + a per-repo
# path allowlist that names those clusters with a reason, rather than a weaker pattern.
#
# ROUNDING IS THE FIX, not the allowlist.  The allowlist is for corpora that are definitionally
# illustrative.  If you are reaching for it on a new file, round the figure instead.
# ---------------------------------------------------------------------------------------------

# Comma-grouped dollar amount, optionally with cents, optionally suffixed M/MM.  The suffix is
# CAPTURED rather than excluded so the precision test can discard it: house notation ($1,725M
# meaning $1.725MM) is definitionally rounded and must never fire.
_GUARD_FIG_RX='\$[0-9]{1,3}(,[0-9]{3})+(\.[0-9]{2})?M{0,2}'

# Credit context.  A precise figure alone is usually the firm's own money or public data; a
# precise figure BESIDE deal vocabulary is the leak shape.  Same list as commit-msg check 4.
_GUARD_CTX_RX='borrower|guarantor|collateral|cap ?rate|\bdscr\b|\bltv\b|rent ?roll|apprais|sponsor|per (sf|unit|door|key)|price per|\bnoi\b|occupanc'

# 0 (true) when the token is precise to the dollar, i.e. NOT rounded to the hundred.
_guard_fig_precise() {
  local n="$1" frac
  case "$n" in *M) return 1 ;; esac          # house M/MM notation is rounded by definition
  n="${n//[\$,]/}"
  case "$n" in
    *.*) frac="${n#*.}"
         case "$frac" in *[1-9]*) return 0 ;; esac   # real cents are always precise
         n="${n%%.*}" ;;
  esac
  [ "${#n}" -ge 3 ] || return 1                # under $100 is never a meaningful leak
  case "${n: -2}" in 00) return 1 ;; *) return 0 ;; esac
}

# A repo may exempt paths whose figures are illustrative by design.  Tracked, not gitignored:
# the REASON a corpus is exempt is domain knowledge and belongs in review, unlike the denylist,
# which is exempt from tracking because its contents are the sensitive thing.
_guard_fig_allowed() {
  local path="$1" allow="$g_root/.guard-figure-allow" pat
  [ -f "$allow" ] || return 1
  while IFS= read -r pat || [ -n "$pat" ]; do
    pat="$(printf '%s' "$pat" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -z "$pat" ] && continue
    case "$pat" in \#*) continue ;; esac
    case "$path" in $pat) return 0 ;; esac
  done < "$allow"
  return 1
}

guard_check_figures() {
  local f added toks t hit_ctx precise
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    # Binaries are handled by each repo's own path rules; scanning them here is noise.
    case "$f" in
      *.png|*.jpg|*.jpeg|*.gif|*.pdf|*.xls|*.xlsx|*.xlsm|*.doc|*.docx|*.ppt|*.pptx|*.zip|*.ico|*.woff|*.woff2|*.svg|*.npz) continue ;;
    esac
    # The guard's own machinery is infrastructure, not content. THIS FILE has to contain a
    # dollar-precise example to document what it blocks, and it is vendored into every repo, so
    # without this skip the commit that installs the guard is blocked by the guard in all ten.
    # Measured 2026-07-28: that is exactly what happened, twice, and ten .guard-figure-allow
    # entries would have been the wrong fix. Integrity of these files is protected by the md5
    # comparison in guard-audit.sh, which is a stronger check than scanning them for figures.
    # Scoped to .githooks/ only: a repo's real documents are never in there.
    case "$f" in .githooks/*) continue ;; esac
    added="$(git diff --cached --no-color -U0 -- "$f" | grep -E '^\+' | grep -vE '^\+\+\+' || true)"
    [ -z "$added" ] && continue

    precise=""
    while IFS= read -r t; do
      [ -z "$t" ] && continue
      _guard_fig_precise "$t" && precise="$precise $t"
    done < <(printf '%s\n' "$added" | grep -Eo "$_GUARD_FIG_RX" || true)
    [ -z "$precise" ] && continue

    hit_ctx=0
    printf '%s\n' "$added" | grep -Eiq "$_GUARD_CTX_RX" && hit_ctx=1

    # A precise figure beside a DENYLISTED NAME is a leak regardless of any allowlist, and the
    # denylist check will already have blocked it.  Say so specifically so the author fixes both
    # halves rather than only removing the name and re-committing the figures.
    if [ "$g_fail" -eq 1 ] && [ "$hit_ctx" -eq 1 ]; then
      guard_note "$f also adds precise figures ($precise) -- remove or round them too, not just the name."
      continue
    fi

    if [ "$hit_ctx" -eq 1 ]; then
      if _guard_fig_allowed "$f"; then
        guard_note "$f: precise figures ($precise) allowed by .guard-figure-allow (illustrative corpus)."
      else
        guard_block "$f adds precise per-deal figures ($precise) beside credit context."
        echo "         Round them (M = thousand, MM = million) or state the generalized point." >&2
        echo "         Illustrative corpus? Add the path to .guard-figure-allow with a reason." >&2
      fi
    else
      guard_note "$f adds a precise figure ($precise) with no deal context; fine if it is your own or public data."
    fi
  done < <(printf '%s\n' "$g_staged")
  return 0
}

guard_verdict() {
  if [ "$g_fail" -ne 0 ]; then
    echo "" >&2
    echo "Commit blocked to protect borrower confidentiality (GLBA)." >&2
    echo "Genuine false positive? Re-run with:  git commit --no-verify" >&2
    return 1
  fi
  return 0
}

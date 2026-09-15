# BookieBeats handoff

Newest entry first. Record measured state only: files changed, checks actually run, commit, remote
comparison, open items, and the next exact action.

## 2026-09-15, Mac: repo stood up for the Windows build of ArbDesk

**What this repo is.** Public home for Kyle's betting-desk tools, starting with ArbDesk, a static port of
the `ARB DESK` tab of the Sweeps2026 Google Sheet. Served free and public by GitHub Pages. No borrower
data, no credentials, no ledger data: only the calculator tab's formulas, formats and sample inputs.

**Why Windows builds it.** Kyle, 2026-09-14: the Windows machine "has more context / chat logs of building
the excel sheet". The Mac searched every Claude session transcript it holds and found exactly one human
turn about the ARB desk (2026-09-08, a request to copy the tab into a standalone sheet), so the layout
rationale and the MLB fee rates were built somewhere the Mac cannot see. Windows: read your own transcripts
for Kyle's stated reasons before building, and treat `ArbDesk/SPEC.md` as parity by default.

**State handed over, all measured on the Mac.**

- `ArbDesk/SPEC.md`: layout contract, block contracts, fee table with verification status, defects, speed
  rules, arithmetic rules, verification procedure, decisions.
- `ArbDesk/reference/Formulas.md`: every cell of the tab, formula verbatim, dropdown rules, formats,
  conditional formats, merges, and the hidden ARB LISTS tab.
- `ArbDesk/reference/ArbDeskCells.json` and `ArbDeskFormat.json`: the raw Sheets API dumps (values,
  formulas, validation, merges, conditional formats; colors, fonts, column widths, row heights).
- `ArbDesk/oracle/arbdesk_math.py`: Python replica of all five blocks in decimal arithmetic.
  `check_oracle.py` reproduces the 23 live output cells of 2026-09-14 (23/23, run 2026-09-15).
- `ArbDesk/oracle/fixtures/SweepCases.json`: 2,500 seeded random cases across every block, venue,
  execution and bet type with the oracle's outputs frozen as strings. This is the JavaScript parity target;
  Windows needs no Sheets access to test.
- Venue fee pages read 2026-09-14: Novig and ProphetX match the sheet's constants; Kalshi's 7% and 1.75%
  match the Feb 2026 schedule (archived copy, live PDF blocked); the MLB rates are unverified.

**Not done.** No HTML exists yet. `index.html` at the repo root is a one-line placeholder so the Pages
address resolves. GitHub Pages is enabled from `main`, root.

**Next exact action (Windows).**

1. `git clone https://github.com/KyleBretsch/BookieBeats` and `bash .githooks/install.sh`.
2. Read your transcripts for Kyle's design reasons; add any to `ArbDesk/SPEC.md` §9.
3. Build `ArbDesk/index.html` and `ArbDesk/arbdesk-math.js` to the spec; write `ArbDesk/test/parity.mjs`.
4. `python3 ArbDesk/oracle/check_oracle.py` and `node ArbDesk/test/parity.mjs`: zero mismatches.
5. Push to `main`; the page is live at `https://kylebretsch.github.io/BookieBeats/ArbDesk/` after the
   Pages build (usually under two minutes). Record the result here.

**Open for Kyle.** Show all execution modes at once (default off); round block 4 Kalshi Side B to whole
contracts; verify the Kalshi MLB rate on an in-app order ticket.

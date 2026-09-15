# ArbDesk: build specification

Port of the `ARB DESK` tab of Kyle's Sweeps2026 Google Sheet to a static web page served free and public
from GitHub Pages. Everything in this file was measured on 2026-09-14 from the live sheet through the Sheets
API unless a line says otherwise. The Sweeps2026 tab stays untouched and remains the fallback until Kyle
retires it.

**Governing rule: speed of use comes first, and the layout is parity by default.** The tab was laid out the
way it is for reasons Kyle holds; the Mac session could not find them written down (see HANDOFF.md). Nothing
about the block order, positions, labels, colors or flow changes unless Kyle opts in. Improvements are
layered on top and default to off where they would change what he sees.

## 1. Deliverable

| Item | Value |
|---|---|
| Page | `ArbDesk/index.html`, static, no framework, no build step, no server |
| Math | `ArbDesk/arbdesk-math.js`, one plain script the page loads and the test imports |
| Test | `ArbDesk/test/parity.mjs` (Node), reads `oracle/fixtures/SweepCases.json` and `oracle/fixtures/LiveCells20260914.json` |
| URL | `https://kylebretsch.github.io/BookieBeats/ArbDesk/` once `index.html` lands on `main` |
| External requests | Google Fonts for Roboto with a system fallback stack, and nothing else |
| State | Last inputs per block in `localStorage`, wrapped in try/catch; nothing leaves the browser |

## 2. Layout contract (measured)

Grid of 9 columns and 38 rows. Column widths in px: A 93, B 93, C 93, D 93, E 18, F 93, G 93, H 93, I 93,
total 762. Row heights: title row 50; each block header row 50; each field row 30; each spacer row 9; final
filler row 171. Total 1,212 px at 100% zoom. The sheet lives in a 912 px wide Chrome window, so design to
762 px content width and let it sit in a 912 px window without horizontal scroll. Gridlines hidden. Row 1
frozen.

Every label sits in a merged pair (A:B or F:G), every value in a merged pair (C:D or H:I). Block headers
span A:I. The left pair is the input side and the right pair is the result side, with these exceptions
that must stay where they are: Bet Type (H4, H11, H19) and Side B Execution (H27) are inputs on the right
side; ROI On Cash (C7) and Guaranteed Profit (C15, C23, C31) are results on the left side.

| Element | Background | Text | Font | Align |
|---|---|---|---|---|
| Page | `#0b0f14` | `#f0f6fc` | Roboto 11 | |
| Title A1 `ARB DESK` | `#0b0f14` | `#f0f6fc` | Roboto 17 bold | center |
| Block header band | `#16324f` | `#f0f6fc` | Roboto 11 bold | center |
| Label cell | `#151b23` | `#f0f6fc` | Roboto 11 | left |
| Input cell | `#0f1722` | `#8fc7ff` | Roboto 11 bold | center |
| Result cell | `#0f2419` | `#7ee787` | Roboto 11 bold | center |
| Result cell, value < 0 | `#2b161a` | `#ffa09a` | Roboto 11 bold | center |

The negative background is the sheet's conditional format (NUMBER_LESS 0) on H6, C7, C15, H15, C23, H23,
C31, H31 and the converter cells G35:G37, I35:I37; the positive rule (NUMBER_GREATER 0) paints `#0f2419`.

Number formats, verbatim from the sheet:

| Kind | Sheets format | Examples |
|---|---|---|
| American odds | `+#,##0.0;-#,##0.0;+0.0` | `+105.0`, `-110.0`, `+330.3` |
| Money | `$#,##0.00;-$#,##0.00` | `$2,597.12`, `-$3.10` |
| Exchange price | `0.00"¢"` | `47.00¢`, `75.45¢` |
| Contracts and stakes in H13, C20, C28, H29 | `#,##0.0` | `5,475.0`, `71.0` |
| Percent | `0.00%` | `7.41%` |

Note the quirk: H13 shows a Novig or ProphetX stake with one decimal (`36.6`) although the value carries
two. Reproduce the display, keep the value.

## 3. Blocks, inputs and outputs

Cell references are the sheet's. `reference/Formulas.md` carries every formula verbatim;
`oracle/arbdesk_math.py` is the executable definition and reproduces all 23 live output cells.

**Block 1, rows 2 to 7, SPORTSBOOK • SPORTSBOOK.** Inputs C4 Side A odds, C5 Side A amount, C6 Side B
odds, H4 Bet Type (Cash Bet | Free Bet). Outputs H5 Side B stake, H6 guaranteed profit, C7 ROI on cash,
H7 free bet conversion (blank unless Free Bet). Math: decimal odds equalization; a free bet returns
winnings only, so the stake at risk is zero.

**Block 2, rows 9 to 15, SPORTSBOOK • {KALSHI | NOVIG | PROPHETX}.** Header A9 is a dropdown that
switches the venue. Inputs C11 sportsbook odds, C12 sportsbook amount, C13 exchange price in cents, C14
execution, H11 Bet Type. Outputs H12 break-even price, H13 contracts to buy (Kalshi) or stake (Novig,
ProphetX), H14 cash required, C15 guaranteed profit, H15 ROI on total cash (or free bet conversion). Labels
A13, F13, A14, F14, F15 rename with the venue. Kalshi buys whole contracts: floor and ceiling of the target
are both evaluated and the one with the better guarantee wins; break even is the highest price, in 0.01¢
steps, at which the rounded debit stays within the limit. Novig and ProphetX use closed forms.

**Block 3, rows 17 to 23, {KALSHI | NOVIG | PROPHETX} • SPORTSBOOK.** Header A17 dropdown. Inputs C19
price, C20 contracts (Kalshi) or stake, C21 execution, C22 sportsbook odds, H19 Bet Type. Outputs H20
break-even odds (blank for a free bet, as the sheet does), H21 sportsbook stake, H22 total cash, C23
guaranteed profit, H23 ROI or conversion.

**Block 4, rows 25 to 31, nine pairings of {KALSHI | NOVIG | PROPHETX}.** Header A25 dropdown. Inputs
C27 Side A price, C28 Side A contracts or stake, C29 Side B price, C30 Side A execution, H27 Side B
execution. Outputs H28 break-even B price, H29 Side B contracts or stake, H30 total cash, C31 guaranteed
profit, H31 ROI. Labels A27 to A30 and F27 to F29 rename with the pairing.

**Block 5, rows 33 to 37, converter.** Inputs C35 Kalshi price, C36 Novig price, C37 ProphetX price.
Outputs American odds after fees: G35 Kalshi maker, I35 Kalshi taker, G36 Novig pre-match, I36 Novig live
taker, G37 and I37 ProphetX (identical). Per-contract fee, no order rounding, no MLB rates.

## 4. Fee models

As the sheet encodes them, then what the venues publish.

| Venue | Executions | Rate and basis | Rounding in the sheet | Verification |
|---|---|---|---|---|
| Kalshi | Taker 7%, Maker 1.75%, MLB Taker 3.5%, MLB Maker 0.875% | rate × contracts × price × (1 − price), added to the cost | fee rounded up to $0.0001, then the order total rounded up to the cent | 7%, 1.75% and round-up-to-the-next-cent match Kalshi's fee schedule effective Feb 5, 2026 (archived copy; the live PDF returned HTTP 429 on 2026-09-14). No MLB category exists in that schedule or in docs.kalshi.com/changelog; 3.5% is the S&P 500 and Nasdaq-100 rate there. The Kalshi help center says some sports markets carry different fees and that the in-app info icon on an order shows the fee. **Kyle verifies the MLB rate on an order ticket before the fee table is frozen.** |
| Novig | Pre-Match 0%, Live Taker 3%, Futures Taker 6%; makers 0% | coefficient × price × (1 − price) × contracts, added on top of the price | fee to 5 places, totals to the cent | Matches support.novig.com "Fees on Novig", read 2026-09-14: "Fee = Coefficient × Price × (1 − Price) × Number of contracts", "only takers pay", "added on top of the trade price". Parlays (0.10) are out of scope. |
| ProphetX | none | 2% of net gains per market | fee to the cent | Matches prophetx.co/lobby/t-c/trading-fees, page dated Aug 19, 2026, read 2026-09-14. No maker or taker distinction is published. |

Put every rate in one table at the top of `arbdesk-math.js` with the source URL and the date it was
last verified, and show that table on the page behind one click. A venue change is then one line.

## 5. Defects in the sheet the port must not carry over

1. H27 holds `Pre-Match / Maker`, which is on no list and matches no fee branch, so the KALSHI • KALSHI
   block charges Side B the 7% taker rate under a label that says Maker. Verified by replication: the
   displayed total $2,635.06, profit $279.94 and ROI 10.62% reproduce only at 7%; at 1.75% the same
   inputs give $2,616.87, $298.13 and 11.39%.
2. The hidden ARB LISTS tab holds Kalshi's four execution options in all four columns. Novig's Live and
   Futures options cannot be selected, and with the Kalshi list a Novig leg prices at 3% for "Taker" and
   0% for anything else. Execution options must follow the venue.
3. Kalshi contracts can be fractional: C20 holds 71.03 and displays 71.0; block 4 never rounds Side B
   to whole contracts, unlike block 2. Whether block 4 should round is Kyle's decision (open).
4. The converter ignores the MLB rates and treats ProphetX maker and taker identically.
5. Each fee rate is typed into 11 or 12 formulas.

## 6. Speed: what stays and what gets faster

Stays identical: five bands in the same order and positions, labels left and values right, inputs in the
left pair and results in the right pair, the dark theme, Roboto, the number formats, and the whole desk on
one screen with no navigation and no modes.

Gets faster:

- Tab and Enter move from input to input in reading order within a block, then to the next block. Result
  cells are not focusable and cannot be overwritten (the sheet has zero protected ranges today).
- Focus selects the whole field. Recalculate on every keystroke. Odds accept `105`, `+105`, `-110`;
  money accepts `2500`, `$2,500`, `2,500.00`; prices accept `47`, `47.5`, `47.5¢`.
- Dropdowns become one-click segmented controls; arrow keys and the first letter also work.
- Inputs survive a reload. Escape clears the block that has focus.
- One click copies a contracts, stake or cash figure as a bare number for the order ticket.
- Optional, default off, Kyle's call: blocks 2 to 4 may show every execution mode side by side, the way
  block 5 does, so the execution toggle disappears rather than moves.

## 7. Arithmetic rules for the port

The sheet is IEEE double arithmetic with these steps, in this order, and the JavaScript must follow them
literally rather than simplify:

- `ROUND(x, n)`: half away from zero.
- `CEILING(x, step)` and `FLOOR(x, step)`: to a multiple of `step`. Snap `x / step` to 9 decimals before
  taking `Math.ceil` or `Math.floor`, otherwise a value that is exactly on a boundary in the sheet lands on
  the wrong side in floating point (23.8062 / 0.0001 is not an integer in a double).
- Kalshi debit for n contracts at price p with rate r: `CEILING(ROUND(n·p + CEILING(ROUND(r·n·p·(1−p), 8),
  0.0001), 8), 0.01)`.
- Kalshi break even: solve the quadratic for the unrounded root, start 0.05 below its floor to 0.0001,
  scan 501 prices upward in 0.0001 steps, keep the highest price at or below 0.9999 whose rounded debit is
  within the limit. Block 2 uses `limit = MIN(win, n − stake at risk)` for both floor and ceiling contract
  counts and reports the larger; block 4 uses `limit = Side A winnings` and the unrounded Side B count.
- Novig break even: `p = ((1+c) − sqrt((1+c)² − 4·c·q)) / (2·c)`, `q = win / payout`, `c = 0` gives
  `p = q`; then floor to 0.0001 and clamp to [0, 0.9999].
- ProphetX break even: block 2 `W(1−f) / (W + R − W·f)`; block 4 `0.98·Awin / (0.98·Awin + cashA)`.
- American odds from a ratio: ratio ≥ 1 gives `+ROUND(100·ratio, 1)`, otherwise `−ROUND(100/ratio, 1)`.
  Block 3 uses ROUNDUP and ROUNDDOWN instead of ROUND for the break-even odds.

`oracle/arbdesk_math.py` implements all of it in decimal arithmetic and is the reference. Where the JS and
the oracle disagree on a boundary case, the live sheet decides; the Mac session can key the case into the
sheet through the API on request.

## 8. Verification before Kyle touches it

1. `node ArbDesk/test/parity.mjs` must report zero mismatches on all 2,500 sweep cases and on the 23
   live cells. Compare the values, not the formatted strings, and compare them exactly. A mismatch is a
   bug, never a tolerance.
2. Render the page at 762 px content width in a 912 px window and screenshot it beside the sheet at the
   same width. Same bands, same labels, same positions, same colors.
3. Keyboard walk: Tab from C4 through every input of every block without touching a result cell.
4. The H27 case: select KALSHI • KALSHI, Side B execution Maker, inputs 75.45¢, 2915, 13.79¢, Side A
   Maker; the page must show total $2,616.87, profit $298.13, ROI 11.39%.

## 9. Decisions

| Decision | Status |
|---|---|
| Hosting | Decided by Kyle 2026-09-14: free and public, GitHub Pages from this repo |
| Repo home | `~/Documents/BookieBeats`, public, `KyleBretsch/BookieBeats` |
| Show all execution modes at once in blocks 2 to 4 | Open, default off |
| Round block 4 Kalshi Side B to whole contracts | Open, changes a number |
| Kalshi MLB rates | Open, Kyle checks an order ticket in the app |
| Layout rationale beyond what is measurable | Open; the Windows machine holds the chat logs from building the sheet and should read them before building |

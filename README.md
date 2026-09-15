# BookieBeats

Kyle Bretsch's betting-desk tools, published free and public on GitHub Pages.

| Tool | Status | Address |
|---|---|---|
| ArbDesk, a static port of the ARB DESK calculator tab of the Sweeps2026 sheet | Build pending on the Windows machine | `https://kylebretsch.github.io/BookieBeats/ArbDesk/` |

Start with `HANDOFF.md` for current state and the next action, then `ArbDesk/SPEC.md` for the build
contract. `ArbDesk/reference/` holds the sheet's formulas and formats as measured; `ArbDesk/oracle/` holds
the Python reference implementation and the frozen test fixtures.

```bash
python3 ArbDesk/oracle/check_oracle.py      # 23 live cells through the oracle
python3 ArbDesk/oracle/generate_sweep.py    # regenerate the 2,500-case parity fixture (seeded)
```

Commit guard: `bash .githooks/install.sh` once per clone. It blocks credentials, SSN and EIN patterns.
Nothing in this repo is confidential; the guard is a backstop.

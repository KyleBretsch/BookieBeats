"""Re-run the 23 live output cells of 2026-09-14 through the Python oracle. Exit 1 on any mismatch."""
import json, sys
from decimal import Decimal as D
from arbdesk_math import block1, block2, block3, block4, block5, rnd
fx = json.load(open("fixtures/LiveCells20260914.json"))
rows = []
b = block1(**fx["block1"]["inputs"]); e = fx["block1"]["expected"]
rows += [("H5", b["stakeB"], e["H5_stakeB"]), ("H6", b["profit"], e["H6_profit"]), ("C7", rnd(100*b["roi"], 2), e["C7_roi_pct"])]
b = block2(**fx["block2"]["inputs"]); e = fx["block2"]["expected"]
rows += [("H12", b["breakeven"], e["H12_breakeven_c"]), ("H13", b["size"], e["H13_size"]), ("H14", b["cash"], e["H14_cash"]), ("C15", b["profit"], e["C15_profit"]), ("H15", rnd(100*b["roi"], 2), e["H15_roi_pct"])]
b = block3(**fx["block3"]["inputs"]); e = fx["block3"]["expected"]
rows += [("H20", b["breakeven"], e["H20_breakeven_odds"]), ("H21", b["stake"], e["H21_stake"]), ("H22", b["total"], e["H22_total"]), ("C23", b["profit"], e["C23_profit"]), ("H23", rnd(100*b["roi"], 2), e["H23_roi_pct"])]
b = block4(**fx["block4"]["inputs"]); e = fx["block4"]["expected"]
rows += [("H28", b["breakeven"], e["H28_breakeven_c"]), ("H29", b["sizeB"], e["H29_sizeB"]), ("H30", b["total"], e["H30_total"]), ("C31", b["profit"], e["C31_profit"]), ("H31", rnd(100*b["roi"], 2), e["H31_roi_pct"])]
for item in fx["block5"]:
    b = block5(item["price_c"])
    for k, v in item["expected"].items():
        rows.append((k.split("_")[0], b[k.split("_", 1)[1]], v))
ok = 0
for cell, got, exp in rows:
    m = D(str(got)).normalize() == D(exp).normalize(); ok += m
    print(f"{cell:4s} sheet={exp:>9s} oracle={str(got):>12s} {'OK' if m else 'MISMATCH'}")
print(f"{ok}/{len(rows)} cells reproduced")
sys.exit(0 if ok == len(rows) else 1)

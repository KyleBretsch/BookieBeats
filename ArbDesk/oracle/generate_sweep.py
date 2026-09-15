"""Generate SweepCases.json: seeded random inputs across every block, venue, execution and bet type,
with the oracle's outputs frozen as strings. The JavaScript port must reproduce every output exactly."""
import json, random
from decimal import Decimal as D
from arbdesk_math import block1, block2, block3, block4, block5
rng = random.Random(20260914)
EX = {"KALSHI": ["Taker", "Maker", "MLB Taker", "MLB Maker"], "NOVIG": ["Pre-Match", "Live Taker", "Futures Taker"], "PROPHETX": ["Taker"]}
V = ["KALSHI", "NOVIG", "PROPHETX"]
def odds():  m = rng.randint(100, 400); return m if rng.random() < 0.5 else -m
def money(lo, hi): return round(rng.uniform(lo, hi), 2) if rng.random() < 0.5 else float(rng.randint(int(lo), int(hi)))
def price(): return rng.randint(3, 97) if rng.random() < 0.7 else round(rng.uniform(3, 97), 2)
def size(venue): return rng.randint(1, 5000) if venue == "KALSHI" else money(5, 5000)
def bet(): return "Cash Bet" if rng.random() < 0.7 else "Free Bet"
def s(x): return None if x is None else str(D(str(x)).normalize()) if not isinstance(x, D) else str(x.normalize())
cases = []
for _ in range(300):
    i = dict(oddsA=odds(), amtA=money(10, 5000), oddsB=odds(), bet=bet()); o = block1(**i)
    cases.append({"block": 1, "inputs": i, "expected": {k: s(v) for k, v in o.items()}})
for venue in V:
    for _ in range(200):
        i = dict(venue=venue, odds=odds(), amount=money(10, 5000), price_c=price(), ex=rng.choice(EX[venue]), bet=bet()); o = block2(**i)
        cases.append({"block": 2, "inputs": i, "expected": {k: s(v) for k, v in o.items()}})
    for _ in range(200):
        i = dict(venue=venue, price_c=price(), size=size(venue), ex=rng.choice(EX[venue]), odds=odds(), bet=bet()); o = block3(**i)
        cases.append({"block": 3, "inputs": i, "expected": {k: s(v) for k, v in o.items()}})
for vA in V:
    for vB in V:
        for _ in range(100):
            i = dict(vA=vA, vB=vB, priceA_c=price(), sizeA=size(vA), priceB_c=price(), exA=rng.choice(EX[vA]), exB=rng.choice(EX[vB])); o = block4(**i)
            cases.append({"block": 4, "inputs": i, "expected": {k: s(v) for k, v in o.items()}})
for _ in range(100):
    p = price(); o = block5(p)
    cases.append({"block": 5, "inputs": {"price_c": p}, "expected": {k: s(v) for k, v in o.items()}})
json.dump({"seed": 20260914, "generated": "2026-09-15", "oracle": "arbdesk_math.py", "count": len(cases), "cases": cases}, open("fixtures/SweepCases.json", "w"), indent=0)
print("cases:", len(cases))

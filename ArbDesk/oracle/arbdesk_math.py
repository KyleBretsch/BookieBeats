"""Python replication of every ARB DESK formula (Sweeps2026, sheetId 394391295), read 2026-09-14.
Mirrors the sheet's rounding exactly: ROUND = half away from zero, CEILING/FLOOR to a step,
ROUND(x,8) before every CEILING as the sheet does. Serves as the differential oracle for a port."""
from decimal import Decimal as D, ROUND_HALF_UP, ROUND_CEILING, ROUND_FLOOR, getcontext
getcontext().prec = 34

def dec(x): return x if isinstance(x, D) else D(str(x))
def rnd(x, places): return dec(x).quantize(D(1).scaleb(-places), rounding=ROUND_HALF_UP)
def ceil_to(x, step): x, step = dec(x), dec(step); return (x/step).to_integral_value(rounding=ROUND_CEILING)*step
def floor_to(x, step): x, step = dec(x), dec(step); return (x/step).to_integral_value(rounding=ROUND_FLOOR)*step
def frac(odds):                       # profit per $1 staked at American odds
    o = dec(odds); return o/100 if o > 0 else D(100)/abs(o)
def american(ratio):                  # ratio = profit per $1 -> American odds, 1 dp
    return rnd(100*ratio, 1) if ratio >= 1 else -rnd(100/ratio, 1)

# Fee constants exactly as the sheet encodes them (unverified against the venues)
def kalshi_rate(ex): return {"MLB Maker": D("0.00875"), "MLB Taker": D("0.035"), "Maker": D("0.0175")}.get(ex, D("0.07"))
def novig_rate(ex):  return D("0.06") if ex == "Futures Taker" else (D("0.03") if ex in ("Live Taker", "Taker") else D(0))
PX = D("0.02")                        # ProphetX: 2% of net winnings

def kalshi_debit(n, px, rate):        # cash to buy n contracts at price px, sheet rounding
    fee = ceil_to(rnd(rate*n*px*(1-px), 8), "0.0001")
    return ceil_to(rnd(n*px + fee, 8), "0.01")

def kalshi_scan(n, lim, rate, guard_limit):   # the SEQUENCE(501)/MAP/FILTER break-even search
    if n <= 0: return D(0)
    if guard_limit and lim <= 0: raw = D(0)
    else:
        disc = (1+rate)**2 - 4*rate*lim/n
        raw = ((1+rate) - max(D(0), disc).sqrt())/(2*rate)
    start = max(D("0.0001"), floor_to(raw, "0.0001") - D("0.05"))
    best = D(0)
    for i in range(501):
        px = start + i*D("0.0001")
        if px <= D("0.9999") and kalshi_debit(n, px, rate) <= lim: best = max(best, px)
    return best

def novig_root(q, c):
    return q if c == 0 else ((1+c) - max(D(0), (1+c)**2 - 4*c*q).sqrt())/(2*c)

def block1(oddsA, amtA, oddsB, bet):          # SPORTSBOOK • SPORTSBOOK
    amtA = dec(amtA); free = bet == "Free Bet"; a = 1+frac(oddsA); b = 1+frac(oddsB)
    stakeB = rnd(amtA*(a-1)/b, 2) if free else rnd(amtA*a/b, 2)
    profit = min(rnd(amtA*frac(oddsA) - stakeB, 2), rnd(stakeB*frac(oddsB) - (D(0) if free else amtA), 2))
    roi = profit/(stakeB if free else amtA + stakeB)
    return dict(stakeB=stakeB, profit=profit, roi=roi, conv=(profit/amtA if free else None))

def block2(venue, odds, amount, price_c, ex, bet):   # SPORTSBOOK • {KALSHI|NOVIG|PROPHETX}
    amount = dec(amount); W = rnd(amount*frac(odds), 2); R = D(0) if bet == "Free Bet" else amount; p = dec(price_c)/100
    if venue == "KALSHI":
        rate = kalshi_rate(ex); target = W + R
        fl, ce = max(D(0), floor_to(target, 1)), max(D(0), ceil_to(target, 1))
        thr = lambda n: D(0) if n <= 0 else kalshi_scan(n, min(W, n - R), rate, True)
        be = 100*max(thr(fl), thr(ce))
        guar = lambda n: min(W - kalshi_debit(n, p, rate), n - kalshi_debit(n, p, rate) - R)
        n = fl if guar(fl) >= guar(ce) else ce
        cash = kalshi_debit(n, p, rate); size = n
        profit = min(rnd(W - cash, 2), rnd(n - cash - R, 2))
    elif venue == "NOVIG":
        c = novig_rate(ex); n = W + R
        be = 100*max(D(0), min(D("0.9999"), floor_to(novig_root(W/n, c), "0.0001")))
        S = rnd(n*p, 2); cash = rnd(S + rnd(c*p*(1-p)*(S/p), 5), 2); size = S
        profit = min(rnd(W - cash, 2), rnd(S/p - cash - R, 2))
    else:
        be = 100*max(D(0), min(D("0.9999"), floor_to(W*(1-PX)/(W + R - W*PX), "0.0001")))
        S = rnd((W+R)/(1 - PX*(1-p))*p, 2); cash = S; size = S; G = S/p - S
        profit = min(rnd(W - S, 2), rnd(G - rnd(PX*G, 2) - R, 2))
    roi = profit/amount if bet == "Free Bet" else profit/(amount + cash)
    return dict(breakeven=be, size=size, cash=cash, profit=profit, roi=roi)

def exch_side(venue, price_c, size, ex):     # shared preamble: cash out the door and winnings if this side wins
    p = dec(price_c)/100; size = dec(size); n = size if venue == "KALSHI" else size/p
    if venue == "KALSHI": cash = kalshi_debit(n, p, kalshi_rate(ex))
    elif venue == "NOVIG": cash = size + rnd(novig_rate(ex)*p*(1-p)*n, 5)
    else: cash = size
    win = (n*(1-p) - rnd(PX*n*(1-p), 2)) if venue == "PROPHETX" else n - cash
    return p, n, cash, win

def block3(venue, price_c, size, ex, odds, bet):    # {KALSHI|NOVIG|PROPHETX} • SPORTSBOOK
    pA, n, cashA, Awin = exch_side(venue, price_c, size, ex); m = frac(odds); free = bet == "Free Bet"
    be = None if (free or n <= 0 or Awin <= 0) else (ceil_to(100*cashA/Awin, "0.1") if cashA/Awin >= 1 else -floor_to(100/(cashA/Awin), "0.1"))
    stake = rnd((Awin + cashA)/m, 2) if free else rnd((Awin + cashA)/(1+m), 2)
    total = rnd(cashA + (D(0) if free else stake), 2)
    profit = min(rnd(Awin - (D(0) if free else stake), 2), rnd(stake*m - cashA, 2))
    return dict(breakeven=be, stake=stake, total=total, profit=profit, roi=(profit/stake if free else profit/total))

def block4(vA, vB, priceA_c, sizeA, priceB_c, exA, exB):   # {K|N|P} • {K|N|P}
    pA, n, cashA, Awin = exch_side(vA, priceA_c, sizeA, exA); pB = dec(priceB_c)/100
    kA, kB, nvB, pxB = vA == "KALSHI", vB == "KALSHI", vB == "NOVIG", vB == "PROPHETX"
    rateB, cB, fB = kalshi_rate(exB), novig_rate(exB), (PX if pxB else D(0))
    nB = n/(1 - fB*(1-pB)) if kA else (Awin + cashA)/(1 - fB*(1-pB))
    SB = rnd(nB*pB, 2); nBf = nB if kB else SB/pB
    cashB = kalshi_debit(nB, pB, rateB) if kB else (SB + rnd(cB*pB*(1-pB)*nBf, 5) if nvB else SB)
    Bwin = ((nBf - SB) - rnd(PX*(nBf - SB), 2)) if pxB else nBf - cashB
    if n <= 0 or Awin <= 0: be = D(0)
    elif kB: be = 100*kalshi_scan(nB, Awin, rateB, False)
    elif nvB: be = 100*max(D(0), min(D("0.9999"), floor_to(novig_root(Awin/(Awin + cashA), cB), "0.0001")))
    else: be = 100*max(D(0), min(D("0.9999"), floor_to(D("0.98")*Awin/(D("0.98")*Awin + cashA), "0.0001")))
    total = rnd(cashA + cashB, 2); profit = rnd(min(Awin - cashB, Bwin - cashA), 2)
    return dict(breakeven=be, sizeB=(nB if kB else SB), total=total, profit=profit, roi=profit/total)

def block5(price_c):                          # converter row: American odds after fees
    p = dec(price_c)/100
    def from_cost(cost): return rnd(100*(1-cost)/cost, 1) if cost <= D("0.5") else -rnd(100*cost/(1-cost), 1)
    win = (1-p)*D("0.98")
    return dict(kalshi_maker=from_cost(ceil_to(p + D("0.0175")*p*(1-p), "0.0001")),
                kalshi_taker=from_cost(ceil_to(p + D("0.07")*p*(1-p), "0.0001")),
                novig_prematch=from_cost(p), novig_live=from_cost(p + D("0.03")*p*(1-p)),
                prophetx=(rnd(100*win/p, 1) if win >= p else -rnd(100*p/win, 1)))

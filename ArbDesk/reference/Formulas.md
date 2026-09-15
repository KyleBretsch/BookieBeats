# ARB DESK formulas, cell by cell

Source: Sweeps2026, tab `ARB DESK` (sheetId 394391295), read through the Sheets API on 2026-09-14. Every
typed value, formula, dropdown rule and number format on the tab. Labels are shown as the text the cell
displays; a label that is itself a formula is listed with its formula. Nothing here is edited or simplified.

Grid: 38 rows × 9 columns (A–I). Labels occupy the left cell of a merged pair (A:B or F:G); values occupy the
right pair (C:D or H:I). Column E is an 18 px spacer. Row 1 is frozen.

## Block 1: SPORTSBOOK • SPORTSBOOK

**A2** text: `SPORTSBOOK • SPORTSBOOK`

**A4** text: `Side A Odds`

**C4** input: `105`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

**F4** text: `Bet Type`

**H4** text: `Cash Bet`  
Dropdown (ONE_OF_LIST): Cash Bet, Free Bet

**A5** text: `Side A Amount`

**C5** input: `40`  
Number format: `$#,##0.00;-$#,##0.00`

**F5** text: `Side B Stake`

**H5** shows `$36.61`  
Number format: `$#,##0.00;-$#,##0.00`

```
=IF(OR($H$4="",$C$4="",$C$5="",$C$6=""),"",LET(a_dec,IF($C$4>0,1+$C$4/100,1+100/ABS($C$4)),b_dec,IF($C$6>0,1+$C$6/100,1+100/ABS($C$6)),ROUND(IF($H$4="Free Bet",$C$5*(a_dec-1)/b_dec,$C$5*a_dec/b_dec),2)))
```

**A6** text: `Side B Odds`

**C6** input: `124`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

**F6** text: `Guaranteed Profit`

**H6** shows `$5.39`  
Number format: `$#,##0.00;-$#,##0.00`

```
=IF($H$5="","",MIN(ROUND($C$5*(IF($C$4>0,$C$4/100,100/ABS($C$4)))-$H$5,2),ROUND($H$5*(IF($C$6>0,$C$6/100,100/ABS($C$6)))-IF($H$4="Free Bet",0,$C$5),2)))
```

**A7** text: `ROI On Cash`

**C7** shows `7.04%`  
Number format: `0.00%`

```
=IF(OR($H$6="",$H$5=""),"",$H$6/IF($H$4="Free Bet",$H$5,$C$5+$H$5))
```

**F7** text: `Free Bet Conversion`

**H7** shows `None`  
Number format: `0.00%`

```
=IF(OR($H$4<>"Free Bet",$H$6=""),"",$H$6/$C$5)
```

## Block 2: SPORTSBOOK • {KALSHI | NOVIG | PROPHETX}

**A9** text: `SPORTSBOOK • KALSHI`  
Dropdown (ONE_OF_LIST): SPORTSBOOK • KALSHI, SPORTSBOOK • NOVIG, SPORTSBOOK • PROPHETX

**A11** text: `Sportsbook Odds`

**C11** input: `119`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

**F11** text: `Bet Type`

**H11** text: `Cash Bet`  
Dropdown (ONE_OF_LIST): Cash Bet, Free Bet

**A12** text: `Sportsbook Amount`

**C12** input: `2500`  
Number format: `$#,##0.00;-$#,##0.00`

**F12** text: `Break Even Price`

**H12** shows `53.90¢`  
Number format: `0.00"¢"`

```
=IF($A$9="SPORTSBOOK • KALSHI",IF(OR($C$11="",$C$12="",$C$14="",$H$11=""),"",LET(stake_amount,$C$12,win_profit,ROUND($C$12*IF($C$11>0,$C$11/100,100/ABS($C$11)),2),stake_at_risk,IF($H$11="Free Bet",0,stake_amount),target_contracts,win_profit+stake_at_risk,floor_contracts,MAX(0,FLOOR(target_contracts,1)),ceil_contracts,MAX(0,CEILING(target_contracts,1)),fee_rate,IF($C$14="MLB Maker",0.00875,IF($C$14="MLB Taker",0.035,IF($C$14="Maker",0.0175,0.07))),debit_for,LAMBDA(n,px,CEILING(ROUND(n*px+CEILING(ROUND(fee_rate*n*px*(1-px),8),0.0001),8),0.01)),threshold_for,LAMBDA(n,IF(n<=0,0,LET(limit_amount,MIN(win_profit,n-stake_at_risk),raw_root,IF(limit_amount<=0,0,((1+fee_rate)-SQRT(MAX(0,(1+fee_rate)^2-4*fee_rate*limit_amount/n)))/(2*fee_rate)),start_price,MAX(0.0001,FLOOR(raw_root,0.0001)-0.05),prices,SEQUENCE(501,1,start_price,0.0001),debits,MAP(prices,LAMBDA(px,debit_for(n,px))),IFERROR(MAX(FILTER(prices,(prices<=0.9999)*(debits<=limit_amount))),0)))),100*MAX(threshold_for(floor_contracts),threshold_for(ceil_contracts)))),IF($A$9="SPORTSBOOK • NOVIG",IF(OR($C$11="",$C$12="",$C$14="",$H$11=""),"",LET(W,ROUND($C$12*IF($C$11>0,$C$11/100,100/ABS($C$11)),2),R,IF($H$11="Free Bet",0,$C$12),n,W+R,c,IF($C$14="Futures Taker",0.06,IF(OR($C$14="Live Taker",$C$14="Taker"),0.03,0)),IF(n<=0,"",LET(q,W/n,root,IF(c=0,q,((1+c)-SQRT(MAX(0,(1+c)^2-4*c*q)))/(2*c)),100*MAX(0,MIN(0.9999,FLOOR(root,0.0001))))))),IF(OR($C$11="",$C$12="",$H$11=""),"",LET(W,ROUND($C$12*IF($C$11>0,$C$11/100,100/ABS($C$11)),2),R,IF($H$11="Free Bet",0,$C$12),f,0.02,IF(W+R<=0,"",100*MAX(0,MIN(0.9999,FLOOR(W*(1-f)/(W+R-W*f),0.0001))))))))
```

**A13** shows `Kalshi Price`

```
=IF($A$9="SPORTSBOOK • NOVIG","Novig Price",IF($A$9="SPORTSBOOK • PROPHETX","ProphetX Price","Kalshi Price"))
```

**C13** input: `47`  
Number format: `0.00"¢"`

**F13** shows `Contracts To Buy`

```
=IF($A$9="SPORTSBOOK • NOVIG","Novig Stake",IF($A$9="SPORTSBOOK • PROPHETX","ProphetX Stake","Contracts To Buy"))
```

**H13** shows `5,475.0`  
Number format: `#,##0.0`

```
=IF($A$9="SPORTSBOOK • KALSHI",IF(OR($C$11="",$C$12="",$C$13="",$C$14="",$H$11=""),"",LET(stake_amount,$C$12,win_profit,ROUND($C$12*IF($C$11>0,$C$11/100,100/ABS($C$11)),2),stake_at_risk,IF($H$11="Free Bet",0,stake_amount),target_contracts,win_profit+stake_at_risk,floor_contracts,MAX(0,FLOOR(target_contracts,1)),ceil_contracts,MAX(0,CEILING(target_contracts,1)),test_price,$C$13/100,fee_rate,IF($C$14="MLB Maker",0.00875,IF($C$14="MLB Taker",0.035,IF($C$14="Maker",0.0175,0.07))),debit_for,LAMBDA(n,CEILING(ROUND(n*test_price+CEILING(ROUND(fee_rate*n*test_price*(1-test_price),8),0.0001),8),0.01)),floor_guarantee,MIN(win_profit-debit_for(floor_contracts),floor_contracts-debit_for(floor_contracts)-stake_at_risk),ceil_guarantee,MIN(win_profit-debit_for(ceil_contracts),ceil_contracts-debit_for(ceil_contracts)-stake_at_risk),IF(floor_guarantee>=ceil_guarantee,floor_contracts,ceil_contracts))),IF(OR($C$11="",$C$12="",$C$13="",$H$11=""),"",LET(W,ROUND($C$12*IF($C$11>0,$C$11/100,100/ABS($C$11)),2),R,IF($H$11="Free Bet",0,$C$12),p,$C$13/100,IF($A$9="SPORTSBOOK • NOVIG",ROUND((W+R)*p,2),ROUND((W+R)/(1-0.02*(1-p))*p,2)))))
```

**A14** shows `Kalshi Execution`

```
=IF($A$9="SPORTSBOOK • NOVIG","Novig Execution",IF($A$9="SPORTSBOOK • PROPHETX","ProphetX Execution","Kalshi Execution"))
```

**C14** text: `Maker`  
Dropdown (ONE_OF_RANGE): ='ARB LISTS'!$A$1:$A$4

**F14** shows `Kalshi Cash Required`

```
=IF($A$9="SPORTSBOOK • NOVIG","Novig Cash Required",IF($A$9="SPORTSBOOK • PROPHETX","ProphetX Cash Required","Kalshi Cash Required"))
```

**H14** shows `$2,597.12`  
Number format: `$#,##0.00;-$#,##0.00`

```
=IF($A$9="SPORTSBOOK • KALSHI",IF($H$13="","",CEILING(ROUND($H$13*($C$13/100)+CEILING(ROUND(IF($C$14="MLB Maker",0.00875,IF($C$14="MLB Taker",0.035,IF($C$14="Maker",0.0175,0.07)))*$H$13*($C$13/100)*(1-$C$13/100),8),0.0001),8),0.01)),IF($H$13="","",IF($A$9="SPORTSBOOK • NOVIG",IF($C$14="","",LET(S,$H$13,p,$C$13/100,c,IF($C$14="Futures Taker",0.06,IF(OR($C$14="Live Taker",$C$14="Taker"),0.03,0)),ROUND(S+ROUND(c*p*(1-p)*(S/p),5),2))),$H$13)))
```

**A15** text: `Guaranteed Profit`

**C15** shows `$377.88`  
Number format: `$#,##0.00;-$#,##0.00`

```
=IF($A$9="SPORTSBOOK • KALSHI",IF($H$14="","",MIN(ROUND(ROUND($C$12*IF($C$11>0,$C$11/100,100/ABS($C$11)),2)-$H$14,2),ROUND($H$13-$H$14-IF($H$11="Free Bet",0,$C$12),2))),IF(OR($H$13="",$H$14=""),"",LET(W,ROUND($C$12*IF($C$11>0,$C$11/100,100/ABS($C$11)),2),R,IF($H$11="Free Bet",0,$C$12),S,$H$13,p,$C$13/100,nb,S/p,IF($A$9="SPORTSBOOK • NOVIG",MIN(ROUND(W-$H$14,2),ROUND(nb-$H$14-R,2)),LET(G,nb-S,fee,ROUND(0.02*G,2),MIN(ROUND(W-S,2),ROUND(G-fee-R,2)))))))
```

**F15** shows `ROI On Total Cash`

```
=IF($H$11="Free Bet","Free Bet Conversion","ROI On Total Cash")
```

**H15** shows `7.41%`  
Number format: `0.00%`

```
=IF(OR($C$15="",$H$14=""),"",IF($H$11="Free Bet",$C$15/$C$12,$C$15/($C$12+$H$14)))
```

## Block 3: {KALSHI | NOVIG | PROPHETX} • SPORTSBOOK

**A17** text: `KALSHI • SPORTSBOOK`  
Dropdown (ONE_OF_LIST): KALSHI • SPORTSBOOK, NOVIG • SPORTSBOOK, PROPHETX • SPORTSBOOK

**A19** shows `Kalshi Price`

```
=IF($A$17="NOVIG • SPORTSBOOK","Novig Price",IF($A$17="PROPHETX • SPORTSBOOK","ProphetX Price","Kalshi Price"))
```

**C19** input: `75.45`  
Number format: `0.00"¢"`

**F19** text: `Bet Type`

**H19** text: `Cash Bet`  
Dropdown (ONE_OF_LIST): Cash Bet, Free Bet

**A20** shows `Kalshi Contracts`

```
=IF($A$17="NOVIG • SPORTSBOOK","Novig Stake",IF($A$17="PROPHETX • SPORTSBOOK","ProphetX Stake","Kalshi Contracts"))
```

**C20** input: `71.03`  
Number format: `#,##0.0`

**F20** text: `Break Even Odds`

**H20** shows `+330.3`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

```
=IF(OR($C$19="",$C$20="",$C$21="",$H$19=""),"",IF($H$19="Free Bet","",LET(tA,$A$17,nvA,tA="NOVIG • SPORTSBOOK",pxA,tA="PROPHETX • SPORTSBOOK",pA,$C$19/100,n,IF(OR(nvA,pxA),$C$20/pA,$C$20),rateA,IF($C$21="MLB Maker",0.00875,IF($C$21="MLB Taker",0.035,IF($C$21="Maker",0.0175,0.07))),cA,IF($C$21="Futures Taker",0.06,IF(OR($C$21="Live Taker",$C$21="Taker"),0.03,0)),cashA,IF(pxA,$C$20,IF(nvA,$C$20+ROUND(cA*pA*(1-pA)*n,5),CEILING(ROUND(n*pA+CEILING(ROUND(rateA*n*pA*(1-pA),8),0.0001),8),0.01))),Awin,IF(pxA,n*(1-pA)-ROUND(0.02*n*(1-pA),2),n-cashA),m,IF($C$22="",0,IF($C$22>0,$C$22/100,100/ABS($C$22))),IF(OR(n<=0,Awin<=0),"",LET(mm,cashA/Awin,IF(mm>=1,ROUNDUP(100*mm,1),-ROUNDDOWN(100/mm,1)))))))
```

**A21** shows `Kalshi Execution`

```
=IF($A$17="NOVIG • SPORTSBOOK","Novig Execution",IF($A$17="PROPHETX • SPORTSBOOK","ProphetX Execution","Kalshi Execution"))
```

**C21** text: `Taker`  
Dropdown (ONE_OF_RANGE): ='ARB LISTS'!$B$1:$B$4

**F21** text: `Sportsbook Stake`

**H21** shows `$13.93`  
Number format: `$#,##0.00;-$#,##0.00`

```
=IF(OR($C$19="",$C$20="",$C$21="",$C$22="",$H$19=""),"",LET(tA,$A$17,nvA,tA="NOVIG • SPORTSBOOK",pxA,tA="PROPHETX • SPORTSBOOK",pA,$C$19/100,n,IF(OR(nvA,pxA),$C$20/pA,$C$20),rateA,IF($C$21="MLB Maker",0.00875,IF($C$21="MLB Taker",0.035,IF($C$21="Maker",0.0175,0.07))),cA,IF($C$21="Futures Taker",0.06,IF(OR($C$21="Live Taker",$C$21="Taker"),0.03,0)),cashA,IF(pxA,$C$20,IF(nvA,$C$20+ROUND(cA*pA*(1-pA)*n,5),CEILING(ROUND(n*pA+CEILING(ROUND(rateA*n*pA*(1-pA),8),0.0001),8),0.01))),Awin,IF(pxA,n*(1-pA)-ROUND(0.02*n*(1-pA),2),n-cashA),m,IF($C$22="",0,IF($C$22>0,$C$22/100,100/ABS($C$22))),IF(OR(n<=0,m<=0),"",ROUND(IF($H$19="Free Bet",(Awin+cashA)/m,(Awin+cashA)/(1+m)),2))))
```

**A22** text: `Sportsbook Odds`

**C22** input: `410`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

**F22** text: `Total Cash Required`

**H22** shows `$68.45`  
Number format: `$#,##0.00;-$#,##0.00`

```
=IF(OR($C$19="",$C$20="",$C$21="",$H$19="",$H$21=""),"",LET(tA,$A$17,nvA,tA="NOVIG • SPORTSBOOK",pxA,tA="PROPHETX • SPORTSBOOK",pA,$C$19/100,n,IF(OR(nvA,pxA),$C$20/pA,$C$20),rateA,IF($C$21="MLB Maker",0.00875,IF($C$21="MLB Taker",0.035,IF($C$21="Maker",0.0175,0.07))),cA,IF($C$21="Futures Taker",0.06,IF(OR($C$21="Live Taker",$C$21="Taker"),0.03,0)),cashA,IF(pxA,$C$20,IF(nvA,$C$20+ROUND(cA*pA*(1-pA)*n,5),CEILING(ROUND(n*pA+CEILING(ROUND(rateA*n*pA*(1-pA),8),0.0001),8),0.01))),Awin,IF(pxA,n*(1-pA)-ROUND(0.02*n*(1-pA),2),n-cashA),m,IF($C$22="",0,IF($C$22>0,$C$22/100,100/ABS($C$22))),ROUND(cashA+IF($H$19="Free Bet",0,$H$21),2)))
```

**A23** text: `Guaranteed Profit`

**C23** shows `$2.58`  
Number format: `$#,##0.00;-$#,##0.00`

```
=IF(OR($H$21="",$H$22=""),"",LET(tA,$A$17,nvA,tA="NOVIG • SPORTSBOOK",pxA,tA="PROPHETX • SPORTSBOOK",pA,$C$19/100,n,IF(OR(nvA,pxA),$C$20/pA,$C$20),rateA,IF($C$21="MLB Maker",0.00875,IF($C$21="MLB Taker",0.035,IF($C$21="Maker",0.0175,0.07))),cA,IF($C$21="Futures Taker",0.06,IF(OR($C$21="Live Taker",$C$21="Taker"),0.03,0)),cashA,IF(pxA,$C$20,IF(nvA,$C$20+ROUND(cA*pA*(1-pA)*n,5),CEILING(ROUND(n*pA+CEILING(ROUND(rateA*n*pA*(1-pA),8),0.0001),8),0.01))),Awin,IF(pxA,n*(1-pA)-ROUND(0.02*n*(1-pA),2),n-cashA),m,IF($C$22="",0,IF($C$22>0,$C$22/100,100/ABS($C$22))),MIN(ROUND(Awin-IF($H$19="Free Bet",0,$H$21),2),ROUND($H$21*m-cashA,2))))
```

**F23** shows `ROI On Total Cash`

```
=IF($H$19="Free Bet","Free Bet Conversion","ROI On Total Cash")
```

**H23** shows `3.77%`  
Number format: `0.00%`

```
=IF(OR($C$23="",$H$22=""),"",IF($H$19="Free Bet",IF($H$21=0,"",$C$23/$H$21),IF($H$22=0,"",$C$23/$H$22)))
```

## Block 4: {KALSHI | NOVIG | PROPHETX} • {KALSHI | NOVIG | PROPHETX}

**A25** text: `KALSHI • KALSHI`  
Dropdown (ONE_OF_LIST): KALSHI • KALSHI, KALSHI • NOVIG, KALSHI • PROPHETX, NOVIG • KALSHI, NOVIG • NOVIG, NOVIG • PROPHETX, PROPHETX • KALSHI, PROPHETX • NOVIG, PROPHETX • PROPHETX

**A27** shows `Side A Price`

```
=LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),nA,IF(vA="KALSHI","Kalshi",IF(vA="NOVIG","Novig","ProphetX")),nBn,IF(vB="KALSHI","Kalshi",IF(vB="NOVIG","Novig","ProphetX")),same,vA=vB,IF(same,"Side A Price",nA&" Price"))
```

**C27** input: `75.45`  
Number format: `0.00"¢"`

**F27** shows `Side B Execution`

```
=LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),nA,IF(vA="KALSHI","Kalshi",IF(vA="NOVIG","Novig","ProphetX")),nBn,IF(vB="KALSHI","Kalshi",IF(vB="NOVIG","Novig","ProphetX")),same,vA=vB,IF(same,"Side B Execution",nBn&" Execution"))
```

**H27** text: `Pre-Match / Maker`  
Dropdown (ONE_OF_RANGE): ='ARB LISTS'!$D$1:$D$4

**A28** shows `Side A Contracts`

```
=LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),nA,IF(vA="KALSHI","Kalshi",IF(vA="NOVIG","Novig","ProphetX")),nBn,IF(vB="KALSHI","Kalshi",IF(vB="NOVIG","Novig","ProphetX")),same,vA=vB,kA,vA="KALSHI",kB,vB="KALSHI",IF(same,IF(kA,"Side A Contracts","Side A Stake"),nA&IF(kA," Contracts"," Stake")))
```

**C28** input: `2915`  
Number format: `#,##0.0`

**F28** shows `Break Even B Price`

```
=LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),nA,IF(vA="KALSHI","Kalshi",IF(vA="NOVIG","Novig","ProphetX")),nBn,IF(vB="KALSHI","Kalshi",IF(vB="NOVIG","Novig","ProphetX")),same,vA=vB,IF(same,"Break Even B Price","Break Even Price"))
```

**H28** shows `22.98¢`  
Number format: `0.00"¢"`

```
=IF(OR($C$27="",$C$28="",$C$30="",$H$27=""),"",LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),kA,vA="KALSHI",nvA,vA="NOVIG",pxA,vA="PROPHETX",kB,vB="KALSHI",nvB,vB="NOVIG",pxB,vB="PROPHETX",pA,$C$27/100,pB,$C$29/100,n,IF(kA,$C$28,$C$28/pA),rateA,IF($C$30="MLB Maker",0.00875,IF($C$30="MLB Taker",0.035,IF($C$30="Maker",0.0175,0.07))),cA,IF($C$30="Futures Taker",0.06,IF(OR($C$30="Live Taker",$C$30="Taker"),0.03,0)),rateB,IF($H$27="MLB Maker",0.00875,IF($H$27="MLB Taker",0.035,IF($H$27="Maker",0.0175,0.07))),cB,IF($H$27="Futures Taker",0.06,IF(OR($H$27="Live Taker",$H$27="Taker"),0.03,0)),cashA,IF(kA,CEILING(ROUND(n*pA+CEILING(ROUND(rateA*n*pA*(1-pA),8),0.0001),8),0.01),IF(nvA,$C$28+ROUND(cA*pA*(1-pA)*n,5),$C$28)),Awin,IF(pxA,n*(1-pA)-ROUND(0.02*n*(1-pA),2),n-cashA),fB,IF(pxB,0.02,0),nB,IF(kA,n/(1-fB*(1-pB)),(Awin+cashA)/(1-fB*(1-pB))),SB,ROUND(nB*pB,2),nBf,IF(kB,nB,SB/pB),cashB,IF(kB,CEILING(ROUND(nB*pB+CEILING(ROUND(rateB*nB*pB*(1-pB),8),0.0001),8),0.01),IF(nvB,SB+ROUND(cB*pB*(1-pB)*nBf,5),SB)),Bwin,IF(pxB,(nBf-SB)-ROUND(0.02*(nBf-SB),2),nBf-cashB),IF(OR(n<=0,Awin<=0),0,IF(kB,LET(lim,Awin,debit_b,LAMBDA(px,CEILING(ROUND(nB*px+CEILING(ROUND(rateB*nB*px*(1-px),8),0.0001),8),0.01)),raw_root,((1+rateB)-SQRT(MAX(0,(1+rateB)^2-4*rateB*lim/nB)))/(2*rateB),start_price,MAX(0.0001,FLOOR(raw_root,0.0001)-0.05),prices,SEQUENCE(501,1,start_price,0.0001),debits,MAP(prices,LAMBDA(px,debit_b(px))),100*IFERROR(MAX(FILTER(prices,(prices<=0.9999)*(debits<=lim))),0)),IF(nvB,LET(q,Awin/(Awin+cashA),root,IF(cB=0,q,((1+cB)-SQRT(MAX(0,(1+cB)^2-4*cB*q)))/(2*cB)),100*MAX(0,MIN(0.9999,FLOOR(root,0.0001)))),100*MAX(0,MIN(0.9999,FLOOR(0.98*Awin/(0.98*Awin+cashA),0.0001))))))))
```

**A29** shows `Side B Price`

```
=LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),nA,IF(vA="KALSHI","Kalshi",IF(vA="NOVIG","Novig","ProphetX")),nBn,IF(vB="KALSHI","Kalshi",IF(vB="NOVIG","Novig","ProphetX")),same,vA=vB,IF(same,"Side B Price",nBn&" Price"))
```

**C29** input: `13.79`  
Number format: `0.00"¢"`

**F29** shows `Side B Contracts`

```
=LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),nA,IF(vA="KALSHI","Kalshi",IF(vA="NOVIG","Novig","ProphetX")),nBn,IF(vB="KALSHI","Kalshi",IF(vB="NOVIG","Novig","ProphetX")),same,vA=vB,kA,vA="KALSHI",kB,vB="KALSHI",IF(same,IF(kB,"Side B Contracts","Side B Stake"),nBn&IF(kB," Contracts"," Stake")))
```

**H29** shows `2,915.0`  
Number format: `#,##0.0`

```
=IF(OR($C$27="",$C$28="",$C$29="",$C$30="",$H$27=""),"",LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),kA,vA="KALSHI",nvA,vA="NOVIG",pxA,vA="PROPHETX",kB,vB="KALSHI",nvB,vB="NOVIG",pxB,vB="PROPHETX",pA,$C$27/100,pB,$C$29/100,n,IF(kA,$C$28,$C$28/pA),rateA,IF($C$30="MLB Maker",0.00875,IF($C$30="MLB Taker",0.035,IF($C$30="Maker",0.0175,0.07))),cA,IF($C$30="Futures Taker",0.06,IF(OR($C$30="Live Taker",$C$30="Taker"),0.03,0)),rateB,IF($H$27="MLB Maker",0.00875,IF($H$27="MLB Taker",0.035,IF($H$27="Maker",0.0175,0.07))),cB,IF($H$27="Futures Taker",0.06,IF(OR($H$27="Live Taker",$H$27="Taker"),0.03,0)),cashA,IF(kA,CEILING(ROUND(n*pA+CEILING(ROUND(rateA*n*pA*(1-pA),8),0.0001),8),0.01),IF(nvA,$C$28+ROUND(cA*pA*(1-pA)*n,5),$C$28)),Awin,IF(pxA,n*(1-pA)-ROUND(0.02*n*(1-pA),2),n-cashA),fB,IF(pxB,0.02,0),nB,IF(kA,n/(1-fB*(1-pB)),(Awin+cashA)/(1-fB*(1-pB))),SB,ROUND(nB*pB,2),nBf,IF(kB,nB,SB/pB),cashB,IF(kB,CEILING(ROUND(nB*pB+CEILING(ROUND(rateB*nB*pB*(1-pB),8),0.0001),8),0.01),IF(nvB,SB+ROUND(cB*pB*(1-pB)*nBf,5),SB)),Bwin,IF(pxB,(nBf-SB)-ROUND(0.02*(nBf-SB),2),nBf-cashB),IF(kB,nB,SB)))
```

**A30** shows `Side A Execution`

```
=LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),nA,IF(vA="KALSHI","Kalshi",IF(vA="NOVIG","Novig","ProphetX")),nBn,IF(vB="KALSHI","Kalshi",IF(vB="NOVIG","Novig","ProphetX")),same,vA=vB,IF(same,"Side A Execution",nA&" Execution"))
```

**C30** text: `Maker`  
Dropdown (ONE_OF_RANGE): ='ARB LISTS'!$C$1:$C$4

**F30** text: `Total Cash Required`

**H30** shows `$2,635.06`  
Number format: `$#,##0.00;-$#,##0.00`

```
=IF(OR($C$27="",$C$28="",$C$29="",$C$30="",$H$27=""),"",LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),kA,vA="KALSHI",nvA,vA="NOVIG",pxA,vA="PROPHETX",kB,vB="KALSHI",nvB,vB="NOVIG",pxB,vB="PROPHETX",pA,$C$27/100,pB,$C$29/100,n,IF(kA,$C$28,$C$28/pA),rateA,IF($C$30="MLB Maker",0.00875,IF($C$30="MLB Taker",0.035,IF($C$30="Maker",0.0175,0.07))),cA,IF($C$30="Futures Taker",0.06,IF(OR($C$30="Live Taker",$C$30="Taker"),0.03,0)),rateB,IF($H$27="MLB Maker",0.00875,IF($H$27="MLB Taker",0.035,IF($H$27="Maker",0.0175,0.07))),cB,IF($H$27="Futures Taker",0.06,IF(OR($H$27="Live Taker",$H$27="Taker"),0.03,0)),cashA,IF(kA,CEILING(ROUND(n*pA+CEILING(ROUND(rateA*n*pA*(1-pA),8),0.0001),8),0.01),IF(nvA,$C$28+ROUND(cA*pA*(1-pA)*n,5),$C$28)),Awin,IF(pxA,n*(1-pA)-ROUND(0.02*n*(1-pA),2),n-cashA),fB,IF(pxB,0.02,0),nB,IF(kA,n/(1-fB*(1-pB)),(Awin+cashA)/(1-fB*(1-pB))),SB,ROUND(nB*pB,2),nBf,IF(kB,nB,SB/pB),cashB,IF(kB,CEILING(ROUND(nB*pB+CEILING(ROUND(rateB*nB*pB*(1-pB),8),0.0001),8),0.01),IF(nvB,SB+ROUND(cB*pB*(1-pB)*nBf,5),SB)),Bwin,IF(pxB,(nBf-SB)-ROUND(0.02*(nBf-SB),2),nBf-cashB),ROUND(cashA+cashB,2)))
```

**A31** text: `Guaranteed Profit`

**C31** shows `$279.94`  
Number format: `$#,##0.00;-$#,##0.00`

```
=IF($H$30="","",LET(tA,$A$25,sep,FIND(" • ",tA),vA,LEFT(tA,sep-1),vB,MID(tA,sep+3,20),kA,vA="KALSHI",nvA,vA="NOVIG",pxA,vA="PROPHETX",kB,vB="KALSHI",nvB,vB="NOVIG",pxB,vB="PROPHETX",pA,$C$27/100,pB,$C$29/100,n,IF(kA,$C$28,$C$28/pA),rateA,IF($C$30="MLB Maker",0.00875,IF($C$30="MLB Taker",0.035,IF($C$30="Maker",0.0175,0.07))),cA,IF($C$30="Futures Taker",0.06,IF(OR($C$30="Live Taker",$C$30="Taker"),0.03,0)),rateB,IF($H$27="MLB Maker",0.00875,IF($H$27="MLB Taker",0.035,IF($H$27="Maker",0.0175,0.07))),cB,IF($H$27="Futures Taker",0.06,IF(OR($H$27="Live Taker",$H$27="Taker"),0.03,0)),cashA,IF(kA,CEILING(ROUND(n*pA+CEILING(ROUND(rateA*n*pA*(1-pA),8),0.0001),8),0.01),IF(nvA,$C$28+ROUND(cA*pA*(1-pA)*n,5),$C$28)),Awin,IF(pxA,n*(1-pA)-ROUND(0.02*n*(1-pA),2),n-cashA),fB,IF(pxB,0.02,0),nB,IF(kA,n/(1-fB*(1-pB)),(Awin+cashA)/(1-fB*(1-pB))),SB,ROUND(nB*pB,2),nBf,IF(kB,nB,SB/pB),cashB,IF(kB,CEILING(ROUND(nB*pB+CEILING(ROUND(rateB*nB*pB*(1-pB),8),0.0001),8),0.01),IF(nvB,SB+ROUND(cB*pB*(1-pB)*nBf,5),SB)),Bwin,IF(pxB,(nBf-SB)-ROUND(0.02*(nBf-SB),2),nBf-cashB),ROUND(MIN(Awin-cashB,Bwin-cashA),2)))
```

**F31** text: `ROI On Total Cash`

**H31** shows `10.62%`  
Number format: `0.00%`

```
=IF(OR($C$31="",$H$30=""),"",$C$31/$H$30)
```

## Block 5: KALSHI • NOVIG • PROPHETX • AMERICAN ODDS AFTER FEES

**A33** text: `KALSHI • NOVIG • PROPHETX • AMERICAN ODDS AFTER FEES`

**A35** text: `Kalshi Price`

**C35** input: `47`  
Number format: `0.00"¢"`

**F35** text: `Maker`

**G35** shows `+110.8`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

```
=IF($C$35="","",LET(p,$C$35/100,cost,CEILING(p+0.0175*p*(1-p),0.0001),IF(cost<=0.5,ROUND(100*(1-cost)/cost,1),-ROUND(100*cost/(1-cost),1))))
```

**H35** text: `Taker`

**I35** shows `+105.1`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

```
=IF($C$35="","",LET(p,$C$35/100,cost,CEILING(p+0.07*p*(1-p),0.0001),IF(cost<=0.5,ROUND(100*(1-cost)/cost,1),-ROUND(100*cost/(1-cost),1))))
```

**A36** text: `Novig Price`

**C36** input: `85`  
Number format: `0.00"¢"`

**F36** text: `Pre-Match`

**G36** shows `-566.7`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

```
=IF($C$36="","",LET(p,$C$36/100,IF(p<=0.5,ROUND(100*(1-p)/p,1),-ROUND(100*p/(1-p),1))))
```

**H36** text: `Live Taker`

**I36** shows `-584.1`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

```
=IF($C$36="","",LET(p,$C$36/100,cost,p+0.03*p*(1-p),IF(cost<=0.5,ROUND(100*(1-cost)/cost,1),-ROUND(100*cost/(1-cost),1))))
```

**A37** text: `ProphetX Price`

**C37** input: `64.52`  
Number format: `0.00"¢"`

**F37** text: `Maker`

**G37** shows `-185.6`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

```
=IF($C$37="","",LET(p,$C$37/100,win,(1-p)*0.98,IF(win>=p,ROUND(100*win/p,1),-ROUND(100*p/win,1))))
```

**H37** text: `Taker`

**I37** shows `-185.6`  
Number format: `+#,##0.0;-#,##0.0;+0.0`

```
=IF($C$37="","",LET(p,$C$37/100,win,(1-p)*0.98,IF(win>=p,ROUND(100*win/p,1),-ROUND(100*p/win,1))))
```

## Conditional formats

- NUMBER_GREATER 0 → background #0f2419 on H6:I6, C7:D7, C15:D15, H15:I15, C23:D23, H23:I23, C31:D31, H31:I31, G35:G37, I35:I37
- NUMBER_LESS 0 → background #2b161a on H6:I6, C7:D7, C15:D15, H15:I15, C23:D23, H23:I23, C31:D31, H31:I31, G35:G37, I35:I37

## Merges

88 merged ranges: A1:I1, A2:I2, A4:B4, C4:D4, F4:G4, H4:I4, A5:B5, C5:D5, F5:G5, H5:I5, A6:B6, C6:D6, F6:G6, H6:I6, A7:B7, C7:D7, F7:G7, H7:I7, A9:I9, A11:B11, C11:D11, F11:G11, H11:I11, A12:B12, C12:D12, F12:G12, H12:I12, A13:B13, C13:D13, F13:G13, H13:I13, A14:B14, C14:D14, F14:G14, H14:I14, A15:B15, C15:D15, F15:G15, H15:I15, A17:I17, A19:B19, C19:D19, F19:G19, H19:I19, A20:B20, C20:D20, F20:G20, H20:I20, A21:B21, C21:D21, F21:G21, H21:I21, A22:B22, C22:D22, F22:G22, H22:I22, A23:B23, C23:D23, F23:G23, H23:I23, A25:I25, A27:B27, C27:D27, F27:G27, H27:I27, A28:B28, C28:D28, F28:G28, H28:I28, A29:B29, C29:D29, F29:G29, H29:I29, A30:B30, C30:D30, F30:G30, H30:I30, A31:B31, C31:D31, F31:G31, H31:I31, A33:I33, A35:B35, C35:D35, A36:B36, C36:D36, A37:B37, C37:D37

## Hidden tab ARB LISTS (sheetId 1191100911)

Columns A–D each hold the same four rows: Taker, Maker, MLB Taker, MLB Maker. They feed the execution dropdowns
C14 (A), C21 (B), C30 (C), H27 (D). There is no Novig or ProphetX list, although the formulas branch on
`Live Taker`, `Futures Taker` and `Pre-Match`.

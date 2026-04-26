# Rail Empire — Balance Model

This document provides concrete numeric constants for the economy. All values are tuned to the **golden rule** below.

> **Golden Rule — Route Profitability**
> - A **first route** must break even in **3–5 successful trips**.
> - A **bad route** loses money after maintenance (break-even > 15 trips or impossible).
> - A **great route** is obvious but contestable (break-even 2–3 trips; rivals will split the supply).

---

## 1. Starting Money per Phase

| Phase / Mode | Starting Treasury (₹) | Notes |
|---|---:|---|
| Phase 0 — Route Toy | 20,000 | 2 cities, tutorial only |
| Phase 1 — Colonial Core | 20,000 | 4 cities, 3 cargo, manual save/load |
| Phase 2 — Economic Depth | 25,000 | 6 cities, contracts, station upgrades |
| Phase 3 — First Rival | 20,000 | Player & AI start equal (fairness rule) |
| Campaign — Act 1 | 20,000 | "First Charter" |
| Campaign — Act 2 | 25,000 | "Port Expansion" |
| Campaign — Act 3 | 30,000 | "Inland Expansion" |
| Campaign — Act 4 | 35,000 | "Monopoly Race" |
| Campaign — Act 5 | 40,000 | "Crisis Finale" |
| Sandbox | 50,000 | All content unlocked |

---

## 2. Track Cost by Terrain

Base cost per km: **₹400** (Plains).

| Terrain | Cost Multiplier | Cost per km (₹) | Design Notes |
|---|---:|---:|---|
| Plains | 1.0 | 400 | Default; cheapest expansion |
| Forest | 1.25 | 500 | Mild penalty; early obstacle |
| Hills | 2.0 | 800 | Slows construction; late tech reduces penalty |
| River | 2.5 | 1,000 | Requires bridge; highest upfront cost |

---

## 3. Train Stats

| Train | Purchase Cost (₹) | Speed (km/h) | Capacity (t) | Maint./Day (₹) | Reliability | Role | Unlock Phase |
|---|---|---:|---:|---:|---:|---|---|
| Freight Engine | 5,000 | 2.0 | 200 | 50 | 0.95 | Bulk cargo workhorse | Phase 1 |
| Mixed Engine | 10,000 | 4.0 | 100 | 80 | 0.90 | Fast flexible service | Phase 1 |
| Express Engine | 15,000 | 6.0 | 80 | 120 | 0.88 | Premium / perishable cargo | Phase 2 |
| *Military Transport* | *20,000* | *4.5* | *150* | *100* | *0.93* | *WW1 era placeholder* | *Phase 8* |

> **Note:** Military Transport stats are placeholders pending Phase 8 scoping.

---

## 4. Cargo Base Prices and Weight Classes

| Cargo | Base Price (₹/ton) | Weight Class | Tags | Unlock Phase |
|---|---:|---|---|---|
| Coal | 15 | Heavy | bulk | Phase 1 |
| Grain | 20 | Medium | food | Phase 1 |
| Textiles | 35 | Light | manufactured | Phase 1 |
| Tea | 60 | Light | luxury, perishable | Phase 2 |
| Indigo | 50 | Light | luxury, perishable | Phase 2 (alt. to Tea) |
| Troops | 40 | Heavy | military | Phase 8 |
| Munitions | 80 | Heavy | military | Phase 8 |
| Medical Supplies | 50 | Light | medical | Phase 8 |

> **Content rule:** Use *either* Tea or Indigo in a given campaign, not both.

---

## 5. City Production & Demand Rates (tons / day)

| City | Produces | Production | Demands | Demand |
|---|---:|---|---:|---|
| **Kolkata** | Textiles | 80 | Coal | 100 |
| | | | Grain | 80 |
| | | | Textiles | 40 |
| **Dacca** | Textiles | 60 | Coal | 80 |
| | | | Grain | 60 |
| | | | Textiles | 30 |
| **Patna** | Coal | 120 | Textiles | 50 |
| | | | Grain | 40 |
| **Murshidabad** | Grain | 100 | Textiles | 40 |
| | | | Coal | 60 |
| **Varanasi** | Textiles | 40 | Coal | 70 |
| | | | Grain | 50 |
| **Siliguri** | Grain | 80 | Textiles | 30 |
| | | | Coal | 50 |

**Balance intent:** Coal and Grain are strongly undersupplied, driving prices toward the upper clamp. Textiles are slightly undersupplied, creating stable mid-tier trade. Cities with multiple demands reward multi-cargo routes.

---

## 6. Station Upgrade Costs and Effects

| Upgrade | Build Cost (₹) | Daily Upkeep (₹) | Effect |
|---|---:|---:|---|
| Warehouse | 5,000 | 20 | +200 tons max stockpile per cargo type |
| Loading Bay | 8,000 | 30 | Reduces loading & unloading time by **1 game hour** each |
| Maintenance Shed | 10,000 | 25 | –20 % maintenance cost for trains on routes ending at this city |

---

## 7. Contract Reward Ranges

| Contract Type | Example Target | Quantity | Reward (₹) | Reputation | Deadline |
|---|---|---:|---:|---:|---:|
| Early Delivery | Coal → Kolkata | 200 t | 8,000 – 12,000 | +5 | 90 days |
| Mid Delivery | Grain → Dacca | 150 t | 6,000 – 9,000 | +4 | 60 days |
| Connection | Kolkata–Murshidabad link | — | 5,000 – 8,000 | +3 | 60 days |
| High-Value | Tea → Kolkata | 100 t | 12,000 – 18,000 | +8 | 45 days |
| Military (WW1) | Munitions → Port | 200 t | 20,000 – 30,000 | +10 | 30 days |

**Reward formula (delivery):**
```
reward = quantity × base_price × (1.5 to 2.0)
```
Connection contracts use a flat distance-based payout.

---

## 8. Event Damage Costs

| Event | Damage / Cost Type | Cost Range (₹) | Counterplay Cost (₹) |
|---|---|---:|---:|
| Monsoon Flood | River track repair (per damaged segment) | 2,000 – 5,000 total | Bridge upgrade (prevention) |
| Labor Strike | Opportunity loss or early settlement | 2,000 – 4,000 opp. cost | 2,500 settlement |
| Port Boom | *Positive event* — no damage | — | — |
| Track Inspection | Fine per low-condition segment | 2,000 – 4,000 total | ~1,500 proactive repair |

---

## 9. AI Starting Treasury

| Difficulty | AI Starting Treasury (₹) | Modifier | Notes |
|---|---:|---:|---|
| Easy | 15,000 | 0.75× | Forgiving first rival |
| Normal | 20,000 | 1.00× | Same as player (fairness rule) |
| Hard | 25,000 | 1.25× | Aggressive expansion pressure |

---

## 10. Expected Break-Even Times

| Route Category | Typical Conditions | Break-Even Trips | Design Intent |
|---|---|---:|---|
| **First Route** | Short plains, high-demand cargo, Freight Engine | **3 – 5** | Core loop validation; player must feel progress |
| **Great Route** | Medium distance, premium cargo, correct train | **2 – 3** | Obvious profit; rivals will contest it |
| **Marginal Route** | Long distance, mixed terrain, sub-optimal train | **6 – 10** | Requires optimization or tech to become viable |
| **Bad Route** | Hills/rivers, oversupplied cargo, Express Engine | **15+ or never** | Loses money after maintenance; player should abandon |

### Worked Example — First Route ✅
- **Route:** Patna → Kolkata, 20 km (15 plains + 5 hills)
- **Track cost:** (15 × ₹400) + (5 × ₹800) = **₹10,000**
- **Train:** Freight Engine = **₹5,000**
- **Total investment:** **₹15,000**
- **Load:** 120 t Coal (supply-limited by daily production)
- **Sell price:** ~₹30/ton (high demand, low stock)
- **Revenue:** 120 × ₹30 = **₹3,600**
- **Maintenance:** ₹50 (one day round-trip at 2 km/h)
- **Net profit per trip:** **₹3,550**
- **Break-even:** 15,000 ÷ 3,550 ≈ **4.2 trips** (within 3–5)

### Worked Example — Bad Route ❌
- **Route:** Murshidabad → Dacca, 35 km (10 river + 15 hills + 10 plains)
- **Track cost:** (10 × ₹1,000) + (15 × ₹800) + (10 × ₹400) = **₹26,000**
- **Train:** Express Engine = **₹15,000**
- **Total investment:** **₹41,000**
- **Load:** 80 t Textiles (oversupplied; price crashed to ₹20)
- **Revenue:** 80 × ₹20 = **₹1,600**
- **Maintenance:** ₹120
- **Net profit per trip:** **₹1,480**
- **Break-even:** 41,000 ÷ 1,480 ≈ **27.7 trips** (never pays back)

### Worked Example — Great Route ⚠️ (Contestable)
- **Route:** Dacca → Kolkata, 15 km (all plains)
- **Track cost:** 15 × ₹400 = **₹6,000**
- **Train:** Freight Engine = **₹5,000**
- **Total investment:** **₹11,000**
- **Load:** 80 t Textiles (limited by daily production)
- **Sell price:** ~₹70/ton (high demand, clamped to 2× base)
- **Revenue:** 80 × ₹70 = **₹5,600**
- **Maintenance:** ₹50
- **Net profit per trip:** **₹5,550**
- **Solo break-even:** 11,000 ÷ 5,550 ≈ **2.0 trips**
- **With one rival splitting supply:** profit ≈ **₹2,775/trip** → break-even ≈ **4.0 trips** (still good, but no longer dominant)

---

## 11. Technology Auction Starting Bids

| Technology | Starting Bid (₹) | Patent Duration | Best For |
|---|---:|---:|---|
| Superheater Design | 8,000 | 5 years | High-volume, short-loop routes |
| Riveted Bridges | 6,000 | 5 years | River-heavy maps |
| Standardized Parts | 10,000 | 4 years | Large fleets (3+ trains) |
| Hydraulic Cranes | 7,000 | 4 years | Hub stations with many trains |
| Rack-and-Pinion | 9,000 | 6 years | Hill-heavy regions |

**Auction mechanics:**
- Trigger: every 2 in-game years **or** 15 % yearly random chance.
- Minimum bid increment: **₹500**.
- Patent expiry: all factions receive the benefit for free.

---

## 12. Quick Reference — Price Clamps

```
price = base_price × (1 + (demand - supply) / (demand + supply + 1))
price = clamp(price, base_price × 0.5, base_price × 2.0)
```

| Cargo | Min Price (₹) | Max Price (₹) |
|---|---:|---:|
| Coal | 7 | 30 |
| Grain | 10 | 40 |
| Textiles | 17 | 70 |
| Tea | 30 | 120 |
| Indigo | 25 | 100 |
| Troops | 20 | 80 |
| Munitions | 40 | 160 |
| Medical Supplies | 25 | 100 |

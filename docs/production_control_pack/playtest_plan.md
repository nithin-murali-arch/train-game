# Rail Empire — Playtest Plan

Version: 1.0
Companion: `risk_register.md`, `release_plan.md`, `design.md` §12 (testing checklists)

---

## 1. Purpose

Define who tests the game, when, what questions they answer, what metrics we collect, and when a phase is NOT ready to advance. This document overrules any informal "it feels fine" advancement.

---

## 2. Playtester Profile (Target Audience)

| Attribute | Description |
|-----------|-------------|
| **Primary** | Fans of tycoon / logistics games (e.g., *OpenTTD*, *Railway Empire*, *Factorio*, *Mini Metro*) |
| **Secondary** | Strategy-curious players who enjoy readable systems and meaningful optimization |
| **Age range** | 18–45 |
| **Platform familiarity** | Comfortable with mouse + keyboard; some trackpad users |
| **Historical interest** | Curious about colonial history but not seeking a textbook; appreciates thoughtful treatment |
| **Experience level** | Mix of "never played a tycoon" (for tutorial testing) and "100+ hours in genre" (for depth testing) |
| **Recruitment** | Internal friends-and-family for Phase 0–1; Discord / Reddit / genre communities for Phase 2+; local IGDA chapter if available |

**Diversity requirement**: At least 30% of playtesters per phase should be from South Asian backgrounds or have lived experience in India/Bangladesh, to validate historical tone and cultural readability.

---

## 3. Feedback Collection Methods

| Method | When Used | What It Captures |
|--------|-----------|------------------|
| **Think-aloud protocol** | Phase 0, Phase 1 first sessions | Real-time confusion, vocabulary mismatch, emotional reactions |
| **Structured observation** | All phases | Time-to-X metrics, misclicks, UI hover patterns, dead time |
| **Post-session questionnaire** | All phases | Quantified satisfaction, clarity ratings, NPS-style likelihood to continue playing |
| **Video recording + timestamped notes** | Phase 2+ | Exact moments of drop-off or delight |
| **Open text feedback** | Phase 3+ | Emergent strategies, feature requests, tone reactions |

**Questionnaire template** (reused every phase):

1. On a scale of 1–5, how easy was it to start playing?
2. On a scale of 1–5, how clearly did you understand why you earned or lost money?
3. On a scale of 1–5, how satisfying was building a route?
4. What was the most confusing thing?
5. What was the most fun thing?
6. Would you play this again? (Yes / Maybe / No)
7. Any historical or cultural tone that felt off? (open text)

---

## 4. Phase 0 — Route Toy Playtest Protocol

**Build version**: v0.0.x (internal prototype)
**Goal**: Prove track + train + money loop is comprehensible and satisfying.
**Duration**: 10–15 minutes per session
**Tester count**: 3–5 internal

### 4.1 Playtest Questions

| # | Question | How to Answer |
|---|----------|---------------|
| Q0.1 | **Did the player understand how to build track?** | Observe: do they click two cities without prompting? Do they use the preview? Do they cancel and retry? |
| Q0.2 | **Did they understand why they earned money?** | Ask after first delivery: "Why did your treasury go up?" Look for mention of cargo, destination, or route. |
| Q0.3 | **Did train movement feel satisfying?** | Ask: "How did it feel to watch the train arrive?" Observe facial reaction. Note if they speed up time or ignore the train. |
| Q0.4 | **Did they want to build a second route?** | Observe: after first profit, do they pan the map, click another city, or buy another train without prompting? |
| Q0.5 | **Did anything feel slow or confusing?** | Think-aloud prompt: "Tell me what you're thinking right now." Note pauses > 10 seconds. |

### 4.2 Metrics to Collect

| Metric | Target | Measurement |
|--------|--------|-------------|
| Time to first track | ≤ 2 minutes | Timestamp: scene load → first edge added to `TrackGraph` |
| Time to first train | ≤ 3 minutes | Timestamp: scene load → train purchased |
| Time to first profit | ≤ 5 minutes | Timestamp: scene load → treasury increase from delivery |
| Failed build attempts | ≤ 1 per route | Count: cancellations, misclicks, invalid paths |
| Routes built in 20 minutes | ≥ 2 | Count: distinct origin–destination pairs |
| Player can explain profit source | 100% | Qualitative: post-delivery think-aloud or questionnaire |

### 4.3 Stop-Ship Criteria (Phase 0)

Do NOT advance to Phase 1 (Colonial Core) if ANY of the following are true:

- [ ] Average time to first track > 3 minutes
- [ ] Any tester cannot explain why they earned money after two deliveries
- [ ] More than 1 failed build attempt per route on average
- [ ] Console errors during normal play (any severity)
- [ ] No tester expresses desire to build a second route
- [ ] Track placement is broken on trackpad or common mouse hardware

---

## 5. Phase 1 — Colonial Core Playtest Protocol

**Build version**: v0.1.x–v0.2.x
**Goal**: Prove the tycoon loop is strategically meaningful over a 20-minute session.
**Duration**: 20–30 minutes per session
**Tester count**: 5–8 (mix of internal + 2–3 external tycoon fans)

### 5.1 Playtest Questions

| # | Question | How to Answer |
|---|----------|---------------|
| Q1.1 | **Could they identify a profitable route without guessing?** | Observe: do they compare city panels, check prices, or read the route preview before building? Ask: "How did you decide to build that route?" |
| Q1.2 | **Did terrain costs matter?** | Observe: do they route around rivers/hills? Ask: "Did you notice terrain making some routes more expensive?" Check if any route preview is consulted. |
| Q1.3 | **Did they understand supply and demand?** | Ask after 10 minutes: "Why is coal cheap in Patna and expensive in Kolkata?" Look for mention of production, stock, or city role. |
| Q1.4 | **Did they expand strategically or randomly?** | Observe: second and third routes follow pricing data, or are placed near first route regardless of profit? Review save file for route coherence. |
| Q1.5 | **Did they understand why they lost money?** | If treasury drops, ask: "What do you think happened?" Check if they mention maintenance, terrain, or oversupply. |
| Q1.6 | **Did save/load feel trustworthy?** | Ask them to save, quit, and reload mid-session. Observe confidence level. |

### 5.2 Metrics to Collect

| Metric | Target | Measurement |
|--------|--------|-------------|
| Time to first track | ≤ 2 minutes | Same as Phase 0 |
| Time to first train | ≤ 3 minutes | Same as Phase 0 |
| Time to first profit | ≤ 5 minutes | Same as Phase 0 |
| Failed build attempts | ≤ 1 per route | Same as Phase 0 |
| Routes built in 20 minutes | ≥ 3 | Count: distinct routes with active trains |
| Player can explain profit source | ≥ 80% | Qualitative: questionnaire + think-aloud |
| Player can explain a price difference | ≥ 60% | Ask: "Why is X cheaper than Y?" |
| Save/load success rate | 100% | Automated + manual round-trip test |

### 5.3 Stop-Ship Criteria (Phase 1)

Do NOT advance to Phase 2 (Economic Depth) if ANY of the following are true:

- [ ] Average routes built in 20 minutes < 2
- [ ] < 60% of testers can explain a price difference
- [ ] Any save/load corruption or state loss
- [ ] Average session length < 15 minutes (indicates disengagement)
- [ ] Playtesters describe economy as "random" or "just pick anything"
- [ ] Route profitability display is ignored or distrusted by ≥ 50% of testers

---

## 6. Phase 2+ — Expanded Playtest Protocol (Summary)

| Phase | Build | Focus | Tester Count | Key Metric |
|-------|-------|-------|--------------|------------|
| Phase 2: Economic Depth | v0.3.x | Contracts, saturation, upgrades | 8–10 external | % who complete a contract voluntarily |
| Phase 3: First Rival | v0.4.x | AI pressure, fairness, visibility | 8–10 external | "Rival feels fair" rating ≥ 3/5 |
| Phase 4: Network Control | v0.5.x | Tolls, ownership, bottlenecks | 10–12 external | % who use toll strategy intentionally |
| Phase 5: Events | v0.6.x | Preparation vs. punishment | 10–12 external | "Events feel fair" rating ≥ 4/5 |
| Phase 6: Colonial Campaign | v0.7.x | Act flow, 5-act completion | 12–15 external | Campaign completion rate ≥ 50% |
| Phase 7+: Post-demo | v0.8.x+ | Polish, faction variety, WW1 | 15–20 external | NPS ≥ 30 |

### 6.1 Phase 2–6 Stop-Ship Criteria (General)

Before advancing past Phase 2, apply these universal gates:

- [ ] No regressions in Phase 0 or Phase 1 metrics
- [ ] All new systems have at least one tester who used them intentionally
- [ ] No console errors during normal play
- [ ] Save/load round-trip passes for new state (contracts, events, etc.)
- [ ] Historical tone feedback: zero unresolved flags from South Asian testers

---

## 7. Feedback Triage Process

After every playtest wave, sort findings into:

| Bucket | Action | Timeline |
|--------|--------|----------|
| **Blocker** | Fix before next build; may delay sprint | This sprint |
| **Friction** | Address if time permits; log in BACKLOG.md | Next sprint or phase |
| **Idea** | Park in BACKLOG.md under deferred features | Post-phase |
| **Praise** | Add to sprint report; informs marketing copy | Immediate |

---

## 8. Playtest Artifacts

Each phase playtest must produce:

1. **Raw notes** (observer + think-aloud transcripts)
2. **Metrics sheet** (spreadsheet with per-tester numbers)
3. **Triage summary** (blocker/friction/idea/praise buckets)
4. **Go / No-Go recommendation** for the phase gate
5. **Updated risk register** if new risks emerge

Store all artifacts in `docs/playtest_reports/phase_X/`

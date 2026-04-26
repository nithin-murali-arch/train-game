# Rail Empire — Risk Register

Version: 1.0
Companion: `scope_lock.md`, `playtest_plan.md`, `release_plan.md`

---

## 1. Purpose

This document tracks the top risks to Rail Empire's production, with severity ratings, mitigation strategies, assigned owners, and early warning signs. Risks are reviewed at the end of each sprint and updated before every phase gate.

---

## 2. Risk Register Table

| # | Risk Description | Severity | Likelihood | Impact on Project | Mitigation Strategy | Owner | Early Warning Sign |
|---|-----------------|----------|------------|-------------------|---------------------|-------|-------------------|
| R01 | **Scope creep into multi-era too early** — WW1, WW2, or Modern era mechanics are implemented before the Colonial loop is proven fun. | High | Medium | Shallow core loop; unmaintainable codebase; no vertical slice | Enforce `scope_lock.md` phase gating. No era transition code before v0.7.0 gate. Use passive `era_id` hooks only. | Lead Designer / Scope Lock Authority | Code review finds `ww1_`, `era_transition`, or `modern_` logic in sprints ≤ 07 |
| R02 | **Economy feels random or shallow** — Prices swing chaotically, or all routes feel identical, removing the core strategic fantasy. | High | Medium | Game fails its primary promise; playtesters disengage | Clamp prices (0.5×–2.0× base). Expose price reason in tooltips. Test break-even visibility in every playtest. Iterate on cargo differentiation (Coal ≠ Textiles ≠ Grain). | Systems Designer | Playtesters cannot explain why one route earned more than another |
| R03 | **Track placement feels clunky** — Click-to-build is imprecise, preview is misleading, or undo is missing, causing player frustration. | High | High | Core loop breaks in first 2 minutes; high drop-off | Start with city-to-city snapped placement. Show cost preview before confirmation. Add cancel/undo before Colonial Core ships. Test with trackpad + mouse. | UX Lead / Programmer | Failed build attempts > 3 per route in Phase 0 metrics |
| R04 | **AI is unfair or invisible** — British East India Rail either dominates the map before the player learns the rules, or operates so quietly the player forgets it exists. | High | Medium | Rival phase fails exit criteria; player rage-quits or ignores competition | AI uses same economy rules as player (no cheating). Cap AI build rate per month. Make AI tracks visually distinct (color overlay). Add newspaper-style AI activity ticker. | AI Programmer | Playtesters describe rival as "cheating" or ask "is there an AI?" |
| R05 | **Save/load becomes fragile** — JSON format drifts, scene node paths leak into save state, or cross-references break on load, corrupting sessions. | High | Medium | Player loses progress; debugging becomes hellish; QA bottleneck | Store all state in serializable dictionaries (`TrackGraph`, `TrainState`, `CityEconomyState`). Never store Node paths. Version-save schema. Automated round-trip test before each release. | Programmer / QA | Smoke test catches save/load mismatch; bug reports mention "lost my trains" |
| R06 | **Art inconsistency across AI-generated assets** — Placeholders and generated sprites clash in style, resolution, palette, or perspective, making the game look unprofessional. | Medium | High | Visual incoherence hurts trust; distracts from economy feedback | Lock an `art_style_guide.md` before any asset generation. Use consistent isometric projection. Batch-generate with locked prompts. Accept placeholders during prototyping; art pass is Sprint 10. | Art Lead | Side-by-side screenshots look like they come from different games |
| R07 | **Historical tone misfires (colonial insensitivity)** — The game trivializes exploitation, uses caricatured depictions, or makes light of famine/labor unrest, causing reputational damage. | High | Low | Review bombing; press backlash; team morale harm; platform rejection | Follow `design_bible.md` §15. Treat colonial extraction as systemic pressure, not comedy. Relief logistics, not famine spectacle. Satire targets corporations and incentives, not communities. Mandatory tone review for all event copy, newspaper headlines, and contract text. | Narrative Lead / Project Lead | Social media or playtest feedback flags a line as "tone-deaf" or "offensive" |
| R08 | **Pathfinding performance suffers** — As the network grows, `TrackGraph` pathfinding slows the frame rate or causes hitches, especially with multiple trains and rivals. | Medium | Medium | Game becomes unplayable in mid/late session; limits map size | Use A* with heuristic. Cache shortest paths invalidating only on edge add/remove. Stress-test with 50+ trains and 200+ edges in Phase 4. Profile before each phase gate. | Programmer | Frame time spikes when trains recalculate routes; profiling shows pathfinding > 2 ms/frame |
| R09 | **Player doesn't understand why they lost money** — Maintenance, terrain costs, tolls, or oversupply drain treasury without clear feedback, making failure feel arbitrary. | High | Medium | Violates "Clear economic feedback" pillar; players blame the game | Break down every trip: revenue, maintenance, tolls, loading costs. Show daily ledger. Use color (green/red) and icons. Flash treasury change with reason. Require "profit source" metric in playtests. | UX Lead / Systems Designer | Playtesters say "I went bankrupt and I don't know why" |
| R10 | **Tutorial is skipped or confusing** — Players ignore tooltips, miss the route preview, or don't realize cities have supply/demand, leading to early-session drop-off. | Medium | Medium | First 10 minutes fail; players never reach strategic depth | In-context tutorial (build first track = prompted). Highlight clickable cities with pulse. Show supply/demand on city select, not in a separate screen. Track "time to first track" metric. Allow skip for veterans. | UX Lead | Time to first track > 5 minutes; playtesters ask "what do I do?" after 3 minutes |

---

## 3. Risk Heat Map

```
Likelihood
   H | R03 (Track clunky)        R06 (Art inconsistency)
     | R09 (Money confusion)
   M | R01 (Scope creep)         R04 (AI unfair)
     | R02 (Economy shallow)     R08 (Pathfinding perf)
     | R05 (Save/load fragile)   R10 (Tutorial confusing)
   L | R07 (Tone misfire)
     +-----------------------------
        L        M        H
              Severity
```

---

## 4. Review Schedule

| When | Action |
|------|--------|
| End of every sprint | Programmer and designer scan for new risks; update likelihood/severity if mitigation is working or failing |
| Before every phase gate | Full risk review; escalate any High-severity open risks to the project lead |
| After every external playtest | Add qualitative observations as risk evidence; adjust early warning thresholds |
| After any public build | Monitor for reputational risks (R07, R06); collect screenshots and quotes |

---

## 5. Escalation Path

1. **Green (Low risk or well-mitigated)** — Track in sprint report, no action needed.
2. **Yellow (Medium risk, needs watch)** — Mention in sprint retrospective; owner proposes mitigation adjustment.
3. **Red (High risk, active threat)** — Pause non-critical tasks; owner drafts mitigation plan; project lead approves or accepts schedule impact.

---

## 6. Deferred Risks

These are not immediate threats but may enter the register after v0.7.0:

- Web export performance and browser compatibility
- Localization complexity (Hindi, Bengali UI)
- Steam/platform certification rejections
- Modding community expectations vs. data format stability

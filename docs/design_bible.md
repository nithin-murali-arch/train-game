# Rail Empire — Design Bible

Version: 0.2  
Companion files: `design.md`, `art_style_guide.md`, `rail_empire_execution_pack.md`

---

## 1. One-sentence vision

Rail Empire is a depth-first isometric railway tycoon where players turn Colonial Bengal into a profitable rail network, then survive competition, crises, and era transitions through logistics rather than combat.

---

## 2. Creative promise

The game should make railways feel like economic arteries. Track placement, cargo flow, city demand, contracts, and historical pressure should combine into a clear but deep strategy game.

The player should feel clever for reading the economy, building the right line at the right time, and adapting when the world changes.

---

## 3. Non-negotiable pillars

## 3.1 Logistics, not combat

The game has no direct unit combat. Conflict is expressed through:

- Profitable route races
- Market saturation
- Track ownership
- Tolls and access
- Contracts
- Monsoon damage
- Labor unrest
- Wartime requisition
- Sabotage-like events in later eras

Do not turn the game into an RTS war game.

## 3.2 India first, world later

The first great version of the game should make Bengal deep and memorable. India-focused regions are the priority. Global maps may exist later as data-driven expansions.

## 3.3 Era over faction

Eras define available trains, cargo, events, and world pressures. Factions are evergreen identities with bonuses and personalities, but they use the same era-appropriate technology pool.

This allows alt-history play while keeping content production manageable.

## 3.4 Depth before breadth

A smaller map with meaningful decisions beats a large map with shallow choices.

Before adding a new era, region, mode, or faction, the current layer must pass its exit criteria.

## 3.5 Clear economic feedback

Players must understand why a route is profitable or losing money. Every major decision needs readable feedback.

## 3.6 Historical flavor with care

The colonial setting is a source of tension, not an endorsement. The game may use satire and alt-history, but it should not trivialize famine, exploitation, war, forced labor, or political suffering.

---

## 4. Target experience

### First 10 minutes

The player learns:

- Cities produce and demand goods.
- Track costs money.
- Trains move cargo.
- Deliveries earn revenue.
- Some routes are better than others.

### First 30 minutes

The player learns:

- Terrain changes route cost.
- Train choice matters.
- City prices move with supply and demand.
- Expanding too fast can hurt profit.

### First 2 hours

The player learns:

- Contracts create short-term pressure.
- Station upgrades create hubs.
- Rival companies can seize important routes.
- Ownership and tolls turn infrastructure into strategy.

### Full campaign arc

The player should feel:

- “I founded a railway company.”
- “I optimized a regional economy.”
- “I fought rivals through logistics.”
- “I survived crises.”
- “My old network had to adapt to a new era.”

---

## 5. Tone

### Base tone

Strategic, readable, slightly satirical, historically flavored, not grimdark.

### Acceptable humor

- Corporate rival personalities
- Newspaper headlines
- Tycoon vanity
- Bureaucratic inconvenience
- Light satirical naming for modern conglomerates

### Avoid

- Mocking victims of famine, war, colonial exploitation, or labor unrest
- Treating human suffering as slapstick
- Making any culture a caricature
- Using real-world tragedies as disposable jokes

### Writing style

UI text should be clear first and flavorful second.

Good:

> Monsoon warning: river-adjacent tracks face flood damage next month. Upgrade bridges or reserve repair funds.

Bad:

> The heavens are angry! Chaos everywhere!

---

## 6. World model

## 6.1 Starting region: Bengal

Bengal is the first deep region because it naturally supports:

- Kolkata as a port hub
- Coal flow from inland mining centers
- Textiles and industrial demand
- Agricultural towns
- River crossings and monsoon pressure
- Colonial extraction themes
- Compact geography for an MVP

## 6.2 Region design rules

A good region should have:

- At least one high-demand hub
- At least one bulk resource origin
- At least one agricultural/support town
- At least one difficult but profitable route
- At least one natural bottleneck
- At least one event vulnerability

## 6.3 City archetypes

| Archetype | Gameplay Role |
|---|---|
| Port Metropolis | High demand, export bonuses, major contracts |
| Mining Center | Bulk cargo origin, low value high volume |
| Industrial City | Converts input demand into manufactured output |
| Agricultural Town | Stable low-margin goods, famine/relief contracts |
| Frontier Resource Town | High reward, expensive access |
| Administrative Capital | Government contracts and reputation pressure |

---

## 7. Canonical first region

## 7.1 Core Bengal cities

| City | Role | Design Purpose |
|---|---|---|
| Kolkata | Port metropolis | Main demand/export hub |
| Patna | Mining center | Coal origin and inland objective |
| Dacca | Industrial city | Textiles and input demand |
| Murshidabad | Agricultural town | Grain stability and low-margin route |

## 7.2 Expansion candidates

| City | Role | Add When |
|---|---|---|
| Siliguri | Frontier tea route | Economic depth phase |
| Varanasi | Large inland demand hub | Economic depth or campaign phase |
| Guwahati | North-east frontier | Later regional expansion |

---

## 8. Factions

## 8.1 Faction design rules

Factions should be mechanically different without requiring separate technology pools.

A faction may have:

- Starting capital modifier
- Construction cost modifier
- Cargo revenue modifier
- Maintenance modifier
- AI route preference
- Contract preference
- Risk tolerance

A faction should not have:

- A completely unique economy
- A separate train list in the same era
- A separate cargo list in the same era
- A unique UI stack

## 8.2 First implemented factions

### British East India Rail

Identity: aggressive colonial rail company.  
Gameplay role: early expansion pressure.  
Bonus: higher starting capital.  
AI personality: builds first, accepts risk, targets trunk routes.

### French Compagnie des Indes

Identity: selective luxury/passenger operator.  
Gameplay role: quality-over-quantity rival.  
Bonus: passenger/luxury revenue.  
AI personality: chooses fewer, more profitable routes.

### Amdani Rail

Identity: aggressive conglomerate satire.  
Gameplay role: freight volume and construction dominance.  
Bonus: cheaper construction or higher freight throughput.  
AI personality: controls ports and undercuts routes.

## 8.3 Long-term faction roster

| Faction | Identity | Primary Strategic Flavor |
|---|---|---|
| British East India Rail | Colonial power | Capital and fast expansion |
| French Compagnie des Indes | Colonial power | Luxury/passenger focus |
| Portuguese Estações do Oriente | Colonial power | Port and coastal efficiency |
| IRCTC | Public sector | Passenger revenue and subsidies |
| Amdani Rail | Conglomerate satire | Construction and freight monopoly |
| Amboney Transport | Conglomerate satire | Innovation and premium routes |
| Tota Railways | Industrial house | Coal, steel, oil, durable trains |
| Mahendra Logistics | Industrial/defense | Speed, maintenance, military contracts |

---

## 9. Era canon

## 9.1 Era design rule

Each era must change pressure, not just paint.

A good era changes:

- Cargo priorities
- Contract types
- Maintenance multipliers
- Event risks
- Train capabilities
- UI/audio flavor

## 9.2 Era roadmap

| Era | Primary Pressure | Gameplay Meaning |
|---|---|---|
| Colonial | Extraction and port economics | Build profitable civilian/resource network |
| WW1 | Military logistics | Repurpose network for urgent contracts |
| WW2 | Infrastructure damage and raids | Resilience under greater disruption |
| Cold War | Planning and public works | Government mandates and industrialization |
| Modern | Corporate competition | Rapid expansion and market booms |
| WW3/Current | Supply chain fragility | Cyber/fuel/logistics crises |

## 9.3 First era: Colonial

Colonial should feel like:

- Sepia ledgers
- High cost of river crossings
- Port demand
- Resource extraction
- Early industrial growth
- Unstable politics and weather

## 9.4 Second era: WW1

WW1 should feel like:

- The same rail network under emergency pressure
- Military contracts replacing some civilian priorities
- Coal demand rising
- Passenger profit declining
- Government requisition overriding normal access
- Tense newspaper/telegraph messaging

---

## 10. Economy canon

## 10.1 Economic verbs

The player should constantly do these:

- Inspect
- Compare
- Build
- Assign
- Deliver
- Upgrade
- Repair
- Reroute
- Bid
- Respond

## 10.2 Cargo design rules

Each cargo should have a different reason to exist.

Bad cargo design:

- Tea, Indigo, Opium, and Cotton all behave identically as “medium value trade good.”

Good cargo design:

- Coal: high volume, low value, steady demand
- Textiles: manufactured good, medium value, tied to industrial cities
- Grain: stable but event-sensitive, famine/relief contracts
- Tea: high value, difficult route, export bonus

## 10.3 Price design rules

Prices should move enough to matter but not so much that the economy becomes chaotic.

- Clamp prices.
- Show price reason.
- Let oversupply recover gradually.
- Do not punish the player without explanation.

---

## 11. Player decision categories

## 11.1 Investment decisions

- Build new route or upgrade existing station?
- Buy cheap freight engine or faster mixed engine?
- Take a contract or build long-term infrastructure?

## 11.2 Spatial decisions

- Direct route through expensive terrain or longer cheap route?
- Control a bridge or avoid the bottleneck?
- Build to port or inland demand center?

## 11.3 Operational decisions

- Which train serves which route?
- Should a route pause because the city is oversupplied?
- Should a station become a hub?

## 11.4 Competitive decisions

- Race the rival to a route?
- Pay tolls or build alternate track?
- Block a bottleneck or keep access open for toll revenue?

## 11.5 Crisis decisions

- Repair before inspection or risk fines?
- Upgrade bridges before monsoon or keep cash?
- Redirect trains to a port boom or stay on contracts?

---

## 12. Campaign identity

## 12.1 First campaign

`Bengal Railway Charter`

This is the first complete campaign. It should prove the full Colonial loop before broader eras.

## 12.2 Campaign acts

### Act 1 — First Charter

Theme: found the company.  
Core challenge: build first profitable line.  
Systems: track, train, cargo, treasury.

### Act 2 — Port Expansion

Theme: Kolkata becomes the prize.  
Core challenge: export routes and port demand.  
Systems: contracts, city roles.

### Act 3 — Inland Expansion

Theme: reach the interior.  
Core challenge: terrain costs and longer routes.  
Systems: station upgrades, saturation.

### Act 4 — Monopoly Race

Theme: rival pressure.  
Core challenge: market share and ownership.  
Systems: AI rival, tolls, junctions.

### Act 5 — Crisis Finale

Theme: network resilience.  
Core challenge: monsoon/unrest/relief contracts.  
Systems: events, repair, contracts, reputation.

---

## 13. Win and loss philosophy

## 13.1 Win paths

The game should allow multiple strategic identities:

- Wealth tycoon: reach net worth target
- Monopoly builder: control market share
- Contract specialist: complete major contracts
- Network builder: connect all key cities with good reputation

## 13.2 Failure

Avoid sudden opaque failure. Failure should be recoverable unless the player repeatedly ignores warnings.

Possible loss states:

- Bankruptcy after grace period
- Reputation collapse in campaign
- Critical contract failure in scenario
- Rival monopoly in specific scenario

---

## 14. UI/UX canon

## 14.1 UI personality

The UI should feel like a railway ledger layered over a map.

Colonial UI:

- Parchment panels
- Ledger tables
- Stamp-like labels
- Newspaper briefings
- Clear modern readability underneath period flavor

WW1 UI:

- Military map overlays
- Telegraph-style notices
- Desaturated palettes
- Urgent contract banners

## 14.2 UI rule

Every flavorful UI element must still be fast to read.

## 14.3 Always-visible information

- Treasury
- Date
- Game speed
- Current objective
- Selected tool
- Active warning/event

## 14.4 Do not hide economic truth

Players must be able to find:

- Why prices changed
- Why a train lost money
- Why a route is blocked
- Why track construction is expensive
- Why a rival got ahead

---

## 15. Historical and satirical boundaries

## 15.1 Colonial context

The game can include colonial companies and extraction mechanics, but it should not sanitize the period. The systems should imply unequal power and resource extraction through mechanics like port bonuses, toll regimes, administrative contracts, and unrest.

## 15.2 Famine and relief

Famine-related content should be handled as relief logistics, not as spectacle. Avoid sensational language.

## 15.3 Labor unrest

Labor events should be treated as serious operational and ethical pressure, not merely a nuisance joke.

## 15.4 Satirical corporations

Satirical corporate houses are allowed, but keep the satire systemic rather than insulting. The joke is about incentives and monopolies, not communities or individuals.

---

## 16. What this game is not

Rail Empire is not:

- A real-time combat game
- A fully realistic railway simulator
- A historical textbook
- A city builder where zoning is the main mechanic
- A train-driving simulator
- A stock-market game first
- A global map game at launch
- A game where more content replaces deeper decisions

---

## 17. Design smell checklist

A proposed feature is suspicious if:

- It adds a new category of content before improving a decision.
- It requires a new UI screen but does not create new strategy.
- It makes the economy harder to understand.
- It adds randomness without counterplay.
- It duplicates an existing cargo, train, or faction role.
- It requires final art before the core loop is proven.
- It turns logistics conflict into direct combat.

---

## 18. Feature approval test

Before adding a feature, answer:

1. Which design pillar does it deepen?
2. What decision does it create for the player?
3. What information does the UI need to explain it?
4. What is the smallest implementation that proves it?
5. What should be postponed?

If those answers are weak, park the feature.

---

## 19. Kimi implementation charter

When Kimi builds this game:

- It should read `design.md` for concrete systems.
- It should read this design bible for tone, scope, and creative rules.
- It should read `art_style_guide.md` before creating visual placeholders or asset folders.
- It should implement one sprint at a time.
- It should not invent extra factions, eras, or modes.
- It should report files changed, manual tests, known issues, and what was intentionally not implemented.

---

## 20. Canon summary

The canonical first version is:

> A readable, strategic, isometric railway tycoon set in Colonial Bengal where a player builds a profitable rail company, learns route economics, manages supply and demand, upgrades stations, faces one rival, controls track, survives events, and eventually adapts the network to WW1.

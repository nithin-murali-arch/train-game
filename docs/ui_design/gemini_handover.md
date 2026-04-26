# Gemini Handover — Rail Empire UI Screens

Copy and paste each section below into Gemini (or your preferred image generator) one screen at a time. Generate images at 1920×1080 or 16:9 aspect ratio.

---

## Prompt 0: Master Design System (Paste First)

Generate a desktop PC strategy game UI design system for "Rail Empire", an isometric 2D railway tycoon set in Colonial Bengal (1850s–1910s).

**Visual direction:**
- Era: Colonial Bengal, 1850s–1910s
- Palette: warm sepia (#F5E6C8), parchment beige, muted indigo (#4B0082), dark ink (#1A1A1A), brass/gold highlights (#B8860B, #D4AF37), rail steel grey (#708090), muted forest green (#4B6F44)
- Avoid: neon, cyberpunk, fantasy, modern SaaS, cartoon UI, mobile card-game look
- UI chrome: ledger paper, stamped documents, railway tickets, brass labels, thin ink borders
- Typography: readable serif headings (Noto Serif), clean sans body text (Noto Sans)
- Layout: desktop-first 16:9, optimized for 1920×1080
- Game camera: isometric railway map occupies most of the screen
- Panels: collapsible, information-dense but not cluttered

**Core UX principles:**
1. Player always sees treasury, date, active route, city prices, route profitability
2. Track building shows cost before confirmation
3. Economy info is clear: supply, demand, price, trend, stockpile
4. Alerts feel like newspaper/telegraph notices
5. Mouse/keyboard PC strategy game — NOT touchscreen

**Required components:**
- HUD components
- Side panels (right-side, slide-in)
- Tooltips (parchment, ink border)
- Buttons (brass accent, ink border, pressed state)
- Modal dialogs (centered, darkened overlay)
- Notification cards (newspaper/telegraph style)
- Tables (ledger rows, alternating parchment tint)
- Map overlays (route highlights, territory colors)
- Icons (cargo: coal=black, textiles=green, grain=gold)
- Empty states (centered, subtle icon)
- Error states (red/rust accent, clear message)

**Technical constraints for Godot 4 implementation:**
- Must be implementable with Control nodes, Panels, StyleBoxFlat, Labels, TextureRects, Buttons, VBox/HBox containers
- Avoid: complex glassmorphism, heavy blur, tiny decorative flourishes, impossible layered effects, gradient text
- Prefer: flat colors, solid borders, simple shapes, readable at 1080p

---

## Prompt 1: Main Game HUD

Generate the main in-game HUD screen for Rail Empire.

**Canvas:** 1920×1080 desktop game UI.

**Background:** Isometric map of Colonial Bengal with visible terrain (plains beige, rivers blue, forests green), river Ganges, city markers for Kolkata and Patna, and a railway track segment connecting them.

**Required UI elements:**
- Top-left: Company name "Bengal Railway Company" in serif font, treasury "₹52,400" in large brass-colored text, reputation "12", market share "0%"
- Top-center: Date "March 1857" in serif, game speed controls: pause button, 1×, 2×, 4× speed pills
- Top-right: One telegraph-style notification strip: "⚠ Monsoon warning: heavy rains expected"
- Left vertical toolbar (60px wide): 5 square buttons with icons — Build Track (hammer), Buy Train (locomotive), Routes (arrows), Contracts (document), Reports (chart)
- Bottom-left mini panel: "Selected: Track Tool | Click origin city, then destination"
- Bottom-center action bar: "Confirm Build" button (brass), "Cancel" button (rust), "Estimated cost: ₹7,000"
- Bottom-right profitability widget: small parchment card showing "Revenue: ₹4,000/trip | Cost: ₹300/trip | Break-even: 2 trips"
- Right edge: Collapsible event log tab handle

**Visual style:** Colonial railway ledger, parchment panels with thin ink borders, dark ink text, brass accent buttons, muted warm colors. Strategic and readable. No fantasy, no sci-fi.

---

## Prompt 2: Track Building Flow

Generate the track-building interaction screen for Rail Empire.

**Canvas:** 1920×1080.

**Background:** Isometric Bengal map. Kolkata (bottom-right) and Patna (top-left) are visible city markers. A preview railway line connects them in bright indigo color with small cost markers along the route.

**Cursor tooltip (near center):**
Small parchment card following cursor:
- Terrain Breakdown:
- Plains: 8 km × ₹500 = ₹4,000
- River Bridge: 1 × ₹3,000 = ₹3,000
- Total: ₹7,000

**Bottom confirmation panel (wide bar, 60% width):**
- Route: Kolkata → Patna
- Estimated construction cost: ₹7,000
- Estimated revenue per coal trip: ₹4,000
- Break-even: 2 trips
- Treasury preview: ₹52,400 → ₹45,400
- Three buttons: "Confirm Build" (brass), "Adjust Route" (parchment), "Cancel" (rust)

**Invalid terrain:** A hill area near the route shows subtle red/brown tint overlay.

**Visual style:** Railway engineer's planning overlay on a map. Technical drawing aesthetic with brass and ink. Clean and readable.

---

## Prompt 3: City Panel (Kolkata)

Generate the City Panel for Rail Empire.

**Canvas:** 1920×1080 with isometric Bengal map in background (dimmed 20%). A right-side panel slides in from the right edge, 400px wide.

**Panel title:** "Kolkata" in large serif, subtitle "Port Metropolis" on a dark sepia pill.

**Section 1 — City Summary (2-column grid):**
- Population: Large
- Connected Tracks: 2
- Station Level: Basic
- Owner Influence: Player 100%

**Section 2 — Supply and Demand (ledger table):**
Columns: Cargo | Stock | Daily Change | Demand | Price | Trend
- Coal | 40 tons | -80/day | High | ₹27/ton | ↑ rising (green arrow)
- Textiles | 620 tons | +50/day | Medium | ₹18/ton | → stable (grey arrow)
- Grain | 90 tons | -35/day | Medium | ₹12/ton | ↑ rising (green arrow)

Alternating row tints on parchment. Small colored squares for cargo icons.

**Section 3 — Special Effects:**
- Port export bonus: +20% on Textiles during Port Boom
- High passenger demand: [locked icon]

**Section 4 — Actions:**
4 full-width buttons: "Build Station Upgrade", "Assign Train Route", "View Contracts", "Center Camera"

**Section 5 — Warning chip:**
Pill-shaped badge at bottom: "Coal shortage: high-profit delivery opportunity" in rust color.

**Visual style:** Colonial ledger table on parchment. Dense but readable data. Small cargo icons. Price trend arrows. Strategy game panel, NOT business dashboard.

---

## Prompt 4: Train Purchase Panel

Generate the Train Purchase panel for Rail Empire.

**Canvas:** 1920×1080. Background map is blurred/dimmed. A large centered panel (900×700px) appears as a purchase ledger.

**Title:** "Purchase Train" in large serif at top.

**Top row:**
- Treasury: ₹52,400 (brass text)
- Home Station dropdown: "Kolkata" with small dropdown arrow

**Two train cards side by side:**

**Card 1 — Freight Engine:**
- Visual: Grey isometric steam locomotive sprite (side view), simple geometric style
- Cost: ₹5,000 (brass)
- Capacity: 200 tons
- Speed: 2 km/tick
- Maintenance: ₹50/day
- Best for: Coal, Grain
- Button: "Buy Freight Engine" (brass)

**Card 2 — Mixed Engine:**
- Visual: Brass-accented isometric steam locomotive, slightly sleeker
- Cost: ₹10,000 (brass)
- Capacity: 100 tons
- Speed: 4 km/tick
- Maintenance: ₹80/day
- Best for: Textiles, fast routes
- Button: "Buy Mixed Engine" (brass)

Each card: parchment background, ink border, brass header strip, stats in clean grid, small recommendation text at bottom.

**Comparison tooltip (bottom center):**
"Freight: better profit for bulk cargo. Mixed: faster turnaround."

**Visual style:** Colonial rail catalog. Brass labels. Technical blueprint accents. Premium strategy game UI. Readable and clean.

---

## Prompt 5: Contracts Panel

Generate the Contracts Panel for Rail Empire.

**Canvas:** 1920×1080. Background map visible but not the focus. A large panel (80% width, 70% height) centered as a government contract ledger.

**Title:** "Contracts" with filter tabs: Available (active/underlined), Active, Completed, Failed.

**Left side — Contract list (60% width):**

**Contract 1:**
- Header: "Coal for the Port" + badge "60 days" (brass pill)
- Body: "Deliver 200 tons of Coal to Kolkata"
- Reward: ₹5,000 + 10 reputation
- Penalty: ₹1,000 and -15 reputation
- Button: "Accept" (brass)

**Contract 2:**
- Header: "Grain Relief" + badge "45 days" (brass pill)
- Body: "Deliver 150 tons of Grain to Murshidabad"
- Reward: ₹3,500 + 15 reputation
- Button: "Accept"

**Contract 3:**
- Header: "Textile Export Order" + badge "30 days" (rust pill = urgent)
- Body: "Deliver 100 tons of Textiles to Kolkata"
- Reward: ₹4,000 + 8 reputation
- Button: "Accept"

Each contract card: parchment background, ink border, stamped paper aesthetic.

**Right side — Detail panel (40% width):**
Selected contract (Contract 1) shows:
- Large map thumbnail showing Kolkata marker
- Cargo: 200 tons Coal (coal icon)
- Destination: Kolkata
- Deadline: 60 days
- Reward: ₹5,000
- Reputation: +10
- Penalty: ₹1,000, -15 rep
- Suggested route: "Patna → Kolkata (Coal)"
- Two buttons: "Accept" (brass), "Decline" (parchment)

**Visual style:** Colonial government contract ledger with stamped papers. Strategic objectives, not RPG quests. Parchment, ink, brass. Readable and serious.

---

## Output Instructions for Gemini

For each screen:
1. Generate at **1920×1080 resolution** or **16:9 aspect ratio**
2. Export as **PNG** with transparent UI elements where possible
3. If transparent backgrounds aren't supported, generate with the isometric map background included
4. Provide a **layer breakdown** if possible (background map vs UI overlay)
5. Keep text readable at full resolution — no tiny labels

**Priority order:** Generate screens 1–5 in order. Do not generate later screens (Auction, Rival Overview, Events, Campaign, Settings, Main Menu) until these 5 are done.

# Rail Empire — UX Flows

**Purpose:** Exact UI/UX flow specifications for every major player interaction.  
**Scope:** Colonial Bengal MVP (Phase 1) + forward-compatible hooks for Phase 2+.  
**Audience:** UI implementers, playtesters, tutorial designers.

---

## Legend

| Term | Meaning |
|---|---|
| **Trigger** | How the flow starts. |
| **Step** | Numbered player or system action. |
| **UI Element** | Specific on-screen control or panel. |
| **Feedback** | Visual, audio, or haptic response at that step. |
| **Exit** | How the flow ends (success, cancel, or error). |
| **Edge Cases** | Known odd states and required handling. |

---

## 1. Main Game Screen Layout

### 1.1 Always-Visible HUD Elements

| Element | Position | Content | Update Frequency |
|---|---|---|---|
| **Treasury Display** | Top-left | ₹ symbol + integer (e.g., `₹20,000`) | Every economic transaction |
| **Date Display** | Top-center | `Day X` early; later `Month Y, 1857` | Every game hour (1 real sec at 1×) |
| **Game Speed Control** | Top-right | Four pill buttons: `⏸` `1×` `2×` `4×` | On click only |
| **Current Objective** | Below date | One-line text (e.g., "Connect Kolkata and Patna") | On objective change |
| **Event Ticker** | Bottom-center | Scrolling or fading banner for active/warning events | On event trigger/dismiss |
| **Selected Tool Indicator** | Bottom-left | Icon + label of active tool (e.g., "Track Tool") | On tool change |
| **Notification Stack** | Right edge, top-to-bottom | Up to 3 transient toasts (revenue, error, event) | Stacking, auto-dismiss 4 s |

### 1.2 Build Menu (Bottom Bar)

- **Track Tool** button
- **Cancel / Pan Tool** button
- **Train Purchase** button
- **Station Upgrade** button (disabled until Phase 2)

### 1.3 Map Interaction Layer

- Isometric terrain rendered by `TileMapLayer`
- City markers as clickable `Area2D` nodes
- Track segments rendered as `Line2D` or sprite overlay
- Trains rendered as `Node2D` sprites interpolating along graph paths

### 1.4 Panel Stack (Center-Right)

Only one full panel visible at a time. New panel replaces previous.
- City Panel
- Train Panel
- Route Preview Panel
- Contract Panel
- Save/Load Panel

---

## 2. Track Building Flow

**Trigger:** Player clicks the **Track Tool** button in the bottom build menu.

| Step | Action | UI Element | Feedback | Exit Condition |
|---|---|---|---|---|
| 1 | Player clicks **Track Tool** | Build Menu — Track Tool button | Button highlights; cursor changes to crosshair; tooltip: "Click a city or track node to start" | — |
| 2 | Player hovers over valid start node (city or existing track junction) | Map — node highlight overlay | Node glows green; tooltip shows node name and "Click to set origin" | Player clicks **Cancel Tool** → Exit (cancelled) |
| 3 | Player clicks valid start node | Map | Origin node pinned with green marker; audio click; tooltip updates: "Click destination" | — |
| 4 | Player hovers over valid destination | Map | Ghost segment drawn from origin to hovered node; color = green if affordable, red if not | Player clicks **Cancel Tool** or presses `Esc` → Exit (cancelled) |
| 5 | System computes preview | Route Preview Panel auto-opens | Shows: endpoints, construction cost, terrain cost multiplier, estimated cargo revenue, break-even trips | — |
| 6 | Player clicks destination to confirm | Map + Route Preview Panel | Treasury deducts cost; track appears as solid Line2D; nodes created in `TrackGraph`; audio build SFX; toast: `Track built: -₹X` | Funds sufficient |
| 7 | Flow ends | Cursor returns to default or stays in Track Tool based on setting | Build menu remains active | — |

### Edge Cases

| Case | Handling |
|---|---|
| **Insufficient Funds** | Ghost segment turns red at Step 4. Clicking destination plays error buzzer, shows toast: "Insufficient funds. Need ₹X, have ₹Y." Flow stays at Step 4 until player picks cheaper destination or cancels. |
| **Invalid Destination** | Clicking non-city / non-junction / same-as-origin plays error buzzer, toast: "Invalid destination." Flow stays at Step 4. |
| **Obstructed Path** | If terrain or rival private track blocks all paths, toast: "No valid path." Ghost segment does not render. |
| **Double-click same node** | Treated as invalid; error feedback as above. |

---

## 3. Train Purchase Flow

**Trigger:** Player clicks the **Train Purchase** button in the bottom build menu.

| Step | Action | UI Element | Feedback | Exit Condition |
|---|---|---|---|---|
| 1 | Player clicks **Train Purchase** | Build Menu — Train Purchase button | Button highlights; modal/panel opens | — |
| 2 | Panel displays available train types | Train Purchase Panel | Lists: Freight Engine, Mixed Engine. Each row shows: sprite thumbnail, name, cost, capacity, speed, maintenance/day, allowed cargo tags. Rows for unaffordable trains tinted red. | Player clicks outside panel or **Cancel** → Exit (cancelled) |
| 3 | Player hovers a train type | Train Purchase Panel | Tooltip expands with full stats comparison to owned trains (if any). | — |
| 4 | Player clicks desired train type | Train Purchase Panel | Selected row highlights; **Confirm Purchase** button activates. | — |
| 5 | Player clicks **Confirm Purchase** | Train Purchase Panel | Panel closes; treasury deducts cost; train sprite spawns at player’s starting city (Kolkata) or nearest city with track connection; toast: `Freight Engine purchased: -₹5,000` | Funds sufficient |
| 6 | Flow ends | Map shows new train idle at spawn city | Selected tool returns to **Cancel / Pan Tool** | — |

### Edge Cases

| Case | Handling |
|---|---|
| **Insufficient Funds** | Confirm button disabled; row tinted red; tooltip: "Need ₹X more." |
| **No connected city to spawn** | If no cities have track, spawn at starting city (Kolkata). Toast: "Train awaits assignment at Kolkata." |
| **Panel open while train selected** | Train panel is replaced by purchase panel. After purchase, no panel is open. |

---

## 4. Route Assignment Flow

**Trigger:** Player clicks an owned train on the map.

| Step | Action | UI Element | Feedback | Exit Condition |
|---|---|---|---|---|
| 1 | Player clicks owned train | Map — train sprite | Train sprite highlights with selection ring; **Train Panel** opens showing current state | Player clicks **Cancel Tool** → Exit (cancelled) |
| 2 | Player clicks **Assign Route** button in Train Panel | Train Panel | Panel minimizes or enters route mode; tooltip: "Click origin city" | — |
| 3 | Player hovers over valid origin city | Map — city glow | City glows blue; tooltip shows city name and stock levels for train’s allowed cargo | Player presses `Esc` → Exit (cancelled) |
| 4 | Player clicks origin city | Map | Origin city pinned with blue marker; audio click; tooltip updates: "Click destination city" | — |
| 5 | Player hovers over valid destination city | Map — city glow + ghost path | Destination glows blue; viable path highlighted on TrackGraph; tooltip shows destination price for relevant cargo | — |
| 6 | Player clicks destination city | Map + Route Preview Panel | Route Preview Panel opens with: endpoints, cargo capacity match, expected destination price, estimated revenue, maintenance estimate, estimated net profit, break-even trips | — |
| 7 | Player clicks **Confirm Route** | Route Preview Panel | Panel closes; train state updates: `route_city_ids = [origin, destination]`; train enters `Loading` state; toast: `Route assigned: Origin → Destination` | Path exists and is traversable |
| 8 | Flow ends | Map shows train loading timer at origin | Train Panel reopens showing new route | — |

### Edge Cases

| Case | Handling |
|---|---|
| **No path between cities** | Ghost path does not render at Step 5. Clicking destination shows toast: "No rail connection. Build track first." Flow stays at Step 5. |
| **Origin has zero relevant cargo** | Warning icon on origin city tooltip at Step 3. Route Preview Panel at Step 6 shows "Expected cargo: 0 tons" in yellow. Player can still confirm. |
| **Train already has route** | Step 1 shows current route. Step 7 overwrites old route. Toast: "Route changed." |
| **Destination same as origin** | Treated as invalid at Step 5. Error buzzer; toast: "Destination must differ from origin." |

---

## 5. City Inspection Flow

**Trigger:** Player clicks any city marker on the map (with **Cancel / Pan Tool** active, or any tool except Track Tool route-select mode).

| Step | Action | UI Element | Feedback | Exit Condition |
|---|---|---|---|---|
| 1 | Player clicks city marker | Map — city marker | City marker pulses; **City Panel** slides in from right | — |
| 2 | City Panel displays data | City Panel | Header: city name + role icon. Body: Produced cargo list (with icons and daily production rates), Demanded cargo list (with icons and consumption rates), Stock levels (progress bars), Current prices (₹/ton), Active contracts tied to city (if any), Station upgrades (if any) | — |
| 3 | Player hovers any cargo row | City Panel | Tooltip shows: base price, price formula hint, last delivery date, market share pie mini-chart (if rival phase active) | — |
| 4 | Player clicks **Close** or clicks another city / empty map | City Panel | Panel slides out; if another city clicked, new City Panel slides in immediately | — |

### Edge Cases

| Case | Handling |
|---|---|
| **City panel already open for this city** | Second click closes panel (toggle behavior). |
| **Track tool active** | If in Step 2 or 4 of Track Building (origin/destination selection), city click is consumed by track flow, not city inspection. |
| **City under event effect** | Event icon (flood, strike, boom) appears in header. Hovering icon shows event description and remaining duration. |

---

## 6. Contract Acceptance Flow

**Trigger:** A contract becomes available (daily tick, event, or campaign progression) AND player opens the Contract Panel via notification or city panel.

| Step | Action | UI Element | Feedback | Exit Condition |
|---|---|---|---|---|
| 1 | Contract available notification appears | Notification Stack | Toast: "New contract available in [City]" with **View** button | Player ignores → toast auto-dismisses after 6 s |
| 2 | Player opens Contract Panel | Contract Panel (full-screen overlay or right panel) | Header: contract name. Body: cargo type + quantity, destination city, deadline (days/months), reward ₹, reputation reward, failure penalty ₹. Footer: **Accept** and **Decline** buttons. | Player clicks **Decline** → Exit (declined) |
| 3 | Player hovers terms | Contract Panel | Tooltip on cargo: current market price for that cargo. Tooltip on deadline: estimated trips needed given best train speed. Tooltip on reward: net profit estimate after deducting operating costs. | — |
| 4 | Player clicks **Accept** | Contract Panel + Treasury | Panel closes or updates to "Active Contracts" tab; contract moves to `active` status; toast: `Contract accepted: [Name]` | Treasury can cover failure penalty reserve (soft check; warning only) |
| 5 | Active contract tracked | HUD — Current Objective updates | Objective text changes to contract goal; progress appears in notification area on delivery | — |

### Edge Cases

| Case | Handling |
|---|---|
| **Player accepts conflicting contract** | Multiple active contracts allowed. If two require same cargo from same city, no block. UI shows both in Active Contracts tab. |
| **Deadline passes** | Automatic failure. Treasury deducts penalty. Toast: `Contract failed: -₹X penalty.` Contract removed from active list. |
| **Contract panel open during event** | If Monsoon Flood or Labor Strike affects destination, warning banner appears in contract panel: "Destination currently affected by [Event]. Deliveries may be delayed." |
| **Already at max active contracts** | Phase 2+ only. Accept button disabled; tooltip: "Complete or decline an active contract first." |

---

## 7. Save / Load Flow

**Trigger:** Player clicks **Menu** button (top-left, gear icon) → selects **Save** or **Load**.

### Save Sub-Flow

| Step | Action | UI Element | Feedback | Exit Condition |
|---|---|---|---|---|
| 1 | Player opens Menu → clicks **Save Game** | Menu Overlay | Save/Load Panel opens, defaulting to Save tab | Player clicks **Back** → Exit (cancelled) |
| 2 | Panel shows save slots | Save/Load Panel | 6 slots. Each shows: slot number, timestamp (if occupied), in-game date (if occupied), thumbnail placeholder, **Overwrite** or **Save** button. Empty slots show "Empty." | — |
| 3 | Player clicks a slot | Save/Load Panel | Slot highlights; if occupied, confirmation dialog appears: "Overwrite save from [Date]?" | — |
| 4 | Player confirms | Confirmation Dialog | Dialog closes; game state serializes to JSON; brief freeze (< 200 ms) acceptable; toast: `Game saved to Slot X` | Write succeeds |
| 5 | Panel auto-closes or remains open based on setting | Save/Load Panel | Returns to game | — |

### Load Sub-Flow

| Step | Action | UI Element | Feedback | Exit Condition |
|---|---|---|---|---|
| 1 | Player opens Menu → clicks **Load Game** | Menu Overlay | Save/Load Panel opens, defaulting to Load tab | Player clicks **Back** → Exit (cancelled) |
| 2 | Panel shows save slots | Save/Load Panel | Same 6 slots. Only occupied slots have active **Load** button. Empty slots disabled. | — |
| 3 | Player clicks occupied slot → clicks **Load** | Save/Load Panel | Confirmation dialog: "Load game from [Date]? Unsaved progress will be lost." | — |
| 4 | Player confirms | Confirmation Dialog | Current scene fades to black; JSON deserialized; game state restored; scene rebuilt; fade in; toast: `Game loaded` | JSON parse succeeds, version compatible |
| 5 | Flow ends | Main game screen | All HUD elements refresh from loaded state | — |

### Edge Cases

| Case | Handling |
|---|---|
| **Save write fails** (disk full, permission) | Toast: "Save failed. Check disk space." Panel remains open. |
| **Load JSON corrupt / version mismatch** | Toast: "Save file incompatible or corrupt." Slot marked with warning icon. Load blocked. |
| **Auto-save slot** | Slot 0 reserved for auto-save (if implemented). Labelled "Auto-Save" and timestamped. |
| **Mid-construction save** | If player is in Track Building preview mode, save stores the in-progress state OR cancels preview before save. Decision: cancel preview before save to avoid serializing transient UI state. |

---

## 8. Error State Flow

### 8.1 Insufficient Funds

**Trigger:** Player attempts a purchase or construction costing more than current treasury.

| Step | Action | UI Element | Feedback |
|---|---|---|---|
| 1 | Player attempts purchase/build | Relevant button / map click | Button click plays error buzzer (not cash register). Toast: `Insufficient funds. Need ₹X, have ₹Y.` |
| 2 | Visual emphasis | Treasury Display | Treasury number flashes red for 0.5 s. |
| 3 | Recovery | — | Player continues play. No modal block. |

### 8.2 Invalid Build

**Trigger:** Player attempts to place track in an illegal configuration.

| Step | Action | UI Element | Feedback |
|---|---|---|---|
| 1 | Player clicks invalid destination or tries to build through obstruction | Map | Error buzzer. Toast: `Cannot build here. [Reason: river unbridged / rival private track / no path found.]` |
| 2 | Ghost segment (if visible) | Map | Turns red for 0.3 s, then fades. |
| 3 | Recovery | — | Flow returns to destination selection (Track Building Step 4). |

### 8.3 Failed Contract

**Trigger:** Contract deadline expires with insufficient quantity delivered.

| Step | Action | UI Element | Feedback |
|---|---|---|---|
| 1 | System detects failure at daily tick | Notification Stack | Toast: `Contract failed: [Name]. Penalty: -₹X.` Treasury deducts penalty. |
| 2 | Persistent log | Contract Panel — History tab | Entry added: red X, name, date failed, penalty paid. |
| 3 | Recovery | — | Player may accept new contracts immediately. No cooldown. |

### 8.4 Train Breakdown (Phase 2+)

**Trigger:** Train condition reaches 0.0 or random failure roll triggered.

| Step | Action | UI Element | Feedback |
|---|---|---|---|
| 1 | Train enters `BrokenDown` state | Map + Train Panel | Train sprite changes to dark tint; stops moving; smoke particle effect; toast: `[Train Name] has broken down near [City].` |
| 2 | Resolution options | Train Panel | **Repair** button (costs ₹ based on train type). Or wait for daily auto-repair (slower, free but minimal). |
| 3 | Post-repair | Map | Train sprite returns to normal; toast: `[Train Name] repaired.` |

---

## 9. Game Speed Control Flow

**Trigger:** Player clicks a speed button in the top-right HUD.

| Step | Action | UI Element | Feedback | Exit Condition |
|---|---|---|---|---|
| 1 | Player clicks speed button | HUD — Speed Control | Active speed button highlights (filled). Others dim. | — |
| 2 | Game time scale updates | Engine | `Engine.time_scale` set accordingly. At pause, all train movement and economy ticks halt. Date display stops advancing. | — |
| 3 | Audio pitch shift | Audio bus | If audio implemented, ambient SFX pitch shifts slightly with speed (1× = normal, 2× = +5%, 4× = +10%). Pause = fade out. | — |
| 4 | Player clicks different speed | HUD — Speed Control | New button highlights; time scale updates immediately. | — |

### Edge Cases

| Case | Handling |
|---|---|
| **Panel open during speed change** | Panels remain open. Time still advances behind them. |
| **Event warning during pause** | Event ticker still animates (if warning imminent). Pause does not block event countdown display. |
| **Keyboard shortcuts** | `Space` = toggle pause/unpause (returns to last active speed). `1` `2` `3` `4` = pause, 1×, 2×, 4×. |
| **Speed change during track build preview** | Allowed. Ghost segment and preview panel remain stable. |

---

## 10. First-Time Player Flow (First 60 Seconds)

**Assumption:** Player launches Colonial Bengal scenario for the first time. Tutorial system is active (see `tutorial_spec.md`).

### Second-by-Second Design

| Time | What Player Sees | System Behavior | Tutorial Hook |
|---|---|---|---|
| 0–3 s | Fade from black to isometric map. Camera centered on Kolkata. HUD elements fade in sequentially (treasury, date, speed, objective). | Game starts paused (`⏸` active). Ambient audio fades in. | — |
| 3–8 s | Notification toast: "Welcome to Rail Empire. Your goal: connect Kolkata to Patna and deliver coal." | Pause remains active. | Tutorial 1 trigger: "First Coal Route" begins. |
| 8–15 s | Tutorial overlay highlights **Track Tool** in bottom build menu. Tooltip: "Click here to start building track." | Input blocked except Track Tool button. | Step 1 of Tutorial 1. |
| 15–25 s | Player clicks Track Tool. Tutorial overlay moves to Kolkata city marker. "Click Kolkata to set the starting point." | Input blocked except Kolkata. | Step 2 of Tutorial 1. |
| 25–35 s | Player clicks Kolkata. Overlay moves to Patna. "Now click Patna." Ghost segment previews. | Input blocked except Patna. Route Preview Panel opens automatically. | Step 3 of Tutorial 1. |
| 35–45 s | Player clicks Patna. Track built. Treasury updates to `₹20,000 − cost`. Toast confirms build. Tutorial overlay moves to **Train Purchase** button. "Buy your first train." | Input blocked except Train Purchase button. | Step 4 of Tutorial 1. |
| 45–55 s | Player buys Freight Engine. Toast confirms. Train spawns at Kolkata. Overlay highlights train sprite: "Click the train to assign its route." | Input blocked except new train. | Step 5 of Tutorial 1. |
| 55–60 s | Player clicks train, assigns Kolkata → Patna route. Train enters Loading state. Tutorial overlay fades. Toast: "Your train will now carry coal to Patna. Unpause to watch it go." | Speed control unblocked. Player can unpause. | Tutorial 1 continues in background until 100 coal delivered. |

### Exit Conditions

- **Success:** Player completes all Tutorial 1 steps within 60 s and unpauses.
- **Abandon:** Player clicks **Skip Tutorial** at any time (button appears top-right during tutorial). Tutorial 1 is marked skippable. Game unpauses; all UI unblocks.
- **Timeout:** If player takes > 120 s on any single step, tutorial auto-advances with a gentler hint pulse.

### Edge Cases

| Case | Handling |
|---|---|
| **Player exits to menu during tutorial** | Tutorial state saved. On return, tutorial resumes at last incomplete step. |
| **Player saves during tutorial** | Save includes tutorial step index. Load restores tutorial overlay at correct step. |
| **Player clicks wrong target** | Soft error: target pulses red, overlay stays on correct target. No penalty. No buzzer. |

---

## Appendix A: Input Mapping Reference

| Action | Mouse | Keyboard | Context |
|---|---|---|---|
| Pan camera | Drag RMB / edge scroll | WASD / Arrow keys | Always |
| Zoom | Scroll wheel | `+` / `-` | Always |
| Select tool | LMB click button | `T` = Track, `C` = Cancel | Always |
| Confirm build / route | LMB click target | `Enter` | During preview |
| Cancel current flow | Click Cancel Tool | `Esc` | During any build/assign flow |
| Pause / unpause | Click ⏸ button | `Space` | Always |
| Speed 1× / 2× / 4× | Click buttons | `1` / `2` / `3` / `4` | Always |
| Open city panel | LMB click city | — | With Pan Tool active |
| Open train panel | LMB click train | — | Always |

## Appendix B: Z-Index / Layering Rules

| Layer | Z-Index | Contents |
|---|---|---|
| Terrain | 0 | `TileMapLayer` tiles |
| Track | 10 | `Line2D` segments |
| Cities | 20 | City markers, labels |
| Trains | 30 | Train sprites |
| Selection / Ghost | 40 | Highlights, preview segments, range circles |
| Panels | 50 | City Panel, Train Panel, etc. |
| Modals | 60 | Confirmation dialogs, Menu Overlay |
| Tutorial Overlay | 70 | Dim overlays, target brackets, text boxes |
| Notifications | 80 | Toast stack |
| Cursor | 90 | Custom cursor sprite (if used) |

# Rail Empire — Release Plan

Version: 1.0
Companion: `risk_register.md`, `playtest_plan.md`, `BACKLOG.md`

---

## 1. Purpose

Define version numbering, milestone targets, export platforms, what is intentionally excluded from each milestone, the build process, and the release checklist. This ensures every build is intentional, testable, and traceable.

---

## 2. Version Naming Scheme

```
v0.X.Y

0   = pre-release (major version 0 until v1.0.0)
X   = phase (maps to design.md phases 0–10)
Y   = sprint within phase (starts at 0, increments per sprint)
```

### Examples

| Version | Meaning |
|---------|---------|
| v0.0.0 | Route Toy — first internal prototype |
| v0.0.2 | Route Toy — Sprint 01, iteration 2 |
| v0.1.0 | Colonial Core — Phase 1 begins |
| v0.2.3 | Colonial Core — Sprint 02, iteration 3 |
| v0.7.0 | Colonial Campaign vertical slice / public demo |
| v1.0.0 | Full Release — all modes, polished, shipped |

### Tagging Rule

Every version that passes its phase gate receives a Git tag:

```bash
git tag -a v0.X.Y -m "Phase X Sprint Y — [milestone name]"
git push origin v0.X.Y
```

Pre-release iterations (internal only) may use lightweight tags or commit hashes.

---

## 3. Milestones

| Version | Milestone Name | Phase Reference | Primary Goal | Exit Criteria Summary |
|---------|---------------|-----------------|--------------|----------------------|
| **v0.0.0–v0.0.x** | Route Toy | Phase 0 | Prove track + train + money | Non-dev builds track, buys train, earns money in < 2 min |
| **v0.1.0–v0.2.x** | Colonial Core | Phase 1 | First real tycoon loop | 20+ min session, 3+ routes, strategic trade-offs |
| **v0.3.0–v0.3.x** | Economic Depth | Phase 2 | Economy is fun without rivals | Contracts, saturation, upgrades create optimization |
| **v0.4.0–v0.4.x** | First Rival | Phase 3 | One visible, fair competitor | AI pressure without unfairness or invisibility |
| **v0.5.0–v0.5.x** | Network Control | Phase 4 | Infrastructure is strategic | Win/lose through ownership, tolls, bottlenecks |
| **v0.6.0–v0.6.x** | Events | Phase 5 | Fair disruption adds variety | Events reward preparation, not luck |
| **v0.7.0** | Colonial Campaign (Vertical Slice / Demo) | Phase 6 | Complete Colonial arc | 5-act campaign feels like a finished small game |
| **v0.8.0–v0.8.x** | Factions | Phase 7 | Mechanically distinct rivals | Faction choice changes strategy |
| **v0.9.0–v0.9.x** | WW1 Expansion | Phase 8 | Same map, wartime pressure | Network feels meaningfully different under WW1 |
| **v1.0.0** | Full Release | Phases 9–10 | All modes, polished, exported | Scenario, Campaign, Sandbox; art/audio pass; accessibility |

---

## 4. Export Targets per Milestone

### Platform Matrix

| Platform | v0.0.x | v0.1–v0.6 | v0.7 (Demo) | v0.8–v0.9 | v1.0.0 |
|----------|--------|-----------|-------------|-----------|--------|
| **Windows** | Internal only | Alpha builds | ✅ Public demo | ✅ Beta | ✅ Release |
| **macOS** | Internal only | Alpha builds | ✅ Public demo | ✅ Beta | ✅ Release |
| **Linux** | Internal only | Alpha builds | ✅ Public demo | ✅ Beta | ✅ Release |
| **Web (HTML5)** | ❌ | ❌ | ❌ Deferred | Evaluated | ✅ If performance passes |

### Export Rules

1. **v0.0.x–v0.6.x**: Desktop exports for internal playtest and QA only. No public builds.
2. **v0.7.0**: First public-facing build. All three desktop platforms must export and launch without errors. This is the vertical slice / demo.
3. **v0.8.x–v0.9.x**: Beta builds for closed community testing. Web export evaluated but not promised.
4. **v1.0.0**: Full release on all committed platforms. Web export ships only if it passes a 30-minute stress test on Chrome, Firefox, and Safari without memory crashes.

### Minimum Spec Targets

| Spec | Target |
|------|--------|
| Resolution | 1920×1080 (scalable down to 1280×720) |
| Frame rate | 60 FPS on mid-tier hardware |
| Memory | ≤ 512 MB RAM at v0.7.0; ≤ 1 GB at v1.0.0 |
| Storage | ≤ 500 MB install size at v1.0.0 |
| Input | Mouse + keyboard required; trackpad should work for build/click actions |

---

## 5. Known-Not-Shipping List (Intentional Exclusions)

Each milestone explicitly lists what is OUT of scope to prevent expectation drift.

### v0.0.x — Route Toy

- ❌ Save/load
- ❌ Terrain cost variation
- ❌ AI
- ❌ Events
- ❌ Sound / music
- ❌ Final art (placeholder only)

### v0.1–v0.2.x — Colonial Core

- ❌ AI rival
- ❌ Contracts
- ❌ Station upgrades
- ❌ Events
- ❌ Campaign structure
- ❌ Sound / music
- ❌ Final art

### v0.3.x — Economic Depth

- ❌ AI rival (British East India Rail)
- ❌ Tolls / track ownership
- ❌ Events
- ❌ Campaign acts
- ❌ Sound / music
- ❌ Final art

### v0.4.x — First Rival

- ❌ Multiple rivals (French, Amdani)
- ❌ Faction selection
- ❌ Configurable tolls
- ❌ Full campaign
- ❌ Sound / music
- ❌ Final art

### v0.5.x — Network Control

- ❌ Events system
- ❌ Campaign
- ❌ Faction variety
- ❌ WW1 era
- ❌ Sound / music
- ❌ Final art

### v0.6.x — Events

- ❌ Campaign acts
- ❌ Faction selection screen
- ❌ WW1 era
- ❌ Sound / music
- ❌ Final art

### v0.7.0 — Colonial Campaign (Demo)

- ❌ WW1 era
- ❌ Full faction roster (only British AI in demo)
- ❌ Sandbox mode
- ❌ Scenario mode
- ❌ Sound / music (placeholder SFX okay)
- ❌ Final art (placeholder + first-pass AI art okay)

### v0.8.x — Factions

- ❌ WW1 era
- ❌ Sandbox mode
- ❌ Scenario mode
- ❌ Full audio pass

### v0.9.x — WW1 Expansion

- ❌ Sandbox mode (may be prototyped)
- ❌ Scenario mode
- ❌ Full audio pass
- ❌ Additional regions (Punjab, Bombay, Madras)

### v1.0.0 — Full Release

- ❌ Multiplayer
- ❌ Mod support
- ❌ Additional regions
- ❌ WW2, Cold War, Modern eras
- ❌ Stock market system
- ❌ 3D camera rotation

---

## 6. Build Process

### 6.1 Environment

- **Engine**: Godot 4.2+ (exact version pinned in `project.godot`)
- **Export templates**: Downloaded and matched to engine version
- **Build machine**: Primary developer workstation (macOS) + CI verification on Linux

### 6.2 Export Steps

```bash
# 1. Ensure project opens without errors
godot --path . --headless --quit

# 2. Run automated smoke tests (if any)
# ./run_tests.sh

# 3. Update version label in project or splash screen
# (manual step until automated)

# 4. Export Windows
godot --path . --headless --export-release "Windows Desktop" "builds/v0.X.Y/RailEmpire_v0.X.Y_windows.exe"

# 5. Export macOS
godot --path . --headless --export-release "macOS" "builds/v0.X.Y/RailEmpire_v0.X.Y_mac.zip"

# 6. Export Linux
godot --path . --headless --export-release "Linux/X11" "builds/v0.X.Y/RailEmpire_v0.X.Y_linux.x86_64"

# 7. (Optional v1.0) Export Web
godot --path . --headless --export-release "Web" "builds/v0.X.Y/web/"
```

### 6.3 Build Verification

After every export:

| Check | How |
|-------|-----|
| Launches without crash | Double-click executable on target OS |
| Reaches title / game scene | Observe load |
| Core loop functional | Build track, buy train, earn money (5-minute sanity test) |
| Save/load works | Save, quit, reload |
| No debug overlays | Confirm `DEBUG` labels are hidden in release |
| File size sanity | Compare to previous build; flag if > 2× |

---

## 7. Release Checklist

Use this checklist before tagging any version.

### Pre-Build

- [ ] All acceptance criteria for the current sprint are checked in `BACKLOG.md`
- [ ] `project.godot` version metadata matches target version
- [ ] No `print()` debug spam left in committed code
- [ ] No placeholder textures named `temp_`, `debug_`, or `old_` in active scenes
- [ ] `CONVENTIONS.md` compliance spot-checked on changed files

### Build

- [ ] Desktop exports succeed for Windows, macOS, Linux
- [ ] Build verification passed (launch + 5-minute sanity test)
- [ ] Save/load round-trip tested on exported build (not just editor)

### Docs

- [ ] `BACKLOG.md` updated: sprint marked complete, next sprint tasks detailed
- [ ] `scope_lock.md` updated if phase completed
- [ ] `CHANGELOG.md` (or release notes) written for this version
- [ ] Known issues section updated

### Tag & Ship

- [ ] Git tag created: `git tag -a v0.X.Y -m "..."`
- [ ] Tag pushed to origin
- [ ] Build artifacts uploaded to internal storage / itch.io (if public)
- [ ] `playtest_plan.md` schedule updated for next phase

---

## 8. Changelog Template

Create `CHANGELOG.md` at project root. Entry format:

```markdown
## v0.X.Y — Milestone Name (YYYY-MM-DD)

### Added
- 

### Changed
- 

### Fixed
- 

### Known Issues
- 

### Deferred
- 
```

---

## 9. Summary

| Milestone | Date Target | Public? | Platforms |
|-----------|-------------|---------|-----------|
| v0.0.x Route Toy | Sprint 01 end | No | Internal desktop |
| v0.2.x Colonial Core | Sprint 02 end | No | Internal desktop |
| v0.3.x Economic Depth | Sprint 03 end | No | Internal desktop |
| v0.4.x First Rival | Sprint 04 end | No | Internal desktop |
| v0.5.x Network Control | Sprint 05 end | No | Internal desktop |
| v0.6.x Events | Sprint 06 end | No | Internal desktop |
| **v0.7.0 Colonial Campaign** | **Sprint 07 end** | **YES — Demo** | **Win / macOS / Linux** |
| v0.8.x Factions | Sprint 08 end | Closed beta | Win / macOS / Linux |
| v0.9.x WW1 Expansion | Sprint 09 end | Closed beta | Win / macOS / Linux |
| **v1.0.0 Full Release** | **Sprint 10 end** | **Public** | **Win / macOS / Linux + Web?** |

*Dates are intentionally not fixed to calendar dates. The project advances sprint-by-sprint based on exit criteria, not deadlines.*

# Godot Playtest Protocol

## Description
Use this skill when testing Rail Empire in Godot, especially with MCP or headless Godot.

## Playtest Rules
- Prefer live playtest over only parse checks.
- Verify the scene visually or through runtime output.
- Check that controls work.
- Check that UI values update.
- Check that state changes are reflected on screen.
- Check that old regression scenes still pass.

## Route Toy Playtest Checklist
1. Launch `scenes/game/route_toy_playable.tscn`.
2. Confirm Bengal map appears.
3. Confirm train appears.
4. Confirm route auto-starts.
5. Confirm train moves Patna → Kolkata.
6. Confirm train returns to Patna.
7. Confirm at least 3 trips complete.
8. Confirm treasury changes.
9. Confirm date advances.
10. Confirm Kolkata coal stock changes.
11. Confirm dynamic price changes.
12. Confirm speed buttons work.
13. Confirm pause works.
14. Confirm reset restores state.
15. Confirm no `.tres` files changed.

## Save/Load Playtest Checklist
1. Let route complete 2 trips.
2. Record treasury, date, city stock, train cargo, trip count.
3. Save (F5).
4. Reset or restart scene.
5. Load (F9).
6. Confirm values restore.
7. Let one more trip complete.
8. Confirm route continues cleanly.

## Headless Quick Check (when MCP unavailable)
```bash
cd ~/Documents/code/train-game && /Applications/Godot.app/Contents/MacOS/Godot --headless --quit 2>&1 | grep -E "ERROR|WARNING|SCRIPT"
```
- Should return empty (no errors/warnings).

## Using MCP Runtime Playtest (when available)
1. Launch scene via MCP.
2. Capture runtime output.
3. Inspect scene tree.
4. Take screenshot if supported.
5. Interact with controls (pause, speed, reset, save/load).
6. Verify expected labels and values.
7. Report: scene loaded, errors/warnings, controls tested, pass/fail.

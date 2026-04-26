# Rail Empire MCP Playtest

## Description
Use this whenever a sprint changes scenes, UI, input, save/load, route behavior, train movement, economy, or HUD.

## Prerequisites
- Godot editor MCP or Godot runtime MCP must be configured.
- Prefer runtime MCP for gameplay verification.

## Required MCP Playtest
1. Launch the relevant Godot scene.
2. Capture runtime output.
3. Inspect scene tree.
4. Take screenshot if supported.
5. Interact with controls:
   - pause
   - 1x/2x/4x
   - reset
   - save/load if present
6. Verify expected labels and values.
7. Report:
   - scene loaded
   - errors/warnings
   - controls tested
   - screenshots captured
   - pass/fail

## Route Toy Specific MCP Playtest
1. Launch `scenes/game/route_toy_playable.tscn`.
2. Confirm HUD appears with treasury, date, route status.
3. Confirm train is moving Patna → Kolkata.
4. Wait until at least 2 trips complete.
5. Record treasury/date/trips/stock values.
6. Trigger save (F5 or button).
7. Reset or restart scene.
8. Trigger load (F9 or button).
9. Confirm saved values restore.
10. Let one more trip complete.
11. Confirm route continues cleanly.
12. Capture runtime output and screenshot if available.

## Fallback (no MCP)
Use headless Godot with `--quit` and grep for errors/warnings.
Use debug scenes (e.g., `scenes/debug/debug_save_load.tscn`) for automated validation.

## Safety
- Do not run arbitrary shell commands through MCP.
- Do not approve MCP operations that modify files outside the project directory.
- Prefer read-only MCP tools for inspection.

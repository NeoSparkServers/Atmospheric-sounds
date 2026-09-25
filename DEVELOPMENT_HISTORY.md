# Development history

This file records the implementation milestones from the project `thinking.md`.
It is a development log, while version-specific user-facing notes belong to
Git tags and release pages.

## Initial standalone port — 2026-06-14

- Created the standalone `ambientsounds` Luanti mod structure.
- Ported all 120 OGG assets from AmbientSounds 26.x to Luanti-safe names.
- Added the per-player sound engine with loop layers, fades, one-shots,
  environment scanning, and player state commands (`on`, `off`, `status`,
  `debug`).
- Added Mineclonia/VoxeLibre compatibility and the initial layer/sound
  catalog.
- Verified the catalog, file references, required files, and Lua parsing.

## Sound engine hardening and compatibility — 2026-06-14

- Hardened `stop_all` and lifecycle cleanup for loop handles, active layers,
  one-shot timers, player death, and context changes.
- Expanded biome and environment detection for Mineclonia and VoxeLibre,
  including weather, thunder, caves, foliage, liquids, sky, and height.
- Refined layer regions and reduced unwanted overlaps between biome and weather
  ambience.
- Ran disposable-world load tests for Mineclonia and Mineclone2/VoxeLibre;
  the port loaded with zero errors.


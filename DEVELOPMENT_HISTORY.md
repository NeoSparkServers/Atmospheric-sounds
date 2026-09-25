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


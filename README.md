<p align="center">
  <img src="icon/Atmospheric soundsL.png" alt="Atmospheric Sounds icon" width="220">
</p>

<h1 align="center">Atmospheric Sounds</h1>

<p align="center">
  Ambient ambience sounds for Luanti — an unofficial port of CreativeMD's
  AmbientSounds 26.x for Mineclonia and VoxeLibre.
</p>

<p align="center">
  <img alt="Luanti 5.10+" src="https://img.shields.io/badge/Luanti-5.10%2B-2ea44f">
  <img alt="Dev state beta" src="https://img.shields.io/badge/dev%20state-beta-f0ad4e">
  <img alt="License LGPL-3.0-only" src="https://img.shields.io/badge/license-LGPL--3.0--only-blue">
  <img alt="AI assisted" src="https://img.shields.io/badge/AI-assisted-6f42c1">
</p>

## About

This mod ports the ambience behavior and sound assets of AmbientSounds 26.x
(Minecraft mod by CreativeMD) to Luanti. It layers atmospheric sounds on top of
normal gameplay: weather, wildlife, and location-based ambience, so worlds stop
being silent.

- Works with Mineclonia and VoxeLibre
- Integrates with existing game systems through optional dependencies
  (`mcl_worlds`, `mcl_weather`, `mcl_liquids`, `mcl_core`, `mcl_trees`,
  `vl_cavesounds`, `vl_env_sounds`)
- Optional Mod Menu integration (`mod_menu`) for settings screens
- Configurable via Luanti settings (`settingtypes.txt`)

## Compatibility

- Luanti 5.10 or newer (`min_minetest_version = 5.10`)
- No hard dependencies; the mod detects what is available at startup

## Mod Menu integration

When the optional `mod_menu` mod is installed, Atmospheric Sounds exposes
settings tabs for general behavior, engine tuning, dimensions, regions,
categories, and individual sound layers. Without Mod Menu, the regular Luanti
settings from `settingtypes.txt` remain available.

## What's inside

The package bundles 120 ambience sound tracks, organized in six layers the
engine mixes during gameplay:

| Layer | Tracks | Purpose |
| --- | --- | --- |
| Animals | 86 | Wildlife ambience near forests, plains, and water |
| Cave | 15 | Deep cave and underground atmosphere |
| Wind | 7 | Open-sky wind ambience with variation |
| Water | 5 | River, lake, and shoreline ambience |
| Weather | 4 | Rain and storm layers |
| Suspense | 3 | Night and danger ambience accents |

Layers are mixed by the engine depending on biome, time of day, weather, and
the player's surroundings — see `settingtypes.txt` (123 settings) or the Mod
Menu tabs for per-layer volume and behavior tuning.

## Screenshots

`icon/Atmospheric soundsL.png` doubles as the package cover image; gameplay
screenshots will be added to the ContentDB package page.

## Licensing And Credits

- Original project: [AmbientSounds](https://www.curseforge.com/minecraft/mc-mods/ambientsounds) by CreativeMD (LGPL-3.0)
- This port: LGPL-3.0-only, see [LICENSE](LICENSE) and [NOTICE](NOTICE)

This is an unofficial port. It is not affiliated with or endorsed by
CreativeMD. The upstream Minecraft source tree is used as reference only and is
not included in this repository.

## ContentDB Checklist

- Package metadata is in English and marks the project as an unofficial port.
- `.cdb.json` sets `license = "LGPL-3.0-only"`,
  `media_license = "LGPL-3.0-only"`, and `ai_disclosure = "ASSISTED"`.
- Root `icon.png` (copy of `icon/Atmospheric soundsL.png`) satisfies the
  Luanti client package icon convention.
- `NOTICE` documents upstream attribution: AmbientSounds by CreativeMD
  (LGPL-3.0), upstream source tree used as reference only.
- The package cover (the logo image) serves as the ContentDB screenshot, as
  recommended for packages without visual content.
- Sound assets: 120 bundled OGG ambience tracks from the upstream
  AmbientSounds 26.x asset set, re-encoded to 64 kbps for a smaller
  download (originals: 160 kbps; three 96 kHz tracks resampled to
  44.1 kHz), renamed for Luanti positional playback. Package size:
  ~41 MB.

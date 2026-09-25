<p align="center">
  <img src="icon/Atmospheric soundsL.png" alt="Atmospheric Sounds icon" width="220">
</p>

<h1 align="center">Atmospheric Sounds</h1>

<p align="center">
  Ambient ambience sounds for Luanti — an unofficial port of CreativeMD's
  AmbientSounds 26.x for Mineclonia and VoxeLibre.
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

## Licensing And Credits

- Original project: [AmbientSounds](https://www.curseforge.com/minecraft/mc-mods/ambientsounds) by CreativeMD (LGPL-3.0)
- This port: LGPL-3.0-only, see [LICENSE](LICENSE) and [NOTICE](NOTICE)

This is an unofficial port. It is not affiliated with or endorsed by
CreativeMD. The upstream Minecraft source tree is used as reference only and is
not included in this repository.

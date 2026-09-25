local core = core

ambientsounds = {
	modname = core.get_current_modname(),
}
ambientsounds.modpath = core.get_modpath(ambientsounds.modname)

local function load(path)
	dofile(ambientsounds.modpath .. "/" .. path)
end

load("engine/util.lua")
load("engine/config.lua")
load("compat/mcl.lua")
load("engine/context.lua")
load("data/sounds.lua")
load("data/layers.lua")
ambientsounds.config.reload()
load("engine/sound_manager.lua")
load("compat/mod_menu.lua")

ambientsounds.sound_manager.start()

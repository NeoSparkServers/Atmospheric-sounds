local AS = ambientsounds
local util = AS.util

local manager = {
	players = {},
	clock = 0,
	timer = 0,
	started = false,
}
AS.sound_manager = manager

local function ensure_state(player_name)
	local state = manager.players[player_name]
	if not state then
		state = {
			loops = {},
			oneshots = {},
			active = {},
			last_context = nil,
		}
		manager.players[player_name] = state
	end
	return state
end

local function layer_gain(layer, ctx)
	local gain = layer.gain
	if type(gain) == "function" then
		gain = gain(ctx)
	end
	return util.clamp((gain or 0) * AS.config.layer_multiplier(layer, ctx), 0, 2)
end

local function loop_start_time()
	if not AS.config.play_sound_with_offset then
		return nil
	end
	if not core.features or not core.features.sound_params_start_time then
		return nil
	end
	return util.random_between(0, 30)
end

local function play_loop(player_name, state, layer, gain)
	local current = state.loops[layer.id]
	if current and current.handle then
		if math.abs((current.gain or 0) - gain) > 0.025 then
			core.sound_fade(current.handle, AS.config.fade_volume, gain)
			current.gain = gain
		end
		return
	end

	local sound = util.pick(layer.sounds)
	if not sound then
		return
	end

	local handle = core.sound_play({ name = sound, gain = 1.0 }, {
		to_player = player_name,
		gain = gain,
		loop = true,
		fade = AS.config.fade_volume,
		start_time = loop_start_time(),
	}, false)

	if handle then
		state.loops[layer.id] = {
			handle = handle,
			sound = sound,
			gain = gain,
		}
		util.debug("loop start " .. player_name .. " " .. layer.id .. " -> " .. sound)
	end
end

local function stop_loop(player_name, state, layer_id)
	local current = state.loops[layer_id]
	if not current then
		return
	end

	local handle = current.handle
	local gain = current.gain or 1
	state.loops[layer_id] = nil
	if handle then
		local fade_step = AS.config.fade_volume or 0.8
		core.sound_fade(handle, fade_step, 0.0)
		core.after(util.clamp((gain / fade_step) + 0.25, 0.5, 10), function()
			core.sound_stop(handle)
		end)
	end
	util.debug("loop stop " .. player_name .. " " .. layer_id)
end

local function play_oneshot(player_name, state, layer, gain)
	local next_time = state.oneshots[layer.id]
	if next_time and manager.clock < next_time then
		return
	end

	local sound = util.pick(layer.sounds)
	if sound then
		core.sound_play({ name = sound, gain = 1.0 }, {
			to_player = player_name,
			gain = gain,
		}, true)
		util.debug("oneshot " .. player_name .. " " .. layer.id .. " -> " .. sound)
	end

	local pause = layer.pause or { min = 30, max = 120 }
	state.oneshots[layer.id] = manager.clock + util.random_between(pause.min, pause.max)
end

local function send_debug_if_changed(player, state, ctx, active)
	if player:get_meta():get_int("ambientsounds:debug") ~= 1 then
		state.last_debug_signature = nil
		return
	end

	local signature = table.concat(active, ",") .. "|"
		.. tostring(ctx.biome) .. "|"
		.. tostring(ctx.dimension) .. "|"
		.. tostring(ctx.weather) .. "|"
		.. tostring(ctx.underwater) .. "|"
		.. tostring(ctx.cave) .. "|"
		.. util.table_keys_string(ctx.tags)
	if state.last_debug_signature == signature then
		return
	end

	state.last_debug_signature = signature
	core.chat_send_player(ctx.player_name,
		"Atmospheric Sounds debug: biome=" .. tostring(ctx.biome)
		.. " dimension=" .. tostring(ctx.dimension)
		.. " weather=" .. tostring(ctx.weather)
		.. " tags=[" .. util.table_keys_string(ctx.tags) .. "]"
		.. " active=[" .. table.concat(active, ", ") .. "]")
end

function manager.stop_all(player_name)
	local state = manager.players[player_name]
	if not state then
		return
	end

	local loop_ids = {}
	for layer_id in pairs(state.loops) do
		loop_ids[#loop_ids + 1] = layer_id
	end
	for _, layer_id in ipairs(loop_ids) do
		stop_loop(player_name, state, layer_id)
	end
	state.oneshots = {}
	state.active = {}
	state.last_context = nil
	state.last_debug_signature = nil
end

function manager.update_player(player)
	local player_name = player:get_player_name()
	local state = ensure_state(player_name)

	if not AS.config.enabled or util.player_disabled(player) then
		manager.stop_all(player_name)
		state.last_context = nil
		return
	end

	local ctx = AS.context.build(player)
	state.last_context = ctx
	if AS.config.is_dimension_silent(ctx) then
		manager.stop_all(player_name)
		state.last_context = ctx
		state.active = {}
		return
	end

	local seen = {}
	local active = {}

	for _, layer in ipairs(AS.layers) do
		if AS.config.categories[layer.category] and layer.check(ctx) then
			local gain = layer_gain(layer, ctx)
			if gain > 0.005 then
				active[#active + 1] = layer.id
				if layer.mode == "loop" then
					seen[layer.id] = true
					play_loop(player_name, state, layer, gain)
				else
					play_oneshot(player_name, state, layer, gain)
				end
			end
		end
	end

	local stale_loop_ids = {}
	for layer_id in pairs(state.loops) do
		if not seen[layer_id] then
			stale_loop_ids[#stale_loop_ids + 1] = layer_id
		end
	end
	for _, layer_id in ipairs(stale_loop_ids) do
		stop_loop(player_name, state, layer_id)
	end

	state.active = active
	send_debug_if_changed(player, state, ctx, active)
end

local function send_status(player_name)
	local state = ensure_state(player_name)
	local ctx = state.last_context
	if not ctx then
		core.chat_send_player(player_name, "Atmospheric Sounds: inactive")
		return
	end
	local player = core.get_player_by_name(player_name)
	local disabled = player and util.player_disabled(player) or false
	local debug = player and player:get_meta():get_int("ambientsounds:debug") == 1 or false

	local loop_ids = {}
	for layer_id in pairs(state.loops) do
		loop_ids[#loop_ids + 1] = layer_id
	end
	table.sort(loop_ids)

	core.chat_send_player(player_name,
		"Atmospheric Sounds: enabled=" .. tostring(AS.config.enabled and not disabled)
		.. " debug=" .. tostring(debug)
		.. " biome=" .. tostring(ctx.biome)
		.. " dimension=" .. tostring(ctx.dimension)
		.. "/" .. tostring(AS.config.dimension_id(ctx))
		.. " silent=" .. tostring(AS.config.is_dimension_silent(ctx))
		.. " weather=" .. tostring(ctx.weather)
		.. " underwater=" .. tostring(ctx.underwater)
		.. " cave=" .. tostring(ctx.cave)
		.. " tags=[" .. util.table_keys_string(ctx.tags) .. "]"
		.. " loops=[" .. table.concat(loop_ids, ", ") .. "]")
end

local function register_command()
	core.register_chatcommand("ambientsounds", {
		params = "on | off | status | debug",
		description = "Control Atmospheric Sounds for yourself.",
		func = function(player_name, param)
			local player = core.get_player_by_name(player_name)
			if not player then
				return false, "Player not found."
			end
			param = string.lower((param or ""):match("^%s*(.-)%s*$"))
			local meta = player:get_meta()

			if param == "" or param == "status" then
				manager.update_player(player)
				send_status(player_name)
				return true
			elseif param == "on" then
				meta:set_int("ambientsounds:disable", 0)
				manager.update_player(player)
				return true, "Atmospheric Sounds enabled."
			elseif param == "off" then
				meta:set_int("ambientsounds:disable", 1)
				manager.stop_all(player_name)
				return true, "Atmospheric Sounds disabled."
			elseif param == "debug" then
				local enabled = meta:get_int("ambientsounds:debug") ~= 1
				meta:set_int("ambientsounds:debug", enabled and 1 or 0)
				return true, "Atmospheric Sounds debug " .. (enabled and "enabled." or "disabled.")
			end

			return false, "Usage: /ambientsounds on | off | status | debug"
		end,
	})
end

function manager.start()
	if manager.started then
		return
	end
	manager.started = true

	core.register_on_joinplayer(function(player)
		ensure_state(player:get_player_name())
		core.after(1.0, function(name)
			local joined = core.get_player_by_name(name)
			if joined then
				manager.update_player(joined)
			end
		end, player:get_player_name())
	end)

	core.register_on_leaveplayer(function(player)
		local player_name = player:get_player_name()
		manager.stop_all(player_name)
		manager.players[player_name] = nil
	end)

	core.register_on_respawnplayer(function(player)
		manager.stop_all(player:get_player_name())
	end)

	core.register_on_dieplayer(function(player)
		manager.stop_all(player:get_player_name())
	end)

	core.register_globalstep(function(dtime)
		manager.clock = manager.clock + dtime
		manager.timer = manager.timer + dtime
		if manager.timer < AS.config.env_interval then
			return
		end
		manager.timer = 0

		for _, player in ipairs(core.get_connected_players()) do
			manager.update_player(player)
		end
	end)

	register_command()
	util.log("action", "loaded with " .. tostring(#AS.layers) .. " ambience layers")
end

function manager.refresh_all()
	for _, player in ipairs(core.get_connected_players()) do
		manager.update_player(player)
	end
end

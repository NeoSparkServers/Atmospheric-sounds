local AS = ambientsounds
local util = AS.util

local compat = {}
AS.compat = compat

function compat.get_dimension(pos)
	if mcl_worlds and type(mcl_worlds.pos_to_dimension) == "function" then
		local dimension = util.safe_call(mcl_worlds.pos_to_dimension, pos)
		if dimension then
			return dimension
		end
	end
	if pos.y < -28000 then
		return "nether"
	end
	if pos.y > 25000 then
		return "end"
	end
	return "overworld"
end

function compat.get_weather()
	if mcl_weather then
		if type(mcl_weather.get_weather) == "function" then
			local weather = util.safe_call(mcl_weather.get_weather)
			if weather then
				return weather
			end
		end
		if type(mcl_weather.state) == "string" then
			return mcl_weather.state
		end
	end
	return "none"
end

function compat.is_underwater(player)
	if mcl_weather and type(mcl_weather.is_underwater) == "function" then
		local underwater = util.safe_call(mcl_weather.is_underwater, player)
		if underwater ~= nil then
			return underwater == true
		end
	end

	local pos = player:get_pos()
	local eye = { x = pos.x, y = pos.y + 1.5, z = pos.z }
	local node = core.get_node_or_nil(eye)
	if not node then
		return false
	end
	local def = core.registered_nodes[node.name]
	return def and def.liquidtype and def.liquidtype ~= "none"
		and string.find(node.name, "water", 1, true) ~= nil
end

function compat.has_rain_at(pos)
	if mcl_weather and type(mcl_weather.has_rain) == "function" then
		local raining = util.safe_call(mcl_weather.has_rain, pos)
		if raining ~= nil then
			return raining == true
		end
	end
	return compat.get_weather() == "rain" or compat.get_weather() == "thunder"
end

function compat.is_outdoor(pos)
	if mcl_weather and type(mcl_weather.is_outdoor) == "function" then
		local outdoor = util.safe_call(mcl_weather.is_outdoor, pos)
		if outdoor ~= nil then
			return outdoor == true
		end
	end
	local light = core.get_natural_light(pos, 0.5)
	return light ~= nil and light >= 13
end

function compat.get_biome(pos)
	local data = core.get_biome_data(pos)
	if not data or not data.biome then
		return "default", nil, nil
	end
	local name = core.get_biome_name(data.biome) or "default"
	local def = core.registered_biomes[name]
	return name, data, def
end


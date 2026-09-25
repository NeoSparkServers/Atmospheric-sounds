local AS = ambientsounds

local config = {}
AS.config = config

config.dimensions = {
	{ id = "surface", label = "Surface" },
	{ id = "cave", label = "Cave" },
	{ id = "nether", label = "Nether" },
	{ id = "end", label = "End" },
}

config.regions = {
	{ id = "beach", label = "Beach" },
	{ id = "cave", label = "Cave" },
	{ id = "cave.ambience", label = "Cave ambience" },
	{ id = "cave.deep-dark", label = "Deep dark cave" },
	{ id = "cave.lush", label = "Lush cave" },
	{ id = "cold", label = "Cold" },
	{ id = "cold.artic", label = "Arctic" },
	{ id = "desert", label = "Desert" },
	{ id = "forest", label = "Forest" },
	{ id = "forest.cold", label = "Cold forest" },
	{ id = "forest.roofed", label = "Roofed forest" },
	{ id = "grass", label = "Grass" },
	{ id = "highland", label = "Highland" },
	{ id = "jungle", label = "Jungle" },
	{ id = "mesa", label = "Mesa" },
	{ id = "mushroom_fields", label = "Mushroom fields" },
	{ id = "ocean", label = "Ocean" },
	{ id = "ocean_deep", label = "Deep ocean" },
	{ id = "pale-garden", label = "Pale garden" },
	{ id = "plains", label = "Plains" },
	{ id = "rain", label = "Rain" },
	{ id = "savanna", label = "Savanna" },
	{ id = "sky", label = "Sky" },
	{ id = "storm.away", label = "Storm away" },
	{ id = "storm.close", label = "Storm close" },
	{ id = "swamp", label = "Swamp" },
	{ id = "taiga", label = "Taiga" },
	{ id = "underwater", label = "Underwater" },
	{ id = "underworld", label = "Underworld" },
	{ id = "warden", label = "Warden" },
}

config.original_categories = {
	{ id = "animal", label = "Animal" },
	{ id = "bird", label = "Bird" },
	{ id = "bird_day", label = "Bird day" },
	{ id = "bird_night", label = "Bird night" },
	{ id = "cave", label = "Cave" },
	{ id = "cicadas", label = "Cicadas" },
	{ id = "cricket", label = "Cricket" },
	{ id = "cricket_day", label = "Cricket day" },
	{ id = "cricket_night", label = "Cricket night" },
	{ id = "suspense", label = "Suspense" },
	{ id = "weather", label = "Weather" },
	{ id = "wind", label = "Wind" },
}

function config.safe_id(value)
	return tostring(value or ""):gsub("[^%w_]", "_")
end

function config.setting_key(prefix, id)
	return "ambientsounds_" .. prefix .. "_" .. config.safe_id(id) .. "_gain"
end

local function get_bool(name, default)
	local value = core.settings:get_bool(name)
	if value == nil then
		return default
	end
	return value
end

local function get_number(name, default, min_value, max_value)
	local value = tonumber(core.settings:get(name)) or default
	if min_value then
		value = math.max(min_value, value)
	end
	if max_value then
		value = math.min(max_value, value)
	end
	return value
end

local function get_string(name, default)
	local value = core.settings:get(name)
	if value == nil or value == "" then
		return default
	end
	return value
end

local function parse_list_setting(name)
	local raw = core.settings:get(name)
	if raw == nil or raw == "" then
		return {}
	end

	local parsed = core.deserialize(raw)
	local result = {}
	if type(parsed) == "table" then
		for _, entry in ipairs(parsed) do
			if type(entry) == "table" then
				local pattern = entry.pattern or entry.name or entry[1]
				if pattern and pattern ~= "" then
					result[#result + 1] = tostring(pattern)
				end
			elseif entry and entry ~= "" then
				result[#result + 1] = tostring(entry)
			end
		end
		return result
	end

	for pattern in string.gmatch(raw, "([^,;]+)") do
		pattern = pattern:match("^%s*(.-)%s*$")
		if pattern ~= "" then
			result[#result + 1] = pattern
		end
	end
	return result
end

local function read_gain_map(items, prefix)
	local result = {}
	for _, item in ipairs(items) do
		result[item.id] = get_number(config.setting_key(prefix, item.id), 1, 0, 1)
	end
	return result
end

local function wildcard_match(text, pattern)
	text = string.lower(tostring(text or ""))
	pattern = string.lower(tostring(pattern or ""))
	if pattern == "" then
		return false
	end

	local escaped = pattern:gsub("([%^%$%(%)%%%.%[%]%+%-])", "%%%1")
	escaped = escaped:gsub("%*", ".*"):gsub("%?", ".")
	return string.find(text, ".*" .. escaped .. ".*") ~= nil
end

function config.reload()
	config.enabled = get_bool("ambientsounds_enabled", true)
	config.engine = get_string("ambientsounds_engine", "basic")
	config.volume = get_number("ambientsounds_volume", 1, 0, 1)
	config.master_gain = get_number("ambientsounds_master_gain", 0.6, 0, 2)
	config.use_sound_master_source = get_bool("ambientsounds_use_sound_master_source", false)
	config.scan_step_amount = math.floor(get_number("ambientsounds_scan_step_amount", 100, 1, 10000))
	config.play_sound_with_offset = get_bool("ambientsounds_play_sound_with_offset", true)
	config.scan_radius = math.floor(get_number("ambientsounds_scan_radius", 16, 4, 32))
	config.env_interval = get_number("ambientsounds_env_interval", 2.0, 0.5, 10)
	config.fade_volume = get_number("ambientsounds_fade_volume", 0.8, 0.01, 10)
	config.fade_pitch = get_number("ambientsounds_fade_pitch", 0.005, 0, 1)
	config.silent_dimensions = parse_list_setting("ambientsounds_silent_dimensions")
	config.debug = get_bool("ambientsounds_debug", false)
	config.categories = {
		animals = get_bool("ambientsounds_category_animals", true),
		cave = get_bool("ambientsounds_category_cave", true),
		water = get_bool("ambientsounds_category_water", true),
		weather = get_bool("ambientsounds_category_weather", true),
		wind = get_bool("ambientsounds_category_wind", true),
		suspense = get_bool("ambientsounds_category_suspense", true),
	}
	config.dimension_gains = read_gain_map(config.dimensions, "dimension")
	config.region_gains = read_gain_map(config.regions, "region")
	config.original_category_gains = read_gain_map(config.original_categories, "original_category")
	config.layer_gains = {}
	for _, layer in ipairs(AS.layers or {}) do
		config.layer_gains[layer.id] = get_number(config.setting_key("layer", layer.id), 1, 0, 1)
	end
end

function config.dimension_id(ctx)
	if not ctx then
		return "surface"
	end
	if ctx.dimension == "nether" then
		return "nether"
	end
	if ctx.dimension == "end" then
		return "end"
	end
	if ctx.cave then
		return "cave"
	end
	return "surface"
end

function config.is_dimension_silent(ctx)
	local dimension_id = config.dimension_id(ctx)
	local candidates = {
		dimension_id,
		ctx and ctx.dimension or "",
		ctx and ctx.biome or "",
	}
	for _, pattern in ipairs(config.silent_dimensions or {}) do
		for _, candidate in ipairs(candidates) do
			if wildcard_match(candidate, pattern) then
				return true
			end
		end
	end
	return false
end

function config.layer_multiplier(layer, ctx)
	local gain = (config.master_gain or 1) * (config.volume or 1)
	gain = gain * ((config.dimension_gains or {})[config.dimension_id(ctx)] or 1)
	gain = gain * ((config.region_gains or {})[layer.region] or 1)
	gain = gain * ((config.layer_gains or {})[layer.id] or 1)

	for _, category in ipairs(layer.original_categories or {}) do
		gain = gain * ((config.original_category_gains or {})[category] or 1)
	end

	return gain
end

config.reload()

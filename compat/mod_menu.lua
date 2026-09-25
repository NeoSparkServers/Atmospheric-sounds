local AS = ambientsounds

if not rawget(_G, "mod_menu") or type(mod_menu.register_settings) ~= "function" then
	return
end

local function title_from_id(id)
	local text = tostring(id or ""):gsub("[_%-%.]+", " ")
	return (text:gsub("(%a)([%w_']*)", function(first, rest)
		return string.upper(first) .. rest
	end))
end

local function gain_setting(key, label, description)
	return {
		key = key,
		type = "number",
		label = label,
		description = description,
		min = 0,
		max = 1,
		default = 1,
		ui = "slider",
	}
end

local function section(id, label, children, description)
	return {
		type = "section",
		id = id,
		label = label,
		description = description,
		default_open = true,
		children = children,
	}
end

local function dimension_settings()
	local settings = {}
	for _, dimension in ipairs(AS.config.dimensions) do
		settings[#settings + 1] = gain_setting(
			AS.config.setting_key("dimension", dimension.id),
			dimension.label .. " volume",
			"Original AmbientSounds dimension volume."
		)
	end
	return settings
end

local function region_settings()
	local settings = {}
	for _, region in ipairs(AS.config.regions) do
		settings[#settings + 1] = gain_setting(
			AS.config.setting_key("region", region.id),
			region.label .. " volume",
			"Original AmbientSounds region volume."
		)
	end
	return settings
end

local function original_category_settings()
	local settings = {}
	for _, category in ipairs(AS.config.original_categories) do
		settings[#settings + 1] = gain_setting(
			AS.config.setting_key("original_category", category.id),
			category.label .. " volume",
			"Original AmbientSounds sound category volume."
		)
	end
	return settings
end

local function layer_settings()
	local settings = {}
	for _, layer in ipairs(AS.layers) do
		local label = title_from_id(layer.region) .. ": " .. title_from_id(layer.sound_id)
		settings[#settings + 1] = gain_setting(
			AS.config.setting_key("layer", layer.id),
			label,
			"Per-sound volume for layer " .. layer.id .. "."
		)
	end
	return settings
end

local function reload_after_save()
	AS.config.reload()
	if AS.sound_manager and AS.sound_manager.refresh_all then
		AS.sound_manager.refresh_all()
	end
end

mod_menu.register_settings("ambientsounds", {
	title = "Atmospheric Sounds",
	tabs = {
		{
			id = "general",
			label = "General",
			settings = {
				section("main", "Main", {
					{ key = "ambientsounds_enabled", type = "bool", label = "Enabled", default = true },
					{ key = "ambientsounds_engine", type = "enum", label = "Engine", values = { "basic" }, default = "basic" },
					{
						key = "ambientsounds_volume",
						type = "number",
						label = "Original volume",
						min = 0,
						max = 1,
						default = 1,
						ui = "slider",
					},
					{
						key = "ambientsounds_master_gain",
						type = "number",
						label = "Luanti master gain",
						min = 0,
						max = 2,
						default = 0.6,
						ui = "slider",
					},
					{ key = "ambientsounds_play_sound_with_offset", type = "bool", label = "Play loops with random offset", default = true },
				}),
				section("runtime", "Runtime", {
					{ key = "ambientsounds_scan_radius", type = "int", label = "Environment scan radius", min = 4, max = 32, default = 16, ui = "slider" },
					{ key = "ambientsounds_env_interval", type = "number", label = "Environment scan interval", min = 0.5, max = 10, default = 2.0, ui = "slider" },
					{ key = "ambientsounds_debug", type = "bool", label = "Debug logging", default = false },
				}),
				section("compatibility", "Compatibility", {
					{
						key = "ambientsounds_use_sound_master_source",
						type = "bool",
						label = "Use master sound source",
						description = "Stored for original config parity; Luanti per-player sounds do not expose Minecraft sound sources.",
						default = false,
						advanced = true,
					},
					{
						key = "ambientsounds_scan_step_amount",
						type = "int",
						label = "Scan step amount",
						description = "Stored for original config parity; the Luanti port scans by radius and interval.",
						min = 1,
						max = 10000,
						default = 100,
						ui = "slider",
						advanced = true,
					},
				}),
			},
		},
		{
			id = "engine",
			label = "Engine",
			settings = {
				section("fade", "Fade", {
					{ key = "ambientsounds_fade_volume", type = "number", label = "Fade volume step", min = 0.01, max = 10, default = 0.8, ui = "slider" },
					{
						key = "ambientsounds_fade_pitch",
						type = "number",
						label = "Fade pitch step",
						description = "Stored for original config parity; Luanti sound fading controls gain only.",
						min = 0,
						max = 1,
						default = 0.005,
						ui = "slider",
						advanced = true,
					},
				}),
				section("silent_dimensions", "Silent dimensions", {
					{
						key = "ambientsounds_silent_dimensions",
						type = "list",
						label = "Silent dimension patterns",
						default = {},
						entry = {
							{ key = "pattern", type = "string", label = "Pattern", default = "" },
						},
					},
				}, "Wildcard patterns such as nether, end, cave, or *deep*."),
			},
		},
		{
			id = "dimensions",
			label = "Dimensions",
			settings = dimension_settings(),
		},
		{
			id = "regions",
			label = "Regions",
			settings = region_settings(),
		},
		{
			id = "categories",
			label = "Categories",
			settings = {
				section("luanti_categories", "Luanti category toggles", {
					{ key = "ambientsounds_category_animals", type = "bool", label = "Animals", default = true },
					{ key = "ambientsounds_category_cave", type = "bool", label = "Cave", default = true },
					{ key = "ambientsounds_category_water", type = "bool", label = "Water", default = true },
					{ key = "ambientsounds_category_weather", type = "bool", label = "Weather", default = true },
					{ key = "ambientsounds_category_wind", type = "bool", label = "Wind", default = true },
					{ key = "ambientsounds_category_suspense", type = "bool", label = "Suspense", default = true },
				}),
				section("original_categories", "Original category volumes", original_category_settings()),
			},
		},
		{
			id = "sounds",
			label = "Sounds",
			settings = layer_settings(),
		},
	},
	on_save = reload_after_save,
})

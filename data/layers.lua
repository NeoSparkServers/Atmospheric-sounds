local AS = ambientsounds
local C = AS.context
local S = AS.sounds

local layers = {}
AS.layers = layers

local function any(ctx, ...)
	return C.any(ctx, { ... })
end

local function none(ctx, ...)
	return not C.any(ctx, { ... })
end

local function surface(ctx)
	return ctx.surface and not ctx.underwater
end

local function loop(id, category, sounds, gain, check)
	layers[#layers + 1] = {
		id = id,
		category = category,
		mode = "loop",
		sounds = sounds,
		gain = gain,
		check = check,
	}
end

local function oneshot(id, category, sounds, gain, min_pause, max_pause, check)
	layers[#layers + 1] = {
		id = id,
		category = category,
		mode = "oneshot",
		sounds = sounds,
		gain = gain,
		pause = { min = min_pause, max = max_pause },
		check = check,
	}
end

loop("forest_day_birds", "animals", S.bird_ambience, 0.30, function(ctx)
	return surface(ctx) and ctx.day and any(ctx, "forest", "trees")
		and none(ctx, "jungle", "swamp", "cold", "roofed_forest", "taiga", "beach", "ocean", "rain", "pale_garden")
end)

loop("taiga_huge_birds", "animals", S.bird_huge, 0.20, function(ctx)
	return surface(ctx) and ctx.day and any(ctx, "taiga", "mega_taiga") and none(ctx, "rain", "pale_garden")
end)

loop("warm_savanna_birds", "animals", S.bird_warm, 0.22, function(ctx)
	return surface(ctx) and ctx.day and any(ctx, "savanna") and none(ctx, "cold", "jungle", "rain")
end)

loop("roofed_forest_spooky_birds", "animals", S.bird_spooky, 0.20, function(ctx)
	return surface(ctx) and any(ctx, "roofed_forest") and none(ctx, "rain", "pale_garden")
end)

loop("jungle_day_birds", "animals", S.bird_jungle_day, 0.34, function(ctx)
	return surface(ctx) and ctx.day and any(ctx, "jungle") and none(ctx, "rain")
end)

loop("jungle_night_birds", "animals", S.bird_jungle_night, 0.24, function(ctx)
	return surface(ctx) and ctx.night and any(ctx, "jungle") and none(ctx, "rain")
end)

loop("swamp_crickets", "animals", S.cricket_swamp, 0.20, function(ctx)
	return surface(ctx) and any(ctx, "swamp") and none(ctx, "rain")
end)

loop("jungle_crickets", "animals", S.cricket_jungle_day, 0.14, function(ctx)
	return surface(ctx) and ctx.day and any(ctx, "jungle") and none(ctx, "rain")
end)

loop("jungle_night_crickets", "animals", S.cricket_jungle_night, 0.28, function(ctx)
	return surface(ctx) and ctx.night and any(ctx, "jungle") and none(ctx, "rain")
end)

loop("field_crickets", "animals", S.cricket_day, 0.13, function(ctx)
	return surface(ctx) and ctx.day and any(ctx, "plains", "grass")
		and none(ctx, "forest", "savanna", "swamp", "jungle", "ocean", "highland", "cold", "rain")
end)

loop("night_crickets", "animals", S.cricket_night, 0.24, function(ctx)
	return surface(ctx) and ctx.night and any(ctx, "plains", "grass")
		and none(ctx, "forest", "savanna", "swamp", "jungle", "ocean", "highland", "cold", "rain")
end)

loop("warm_night_crickets", "animals", S.cricket_warm, 0.22, function(ctx)
	return surface(ctx) and ctx.night and any(ctx, "savanna", "swamp", "mesa") and none(ctx, "rain")
end)

loop("cicadas_day", "animals", S.cicadas, 0.16, function(ctx)
	return surface(ctx) and ctx.day and any(ctx, "savanna") and none(ctx, "cold", "rain")
end)

loop("desert_cicadas", "animals", S.cicadas_desert, 0.16, function(ctx)
	return surface(ctx) and ctx.day and any(ctx, "desert", "mesa") and none(ctx, "beach", "ocean")
end)

loop("night_cicadas", "animals", S.cicadas_night, 0.14, function(ctx)
	return surface(ctx) and ctx.night and any(ctx, "plains", "grass")
		and none(ctx, "forest", "savanna", "swamp", "jungle", "ocean", "highland", "cold", "rain")
end)

loop("mushroom_cicadas", "animals", S.cicadas_mushroom, 0.18, function(ctx)
	return surface(ctx) and any(ctx, "mushroom")
end)

loop("beach_seagulls_long", "animals", S.seagull_long, 0.18, function(ctx)
	return surface(ctx) and any(ctx, "beach") and ctx.day
end)

loop("mushroom_special", "animals", S.special_mushroom, 0.16, function(ctx)
	return surface(ctx) and any(ctx, "mushroom")
end)

loop("warden_suspense", "animals", S.warden, 0.24, function(ctx)
	return ctx.cave and any(ctx, "deep_dark")
end)

oneshot("doves", "animals", S.dove, 0.35, 25, 90, function(ctx)
	return surface(ctx) and ctx.day and any(ctx, "forest", "plains") and none(ctx, "cold", "rain")
end)

oneshot("owls", "animals", S.owl, 0.38, 20, 130, function(ctx)
	return surface(ctx) and ctx.night and any(ctx, "forest", "taiga", "leafy", "pale_garden")
		and none(ctx, "jungle", "swamp", "rain")
end)

oneshot("crows", "animals", S.crow, 0.35, 18, 95, function(ctx)
	return surface(ctx) and any(ctx, "forest", "taiga", "cold") and none(ctx, "jungle", "rain")
end)

oneshot("frogs", "animals", S.frog, 0.42, 18, 80, function(ctx)
	return surface(ctx) and any(ctx, "swamp") and ctx.counts.water > 0
end)

oneshot("cave_frogs", "animals", S.frog_cave, 0.30, 35, 160, function(ctx)
	return ctx.cave and any(ctx, "lush", "water_near")
end)

oneshot("seagulls", "animals", S.seagull, 0.45, 14, 70, function(ctx)
	return surface(ctx) and any(ctx, "beach") and ctx.day
end)

oneshot("whales", "animals", S.whale, 0.42, 45, 180, function(ctx)
	return (ctx.underwater or any(ctx, "deep_ocean") or (any(ctx, "ocean") and none(ctx, "beach", "river")))
		and not ctx.cave
end)

oneshot("wolves", "animals", S.wolf, 0.40, 30, 150, function(ctx)
	return surface(ctx) and ctx.night and any(ctx, "savanna", "taiga") and none(ctx, "rain")
end)

oneshot("long_wolves", "animals", S.long_wolf, 0.45, 90, 240, function(ctx)
	return surface(ctx) and ctx.night and any(ctx, "savanna", "taiga") and none(ctx, "rain")
end)

loop("cave_ambience", "cave", S.cave, 0.34, function(ctx)
	return ctx.cave and (ctx.counts.stone >= 60 or any(ctx, "dripstone", "lush", "deep_dark"))
		and none(ctx, "deep", "deep_dark", "lush")
end)

loop("large_cave_ambience", "cave", S.cave_large, 0.28, function(ctx)
	return ctx.cave and ctx.y < -20 and ctx.counts.stone >= 120 and not any(ctx, "deep_dark")
end)

loop("deep_cave_ambience", "cave", S.cave_deep, 0.34, function(ctx)
	return ctx.cave and any(ctx, "deep") and none(ctx, "deep_dark", "lush")
end)

loop("cave_water", "cave", S.cave_water, 0.25, function(ctx)
	return ctx.cave and ctx.counts.water > 0
end)

loop("lush_cave", "cave", S.cave_lush, 0.30, function(ctx)
	return ctx.cave and (any(ctx, "lush") or ctx.counts.lush > 0 or (ctx.counts.leaves > 6 and ctx.counts.water > 0))
end)

loop("deep_dark", "cave", S.cave_deep_dark, 0.34, function(ctx)
	return ctx.cave and any(ctx, "deep_dark")
end)

loop("underworld_cave", "cave", S.cave_underworld, 0.22, function(ctx)
	return ctx.dimension == "nether" or (ctx.cave and ctx.y < -70)
end)

loop("beach_water", "water", S.water_beach, 0.26, function(ctx)
	return surface(ctx) and any(ctx, "beach") and ctx.counts.water > 0
end)

loop("ocean_water", "water", S.water_ocean, 0.32, function(ctx)
	return surface(ctx) and any(ctx, "ocean") and ctx.counts.water > 0
end)

loop("underwater", "water", S.water_underwater, 0.42, function(ctx)
	return ctx.underwater and not any(ctx, "deep_ocean")
end)

loop("deep_underwater", "water", S.water_underwater_deep, 0.46, function(ctx)
	return ctx.underwater and (any(ctx, "deep_ocean") or ctx.y < -20)
end)

loop("rain", "weather", S.weather_rain, 0.30, function(ctx)
	return ctx.raining and ctx.rain_at_pos and not ctx.underwater and none(ctx, "cold", "arctic")
end)

loop("storm_close", "weather", S.weather_storm_close, 0.36, function(ctx)
	return ctx.thunder and ctx.rain_at_pos and ctx.outdoor and not ctx.underwater and none(ctx, "cold", "arctic")
end)

loop("storm_away", "weather", S.weather_storm_away, 0.22, function(ctx)
	return ctx.thunder and not ctx.underwater and none(ctx, "cold", "arctic")
		and (ctx.cave or any(ctx, "sky") or not ctx.outdoor)
end)

loop("light_wind", "wind", S.wind_light, 0.17, function(ctx)
	return surface(ctx) and ctx.outdoor and any(ctx, "beach", "ocean")
		and none(ctx, "highland", "arctic", "mesa")
end)

loop("heavy_wind", "wind", S.wind_heavy, 0.22, function(ctx)
	return surface(ctx) and ctx.outdoor and any(ctx, "highland") and none(ctx, "arctic", "mesa", "rain")
end)

loop("howling_wind", "wind", S.wind_howling, 0.20, function(ctx)
	return surface(ctx) and ctx.outdoor and any(ctx, "sky") and none(ctx, "end")
end)

loop("mesa_wind", "wind", S.wind_mesa, 0.22, function(ctx)
	return surface(ctx) and any(ctx, "mesa")
end)

loop("arctic_wind", "wind", S.wind_heavy, 0.24, function(ctx)
	return surface(ctx) and ctx.outdoor and any(ctx, "arctic")
end)

loop("cold_light_wind", "wind", S.wind_light, 0.12, function(ctx)
	return surface(ctx) and ctx.outdoor and any(ctx, "cold") and none(ctx, "arctic", "rain")
end)

loop("wind_in_leaves", "wind", S.wind_leaves, 0.16, function(ctx)
	return surface(ctx) and ctx.outdoor and ctx.counts.leaves >= 25
		and none(ctx, "jungle", "swamp", "rain", "arctic")
end)

loop("nether_suspense", "suspense", S.suspense_nether, 0.36, function(ctx)
	return ctx.dimension == "nether"
end)

loop("end_suspense", "suspense", S.suspense_end, 0.36, function(ctx)
	return ctx.dimension == "end"
end)

loop("pale_garden_suspense", "suspense", S.suspense_pale, 0.26, function(ctx)
	return surface(ctx) and any(ctx, "pale_garden")
end)

local layer_metadata = {
	forest_day_birds = { region = "forest", sound_id = "bird-ambience", original_categories = { "animal", "bird", "bird_day" } },
	taiga_huge_birds = { region = "taiga", sound_id = "bird-ambience-huge", original_categories = { "animal", "bird", "bird_day" } },
	warm_savanna_birds = { region = "savanna", sound_id = "bird-ambience-warm", original_categories = { "animal", "bird", "bird_day" } },
	roofed_forest_spooky_birds = { region = "forest.roofed", sound_id = "bird-ambience-spooky", original_categories = { "animal", "bird" } },
	jungle_day_birds = { region = "jungle", sound_id = "bird-ambience-jungle", original_categories = { "animal", "bird", "bird_day" } },
	jungle_night_birds = { region = "jungle", sound_id = "bird-ambience-jungle-night", original_categories = { "animal", "bird", "bird_night" } },
	swamp_crickets = { region = "swamp", sound_id = "cricket-swamp", original_categories = { "animal", "cricket" } },
	jungle_crickets = { region = "jungle", sound_id = "cricket-jungle", original_categories = { "animal", "cricket", "cricket_day" } },
	jungle_night_crickets = { region = "jungle", sound_id = "cricket-jungle-night", original_categories = { "animal", "cricket", "cricket_night" } },
	field_crickets = { region = "grass", sound_id = "cricket", original_categories = { "animal", "cricket", "cricket_day" } },
	night_crickets = { region = "plains", sound_id = "cricket-night", original_categories = { "animal", "cricket", "cricket_night" } },
	warm_night_crickets = { region = "savanna", sound_id = "cricket-warm-night", original_categories = { "animal", "cricket", "cricket_night" } },
	cicadas_day = { region = "savanna", sound_id = "cicadas", original_categories = { "animal", "cicadas" } },
	desert_cicadas = { region = "desert", sound_id = "cicadas-desert", original_categories = { "animal", "cicadas" } },
	night_cicadas = { region = "grass", sound_id = "cicadas-night", original_categories = { "animal", "cicadas" } },
	mushroom_cicadas = { region = "mushroom_fields", sound_id = "cicadas-mushroom-fields", original_categories = { "animal", "cicadas" } },
	beach_seagulls_long = { region = "beach", sound_id = "seagull-long", original_categories = { "animal" } },
	mushroom_special = { region = "mushroom_fields", sound_id = "special-mushroom-fields", original_categories = { "animal" } },
	warden_suspense = { region = "warden", sound_id = "warden", original_categories = { "suspense" } },
	doves = { region = "forest", sound_id = "mourning-dove", original_categories = { "animal", "bird", "bird_day" } },
	owls = { region = "forest", sound_id = "owl", original_categories = { "animal", "bird", "bird_night" } },
	crows = { region = "forest.cold", sound_id = "crow", original_categories = { "animal", "bird" } },
	frogs = { region = "swamp", sound_id = "frog", original_categories = { "animal" } },
	cave_frogs = { region = "cave.lush", sound_id = "frog-cave", original_categories = { "animal" } },
	seagulls = { region = "beach", sound_id = "seagull", original_categories = { "animal" } },
	whales = { region = "ocean_deep", sound_id = "whale", original_categories = { "animal" } },
	wolves = { region = "taiga", sound_id = "wolf", original_categories = { "animal" } },
	long_wolves = { region = "taiga", sound_id = "long-wolf", original_categories = { "animal" } },
	cave_ambience = { region = "cave.ambience", sound_id = "cave", original_categories = { "cave" } },
	large_cave_ambience = { region = "cave", sound_id = "cave-large", original_categories = { "cave" } },
	deep_cave_ambience = { region = "cave", sound_id = "cave-deep", original_categories = { "cave" } },
	cave_water = { region = "cave", sound_id = "cave-water", original_categories = { "cave" } },
	lush_cave = { region = "cave.lush", sound_id = "cave-lush", original_categories = { "cave" } },
	deep_dark = { region = "cave.deep-dark", sound_id = "deep-dark", original_categories = { "cave", "suspense" } },
	underworld_cave = { region = "underworld", sound_id = "underworld", original_categories = { "cave", "suspense" } },
	beach_water = { region = "beach", sound_id = "water-beach", original_categories = {} },
	ocean_water = { region = "ocean", sound_id = "water-ocean", original_categories = {} },
	underwater = { region = "underwater", sound_id = "underwater", original_categories = {} },
	deep_underwater = { region = "ocean_deep", sound_id = "underwater-deep", original_categories = {} },
	rain = { region = "rain", sound_id = "rain", original_categories = { "weather" } },
	storm_close = { region = "storm.close", sound_id = "storm-close", original_categories = { "weather" } },
	storm_away = { region = "storm.away", sound_id = "storm-away", original_categories = { "weather" } },
	light_wind = { region = "beach", sound_id = "light-wind", original_categories = { "wind" } },
	heavy_wind = { region = "highland", sound_id = "heavy-wind", original_categories = { "wind" } },
	howling_wind = { region = "sky", sound_id = "howling-wind", original_categories = { "wind" } },
	mesa_wind = { region = "mesa", sound_id = "mesa", original_categories = { "wind" } },
	arctic_wind = { region = "cold.artic", sound_id = "heavy-wind", original_categories = { "wind" } },
	cold_light_wind = { region = "cold", sound_id = "light-wind", original_categories = { "wind" } },
	wind_in_leaves = { region = "forest", sound_id = "wind-in-leaves", original_categories = { "wind" } },
	nether_suspense = { region = "underworld", sound_id = "nether", original_categories = { "suspense" } },
	end_suspense = { region = "underworld", sound_id = "end", original_categories = { "suspense" } },
	pale_garden_suspense = { region = "pale-garden", sound_id = "pale-garden", original_categories = { "suspense" } },
}

for _, layer in ipairs(layers) do
	local metadata = layer_metadata[layer.id]
	if metadata then
		layer.region = metadata.region
		layer.sound_id = metadata.sound_id
		layer.original_categories = metadata.original_categories
	else
		layer.region = layer.category
		layer.sound_id = layer.id
		layer.original_categories = {}
	end
end

local AS = ambientsounds

local context = {}
AS.context = context

local scan_nodes = {
	"group:leaves",
	"group:tree",
	"group:wood",
	"group:material_wood",
	"group:material_stone",
	"group:stone",
	"group:material_sand",
	"group:sand",
	"group:ice",
	"group:grass",
	"group:grass_block",
	"group:flora",
	"group:flower",
	"group:plant",
	"group:sculk",
	"group:liquid_source",
	"mcl_core:water_source",
	"mcl_core:water_flowing",
	"mclx_core:river_water_source",
	"mclx_core:river_water_flowing",
	"mcl_core:lava_source",
	"mcl_core:lava_flowing",
	"mcl_dripstone:dripstone_block",
	"mcl_dripstone:dripstone_bottom_tip",
	"mcl_dripstone:dripstone_top_tip",
	"mcl_sculk:sculk",
	"mcl_sculk:vein",
	"mcl_sculk:catalyst",
	"mcl_sculk:sensor",
	"mcl_sculk:shrieker",
	"mcl_lush_caves:moss",
	"mcl_lush_caves:moss_carpet",
	"mcl_lush_caves:azalea",
	"mcl_lush_caves:azalea_flowering",
	"mcl_lush_caves:dripleaf_big",
	"mcl_lush_caves:dripleaf_big_stem",
	"mcl_lush_caves:dripleaf_small",
	"mcl_lush_caves:dripleaf_small_stem",
	"mcl_lush_caves:cave_vines",
	"mcl_lush_caves:cave_vines_lit",
	"mcl_lush_caves:hanging_roots",
	"mcl_lush_caves:spore_blossom",
	"mcl_moss:moss",
}

local function add_tag(tags, tag)
	tags[tag] = true
end

local function scan_environment(pos, radius)
	local minp = { x = pos.x - radius, y = pos.y - radius, z = pos.z - radius }
	local maxp = { x = pos.x + radius, y = pos.y + radius, z = pos.z + radius }
	local found = core.find_nodes_in_area(minp, maxp, scan_nodes, true) or {}
	local counts = {
		leaves = 0,
		tree = 0,
		wood = 0,
		stone = 0,
		sand = 0,
		ice = 0,
		grass = 0,
		plants = 0,
		dripstone = 0,
		sculk = 0,
		lush = 0,
		water = 0,
		lava = 0,
		liquid = 0,
	}

	for node_name, positions in pairs(found) do
		local count = type(positions) == "table" and #positions or 0
		if count > 0 then
			local lname = string.lower(node_name)
			local def = core.registered_nodes[node_name]
			if core.get_item_group(node_name, "leaves") > 0 then
				counts.leaves = counts.leaves + count
			end
			if core.get_item_group(node_name, "tree") > 0 then
				counts.tree = counts.tree + count
			end
			if core.get_item_group(node_name, "wood") > 0 or core.get_item_group(node_name, "material_wood") > 0 then
				counts.wood = counts.wood + count
			end
			if core.get_item_group(node_name, "stone") > 0 or core.get_item_group(node_name, "material_stone") > 0 then
				counts.stone = counts.stone + count
			end
			if core.get_item_group(node_name, "sand") > 0 or core.get_item_group(node_name, "material_sand") > 0 then
				counts.sand = counts.sand + count
			end
			if core.get_item_group(node_name, "ice") > 0 then
				counts.ice = counts.ice + count
			end
			if core.get_item_group(node_name, "grass") > 0 then
				counts.grass = counts.grass + count
			end
			if core.get_item_group(node_name, "flora") > 0 or core.get_item_group(node_name, "flower") > 0
					or core.get_item_group(node_name, "plant") > 0
					or string.find(lname, "flower", 1, true) or string.find(lname, "tallgrass", 1, true)
					or string.find(lname, "fern", 1, true) or string.find(lname, "grass", 1, true) then
				counts.plants = counts.plants + count
			end
			if string.find(lname, "dripstone", 1, true) then
				counts.dripstone = counts.dripstone + count
			end
			if string.find(lname, "sculk", 1, true) then
				counts.sculk = counts.sculk + count
			end
			if string.find(lname, "lush", 1, true) or string.find(lname, "moss", 1, true)
					or string.find(lname, "azalea", 1, true) or string.find(lname, "dripleaf", 1, true) then
				counts.lush = counts.lush + count
			end
			if def and def.liquidtype and def.liquidtype ~= "none" then
				counts.liquid = counts.liquid + count
			end
			if string.find(lname, "water", 1, true) or string.find(lname, "river", 1, true) then
				counts.water = counts.water + count
			end
			if string.find(lname, "lava", 1, true) then
				counts.lava = counts.lava + count
			end
		end
	end

	return counts
end

local function contains_any(text, needles)
	for _, needle in ipairs(needles) do
		if string.find(text, needle, 1, true) then
			return true
		end
	end
	return false
end

local function add_biome_tags(tags, biome, biome_def)
	local b = string.lower(biome or "")
	if b == "" then
		return
	end

	if contains_any(b, { "forest", "woods", "grove", "thicket", "orchard", "cherrygrove", "cherry_grove" }) then
		add_tag(tags, "forest")
	end
	if contains_any(b, { "darkforest", "dark_forest", "roofed", "roofedforest" }) then add_tag(tags, "roofed_forest") end
	if contains_any(b, { "cherrygrove", "cherry_grove" }) then add_tag(tags, "cherry_grove") end
	if contains_any(b, { "taiga", "spruce", "megataiga", "megasprucetaiga", "coldtaiga" }) then add_tag(tags, "taiga") end
	if contains_any(b, { "megataiga", "megasprucetaiga" }) then add_tag(tags, "mega_taiga") end
	if contains_any(b, { "jungle", "bamboo" }) then add_tag(tags, "jungle") end
	if contains_any(b, { "bamboojungle", "bamboo_jungle" }) then add_tag(tags, "bamboo_jungle") end
	if contains_any(b, { "swamp", "swampland", "mangrove", "marsh", "bayou" }) then add_tag(tags, "swamp") end
	if contains_any(b, { "mangroveswamp", "mangrove_swamp" }) then add_tag(tags, "mangrove_swamp") end
	if contains_any(b, { "plain", "meadow", "field", "flower", "sunflower", "pasture" }) then add_tag(tags, "plains") end
	if contains_any(b, { "desert" }) then add_tag(tags, "desert") end
	if contains_any(b, { "savanna", "prairie", "chaparral" }) then add_tag(tags, "savanna") end
	if contains_any(b, { "mesa", "badland", "outback", "wasteland", "canyon" }) then add_tag(tags, "mesa") end
	if contains_any(b, { "beach", "shore", "stonebeach" }) then add_tag(tags, "beach") end
	if contains_any(b, { "river" }) then add_tag(tags, "river") end
	if contains_any(b, { "ocean", "river", "lake", "sea", "coral", "kelp" }) then add_tag(tags, "ocean") end
	if contains_any(b, { "deep_ocean", "deep ocean", "deepocean" }) then add_tag(tags, "deep_ocean") end
	if contains_any(b, { "extremehills", "extreme_hills", "mountain", "hills", "peaks", "slopes", "stony" }) then add_tag(tags, "highland") end
	if contains_any(b, { "ice", "snow", "frozen", "cold", "snowy", "frozenpeaks", "snowyslopes" }) then
		add_tag(tags, "cold")
	end
	if contains_any(b, { "iceplains", "frozen", "snowy", "snowyslopes", "frozenpeaks", "jaggedpeaks" }) then add_tag(tags, "arctic") end
	if string.find(b, "mushroom", 1, true) then add_tag(tags, "mushroom") end
	if string.find(b, "lush", 1, true) then add_tag(tags, "lush") end
	if string.find(b, "dripstone", 1, true) then add_tag(tags, "dripstone") end
	if contains_any(b, { "deepdark", "deep_dark", "sculk" }) then
		add_tag(tags, "deep_dark")
	end
	if string.find(b, "pale", 1, true) then add_tag(tags, "pale_garden") end
	if contains_any(b, { "nether", "soulsand", "crimson", "warped", "basaltdelta" }) then add_tag(tags, "nether") end
	if string.find(b, "end", 1, true) then add_tag(tags, "end") end

	local biome_type = biome_def and biome_def._mcl_biome_type
	if biome_type == "snowy" or biome_type == "cold" then
		add_tag(tags, "cold")
	end
	if biome_type == "snowy" then
		add_tag(tags, "arctic")
	end
	if biome_type == "hot" then
		add_tag(tags, "hot")
	end
end

function context.has(ctx, tag)
	return ctx.tags[tag] == true
end

function context.any(ctx, tags)
	for _, tag in ipairs(tags) do
		if ctx.tags[tag] then
			return true
		end
	end
	return false
end

function context.build(player)
	local pos = player:get_pos()
	local biome, biome_data, biome_def = AS.compat.get_biome(pos)
	local dimension = AS.compat.get_dimension(pos)
	local weather = AS.compat.get_weather()
	local tod = core.get_timeofday() or 0
	local tags = {}
	local counts = scan_environment(pos, AS.config.scan_radius)

	add_biome_tags(tags, biome, biome_def)
	if dimension == "nether" then add_tag(tags, "nether") end
	if dimension == "end" then add_tag(tags, "end") end
	if counts.leaves >= 8 then add_tag(tags, "leafy") end
	if counts.tree >= 2 then add_tag(tags, "trees") end
	if counts.grass >= 8 or counts.plants >= 8 then add_tag(tags, "grass") end
	if counts.water > 0 then add_tag(tags, "water_near") end
	if counts.lava > 0 then add_tag(tags, "lava_near") end
	if counts.sand >= 20 then add_tag(tags, "sandy") end
	if counts.ice >= 8 then add_tag(tags, "icy") end
	if counts.ice >= 20 then add_tag(tags, "arctic") end
	if counts.dripstone > 0 then add_tag(tags, "dripstone") end
	if counts.sculk > 0 then add_tag(tags, "deep_dark") end
	if counts.lush > 0 then add_tag(tags, "lush") end

	local natural_light = core.get_natural_light(pos, 0.5) or 0
	local node_light = core.get_node_light(pos, 0.5) or 0
	local sky_factor = natural_light / 15
	local open_sky = AS.compat.is_outdoor(pos)
	local day = tod >= 0.23 and tod <= 0.77
	local underwater = AS.compat.is_underwater(player)
	local cave = dimension == "overworld" and not underwater
		and (pos.y < -8 or (natural_light <= 5 and node_light <= 8 and counts.stone >= 60))

	if cave then add_tag(tags, "cave") end
	if pos.y < -45 then add_tag(tags, "deep") end
	if open_sky then add_tag(tags, "outdoor") end
	if open_sky and (pos.y > 90 or tags.highland) then add_tag(tags, "sky") end
	if weather == "rain" or weather == "thunder" then add_tag(tags, "rain") end
	if weather == "thunder" then add_tag(tags, "thunder") end

	return {
		player = player,
		player_name = player:get_player_name(),
		pos = pos,
		biome = biome,
		biome_data = biome_data,
		biome_def = biome_def,
		dimension = dimension,
		weather = weather,
		raining = weather == "rain" or weather == "thunder",
		thunder = weather == "thunder",
		rain_at_pos = AS.compat.has_rain_at(pos),
		day = day,
		night = not day,
		timeofday = tod,
		underwater = underwater,
		cave = cave,
		surface = dimension == "overworld" and not cave and not underwater,
		outdoor = tags.outdoor == true,
		open_sky = open_sky,
		natural_light = natural_light,
		node_light = node_light,
		sky_factor = sky_factor,
		y = pos.y,
		counts = counts,
		tags = tags,
	}
end

local AS = ambientsounds

local util = {}
AS.util = util

function util.log(level, message)
	core.log(level, "[ambientsounds] " .. tostring(message))
end

function util.debug(message)
	if AS.config and AS.config.debug then
		util.log("action", message)
	end
end

function util.clamp(value, min_value, max_value)
	if value < min_value then
		return min_value
	end
	if value > max_value then
		return max_value
	end
	return value
end

function util.contains_text(text, needle)
	return text and needle and string.find(string.lower(text), needle, 1, true) ~= nil
end

function util.pick(list)
	if not list or #list == 0 then
		return nil
	end
	return list[math.random(1, #list)]
end

function util.random_between(min_value, max_value)
	if max_value <= min_value then
		return min_value
	end
	return min_value + math.random() * (max_value - min_value)
end

function util.safe_call(fn, ...)
	if type(fn) ~= "function" then
		return nil
	end
	local ok, result = pcall(fn, ...)
	if ok then
		return result
	end
	util.debug(result)
	return nil
end

function util.player_disabled(player)
	return player:get_meta():get_int("ambientsounds:disable") == 1
end

function util.table_keys_string(tbl)
	local keys = {}
	for key, value in pairs(tbl or {}) do
		if value then
			keys[#keys + 1] = key
		end
	end
	table.sort(keys)
	return table.concat(keys, ", ")
end


---@type string
local who_am_i = MOD_ID
if not MOD_ID then
	local path = "data/noita_oop/temp.txt"
	ModTextFileSetContent(path, "empty")
	who_am_i = ModTextFileWhoSetContent(path)
	MOD_ID = who_am_i
end

local _require = require
---@param modname string
---@return any
function require(modname)
	return dofile_once(("mods/%s/lib/ecs/%s.lua"):format(who_am_i, modname:gsub("%.", "/")))
end

local ECS = require "src.ECS"
require = _require

return ECS

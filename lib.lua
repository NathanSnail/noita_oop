---@type string
local whoami = MODID
if not MODID then
	local path = "data/noita_oop/temp.txt"
	ModTextFileSetContent(path, "empty")
	whoami = ModTextFileWhoSetContent(path)
	MODID = whoami
end

local _require = require
---@param modname string
---@return any
function require(modname)
	return dofile_once(("mods/%s/lib/ecs/%s.lua"):format(whoami, modname:gsub("%.", "/")))
end

local ECS = require "src.ECS"
require = _require

return ECS

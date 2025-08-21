if not TESTING then
	local path = "data/noita_oop/temp.txt"
	ModTextFileSetContent(path, "empty")
	local whoami = ModTextFileWhoSetContent(path)
	---@param modname string
	---@return any
	function require(modname)
		return dofile_once(("mods/%s/%s.lua"):format(whoami, (modname:gsub("%.", "/"))))
	end
end

local Entity = require "src.Entity"

---@class (exact) ECS
---@field me Entity

---@type ECS
---@diagnostic disable-next-line: missing-fields
local M = {}

local opts = {
	me = function()
		return Entity.from_id(GetUpdatedEntityID())
	end,
}
---@type metatable
local mt = {
	---@param self ECS
	---@param k any
	__index = function(self, k)
		if opts[k] then return opts[k]() end
		return nil
	end,
	__newindex = function()
		error("cannot add fields to ECS")
	end,
}

setmetatable(M, mt)
return M

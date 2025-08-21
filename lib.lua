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
local typed = require "src.typed"

---@class (exact) ECS
---@field me Entity
---@field load fun(file: string, x: number?, y: number?): Entity

---@type ECS
---@diagnostic disable-next-line: missing-fields
local M = {}

---@type table<string, (fun(): any) | (fun(...): any)[]>
local opts = {
	me = function()
		return Entity.from_id(GetUpdatedEntityID())
	end,
	load = {
		function(filename, x, y)
			filename = typed.must(filename, "string")
			x = typed.maybe(x, 0)
			y = typed.maybe(y, 0)
			local eid = EntityLoad(filename, x, y)
			-- EntityLoad truncates
			EntitySetTransform(eid, x, y)
			return Entity.from_id(eid)
		end,
	},
}

---@type metatable
local mt = {
	---@param self ECS
	---@param k any
	__index = function(self, k)
		local field = opts[k]
		if field then
			if type(field) == "table" then return field[1] end
			return opts[k]()
		end
		error(("field '%s' does not exist in ECS"):format(k))
	end,
	__newindex = function()
		error("cannot add fields to ECS")
	end,
	__tostring = function()
		error("<class ECS>")
	end,
}

setmetatable(M, mt)
return M

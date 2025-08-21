local freeze = require "src.freeze"
local metatable = require "src.metatable"
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
---@field load fun(file: string, x: number?, y: number?, rotation: number?, scale_x: number?, scale_y: number?): Entity

---@type ECS
---@diagnostic disable-next-line: missing-fields
local M = {}

---@type table<string, (fun(): any) | (fun(...): any)[]>
local index = {
	me = function()
		return Entity.from_id(GetUpdatedEntityID())
	end,
	load = {
		function(filename, x, y, rotation, scale_x, scale_y)
			filename = typed.must(filename, "string")
			x = typed.maybe(x, 0)
			y = typed.maybe(y, 0)
			rotation = typed.maybe(rotation, 0)
			scale_x = typed.maybe(scale_x, 1)
			scale_y = typed.maybe(scale_y, 1)
			local eid = EntityLoad(filename, x, y)
			-- EntityLoad truncates
			EntitySetTransform(eid, x, y, rotation, scale_x, scale_y)
			return Entity.from_id(eid)
		end,
	},
}

local mt = metatable.metatable(index, {}, "ECS")

freeze.freeze(M, "ECS", mt)
return M

---@class ECS.EntityLib
local M = {}

local Transform = require "src.Transform"
local freeze = require "src.freeze"
local metatable = require "src.metatable"
local typed = require "src.typed"

---@class (exact) Entity
---@field id entity_id
---@field name string
---@field file string
---@field transform Transform
---@field x number equivalent to `transform.pos.x`
---@field y number equivalent to `transform.pos.y`

---@type table<string, fun(self: Entity): any>
local index = {
	name = function(self)
		return EntityGetName(self.id)
	end,
	file = function(self)
		return EntityGetFilename(self.id)
	end,
	transform = function(self)
		return Transform.from_entity(self)
	end,
	x = function(self)
		return self.transform.x
	end,
	y = function(self)
		return self.transform.y
	end,
}

---@type table<string, fun(self: Entity, value: any)>
local newindex = {
	name = function(self, value)
		value = typed.must(value, "string")
		EntitySetName(self.id, value)
	end,
	file = function(_)
		error("Entity file is readonly")
	end,
	x = function(self, value)
		self.transform.x = value
	end,
	y = function(self, value)
		self.transform.y = value
	end,
}

local mt = metatable.metatable(index, newindex, "Entity", function(self)
	return tostring(self.id)
end)

---@param entity_id entity_id
---@return Entity
function M.from_id(entity_id)
	return setmetatable({ id = entity_id }, mt)
end

freeze.freeze(M, "ECS.EntityLib")

return M

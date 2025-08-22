local require = require

---@class ECS.EntityLib
---@operator call(entity_id): Entity
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
---@field pos Vec2 equivalent to `transform.pos`
---@field rotation number equivalent to `transform.rotation`
---@field scale Vec2 equivalent to `transform.scale`
---@field parent Entity?

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
	parent = function(self)
		local parent_id = EntityGetParent(self.id)
		if parent_id == 0 then return end
		return M(parent_id)
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
	transform = function(self, value)
		value = typed.must(value, "table")
		self.transform.pos = value.pos
		self.transform.rotation = value.rotation
		self.transform.scale = value.scale
	end,
	parent = function(self, value)
		if value == nil then
			EntityRemoveFromParent(self.id)
			return
		end
		value = typed.must(value, "table")
		---@cast value Entity
		local parent_id = typed.must(value.id, "number")
		---@diagnostic disable-next-line: cast-type-mismatch
		---@cast parent_id entity_id
		EntityAddChild(parent_id, self.id)
	end,
}

local transform_fields = { "pos", "rotation", "scale" }
for _, v in ipairs(transform_fields) do
	index[v] = function(self)
		return self.transform[v]
	end
	newindex[v] = function(self, value)
		self.transform[v] = value
	end
end

local mt = metatable.metatable(index, newindex, "Entity", function(self)
	return tostring(self.id)
end)

---@param entity_id entity_id
---@return Entity
function M.from_id(entity_id)
	typed.must(entity_id, "number")
	return setmetatable({ id = entity_id }, mt)
end

freeze.freeze(M, "ECS.EntityLib", {
	---@param self ECS.EntityLib
	---@param arg any
	---@return Entity
	__call = function(self, arg)
		return self.from_id(arg)
	end,
})

return M

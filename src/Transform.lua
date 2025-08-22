local require = require

local Vec2 = require "src.Vec2"
local freeze = require "src.freeze"
local metatable = require "src.metatable"
local typed = require "src.typed"
---@class ECS.TransformLib
local M = {}

---@class (exact) Transform
---@field pos Vec2
---@field rotation number
---@field scale Vec2

---@class (exact) ECS.EntityTransform : Transform
---@field entity Entity?

---@class (exact) ECS.CustomTransform : Transform
---@field backing Transform?

---@type table<string, fun(self: Transform, value: any): any>
local index = {
	pos = function(self)
		---@cast self ECS.EntityTransform
		if self.entity then return Vec2.from_entity(self.entity, "pos") end
	end,
	scale = function(self)
		---@cast self ECS.EntityTransform
		if self.entity then return Vec2.from_entity(self.entity, "scale") end
	end,
	rotation = function(self)
		---@cast self ECS.EntityTransform
		if self.entity then
			local _, _, rotation, _, _ = EntityGetTransform(self.entity.id)
			return rotation
		end
	end,
}

---@type table<string, fun(self: Transform, value: any)>
local newindex = {
	pos = function(self, value)
		typed.must(value, "table")
		self.pos.x = value.x
		self.pos.y = value.y
	end,
	scale = function(self, value)
		typed.must(value, "table")
		self.scale.x = value.x
		self.scale.y = value.y
	end,
	rotation = function(self, value)
		value = typed.must(value, "number")
		---@cast self ECS.EntityTransform
		if self.entity then
			local x, y, _, scale_x, scale_y = EntityGetTransform(self.entity.id)
			EntitySetTransform(self.entity.id, x, y, value, scale_x, scale_y)
		else
			---@cast self ECS.CustomTransform
			self.backing.rotation = value
		end
	end,
}

local mt = metatable.metatable(index, newindex, "Transform", function(self)
	---@cast self ECS.EntityTransform
	if self.entity then return tostring(self.entity) end
end)

---@param entity Entity
---@return Transform
function M.from_entity(entity)
	return setmetatable({ entity = entity }, mt)
end

freeze.freeze(M, "ECS.TransformLib")
return M

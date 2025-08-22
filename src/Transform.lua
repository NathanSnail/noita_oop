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
		if self.entity then
			return Vec2.from_entity(self.entity, "pos")
		else
			---@cast self ECS.CustomTransform
			return self.backing.pos
		end
	end,
	scale = function(self)
		---@cast self ECS.EntityTransform
		if self.entity then
			return Vec2.from_entity(self.entity, "scale")
		else
			---@cast self ECS.CustomTransform
			return self.backing.scale
		end
	end,
	rotation = function(self)
		---@cast self ECS.EntityTransform
		if self.entity then
			local _, _, rotation, _, _ = EntityGetTransform(self.entity.id)
			return rotation
		else
			---@cast self ECS.CustomTransform
			return self.backing.rotation
		end
	end,
	entity = function(_)
		-- we can't have this as nil because then we try and print an error that the field doesn't exist
		return false
	end,
}

---@type table<string, fun(self: ECS.EntityTransform, value: any)>
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

---For internal use only, use `entity.transform`
---@param entity Entity
---@return Transform
function M.from_entity(entity)
	return setmetatable({ entity = entity }, mt)
end

---@param pos Vec2? {x = 0, y = 0}
---@param rotation number? 0
---@param scale Vec2? {x = 1, y = 1}
function M.new(pos, rotation, scale)
	pos = Vec2(typed.maybe(pos, { x = 0, y = 0 }))
	rotation = typed.maybe(rotation, 0)
	scale = Vec2(typed.maybe(scale, { x = 1, y = 1 }))
	return setmetatable({ backing = { pos = pos, rotation = rotation, scale = scale } }, mt)
end

freeze.freeze(M, "ECS.TransformLib", {
	---@param self ECS.TransformLib
	---@param arg any
	__call = function(self, arg)
		arg = typed.must(arg, "table")
		local t = self.new(arg.pos, arg.rotation, arg.scale)
		return t
	end,
})
return M

local Vec2 = require "src.Vec2"
local freeze = require "src.freeze"
local metatable = require "src.metatable"
---@class ECS.TransformLib
local M = {}

---@class (exact) Transform
---@field pos Vec2
---@field rotation number
---@field scale Vec2

---@class (exact) EntityTransform : Transform
---@field entity Entity?

---@class (exact) CustomTransform : Transform
---@field backing Transform?

---@type table<string, fun(self: Transform, value: any): any>
local index = {
	pos = function(self)
		---@cast self EntityTransform
		if self.entity then return Vec2.from_entity(self.entity) end
	end,
}

---@type table<string, fun(self: Transform, value: any)>
local newindex = {}

local mt = metatable.metatable(index, newindex, "Transform", function(self)
	---@cast self EntityTransform
	if self.entity then return tostring(self.entity) end
end)

---@param entity Entity
---@return Transform
function M.from_entity(entity)
	return setmetatable({ entity = entity }, mt)
end

freeze.freeze(M, "ECS.TransformLib")
return M

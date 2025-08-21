local freeze = require "src.freeze"
local metatable = require "src.metatable"
local typed = require "src.typed"
---@class ECS.Vec2Lib
local M = {}

---@class (exact) Vec2
---@field x number
---@field y number

---@class (exact) EntityVec2 : Vec2
---@field entity Entity

-- if the index is actually used we are secretly an EntityVec2
---@type table<string, fun(self: EntityVec2): any>
local index = {
	x = function(self)
		local x = EntityGetTransform(self.entity.id)
		return x
	end,
	y = function(self)
		local _, y = EntityGetTransform(self.entity.id)
		return y
	end,
}

---@type table<string, fun(self: EntityVec2, value: any)>
local newindex = {
	x = function(self, x)
		x = typed.must(x, "number")
		local _, y, rotation, scale_x, scale_y = EntityGetTransform(self.entity.id)
		EntitySetTransform(self.entity.id, x, y, rotation, scale_x, scale_y)
	end,
	y = function(self, y)
		y = typed.must(y, "number")
		local x, _, rotation, scale_x, scale_y = EntityGetTransform(self.entity.id)
		EntitySetTransform(self.entity.id, x, y, rotation, scale_x, scale_y)
	end,
}

local mt = metatable.metatable(index, newindex, "Vec2", function(self)
	---@cast self EntityVec2
	local entity = ""
	if self.entity then entity = " from " .. tostring(self.entity) end
	return ("%d, %d%s"):format(self.x, self.y, entity)
end)

---@param entity Entity
---@return Vec2
function M.from_entity(entity)
	return setmetatable({ entity = entity }, mt)
end

freeze.freeze(M, "ECS.Vec2Lib")
return M

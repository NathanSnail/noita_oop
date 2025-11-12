local require = require
local freeze = require "src.utils.freeze"
local metatable = require "src.utils.metatable"
local typed = require "src.utils.typed"

---@class (exact) Vec2.mimic
---@field x number
---@field y number

---@alias Vec2.like Vec2 | Vec2.mimic

---@class ECS.Vec2Lib
---@overload fun(Vec2.like): Vec2
local M = {}

---@class (exact) Vec2
---@field x number
---@field y number
---@field clone fun(self: Vec2): Vec2
---@operator mul(number): Vec2
---@operator div(number): Vec2
---@operator add(Vec2.like): Vec2
---@operator sub(Vec2.like): Vec2
---@operator unm: Vec2

---@alias ECS.TransformVec2Variant "pos" | "scale"

---@class (exact) ECS.EntityVec2 : Vec2
---@field entity Entity
---@field variant ECS.TransformVec2Variant

---@class (exact) ECS.ComponentVec2 : Vec2
---@field component Component
---@field field string

local function clone_vec(self)
	return M.xy(self.x, self.y)
end

---@type metatable
local arithmetic_mt = {
	---@param self Vec2
	---@param other Vec2
	---@return Vec2
	__add = function(self, other)
		other = typed.must(other, "table")
		local x, y = typed.must(other.x, "number"), typed.must(other.y, "number")
		return M.xy(self.x + x, self.y + y)
	end,
	---@param self Vec2
	---@param other Vec2
	---@return Vec2
	__sub = function(self, other)
		other = typed.must(other, "table")
		local x, y = typed.must(other.x, "number"), typed.must(other.y, "number")
		return M.xy(self.x - x, self.y - y)
	end,
	---@param self Vec2
	---@param other number
	---@return Vec2
	__mul = function(self, other)
		other = typed.must(other, "number")
		return M.xy(self.x * other, self.y * other)
	end,
	---@param self Vec2
	---@param other number
	---@return Vec2
	__div = function(self, other)
		other = typed.must(other, "number")
		return M.xy(self.x / other, self.y / other)
	end,
	---@param self Vec2
	---@return Vec2
	__unm = function(self)
		return M.xy(-self.x, -self.y)
	end,
}

-- if the index is actually used we are secretly an EntityVec2
---@type table<string, (fun(self: ECS.EntityVec2): any) | (fun(self: ECS.EntityVec2): any)[]>
local entity_index = {
	x = function(self)
		if self.variant == "pos" then
			local x = EntityGetTransform(self.entity.id)
			return x
		else
			local _, _, _, scale_x = EntityGetTransform(self.entity.id)
			return scale_x
		end
	end,
	y = function(self)
		if self.variant == "pos" then
			local _, y = EntityGetTransform(self.entity.id)
			return y
		else
			local _, _, _, _, scale_y = EntityGetTransform(self.entity.id)
			return scale_y
		end
	end,
	clone = { clone_vec },
}

---@type table<string, fun(self: ECS.EntityVec2, value: any)>
local entity_newindex = {
	x = function(self, value)
		value = typed.must(value, "number")
		if self.variant == "pos" then
			local _, y, rotation, scale_x, scale_y = EntityGetTransform(self.entity.id)
			EntitySetTransform(self.entity.id, value, y, rotation, scale_x, scale_y)
		else
			local x, y, rotation, _, scale_y = EntityGetTransform(self.entity.id)
			EntitySetTransform(self.entity.id, x, y, rotation, value, scale_y)
		end
	end,
	y = function(self, value)
		value = typed.must(value, "number")
		if self.variant == "pos" then
			local x, _, rotation, scale_x, scale_y = EntityGetTransform(self.entity.id)
			EntitySetTransform(self.entity.id, x, value, rotation, scale_x, scale_y)
		else
			local x, y, rotation, scale_x, _ = EntityGetTransform(self.entity.id)
			EntitySetTransform(self.entity.id, x, y, rotation, scale_x, value)
		end
	end,
}

local entity_mt = metatable.metatable(entity_index, entity_newindex, "Vec2", function(self)
	---@cast self ECS.EntityVec2
	return ("%d, %d from %s"):format(self.x, self.y, self.entity)
end, arithmetic_mt)

-- if the index is actually used we are secretly a ComponentVec2
---@type table<string, (fun(self: ECS.ComponentVec2): any) | (fun(self: ECS.ComponentVec2): any)[]>
local component_index = {
	x = function(self)
		local x, _ = ComponentGetValue2(self.component.id, self.field)
		return x
	end,
	y = function(self)
		local _, y = ComponentGetValue2(self.component.id, self.field)
		return y
	end,
	clone = { clone_vec },
}

---@type table<string, fun(self: ECS.ComponentVec2, value: any)>
local component_newindex = {
	x = function(self, value)
		local x = typed.must(value, "number")
		local _, y = ComponentGetValue2(self.component.id, self.field)
		ComponentSetValue2(self.component.id, self.field, x, y)
	end,
	y = function(self, value)
		local y = typed.must(value, "number")
		local x, _ = ComponentGetValue2(self.component.id, self.field)
		ComponentSetValue2(self.component.id, self.field, x, y)
	end,
}

local component_mt = metatable.metatable(component_index, component_newindex, "Vec2", function(self)
	---@cast self ECS.ComponentVec2
	return ("%d, %d from %s"):format(self.x, self.y, self.component)
end, arithmetic_mt)

local basic_mt = metatable.metatable({ clone = { clone_vec } }, {}, "Vec2", function(self)
	return ("%d, %d"):format(self.x, self.y)
end, arithmetic_mt)

---For internal use only, use `entity.transform.*`
---@param entity Entity
---@param variant ECS.TransformVec2Variant
---@return ECS.EntityVec2
function M.from_entity(entity, variant)
	return setmetatable({ entity = entity, variant = variant }, entity_mt)
end

---For internal use only, use `entity.components.*.*`
---@param component Component
---@param field field_type
---@return ECS.ComponentVec2
function M.from_component_field(component, field)
	return setmetatable({ component = component, field = field }, component_mt)
end

---You can also do `Vec2{x = x, y = y}` instead of `Vec2.xy(x, y)`
---@param x number
---@param y number
---@return Vec2
function M.xy(x, y)
	return setmetatable({ x = x, y = y }, basic_mt)
end

---@type metatable
local lib_mt = {
	---@param self ECS.Vec2Lib
	---@param arg any
	---@return Vec2
	__call = function(self, arg)
		arg = typed.must(arg, "table")
		local x, y = arg.x, arg.y
		x = typed.must(x, "number")
		y = typed.must(y, "number")
		return self.xy(x, y)
	end,
}

freeze.freeze(M, "ECS.Vec2Lib", lib_mt)
return M

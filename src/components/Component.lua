local require = require
local ComponentTags = require "src.components.ComponentTags"
local freeze = require "src.utils.freeze"
local metatable = require "src.utils.metatable"
local special_component_fields = require "src.components.fields.special_component_fields"
local tags = require "src.utils.tags"

---@class (exact) Component
---@field id component_id readonly
---@field tags Tags | string
---@field type component_type readonly

---@class ECS.ComponentLib
---@overload fun(component_id: component_id): Component
local M = {}

---@class (exact) ECS.CustomType
---@field get fun(component: Component, field: string): any
---@field set fun(component: Component, field: string, value: any)

---@type table<string, ECS.CustomType>
local custom_types = {
	Vec2 = {
		get = require "src.Vec2".from_component_field,
		set = function(component, field, value)
			ComponentSetValue2(component.id, field, value.x, value.y)
		end,
	},
}

local index = {
	tags = function(self)
		return ComponentTags.from_component(self)
	end,
	type = function(self)
		return ComponentGetTypeName(self.id)
	end,
}

local newindex = {
	tags = tags.new_index,
}

local mt = metatable.metatable(nil, nil, "Component", function(self)
	return tostring(self.id)
end, {
	---@param self Component
	---@param key string
	---@return any
	__index = function(self, key)
		if index[key] then return index[key](self) end
		local custom_type = special_component_fields[self.type][key]
		if custom_type then return custom_types[custom_type].get(self, key) end
		return ComponentGetValue2(self.id, key)
	end,
	---@param self Component
	---@param key string
	---@param value any
	__newindex = function(self, key, value)
		if newindex[key] then return newindex[key](self, value) end
		local custom_type = special_component_fields[self.type][key]
		if custom_type then return custom_types[custom_type].set(self, key, value) end
		ComponentSetValue2(self.id, key, value)
	end,
})

---@param component_id component_id
---@return Component
function M.from_id(component_id)
	return setmetatable({ id = component_id }, mt)
end

freeze.freeze(M, "ECS.ComponentLib", {
	__call = function(_, arg)
		return M.from_id(arg)
	end,
})
return M

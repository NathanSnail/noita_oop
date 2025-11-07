local require = require
local ComponentTags = require "src.components.ComponentTags"
local freeze = require "src.utils.freeze"
local metatable = require "src.utils.metatable"
local tags = require "src.utils.tags"

---@class (exact) Component
---@field id component_id readonly
---@field tags Tags | string

---@class ECS.ComponentLib
---@overload fun(component_id: component_id): Component
local M = {}

local index = {
	tags = function(self)
		return ComponentTags.from_component(self)
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
		return ComponentGetValue2(self.id, key)
	end,
	---@param self Component
	---@param key string
	---@param value any
	__newindex = function(self, key, value)
		if newindex[key] then return newindex[key](self, value) end
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

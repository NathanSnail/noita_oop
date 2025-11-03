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

local new_index = {
	tags = tags.new_index,
}

local mt = metatable.metatable(index, new_index, "Component", function(self)
	return tostring(self.id)
end)

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

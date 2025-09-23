local require = require
local freeze = require "src.utils.freeze"
local functional = require "src.utils.functional"
local metatable = require "src.utils.metatable"
local typed = require "src.utils.typed"

---@class (exact) Component
---@overload fun(component_id: component_id): Component
---@field id component_id readonly

---@class ECS.ComponentLib
local M = {}

local mt = metatable.metatable({}, {}, "Component", function(self)
	return tostring(self.id)
end)

---@param component_id component_id
---@return Component
function M.from_id(component_id)
	return setmetatable({ id = component_id }, mt)
end

freeze.freeze(M, "ECS.ComponentLib", { __call = M.from_id })
return M

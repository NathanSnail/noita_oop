local require = require
local freeze = require "src.utils.freeze"
local tags = require "src.utils.tags"

---@class ECS.ComponentTagsLib
local M = {}

---@class (exact) ECS.ComponentTags : Tags
---@field [1] ECS.ComponentTagsBacking

---@class (exact) ECS.ComponentTagsBacking
---@field component Component
---@field tags string[]?
---@field index integer

local mt = tags.make_tags_mt(function(self)
	return ComponentGetTags(self[1].component.id) or ""
end, function(self, tag)
	return ComponentAddTag(self[1].component.id, tag)
end, function(self, tag)
	return ComponentRemoveTag(self[1].component.id, tag)
end, function(self, tag)
	return ComponentHasTag(self[1].component.id, tag)
end)

---@param component Component
function M.from_component(component)
	return setmetatable({ { component = component, index = 0 } }, mt)
end

freeze.freeze(M, "ECS.ComponentTagsLib")
return M

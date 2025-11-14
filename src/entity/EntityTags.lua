local require = require
local freeze = require "src.utils.freeze"
local tags = require "src.utils.tags"

---@class ECS.EntityTagsLib
local M = {}

---@class (exact) ECS.EntityTags : Tags
---@field [1] ECS.EntityTagsBacking

---@class (exact) ECS.EntityTagsBacking
---@field entity Entity
---@field tags string[]?
---@field index integer

local mt = tags.make_tags_mt(function(self)
	return EntityGetTags(self[1].entity.id)
end, function(self, tag)
	return EntityAddTag(self[1].entity.id, tag)
end, function(self, tag)
	return EntityRemoveTag(self[1].entity.id, tag)
end, function(self, tag)
	return EntityHasTag(self[1].entity.id, tag)
end)

---@param entity Entity
function M.from_entity(entity)
	return setmetatable({ { entity = entity, index = 0 } }, mt)
end

freeze.freeze(M, "ECS.EntityTagsLib")
return M

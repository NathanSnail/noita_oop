local require = require
local freeze = require "src.freeze"
local metatable = require "src.metatable"
local typed = require "src.typed"

---@class (exact) EntityTags
---@field [string] true

---@class (exact) ECS.EntityTags : EntityTags
---@field [1] Entity

---@class ECS.EntityTagsLib
local M = {}

local mt = metatable.metatable({}, {}, "EntityTags", function(self)
	---@cast self ECS.EntityTags
	return EntityGetTags(self[1].id)
end, {
	---@param self ECS.EntityTags
	---@param index any
	__index = function(self, index)
		index = typed.must(index, "string")
		return EntityHasTag(self[1].id, index)
	end,
	---@param self ECS.EntityTags
	---@param index any
	---@param value any
	__newindex = function(self, index, value)
		index = typed.must(index, "string")
		value = typed.must(value, "boolean")
		if value then
			EntityAddTag(self[1].id, index)
		else
			EntityRemoveTag(self[1].id, index)
		end
	end,
})

---@param entity Entity
function M.from_entity(entity)
	return setmetatable({ entity }, mt)
end

freeze.freeze(M, "ECS.EntityTagsLib")
return M

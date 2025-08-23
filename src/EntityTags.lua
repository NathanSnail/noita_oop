local require = require
local freeze = require "src.freeze"
local metatable = require "src.metatable"
local typed = require "src.typed"

---@class (exact) EntityTags
---@overload fun(): string?
---@field [string] boolean

---@class (exact) ECS.EntityTags : EntityTags
---@field [1] ECS.EntityTagsBacking

---@class (exact) ECS.EntityTagsBacking
---@field entity Entity
---@field tags string[]?
---@field index integer

---@class ECS.EntityTagsLib
local M = {}

local mt = metatable.metatable({}, {}, "EntityTags", function(self)
	---@cast self ECS.EntityTags
	return EntityGetTags(self[1].entity.id)
end, {
	---@param self ECS.EntityTags
	---@param index any
	__index = function(self, index)
		index = typed.must(index, "string")
		return EntityHasTag(self[1].entity.id, index)
	end,
	---@param self ECS.EntityTags
	---@param index any
	---@param value any
	__newindex = function(self, index, value)
		index = typed.must(index, "string")
		value = typed.must(value, "boolean")
		if value then
			EntityAddTag(self[1].entity.id, index)
		else
			EntityRemoveTag(self[1].entity.id, index)
		end
	end,
	---@param self ECS.EntityTags
	---@return string?
	__call = function(self)
		local backing = self[1]
		if not backing.tags then
			backing.tags = {}
			for tag in EntityGetTags(backing.entity.id):gmatch("[^,]+") do
				table.insert(backing.tags, tag)
			end
		end
		backing.index = backing.index + 1
		return backing.tags[backing.index]
	end,
})

---@param entity Entity
function M.from_entity(entity)
	return setmetatable({ { entity = entity, index = 0 } }, mt)
end

freeze.freeze(M, "ECS.EntityTagsLib")
return M

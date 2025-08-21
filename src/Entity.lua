local typed = require "src.typed"

---@class (exact) Entity
---@field id entity_id
---@field name string
---@field file string

---@class ECS.src.Entity
local M = {}

---@type table<string, fun(self: Entity): any>
local index = {
	name = function(self)
		return EntityGetName(self.id)
	end,
	file = function(self)
		return EntityGetFilename(self.id)
	end,
}

---@type table<string, fun(self: Entity, value: any)>
local newindex = {
	name = function(self, value)
		value = typed.must(value, "string")
		EntitySetName(self.id, value)
	end,
	file = function(self)
		error("Entity file is readonly")
	end,
}

---@type metatable
local mt = {
	---@param self Entity
	---@param key any
	__index = function(self, key)
		if index[key] then return index[key](self) end
	end,
	---@param self Entity
	---@param key any
	---@param value any
	__newindex = function(self, key, value)
		if newindex[key] then return newindex[key](self, value) end
		error("cannot add fields to Entity")
	end,
	---@param self Entity
	__tostring = function(self)
		return ("<class Entity(%d)>"):format(self.id)
	end,
}

---@param entity_id entity_id
---@return Entity
function M.from_id(entity_id)
	return setmetatable({ id = entity_id }, mt)
end

return M

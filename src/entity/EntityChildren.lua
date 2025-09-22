local require = require
local freeze = require "src.utils.freeze"
local functional = require "src.utils.functional"
local metatable = require "src.utils.metatable"
local typed = require "src.utils.typed"

---@class (exact) EntityChildren
---@overload fun(): Entity?
---@field tagged fun(self: EntityChildren, tag: string): EntityChildren
---@field named fun(self: EntityChildren, name: string): EntityChildren

---@class (exact) ECS.EntityChildren : EntityChildren
---@field entity_id entity_id
---@field tag string?
---@field name string?
---@field children Entity[]?
---@field index integer

---@class ECS.EntityChildrenLib
local M = {}

---@type ECS.metatable.index
local index = {
	named = {
		function(self, name)
			name = typed.must(name, "string")
			self.name = name
			return self
		end,
	},
	tagged = {
		function(self, tag)
			tag = typed.must(tag, "string")
			self.tag = tag
			return self
		end,
	},
}

local newindex = {}

local transparent = { "children", "tag", "name" }
for _, v in pairs(transparent) do
	index[v] = function() end
	newindex[v] = function(self, value)
		rawset(self, v, value)
	end
end

local mt = metatable.metatable(index, newindex, "EntityChildren", function(self)
	---@cast self ECS.EntityChildren
	return ("%d%s%s"):format(
		self.entity_id,
		self.name and (" named " .. self.name) or "",
		self.tag and (" tagged " .. self.tag) or ""
	)
end, {
	---@param self ECS.EntityChildren
	---@return Entity?
	__call = function(self)
		if not self.children then
			-- must lazy load because otherwise we have a cycle
			local Entity = require "src.entity.Entity"
			local children
			if self.tag then
				children = EntityGetAllChildren(self.entity_id, self.tag)
			else
				-- absence of value != nil
				children = EntityGetAllChildren(self.entity_id)
			end
			children = functional.map(children or {}, Entity.from_id)
			if self.name then
				children = functional.filter(children, function(val)
					return val.name == self.name
				end)
			end
			self.children = children
		end
		self.index = self.index + 1
		return self.children[self.index]
	end,
})

---@param entity Entity
---@return EntityChildren
function M.from_entity(entity)
	return setmetatable({ entity_id = entity.id, index = 0 }, mt)
end

freeze.freeze(M, "ECS.EntityChildrenLib")

return M

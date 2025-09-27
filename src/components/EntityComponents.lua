local require = require
local Component = require "src.components.Component"
local freeze = require "src.utils.freeze"
local functional = require "src.utils.functional"
local metatable = require "src.utils.metatable"
local typed = require "src.utils.typed"

-- TODO: this needs to be generated
---@class (exact) SpecificComponents
---@overload fun(): Component?
---@field enabled fun(self: SpecificComponents, enabled: boolean): SpecificComponents
---@field tagged fun(self: SpecificComponents, tag: string): SpecificComponents
---@field with_field fun(self: SpecificComponents, field: string, value: any): SpecificComponents
---@field add fun(self: SpecificComponents, fields: table?): SpecificComponents

---@class (exact) ECS.SpecificComponents : SpecificComponents
---@field _entity Entity
---@field _type component_type
---@field _tag string?
---@field _enabled boolean?
---@field _index integer?
---@field _components Component[]?

---@class (exact) Components
---@field VariableStorage SpecificComponents

---@class (exact) ECS.Components : Components
---@field _entity Entity

---@class ECS.EntityComponentsLib
---@overload fun(component_id): Components
local M = {}

---@type ECS.metatable.index
local specific_index = {
	add = {
		---@param self ECS.SpecificComponents
		---@param fields table?
		---@return Component
		function(self, fields)
			fields = typed.maybe(fields, {})
			local comp = Component(EntityAddComponent2(self._entity.id, self._type, fields))
			if fields.tags then
				local tags = typed.must(fields.tags, "string")
				comp.tags = tags
			end
			return comp
		end,
	},
	tagged = {
		---@param self ECS.SpecificComponents
		---@param tag string
		---@return ECS.SpecificComponents
		function(self, tag)
			self._tag = tag
			return self
		end,
	},
}

---@type ECS.metatable.newindex
local specific_newindex = {}

local transparent = { "_components", "_index", "_tag", "_enabled" }
for _, v in pairs(transparent) do
	specific_index[v] = function() end
	specific_newindex[v] = function(self, value)
		rawset(self, v, value)
	end
end

local specific_mt = metatable.metatable(
	specific_index,
	specific_newindex,
	"ECS.SpecificComponents",
	function(self)
		return self._type
	end,
	{
		---@param self ECS.SpecificComponents
		---@return fun(): Component?
		__call = function(self)
			if not self._components then
				local comps
				if self._tag then
					comps = EntityGetComponent(self._entity.id, self._type, self._tag) or {}
				else
					comps = EntityGetComponent(self._entity.id, self._type) or {}
				end

				self._components = functional.map(comps, Component --[[@as function]])
				self._index = 0
			end
			self._index = self._index + 1
			if self._index > #self._components then return end
			return Component(self._components[self._index])
		end,
	}
)

local components_mt = metatable.metatable({}, {}, "Components", nil, {
	---@param self ECS.Components
	---@param index component_type
	---@return ECS.SpecificComponents
	__index = function(self, index)
		return setmetatable({ _entity = self._entity, _type = index .. "Component" }, specific_mt)
	end,
})

---@param entity Entity
---@return Components
function M.from_entity(entity)
	return setmetatable({ _entity = entity }, components_mt)
end

freeze.freeze(M, "ECS.EntityComponentsLib")
return M

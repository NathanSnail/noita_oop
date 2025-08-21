local typed = require "src.typed"

---@class (exact) mock.Entity
---@field children entity_id[]
---@field name string
---@field file string
---@field x number
---@field y number
---@field rotation number
---@field scale_x number
---@field scale_y number

---@class (exact) mock.EntityPartial
---@field children entity_id[]?
---@field name string?
---@field file string?
---@field x number?
---@field y number?
---@field rotation number?
---@field scale_x number?
---@field scale_y number?

---@type mock.Entity[]
local entities = {}
---@type entity_id
---@diagnostic disable-next-line: assign-type-mismatch
local entity_id_max = 1

---@param partial mock.EntityPartial
---@return mock.Entity
local function entity_defaults(partial)
	local defaults = {
		children = {},
		name = "",
		file = "",
		x = 0,
		y = 0,
		rotation = 0,
		scale_x = 1,
		scale_y = 1,
	}
	for k, v in pairs(defaults) do
		if partial[k] == nil then partial[k] = v end
	end
	---@diagnostic disable-next-line: cast-type-mismatch
	---@cast partial mock.Entity
	return partial
end

---@param name string?
---@return entity_id
function EntityCreateNew(name)
	entities[entity_id_max] = entity_defaults { children = {}, name = name }
	entity_id_max = entity_id_max + 1
	return entity_id_max - 1
end

---@param file string
---@param x number?
---@param y number?
---@return entity_id
function EntityLoad(file, x, y)
	local eid = EntityCreateNew("entity from file" .. file)
	EntitySetTransform(eid, typed.maybe(x, 0), typed.maybe(y, 0))
	entities[eid].file = file
	return eid
end

function EntitySetTransform(eid, x, y, rotation, scale_x, scale_y)
	entities[eid].x = x
	entities[eid].y = typed.maybe(y, 0)
	entities[eid].rotation = typed.maybe(rotation, 0)
	entities[eid].scale_x = typed.maybe(scale_x, 1)
	entities[eid].scale_y = typed.maybe(scale_y, 1)
end

function EntityGetTransform(eid)
	local entity = entities[eid]
	return entity.x, entity.y, entity.rotation, entity.scale_x, entity.scale_y
end

---@param entity_id entity_id
---@return string
function EntityGetFilename(entity_id)
	return entities[entity_id].file
end

---@param entity_id entity_id
---@return string
function EntityGetName(entity_id)
	return entities[entity_id].name
end

---@param entity_id entity_id
---@param name string
function EntitySetName(entity_id, name)
	entities[entity_id].name = name
end

local me = EntityCreateNew()
---@return entity_id
function GetUpdatedEntityID()
	return me
end

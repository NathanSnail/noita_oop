---@class (exact) mock.Entity
---@field children entity_id[]
---@field name string

---@type mock.Entity[]
local entities = {}
---@type entity_id
---@diagnostic disable-next-line: assign-type-mismatch
local entity_id_max = 1

function EntityCreateNew(name)
	entities[entity_id_max] = { children = {}, name = name or "" }
	entity_id_max = entity_id_max + 1
	return entity_id_max - 1
end

function EntityGetName(entity_id)
	return entities[entity_id].name
end

function EntitySetName(entity_id, name)
	entities[entity_id].name = name
end

local me = EntityCreateNew()
function GetUpdatedEntityID()
	return me
end

local functional = require "src.utils.functional"
local typed = require "src.utils.typed"

---@class (exact) mock.Entity
---@field children entity_id[]
---@field name string
---@field file string
---@field x number
---@field y number
---@field rotation number
---@field scale_x number
---@field scale_y number
---@field tags table<string, true>
---@field components table<string, component_id[]>

---@class (exact) mock.EntityPartial
---@field children entity_id[]?
---@field name string?
---@field file string?
---@field x number?
---@field y number?
---@field rotation number?
---@field scale_x number?
---@field scale_y number?
---@field tags table<string, true>?
---@field components component_id[]?

---@class (exact) mock.EntityComponent
---@field [string] any
---@field _ty string
---@field _tags table<string, true>

---@type mock.Entity[]
local entities = {}
---@type mock.EntityComponent[]
local components = {}
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
		tags = {},
		components = {},
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
	entities[entity_id_max] = entity_defaults { name = name }
	entity_id_max = entity_id_max + 1
	return entity_id_max - 1
end

---@param file string
---@param x number?
---@param y number?
---@return entity_id
function EntityLoad(file, x, y)
	local eid = EntityCreateNew("entity from file " .. file)
	EntitySetTransform(eid, typed.maybe(x, 0), typed.maybe(y, 0))
	entities[eid].file = file
	return eid
end

---@param eid entity_id
---@param x number
---@param y number
---@param rotation number
---@param scale_x number
---@param scale_y number
function EntitySetTransform(eid, x, y, rotation, scale_x, scale_y)
	entities[eid].x = x
	entities[eid].y = typed.maybe(y, 0)
	entities[eid].rotation = typed.maybe(rotation, 0)
	entities[eid].scale_x = typed.maybe(scale_x, 1)
	entities[eid].scale_y = typed.maybe(scale_y, 1)
end

---@param eid entity_id
---@return number
---@return number
---@return number
---@return number
---@return number
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

---@param entity_id entity_id
---@return entity_id | 0
function EntityGetParent(entity_id)
	for k, v in pairs(entities) do
		for _, child in ipairs(v.children) do
			if child == entity_id then return k end
		end
	end
	return 0
end

---@param entity_id entity_id
function EntityRemoveFromParent(entity_id)
	local old = EntityGetParent(entity_id)
	if old ~= 0 then
		local parent = entities[old]
		for k, child in ipairs(parent.children) do
			if child == entity_id then table.remove(parent.children, k) end
		end
	end
end

---@param parent_id entity_id
---@param child_id entity_id
function EntityAddChild(parent_id, child_id)
	EntityRemoveFromParent(child_id)
	table.insert(entities[parent_id].children, child_id)
end

---@param entity_id entity_id
---@return entity_id
function EntityGetRootEntity(entity_id)
	local parent = EntityGetParent(entity_id)
	if parent ~= 0 then
		---@cast parent entity_id
		return EntityGetRootEntity(parent)
	end
	return entity_id
end

---@param entity_id entity_id
---@param tag string?
function EntityGetAllChildren(entity_id, tag)
	local children = entities[entity_id].children
	if tag then
		return functional.filter(children, function(val)
			return EntityHasTag(val, tag)
		end)
	end
	return children
end

---@param entity_id entity_id
---@param tag string
---return bool
function EntityHasTag(entity_id, tag)
	return entities[entity_id].tags[tag] == true
end

---@param entity_id entity_id
---@param tag string
function EntityAddTag(entity_id, tag)
	entities[entity_id].tags[tag] = true
end

---@param entity_id entity_id
---@param tag string
function EntityRemoveTag(entity_id, tag)
	entities[entity_id].tags[tag] = nil
end

---@param entity_id string
---@return string
function EntityGetTags(entity_id)
	local s = ""
	for tag, _ in pairs(entities[entity_id].tags) do
		s = s .. "," .. tag
	end
	return s:sub(2)
end

local me = EntityCreateNew()
---@return entity_id
function GetUpdatedEntityID()
	return me
end

---@param entity_id entity_id
---@param component_type_name component_type
---@param tag string? '""'
---@return component_id[]|nil
---@nodiscard
function EntityGetComponent(entity_id, component_type_name, tag)
	local entity = entities[entity_id]
	local entity_components = entity.components[component_type_name]
	local res = {}
	for _, component in ipairs(entity_components) do
		if tag == nil or components[component]._tags[tag] then table.insert(res, component) end
	end
	return res
end

---@param entity_id entity_id
---@param component_type_name component_type
---@param table_of_component_values {[string]:any}? nil
---@return component_id
function EntityAddComponent2(entity_id, component_type_name, table_of_component_values)
	table_of_component_values._ty = component_type_name
	table.insert(components, table_of_component_values)
	local entity = entities[entity_id]
	entity.components[component_type_name] = entity.components[component_type_name] or {}
	table.insert(entity.components[component_type_name], #components)
	---@diagnostic disable-next-line: return-type-mismatch
	return #components
end

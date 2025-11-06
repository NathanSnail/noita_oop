local require = require
local freeze = require "src.utils.freeze"
local metatable = require "src.utils.metatable"
local typed = require "src.utils.typed"

---@class (exact) Tags
---@overload fun(): string?
---@field [string] boolean

---@class ECS.TagsLib
local M = {}

---Makes the setter for `whatever.tags`
---@param self any
---@param value any
M.new_index = function(self, value)
	for tag in self.tags do
		self.tags[tag] = false
	end
	if type(value) == "string" then
		for tag in value:gmatch("[^,]+") do
			self.tags[tag] = true
		end
		return
	end
	value = typed.must(value, "table")
	for tag in value do
		self.tags[tag] = true
	end
end

---Makes the metatable for `whatever.tags`
---`self[1]` must return the backing table used for iterators
---@param get any
---@param add any
---@param remove any
---@param has any
---@return metatable
function M.make_tags_mt(get, add, remove, has)
	local mt = metatable.metatable(nil, nil, "Tags", function(self)
		---@cast self ECS.EntityTags
		return get(self)
	end, {
		---@param self ECS.EntityTags
		---@param index any
		__index = function(self, index)
			index = typed.must(index, "string")
			return has(self, index)
		end,
		---@param self ECS.EntityTags
		---@param index any
		---@param value any
		__newindex = function(self, index, value)
			index = typed.must(index, "string")
			value = typed.must(value, "boolean")
			if value then
				add(self, index)
			else
				remove(self, index)
			end
		end,
		---@param self ECS.EntityTags
		---@return string?
		__call = function(self)
			local backing = self[1]
			if not backing.tags then
				backing.tags = {}
				for tag in get(self):gmatch("[^,]+") do
					table.insert(backing.tags, tag)
				end
			end
			backing.index = backing.index + 1
			return backing.tags[backing.index]
		end,
	})

	return mt
end

freeze.freeze(M, "ECS.TagsLib")
return M

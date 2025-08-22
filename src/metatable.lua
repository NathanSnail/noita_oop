local require = require
local null = require "src.null"

local freeze = require "src.freeze"
local typed = require "src.typed"
---@class ECS.metatable
local M = {}

---@alias ECS.metatable.index table<string, (fun(self: table): any) | (fun(...): any)[]>
---@alias ECS.metatable.newindex table<string, fun(self: table, value: any)>

---@generic T
---@param index ECS.metatable.index
---@param newindex ECS.metatable.newindex
---@param name `T`
---@param info (fun(self: T): string?)?
---@param default_mt metatable?
---@return metatable
function M.metatable(index, newindex, name, info, default_mt)
	info = typed.maybe(info, function() end)
	default_mt = typed.maybe(default_mt, {})
	-- luals cant handle my type nonsense :(
	---@cast info fun(self: table): string?

	---@param self table
	---@return string
	local function get_name(self)
		local extra = info(self)
		if extra then
			extra = ("(%s)"):format(extra)
		else
			extra = ""
		end
		return ("<class %s%s>"):format(name, extra)
	end

	local function do_index(index_table, self, key)
		local indexed = index_table[key]
		if indexed then
			if type(indexed) == "function" then
				return indexed(self)
			else
				return indexed[1]
			end
		end
		return null
	end

	---@type metatable
	local mt = {
		---@param self table
		---@param key any
		__index = function(self, key)
			local result = do_index(index, self, key)
			if result ~= null then return result end
			error(("Field %s does not exist in %s"):format(key, get_name(self)))
		end,
		---@param self table
		---@param key any
		---@param value any
		__newindex = function(self, key, value)
			if newindex[key] then
				newindex[key](self, value)
				return
			end
			error(("Cannot add fields to %s"):format(get_name(self)))
		end,
		---@param self table
		__tostring = function(self)
			return get_name(self)
		end,
		---@param self any
		---@param other any
		__eq = function(self, other)
			if type(self) ~= type(other) then return false end
			for k, v in pairs(self) do
				if v ~= other[k] then return false end
			end
			return true
		end,
	}

	for k, v in pairs(default_mt) do
		mt[k] = v
	end

	return mt
end

freeze.freeze(M, "ECS.metatable")
return M

local require = require
local null = require "src.utils.null"
local freeze = require "src.utils.freeze"
local typed = require "src.utils.typed"

---@class ECS.metatable
local M = {}

---@alias ECS.metatable.index table<string, (fun(self: table): any) | (fun(...): any)[]>
---@alias ECS.metatable.newindex table<string, fun(self: table, value: any)>

---If `__index` or `__newindex` is in defaults it is only applied if `index == nil` or `newindex == nil`
---@generic T
---@param index ECS.metatable.index? if nil then `__index` must be set
---@param newindex ECS.metatable.newindex? if nil then `__newindex` must be set
---@param name `T`
---@param info (fun(self: T): string?)?
---@param default_mt metatable? only works as a default if that field isn't set
---@return metatable
function M.metatable(index, newindex, name, info, default_mt)
	info = typed.maybe(info, function() end)
	default_mt = typed.maybe(default_mt, {})
	---@cast default_mt metatable
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
			---@cast newindex -?
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

	if not index then
		mt.__index = default_mt.__index
	end
	if not newindex then
		mt.__newindex = default_mt.__newindex
	end

	for k, v in pairs(default_mt) do
		mt[k] = mt[k] or v
	end

	return mt
end

freeze.freeze(M, "ECS.metatable")
return M

local freeze = require "src.freeze"
local typed = require "src.typed"
---@class ECS.metatable
local M = {}

---@generic T
---@param index table<string, fun(self: T): any>
---@param newindex table<string, fun(self: T, value: any)>
---@param name `T`
---@param info (fun(self: T): string?)?
---@return metatable
function M.metatable(index, newindex, name, info)
	typed.maybe(info, function() end)
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

	---@type metatable
	local mt = {
		---@param self table
		---@param key any
		__index = function(self, key)
			if index[key] then return index[key](self) end
			error(("Field %s does not exist in %s"):format(key, get_name(self)))
		end,
		---@param self table
		---@param key any
		---@param value any
		__newindex = function(self, key, value)
			if newindex[key] then return newindex[key](self, value) end
			error(("Cannot add fields to %s"):format(get_name(self)))
		end,
		---@param self table
		__tostring = function(self)
			return get_name(self)
		end,
	}

	return mt
end

freeze.freeze(M, "ECS.metatable")
return M

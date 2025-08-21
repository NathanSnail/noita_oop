local require = require

local freeze = require "src.freeze"
local typed = require "src.typed"
---@class ECS.metatable
local M = {}

---@alias ECS.metatable.index table<string, (fun(self: table): any) | (fun(...): any)[]>
---@alias ECS.metatable.newindex table<string, fun(self: table, value: any)>

---@generic T
---@param index ECS.metatable.index | {[1]: ECS.metatable.index, [integer]: string}
---@param newindex ECS.metatable.newindex | {[1]: ECS.metatable.newindex, [integer]: string}
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

	local function do_index(index_table, self, key)
		local indexed = index_table[key]
		if indexed then
			if type(indexed) == "function" then
				return indexed(self)
			else
				return indexed[1]
			end
		end
	end

	---@type metatable
	local mt = {
		---@param self table
		---@param key any
		__index = function(self, key)
			if #index > 1 then
				for k, index_subfield in ipairs(index) do
					if k == 1 then
						local result = do_index(index_subfield, self, key)
						if result ~= nil then return result end
					else
						local result = self[index_subfield][key]
						if result ~= nil then return result end
					end
				end
			else
				local result = do_index(index, self, key)
				if result ~= nil then return result end
			end
			error(("Field %s does not exist in %s"):format(key, get_name(self)))
		end,
		---@param self table
		---@param key any
		---@param value any
		__newindex = function(self, key, value)
			if #newindex > 1 then
				for k, newindex_subfield in ipairs(newindex) do
					if k == 1 then
						local first = newindex[1]
						if first[key] then return first[key](self, value) end
					else
						-- TODO: make this work with more than 2, currently throws
						self[newindex_subfield][key] = value
						return
					end
				end
			else
				if newindex[key] then return newindex[key](self, value) end
			end
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

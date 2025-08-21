local M = {}

---Freezes a table and returns it, table must not already have a metatable
---@generic T : table
---@param t T
---@param name string
---@return T
function M.freeze(t, name)
	---@type metatable
	local mt = {
		__newindex = function()
			error(("Cannot add fields to <class %s>"):format(name))
		end,
		__tostring = function()
			return ("<class %s>"):format(name)
		end,
	}
	return setmetatable(t, mt)
end

return M

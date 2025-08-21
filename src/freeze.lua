local M = {}

---Freezes a table and returns it, table must not already have a metatable
---@generic T : table
---@param t T
---@param name string
---@param mt_defaults metatable?
---@return T
function M.freeze(t, name, mt_defaults)
	mt_defaults = mt_defaults or {}
	---@type metatable
	local mt = {
		__newindex = function()
			error(("Cannot add fields to <class %s>"):format(name))
		end,
		__tostring = function()
			return ("<class %s>"):format(name)
		end,
	}
	for k, v in pairs(mt_defaults) do
		if mt[k] == nil then mt[k] = v end
	end
	return setmetatable(t, mt)
end

return M

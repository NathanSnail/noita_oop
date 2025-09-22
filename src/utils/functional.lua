local require = require
local freeze = require "src.utils.freeze"

---@class ECS.functional
local M = {}

---@generic T, U
---@param t T[]
---@param f fun(val: T): U
---@return U[]
function M.map(t, f)
	local new = {}
	for k, v in ipairs(t) do
		new[k] = f(v)
	end
	return new
end

---@generic T
---@param t T[]
---@param f fun(val: T): boolean
---@return T[]
function M.filter(t, f)
	local new = {}
	for _, v in ipairs(t) do
		if f(v) then table.insert(new, v) end
	end
	return new
end

freeze.freeze(M, "ECS.functional")

return M

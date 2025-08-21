local require = require

---@class typed
local M = {}

---@generic T
---@param value any
---@param ty `T`
---@return T
function M.must(value, ty)
	if type(value) ~= ty then
		error(
			("Attempt to assign value %s of type %s to field of type %s"):format(
				tostring(value),
				type(value),
				ty
			)
		)
	end
	return value
end

---@generic T
---@param value any
---@param default T
---@return T
function M.maybe(value, default)
	if value == nil then return default end
	if type(value) ~= type(default) then
		error(
			("Attempt to assign value %s of type %s to field of type %s"):format(
				tostring(value),
				type(value),
				type(default)
			)
		)
	end
	return value
end

return M

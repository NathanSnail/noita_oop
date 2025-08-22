local freeze = require "src.freeze"

---@type metatable
local mt = {
	__unm = function(_)
		-- null is false
		return false
	end,
}

return freeze.freeze({}, "null", mt)

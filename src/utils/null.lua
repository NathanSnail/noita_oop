local require = require
local freeze = require "src.utils.freeze"

---@type metatable
local mt = {
	__unm = function(_)
		-- null is false
		return false
	end,
}

---@class (exact) ECS.null
local M = {}
freeze.freeze(M, "null", mt)
return M

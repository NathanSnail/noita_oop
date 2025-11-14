local require = require
local freeze = require "src.utils.freeze"

---@class (exact) ECS.null
local M = {}

---@type metatable
local mt = {
	__unm = function(_)
		-- null is false
		return false
	end,
}

freeze.freeze(M, "null", mt)
return M

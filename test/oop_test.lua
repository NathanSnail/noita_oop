local test = require "test.test"

require "test.mock.ecs"

local ecs = require "lib"

test.test {
	{
		name = "Entity name",
		body = function()
			ecs.me.name = "fish"
			test.eq(ecs.me.name, "fish")
		end,
	},
}

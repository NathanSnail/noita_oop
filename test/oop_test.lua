local Vec2 = require "src.Vec2"
local test = require "test.test"

require "test.mock.ecs"

local ecs = require "ECS"

test.test {
	{
		name = "Entity name",
		body = function()
			ecs.me.name = "fish"
			test.eq(ecs.me.name, "fish")
		end,
	},
	{
		name = "Entity creation",
		body = function()
			local entity = ecs.load("something")
			test.eq(entity.file, "something")
		end,
	},
	{
		name = "Position getting",
		body = function()
			local entity = ecs.load("something", 100, 200)
			test.eq(entity.transform.pos.x, 100)
		end,
	},
	{
		name = "Position field setting",
		body = function()
			local entity = ecs.load("something", 100, 200)
			entity.transform.pos.x = -1
			test.eq(entity.transform.pos.x, -1)
		end,
	},
	{
		name = "Position vec setting",
		body = function()
			local entity = ecs.load("something", 100, 200)
			entity.transform.pos = Vec2 { x = 20, y = 0 }
			test.eq(entity.transform.pos.x, 20)
		end,
	},
}

local Vec2 = require "src.Vec2"
local test = require "test.test"

require "test.mock.ecs"
local ecs = require "src.ECS"

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
	{
		name = "Scale vec setting",
		body = function()
			local entity = ecs.load("something", 100, 200)
			entity.transform.scale = Vec2 { x = 5, y = 4 }
			test.eq(entity.transform.scale.x, 5)
		end,
	},
	{
		name = "Transform rotation getting",
		body = function()
			local entity = ecs.load("something", 100, 200, 180)
			test.eq(entity.transform.rotation, 180)
		end,
	},
	{
		name = "Transform rotation setting",
		body = function()
			local entity = ecs.load("something", 100, 200, 180)
			entity.transform.rotation = 0
			test.eq(entity.transform.rotation, 0)
		end,
	},
}

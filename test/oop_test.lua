local Entity = require "src.entity.Entity"
local Transform = require "src.Transform"
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
	{
		name = "Entity rotation getting",
		body = function()
			local entity = ecs.load("something", 100, 200, 180)
			test.eq(entity.rotation, 180)
		end,
	},
	{
		name = "Entity rotation setting",
		body = function()
			local entity = ecs.load("something", 100, 200, 180)
			entity.rotation = 0
			test.eq(entity.transform.rotation, 0)
		end,
	},
	{
		name = "Entity call constructor",
		body = function()
			local entity = ecs.load("something", 100, 200, 180)
			local entity2 = Entity(entity.id)
			entity2.pos.x = 0
			test.eq(entity.pos.x, 0)
		end,
	},
	{
		name = "Entity transform assign",
		body = function()
			local entity = ecs.load("something", 100, 200, 180)
			local entity2 = ecs.load("something", 0, 0)
			entity.transform = entity2.transform
			test.eq(entity.pos.x, 0)
		end,
	},
	{
		name = "Transform construct",
		body = function()
			local entity = ecs.load("something", 100, 200, 180, 0, 0)
			local transform = Transform { pos = { x = 0, y = 20 }, rotation = -1 }
			entity.transform = transform
			test.eq(entity.pos.x, 0)
			test.eq(entity.rotation, -1)
			test.eq(entity.scale.x, 1)
		end,
	},
	{
		name = "Vector arithmetic",
		body = function()
			local v1 = Vec2.xy(3, 4)
			local v2 = Vec2.xy(0, 1)
			local v3 = v1 + v2
			test.eq(v3.y, 5)
			local v4 = v1 - v2
			test.eq(v4.y, 3)
			local v5 = v1 * 2
			test.eq(v5.x, 6)
			local v6 = v1 / 2
			test.eq(v6.y, 2)
			local v7 = -v1
			test.eq(v7.y, -4)
		end,
	},
	{
		name = "Entity parent get / set",
		body = function()
			local child = ecs.load("file")
			local parent = ecs.load("file2")
			test.eq(child.parent, nil)
			child.parent = parent
			test.eq(child.parent, parent)
		end,
	},
	{
		name = "Entity unparent",
		body = function()
			local child = ecs.load("file")
			local parent = ecs.load("file2")
			child.parent = parent
			child.parent = nil
			test.eq(child.parent, nil)
		end,
	},
	{
		name = "Entity root",
		body = function()
			local child = ecs.load("file")
			local parent = ecs.load("file2")
			local parent2 = ecs.load("file3")
			child.parent = parent
			parent.parent = parent2
			test.eq(child.root, parent2)
		end,
	},
	{
		name = "Entity equality",
		body = function()
			local child = ecs.load("file")
			local copy = Entity(child.id)
			test.eq(child == copy, true)
		end,
	},
	{
		name = "Transform equality",
		body = function()
			local ctor = { pos = { x = 4, y = 3 }, rotation = 4, scale = { x = 4, y = 5 } }
			local transform1 = Transform(ctor)
			local transform2 = Transform(ctor)
			test.eq(transform1 == transform2, true)
		end,
	},
	{
		name = "Entity get child",
		body = function()
			local parent = ecs.load("file")
			local child = ecs.load("file")
			child.parent = parent
			test.eq(parent.children(), child)
		end,
	},
	{
		name = "Named children",
		body = function()
			local parent = ecs.load("file")
			local child1 = ecs.load("a")
			child1.parent = parent
			local child2 = ecs.load("a")
			child2.parent = parent
			local child3 = ecs.load("b")
			child3.parent = parent
			local counter = 0
			for _ in parent.children:named("entity from file a") do
				counter = counter + 1
			end
			test.eq(counter, 2)
		end,
	},
	{
		name = "Tag get / set",
		body = function()
			local entity = ecs.load("file")
			entity.tags["foo"] = true
			test.eq(entity.tags["foo"], true)
		end,
	},
	{
		name = "Tag iterate",
		body = function()
			local entity = ecs.load("file")
			entity.tags["foo"] = true
			entity.tags["bar"] = true
			entity.tags["baz"] = true
			local counter = 0
			for _ in entity.tags do
				counter = counter + 1
			end
			test.eq(counter, 3)
		end,
	},
	{
		name = "Tag remove",
		body = function()
			local entity = ecs.load("file")
			entity.tags["foo"] = true
			entity.tags["foo"] = false
			test.eq(entity.tags["foo"], false)
		end,
	},
	{
		name = "Tag copy",
		body = function()
			local entity = ecs.load("file")
			local entity2 = ecs.load("file")
			entity.tags["foo"] = true
			entity2.tags = entity.tags
			test.eq(entity2.tags["foo"], true)
		end,
	},
	{
		name = "Tag set",
		body = function()
			local entity = ecs.load("file")
			entity.tags = "foo,bar,baz"
			local counter = 0
			for _ in entity.tags do
				counter = counter + 1
			end
			test.eq(counter, 3)
		end,
	},
	{
		name = "Components iterate",
		body = function()
			local entity = ecs.load("file")
			entity.components.VariableStorage:add()
			entity.components.VariableStorage:add()
			entity.components.VariableStorage:add()
			local counter = 0
			for _ in entity.components.VariableStorage do
				counter = counter + 1
			end
			test.eq(counter, 3)
		end,
	},
}

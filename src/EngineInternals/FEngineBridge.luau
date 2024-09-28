--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local Utilities = require(ReplicatedFirst.EngineLibraries.Utilities)
local factory = {}

function factory.new<T>(events: { InternalTypeDefinitions.FEngineEvent})
	assert(typeof(events) == "table", "events must be a table.")

	return Utilities.ForceCast(setmetatable({
		packet = moduleName,
		LoadOrder = moduleLoadOrder,
	}, {
		__index = functionTable,
	})) :: T
end

return factory

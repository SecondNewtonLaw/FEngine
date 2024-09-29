--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local Utilities = require(ReplicatedFirst.EngineLibraries.Utilities)
local factory = {}

function factory.new<T>(bridgeName: string, functionTable: InternalTypeDefinitions.FEngineBridgeFunctionTable<T>)
	assert(typeof(bridgeName) == "string", "brdigeName must be a string.")
	assert(typeof(functionTable) == "table", "functionTable must be a table.")

	return Utilities.ForceCast(setmetatable({
		BridgeName = bridgeName,
	}, {
		__index = functionTable,
	})) :: T
end

return factory

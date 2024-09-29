--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local Utilities = require(ReplicatedFirst.EngineLibraries.Utilities)
local factory = {}

function factory.new<T>(moduleName: string, functionTable: InternalTypeDefinitions.FEngineModuleFunctionTable<T>)
	assert(typeof(moduleName) == "string", "moduleName must be a string.")
	assert(typeof(functionTable) == "table", "functionTable must be a table.")

	return Utilities.ForceCast(setmetatable({
		ModuleName = moduleName,
	}, {
		__index = functionTable,
	})) :: T
end

return factory

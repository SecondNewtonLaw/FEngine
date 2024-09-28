--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local Utilities = require(ReplicatedFirst.EngineLibraries.Utilities)
local factory = {}

function factory.new<T>(
	moduleName: string,
	moduleLoadOrder: number,
	functionTable: InternalTypeDefinitions.FEngineModuleFunctionTable<T>
)
	assert(typeof(moduleName) == "string", "moduleName must be a string.")
	assert(typeof(moduleLoadOrder) == "number", "moduleLoadOrder must be a number.")
	assert(typeof(functionTable) == "table", "functionTable must be a table.")

	return Utilities.ForceCast(setmetatable({
		ModuleName = moduleName,
		LoadOrder = moduleLoadOrder,
	}, {
		__index = functionTable,
	})) :: T
end

return factory

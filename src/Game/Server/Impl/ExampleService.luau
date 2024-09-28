--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local FEngineModule = require(ReplicatedFirst.EngineInternals.FEngineModule)
local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)

type ExampleService = {
	Hello: string,
	Number: number,
}

local vftable = {
	Initialize = function(
		self: InternalTypeDefinitions.FEngineModuleFunctionTable<ExampleService>,
		FEngineServiceProvider: InternalTypeDefinitions.FEngineServiceProvider
	)
		print(self.Hello) -- Values Uninitialized
		print(self.Number)
	end,
}

local fengine = FEngineModule.new(
	"ExampleService",
	0,
	vftable :: InternalTypeDefinitions.FEngineModuleFunctionTable<ExampleService>
) :: ExampleService

return fengine

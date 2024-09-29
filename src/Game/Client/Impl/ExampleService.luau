--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local GameTypes = require(ReplicatedFirst.Common.GameTypes)
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
		local bridge =
			FEngineServiceProvider:GetBridge("ExampleBridge") :: { SetSprint: (self: unknown, packet: GameTypes.SetSprintPacket) -> () }
		warn("Loaded ExampleService on Client!")
		warn("Attempting to sprint in 5 seconds...")
		task.wait(5)
		bridge:SetSprint({ newMode = true })
		warn("Attempting to walk in 5 seconds...")
		task.wait(5)
		bridge:SetSprint({ newMode = false })
		print("Nil should print after this")
		print(self.Hello) -- Values Uninitialized
		print(self.Number)
	end,
}

local fengine = FEngineModule.new(
	"ExampleService",
	vftable :: InternalTypeDefinitions.FEngineModuleFunctionTable<ExampleService>
) :: ExampleService

return fengine

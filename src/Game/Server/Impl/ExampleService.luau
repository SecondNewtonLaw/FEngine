--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local GameTypes = require(ReplicatedFirst.Common.GameTypes)
local FEngineModule = require(ReplicatedFirst.EngineInternals.FEngineModule)
local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local Instance = require(ReplicatedFirst.EngineLibraries.Wrappers.Instance)
local Players = require(ReplicatedFirst.EngineLibraries.Wrappers.Players)

type ExampleService = {
	Hello: string,
	Number: number,
}

local vftable = {
	Initialize = function(
		self: InternalTypeDefinitions.FEngineModuleFunctionTable<ExampleService>,
		FEngineServiceProvider: InternalTypeDefinitions.FEngineServiceProvider
	)
		warn("Loaded ExampleService on Server!")
		local bridge = FEngineServiceProvider:GetBridge("ExampleBridge") :: {
			Events: { SetSprint: InternalTypeDefinitions.FEngineEvent<GameTypes.SetSprintPacket> },
			SetSprint: (self: unknown, packet: GameTypes.SetSprintPacket) -> (),
		}

		bridge.Events.SetSprint:OnServer(function(player: Player, packet)
			print(packet)
			warn("New Mode: ", packet.newMode)

			local character = Players:GetCharacterOfPlayer(player)
			local humanoid =
				Instance.wrap(Instance.wrap(character):WaitForChildOfClass("Humanoid", 10) :: Humanoid)

			if not humanoid then
				warn("no humanoid found")
				return
			end

			humanoid.WalkSpeed = if packet.newMode then 50 else 16
		end)

		warn("Attempting to connect to PlayerAdded")

		Players:OnPlayerAdded(function(player: Player)
			print("Hello! " .. player:GetFullName())
		end)
	end,
}

local fengine = FEngineModule.new(
	"ExampleServerService",
	vftable :: InternalTypeDefinitions.FEngineModuleFunctionTable<ExampleService>
) :: ExampleService

return fengine

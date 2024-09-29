--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local GameTypes = require(ReplicatedFirst.Common.GameTypes)
local SetSprintPacket = require(ReplicatedFirst.Common.Structures.SetSprintPacket)
local FEngineBridge = require(ReplicatedFirst.EngineInternals.FEngineBridge)
local FEngineEvent = require(ReplicatedFirst.EngineInternals.FEngineEvent)
local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)

local bridge = {
	BridgeName = "",
}

do
	function bridge:Initialize()
		bridge.Events = {
			SetSprint = FEngineEvent.new({ Name = "SetSprint", Unreliable = false }, SetSprintPacket),
		}
	end
end

function bridge:SetSprint(SetSprintPacket: GameTypes.SetSprintPacket)
	bridge.Events.SetSprint:FireServer(SetSprintPacket)
end

return FEngineBridge.new("ExampleBridge", bridge :: InternalTypeDefinitions.FEngineBridgeFunctionTable<{}>)

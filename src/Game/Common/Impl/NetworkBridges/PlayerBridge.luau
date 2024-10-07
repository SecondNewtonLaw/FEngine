--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local GameTypes = require(ReplicatedFirst.Common.GameTypes)
local SetSprintPacket = require(ReplicatedFirst.Common.Structures.SetSprintPacket)
local FEngineBridge = require(ReplicatedFirst.EngineInternals.FEngineBridge)
local FEngineEvent = require(ReplicatedFirst.EngineInternals.FEngineEvent)
local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)

local bridge = {
	BridgeName = "PlayerBridge",
}

do
	function bridge:Initialize()
		bridge.Events = {
			SetSprint = FEngineEvent.new({ Name = "SetSprint", Unreliable = false }, nil),
		}
	end

	function bridge:SetSprint(packet: GameTypes.SetSprintPacket)
		bridge.Events.SetSprint:Fire(packet)
	end
end

return FEngineBridge.new(
	"PlayerBridge",
	bridge :: InternalTypeDefinitions.FEngineBridgeFunctionTable<GameTypes.PlayerBridge>
)

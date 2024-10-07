local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local TypeDefinitions = require(ReplicatedFirst.EngineLibraries.TypeDefinitions)
local camerashaker = require(ReplicatedStorage.Packages.camerashaker)

export type UIStatusService = {}

export type MovementService = {
	PlayerBridge: PlayerBridge,
	CameraShaker: typeof(camerashaker.new(0, function(mCFrame: CFrame) end)),

	SetSprint: (self: MovementService, enableSprint: boolean) -> (),
}

export type SetSprintPacket = {
	newMode: boolean,
}

export type PlayerBridge = {
	Events: {
		SetSprint: InternalTypeDefinitions.FEngineEvent<SetSprintPacket>,
	},
	SetSprint: (self: PlayerBridge, packet: SetSprintPacket) -> (),
} & InternalTypeDefinitions.FEngineBridgeFunctionTable<unknown>

export type SetSprintPacketFactory =
	{}
	& InternalTypeDefinitions.Serializable<SetSprintPacket>
	& TypeDefinitions.Creatable<SetSprintPacket, boolean>

return {}

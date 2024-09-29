local ReplicatedFirst = game:GetService("ReplicatedFirst")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local TypeDefinitions = require(ReplicatedFirst.EngineLibraries.TypeDefinitions)
export type SetSprintPacket = {
	newMode: boolean,
}
export type SetSprintPacketFactory =
	{}
	& InternalTypeDefinitions.Serializable<SetSprintPacket>
	& TypeDefinitions.Creatable<SetSprintPacket, boolean>

return {}

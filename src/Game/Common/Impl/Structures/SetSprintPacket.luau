--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameTypes = require(ReplicatedFirst.Common.GameTypes)
local squash = require(ReplicatedStorage.Packages.squash)
local struct = {}

function struct.new(newStatus: boolean)
	local self = { newMode = newStatus } :: GameTypes.SetSprintPacket
	return self
end

function struct.Serialize(packet: GameTypes.SetSprintPacket): buffer
	local cursor = squash.cursor(1, 0)
	squash.boolean().ser(cursor, packet.newMode)

	return cursor.Buf
end

function struct.Deserialize(buf: buffer): GameTypes.SetSprintPacket
	local cursor = squash.frombuffer(buf)
	local bool = squash.boolean().des(cursor)

	return struct.new(bool)
end

return struct

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local red = require(ReplicatedStorage.Packages.red)

local FEngineEvent = {}

function FEngineEvent.new<T>(
	eventName: InternalTypeDefinitions.FEngineEventOptions,
	structDeserializer: InternalTypeDefinitions.Serializable<T>
)
	local backingEvent = red.SharedSignalEvent(eventName, function(...)
		assert(select("#", ...) == 1, "expected an argument count of 1")
		assert(typeof(select(1, ...)) == "buffer", "expected argument one to be a buffer")

		return structDeserializer.Deserialize(select(1, ...))
	end)

	local engineEvent = {}

	engineEvent.FireAllClients = function(self, a: T)
		assert(typeof(a) ~= "nil", "no second argument provided. Did you use an index instead of a namecall?")
		backingEvent.FireAllClients(backingEvent, structDeserializer.Serialize(a))
	end

	engineEvent.FireClient = function(self, player: Player, a: T)
		assert(typeof(a) ~= "nil", "no third argument provided. Did you use an index instead of a namecall?")
		backingEvent.FireClient(backingEvent, player, structDeserializer.Serialize(a))
	end

	engineEvent.FireAllClientsExcept = function(self, player: Player, a: T)
		assert(typeof(a) ~= "nil", "no third argument provided. Did you use an index instead of a namecall?")
		backingEvent.FireAllClientsExcept(backingEvent, player, structDeserializer.Serialize(a))
	end

	engineEvent.FireClients = function(self, players: { Player }, a: T)
		assert(typeof(a) ~= "nil", "no third argument provided. Did you use an index instead of a namecall?")
		backingEvent.FireClients(backingEvent, players, structDeserializer.Serialize(a))
	end

	engineEvent.FireFilteredClients = function(self, filter: (Player) -> boolean, a: T)
		assert(typeof(a) ~= "nil", "no third argument provided. Did you use an index instead of a namecall?")
		backingEvent.FireFilteredClients(backingEvent, filter, structDeserializer.Serialize(a))
	end

	engineEvent.FireServer = function(self, a: T)
		assert(typeof(a) ~= "nil", "no second argument provided. Did you use an index instead of a namecall?")
		backingEvent.FireServer(backingEvent, structDeserializer.Serialize(a))
	end

	engineEvent.OnServer = function(self, callback: (player: Player, packet: T) -> ()): RBXScriptConnection
		assert(
			typeof(callback) == "function",
			"second argument is not a closure. Did you use an index instead of a namecall or sent the wrong parameter?"
		)

		local disconnector = backingEvent.OnServer(backingEvent, function(player, arg)
			callback(player, structDeserializer.Deserialize(arg))
		end)

		return (
			{
				Disconnect = function(self: RBXScriptConnection)
					self.Connected = false
					return disconnector.Disconnect()
				end,
			} :: any
		) :: RBXScriptConnection
	end

	engineEvent.OnClient = function(self, callback: (packet: T) -> ()): RBXScriptConnection
		assert(
			typeof(callback) == "function",
			"second argument is not a closure. Did you use an index instead of a namecall or sent the wrong parameter?"
		)

		local disconnector = backingEvent.OnClient(backingEvent, function(arg)
			callback(structDeserializer.Deserialize(arg))
		end)

		return (
			{
				Disconnect = function(self: RBXScriptConnection)
					self.Connected = false
					return disconnector.Disconnect()
				end,
			} :: any
		) :: RBXScriptConnection
	end

	return engineEvent
end

return FEngineEvent

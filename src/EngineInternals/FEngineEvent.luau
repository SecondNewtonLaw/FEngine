local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local red = require(ReplicatedStorage.Packages.red)

local FEngineEvent = {}

--[[
	FEngineEvent<T, U...>, type T is discarded :)

	if structDeserializer is nil, then any argument may be passed, regardless.
	if structDeserializer is a table, then the input will be checked to be a buffer.
	if structDeserializer is a function, then the input will be passed to the function for validation.
]]

function FEngineEvent.new<T, U...>(
	eventName: InternalTypeDefinitions.FEngineEventOptions,
	structDeserializer: InternalTypeDefinitions.Serializable<T>? | (U...) -> U...
)
	local backingEvent = red.SharedSignalEvent(eventName, function(...)
		if typeof(structDeserializer) == "table" then
			assert(select("#", ...) == 1, "expected an argument count of 1")
			assert(typeof(select(1, ...)) == "buffer", "expected argument one to be a buffer")

			return structDeserializer.Deserialize(select(1, ...))
		elseif typeof(structDeserializer) == "function" then
			return structDeserializer(...)
		end

		return ...
	end)

	local engineEvent = {}

	engineEvent.FireAllClients = function(self, ...)
		assert(
			select("#", ...) ~= 0,
			"no second argument/arguments provided. Did you use an index instead of a namecall?"
		)

		backingEvent.FireAllClients(
			backingEvent,
			if typeof(structDeserializer) == "table" then structDeserializer.Serialize(select(1, ...)) else ...
		)
	end

	engineEvent.FireClient = function(self, player: Player, ...)
		assert(
			select("#", ...) ~= 0,
			"no third argument/arguments provided. Did you use an index instead of a namecall?"
		)
		backingEvent.FireClient(
			backingEvent,
			player,
			if typeof(structDeserializer) == "table" then structDeserializer.Serialize(select(1, ...)) else ...
		)
	end

	engineEvent.FireAllClientsExcept = function(self, player: Player, ...)
		assert(
			select("#", ...) ~= 0,
			"no third argument/arguments provided. Did you use an index instead of a namecall?"
		)
		backingEvent.FireAllClientsExcept(
			backingEvent,
			player,
			if typeof(structDeserializer) == "table" then structDeserializer.Serialize(select(1, ...)) else ...
		)
	end

	engineEvent.FireClients = function(self, players: { Player }, ...)
		assert(
			select("#", ...) ~= 0,
			"no third argument/arguments provided. Did you use an index instead of a namecall?"
		)
		backingEvent.FireClients(
			backingEvent,
			players,
			if typeof(structDeserializer) == "table" then structDeserializer.Serialize(select(1, ...)) else ...
		)
	end

	engineEvent.FireFilteredClients = function(self, filter: (Player) -> boolean, ...)
		assert(
			select("#", ...) ~= 0,
			"no third argument/arguments provided. Did you use an index instead of a namecall?"
		)
		backingEvent.FireFilteredClients(
			backingEvent,
			filter,
			if typeof(structDeserializer) == "table" then structDeserializer.Serialize(select(1, ...)) else ...
		)
	end

	engineEvent.FireServer = function(self, ...)
		assert(
			select("#", ...) ~= 0,
			"no second argument/arguments provided. Did you use an index instead of a namecall?"
		)

		backingEvent.FireServer(
			backingEvent,
			if typeof(structDeserializer) == "table" then structDeserializer.Serialize(select(1, ...)) else ...
		)
	end

	engineEvent.OnServer = function<T...>(self, callback: (player: Player, T...) -> ()): RBXScriptConnection
		assert(
			typeof(callback) == "function",
			"second argument is not a closure. Did you use an index instead of a namecall or sent the wrong parameter?"
		)

		local disconnector = backingEvent.OnServer(backingEvent, function(player, ...)
			(callback :: any)(
				player,
				if typeof(structDeserializer) == "table" then structDeserializer.Deserialize(select(1, ...)) else ...
			)
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

	engineEvent.OnClient = function<T...>(self, callback: (T...) -> ()): RBXScriptConnection
		assert(
			typeof(callback) == "function",
			"second argument is not a closure. Did you use an index instead of a namecall or sent the wrong parameter?"
		)

		local disconnector = backingEvent.OnClient(backingEvent, function(...)
			(callback :: any)(
				if typeof(structDeserializer) == "table" then structDeserializer.Deserialize(select(1, ...)) else ...
			)
		end)

		return (
			{
				Connected = true,
				Disconnect = function(self: RBXScriptConnection)
					assert(self.Connected, "cannot disconnect an already disconnected")
					self.Connected = false
					return disconnector()
				end,
			} :: any
		) :: RBXScriptConnection
	end

	return engineEvent :: InternalTypeDefinitions.FEngineEvent<U...>
end

return FEngineEvent

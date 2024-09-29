--!strict

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local TypeDefinitions = require(ReplicatedFirst.EngineLibraries.TypeDefinitions)
local WrapperFactory = require(ReplicatedFirst.EngineLibraries.Wrappers.WrapperFactory)

local players = WrapperFactory.new({} :: TypeDefinitions.FEnginePlayers, Players)

function players:OnCharacterCreated(f: (character: Model) -> ()): ()
	assert(typeof(f) == "function", "f must be a closure")

	self.PlayerAdded:Connect(function(player: Player)
		player.CharacterAdded:Connect(f)
	end)

	for _, player in self:GetPlayers() do
		player.CharacterAdded:Connect(f)

		if player.Character then
			task.spawn(f, player.Character)
		end
	end
end

function players:OnPlayerAdded(f: (player: Player) -> ()): ()
	assert(typeof(f) == "function", "f must be a closure")

	self.PlayerAdded:Connect(f)

	for _, player in self:GetPlayers() do
		task.spawn(f, player)
	end
end

function players:GetCharacterOfPlayer(player: Player): Model
	return player.Character or player.CharacterAdded:Wait()
end

players = WrapperFactory.lock(players)
return players

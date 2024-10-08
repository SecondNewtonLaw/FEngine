--!strict
--[[
	Players.lua - Part of the FEngine Roblox Framework
		- Written by @usrdottik

	Extends the Players Roblox Service for added functionality.
]]

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

function players:GetCharacters(waitForCharactersWhichAreNotCreated: boolean): { Model }
	local characters = {}

	for _, player in self:GetPlayers() do
		if player.Character then
			table.insert(characters, player.Character)
		elseif waitForCharactersWhichAreNotCreated then
			table.insert(characters, player.CharacterAdded:Wait())
		end
	end

	return characters
end

function players:GetNearestPlayerToPosition(position: Vector3, waitForCharactersWhichAreNotCreated: boolean): Player?
	local nearestDistance = math.huge
	local nearestPlayer: Player?

	for _, player in self:GetPlayers() do
		local character = player.Character

		if not character then
			if not waitForCharactersWhichAreNotCreated then
				continue
			end
			character = player.CharacterAdded:Wait()
		end

		assert(character, "Ok this is just impossible to occur I'm surprised")

		local distance = character:GetPivot().Position - position
		if distance.Magnitude < nearestDistance then
			nearestDistance = distance.Magnitude
			nearestPlayer = player
		end
	end

	return nearestPlayer
end

players = WrapperFactory.lock(players)
return players

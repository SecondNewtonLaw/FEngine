--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local FEngineFastFlags = {}

local flagsContainer
if RunService:IsServer() then
	flagsContainer = Instance.new("Folder")
	flagsContainer.Name = "FEngineFastFlags"
	flagsContainer.Parent = ReplicatedStorage
else
	flagsContainer = ReplicatedStorage:WaitForChild("FEngineFastFlags") :: Folder
end

function FEngineFastFlags.DoesFlagExist(flagName: string)
	return not not flagsContainer:FindFirstChild(flagName)
end

function FEngineFastFlags.IsFlagEnabled(flagName: string)
	assert(
		FEngineFastFlags.DoesFlagExist(flagName),
		"Flag '" .. flagName .. "' does not exist on the Fast flag registry."
	)
	assert((flagsContainer :: any)[flagName].ClassName == "BoolValue", "Flag '" .. flagName .. "' is not a fast flag.")

	return (flagsContainer :: any)[flagName].Value :: boolean
end

function FEngineFastFlags.CreateFromDefinitions(flags: { InternalTypeDefinitions.FEngineFastFlagDefinition })
	for _, flag in flags do
		FEngineFastFlags.CreateFlag(flag.FlagName, flag.Value)
	end
end

function FEngineFastFlags.CreateFlagDefinition(flagName: string, defaultValue: boolean)
	return {
		FlagName = flagName,

		Value = defaultValue,
	} :: InternalTypeDefinitions.FEngineFastFlagDefinition
end

function FEngineFastFlags.SetFlag(flagName: string, status: boolean)
	assert(RunService:IsServer(), "Only the server can modify fast flags.")
	assert(
		FEngineFastFlags.DoesFlagExist(flagName),
		"Flag '" .. flagName .. "' does not exist on the Fast flag registry."
	)
	assert((flagsContainer :: any)[flagName].ClassName == "BoolValue", "Flag '" .. flagName .. "' is not a fast flag.");

	(flagsContainer :: any)[flagName].Value = status
end

function FEngineFastFlags.CreateFlag(flagName: string, defaultValue: boolean)
	assert(RunService:IsServer(), "Only the server can modify fast flags.")
	assert(
		not FEngineFastFlags.DoesFlagExist(flagName),
		"Flag '" .. flagName .. "' already exists on the Fast flag registry."
	)

	local flag = Instance.new("BoolValue")
	flag.Name = flagName
	flag.Value = defaultValue
	flag.Parent = flagsContainer

	return flag
end

return FEngineFastFlags

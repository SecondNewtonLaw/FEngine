--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

local GameTypes = require(ReplicatedFirst.Common.GameTypes)
local FEngineFastFlags = require(ReplicatedFirst.EngineInternals.FEngineFastFlags)
local FEngineModule = require(ReplicatedFirst.EngineInternals.FEngineModule)
local FEngineNetVar = require(ReplicatedFirst.EngineInternals.FEngineNetVar)
local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local InstanceWrapper = require(ReplicatedFirst.EngineLibraries.Wrappers.Instance)
local Players = require(ReplicatedFirst.EngineLibraries.Wrappers.Players)

type InitService = {}

local vftable = {
	Initialize = function(
		self: InternalTypeDefinitions.FEngineModuleFunctionTable<InitService>,
		FEngineServiceProvider: InternalTypeDefinitions.FEngineServiceProvider
	)
		print("Defining FEngineFastFlags...")
	
		FEngineFastFlags.CreateFromDefinitions({
			FEngineFastFlags.CreateFlagDefinition("MovementService::EnableViewBobbing", true),
			FEngineFastFlags.CreateFlagDefinition("MovementService::SmoothFoV", true)
		})
	end,
}

local fengine = FEngineModule.new(
	"InitService",
	vftable :: InternalTypeDefinitions.FEngineModuleFunctionTable<InitService>
) :: InitService

return fengine

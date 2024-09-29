local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

local FEngineServiceProvider = require(ReplicatedFirst.EngineInternals.FEngineServiceProvider)

local print = if RunService:IsStudio() or RunService:IsServer()
	then print
	else function()
		--[[ :> ]]
	end

print("--[[ FEngine loading sequence began ]]--")
print("NOTICE: this will not appear on released games to clients (only on servers or studio environments)!")
local Environment = if RunService:IsServer() then "Server" else "Client"

print("FEngine Running On Environment: ", Environment)

local scripts = nil

if Environment == "Server" then
	scripts = game:GetService("ServerStorage").Server
elseif Environment == "Client" then
	scripts = ReplicatedFirst:WaitForChild("Client")
else
	error("-- This should never occur.")
end

print("Bootstrapping NetworkBridges...")

for _, bridgeModule: ModuleScript in ReplicatedFirst.Common.NetworkBridges:GetDescendants() do
	task.spawn(function()
		local success, bridge = xpcall(function()
			return require(bridgeModule)
		end, function(err: string)
			warn(
				"Error Loading module "
					.. err
					.. "\nTrace: "
					.. debug.traceback("FEngine NetworkBridge require failed: ")
			)
		end)

		assert(
			typeof(bridge.Initialize) == "function",
			"Initialize does not exist or is not a function on NetworkBridge; cannot initialize FEngine NetworkBridge. Affected NetworkBridge -> "
				.. bridgeModule:GetFullName()
		)

		if not success then
			warn("-- FEngine NetworkBridge require failed")
		else
			print("FEngine: Bootstrapping NetworkBridge " .. bridgeModule:GetFullName())
			bridge:Initialize(FEngineServiceProvider)
			FEngineServiceProvider:RegisterBridge(bridge)
		end
	end)
end

print("Bootstrapping Modules...")

for _, engineModule: ModuleScript in scripts:GetDescendants() do
	if not engineModule:IsA("ModuleScript") then
		continue
	end

	task.spawn(function()
		local success, service = xpcall(function()
			return require(engineModule)
		end, function(err: string)
			warn("Error Loading module " .. err .. "\nTrace: " .. debug.traceback("FEngine module require failed: "))
		end)

		assert(
			typeof(service.Initialize) == "function",
			"Initialize does not exist or is not a function on Service; cannot initialize FEngine Service. Affected Service -> "
				.. engineModule:GetFullName()
		)
		if not success then
			warn("-- FEngine module require failed: ")
		else
			print("FEngine: Bootstrapping Service " .. engineModule:GetFullName())
			service:Initialize(FEngineServiceProvider)
			FEngineServiceProvider:RegisterService(service)
		end
	end)
end

warn("--[[ FEngine loading sequence ended ]]--")

return {}

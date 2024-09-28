--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)

local FEngineServiceProvider = {} :: InternalTypeDefinitions.FEngineServiceProvider & {
	Services: { InternalTypeDefinitions.FEngineModuleFunctionTable<InternalTypeDefinitions.FEngineModule> },
}

function FEngineServiceProvider:GetService<T>(serviceName): T?
	for _, service in FEngineServiceProvider.Services do
		if service.ModuleName == serviceName then
			return (service :: any) :: T
		end
	end

	return nil
end

function FEngineServiceProvider:IsLoaded(serviceName: string)
	return not not FEngineServiceProvider:GetService(serviceName)
end

return FEngineServiceProvider

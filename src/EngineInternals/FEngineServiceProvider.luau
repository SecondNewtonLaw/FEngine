--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)

local FEngineServiceProvider = { Bridges = {}, Services = {} } :: InternalTypeDefinitions.FEngineServiceProvider & {
	Services: { InternalTypeDefinitions.FEngineModuleFunctionTable<InternalTypeDefinitions.FEngineModule<unknown>> },
	Bridges: { InternalTypeDefinitions.FEngineBridgeFunctionTable<InternalTypeDefinitions.FEngineBridge<unknown>> },
}

function FEngineServiceProvider:GetService<T>(serviceName: string): T?
	for _, service in FEngineServiceProvider.Services do
		if service.ModuleName == serviceName then
			return (service :: any) :: T
		end
	end

	return nil
end

function FEngineServiceProvider:GetBridge<T>(bridgeName: string): T?
	for _, bridge in FEngineServiceProvider.Bridges do
		if bridge.BridgeName == bridgeName then
			return (bridge :: any) :: T
		end
	end

	return nil
end

function FEngineServiceProvider:RegisterService(service: any)
	assert(not table.find(FEngineServiceProvider.Services, service), "Service already registered.")
	table.insert(FEngineServiceProvider.Services, service)
end

function FEngineServiceProvider:RegisterBridge(bridge: any)
	assert(not table.find(FEngineServiceProvider.Bridges, bridge), "NetworkBridge already registered.")
	table.insert(FEngineServiceProvider.Bridges, bridge)
end

function FEngineServiceProvider:IsLoaded(serviceOrBridge: string)
	return not not (
		FEngineServiceProvider:GetService(serviceOrBridge) or FEngineServiceProvider:GetBridge(serviceOrBridge)
	)
end

return FEngineServiceProvider

--!strict

export type FEngineServiceProvider = {
	IsLoaded: (self: FEngineServiceProvider, serviceName: string) -> boolean,
	GetService: <T>(self: FEngineServiceProvider, serviceName: string) -> T?,
}

export type FEngineModule = {
	ModuleName: string,
	LoadOrder: number,
}

export type FEngineModuleFunctionTable<T> = {
	--[=[
		Run by FEngine when the module is required for the first time, initializes the module.
	]=]
	Initialize: (self: FEngineModuleFunctionTable<T>, FEngineServiceProvider: FEngineServiceProvider) -> (),
} & T

export type FEngineEvent = {
	
}

export type FEngineBridge = {
	Events: { FEngineEvent },
}

export type FEngineBridgeFunctionTable<T> = {
	--[=[
		Run by FEngine when the Bridge is required for the first time, initializes the Bridge.
	]=]
	Initialize: (self: FEngineBridgeFunctionTable<T>, FEngineServiceProvider: FEngineServiceProvider) -> (),
} & T

return {}

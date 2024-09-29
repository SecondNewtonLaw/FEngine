--!strict

export type FEngineServiceProvider = {
	IsLoaded: (self: FEngineServiceProvider, serviceName: string) -> boolean,
	RegisterService: (self: FEngineServiceProvider, service: any) -> (),
	RegisterBridge: (self: FEngineServiceProvider, bridge: any) -> (),

	GetBridge: <T>(self: FEngineServiceProvider, bridgeName: string) -> T?,
	GetService: <T>(self: FEngineServiceProvider, serviceName: string) -> T?,
}

export type FEngineModule<T> = {
	ModuleName: string,
} & T

export type FEngineModuleFunctionTable<T> = {
	--[=[
		Run by FEngine when the module is required for the first time, initializes the module.
	]=]
	Initialize: (self: FEngineModuleFunctionTable<T>, FEngineServiceProvider: FEngineServiceProvider) -> (),
} & FEngineModule<T>

export type FEngineEvent<T> = {
	FireAllClients: (self: FEngineEvent<T>, obj: T) -> (),
	FireClient: (self: FEngineEvent<T>, player: Player, obj: T) -> (),
	FireClients: (self: FEngineEvent<T>, players: { Player }, obj: T) -> (),
	FireAllClientsExcept: (self: FEngineEvent<T>, player: Player, obj: T) -> (),
	FireFilteredClients: (self: FEngineEvent<T>, filter: (player: Player) -> boolean, obj: T) -> (),

	FireServer: (self: FEngineEvent<T>, obj: T) -> (),

	OnServer: (self: FEngineEvent<T>, callback: (player: Player, packet: T) -> ()) -> RBXScriptConnection,
	OnClient: (self: FEngineEvent<T>, callback: (packet: T) -> ()) -> RBXScriptConnection,
}

export type FEngineBridge<T> = {
	BridgeName: string,
} & T

export type FEngineEventOptions = {
	Name: string,
	Unreliable: boolean?,
}

export type Serializable<T> = {
	Deserialize: (buf: buffer) -> T,
	Serialize: (obj: T) -> buffer,
}

export type FEngineBridgeFunctionTable<T> = {
	--[=[
		Run by FEngine when the Bridge is required for the first time, initializes the Bridge.
	]=]
	Initialize: (self: FEngineBridgeFunctionTable<T>, FEngineServiceProvider: FEngineServiceProvider) -> (),
} & FEngineBridge<T>

return {}

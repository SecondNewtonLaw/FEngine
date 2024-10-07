--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type FEngineServiceProvider = {
	IsLoaded: (self: FEngineServiceProvider, serviceName: string) -> boolean,
	RegisterService: (self: FEngineServiceProvider, service: any) -> (),
	RegisterBridge: (self: FEngineServiceProvider, bridge: any) -> (),

	GetBridge: <T>(self: FEngineServiceProvider, bridgeName: string) -> T?,
	GetService: <T>(self: FEngineServiceProvider, serviceName: string) -> T?,
}

export type FEngineFastFlagDefinition = {
	FlagName: string,
	Value: boolean,
}

export type FEngineNetVar<T> = {
	GetValue: (self: FEngineNetVar<T>) -> T,
	--[=[
		This function only works on the server.

		@return T a copy of the old, original value.
	]=]
	SetValue: (self: FEngineNetVar<T>, value: T) -> T,

	HasValue: (self: FEngineNetVar<T>) -> boolean,

	IsOwned: (self: FEngineNetVar<T>) -> boolean,

	OnValueChanged: (self: FEngineNetVar<T>, callback: (T) -> ()) -> RBXScriptConnection,
} & T

export type FEngineModule<T> = {
	ModuleName: string,
} & T

export type FEngineModuleFunctionTable<T> = {
	--[=[
		Run by FEngine when the module is required for the first time, initializes the module.
	]=]
	Initialize: (self: FEngineModuleFunctionTable<T>, FEngineServiceProvider: FEngineServiceProvider) -> (),
} & FEngineModule<T>

export type FEngineEvent<U...> = {
	FireAllClients: (self: FEngineEvent<U...>, U...) -> (),
	FireClient: (self: FEngineEvent<U...>, player: Player, U...) -> (),
	FireClients: (self: FEngineEvent<U...>, players: { Player }, U...) -> (),
	FireAllClientsExcept: (self: FEngineEvent<U...>, player: Player, U...) -> (),
	FireFilteredClients: (self: FEngineEvent<U...>, filter: (player: Player) -> boolean, U...) -> (),

	FireServer: (self: FEngineEvent<U...>, U...) -> (),

	OnServer: (self: FEngineEvent<U...>, callback: (player: Player, U...) -> ()) -> RBXScriptConnection,
	OnClient: (self: FEngineEvent<U...>, callback: (U...) -> ()) -> RBXScriptConnection,
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

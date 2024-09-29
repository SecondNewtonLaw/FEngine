--!strict

export type FEngineUtilities = {
	RandomString: (size: number) -> string,
	SynchronizeIfParallel: (runner: BaseScript) -> (),
	DesynchronizeIfParallel: (runner: BaseScript) -> (),
	GetArgumentCount: (f: () -> ()) -> number,
	ForceCast: <T>(x: any) -> T,

	IsLuaClosure: (f: () -> ()) -> boolean,
	IsCClosure: (f: () -> ()) -> boolean,
}

export type FEnginePlayers = {
	OnCharacterCreated: (self: FEnginePlayers, f: (Model) -> ()) -> (),
	OnPlayerAdded: (self: FEnginePlayers, f: (Player) -> ()) -> (),
	--[=[
		@yields
	]=]
	GetCharacterOfPlayer: (self: FEnginePlayers, player: Player) -> Model,
} & Players

export type Creatable<T, U...> = {
	new: (U...) -> T,
}


return {}

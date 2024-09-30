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
	GetCharacters: (self: FEnginePlayers, waitForCharactersWhichAreNotCreated: boolean) -> { Model },
	GetNearestPlayerToPosition: (
		self: FEnginePlayers,
		position: Vector3,
		waitForCharactersWhichAreNotCreated: boolean
	) -> Player?,
} & Players

export type FEngineInstance<T> = {
	ExecuteUntilDestroyed: (self: FEngineInstance<T>, f: () -> (), executeEverySeconds: number) -> (),
	IsClonable: (self: FEngineInstance<T>) -> boolean,
	--[=[
		@yields
	]=]
	WaitForChildOfClass: <U>(self: FEngineInstance<T>, className: string, timeout: number?) -> (U & Instance) | nil,
	--[=[
		@yields
	]=]
	WaitForChildWhichIsA: <U>(self: FEngineInstance<T>, className: string, timeout: number?) -> (U & Instance) | nil,
} & Instance & T

export type Creatable<T, U...> = {
	new: (U...) -> T,
}

return {}

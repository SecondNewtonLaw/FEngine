--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local TypeDefinitions = require(ReplicatedFirst.EngineLibraries.TypeDefinitions)
local utilities = {}

do
	local charset = (
		setmetatable(table.create(60, 0), {
			__newindex = function(self, index, newValue)
				assert(typeof(index) == "number", "this table only accepts numbers as keys.")
				assert(typeof(newValue) == "number", "this table only accepts numbers as values.")
				assert(newValue >= 0 and newValue <= 255, "newValue has to be in the range of 0 - 255.")

				rawset(self, index, newValue)
			end,
		}) :: any
	) :: { number }
	do
		for c = 48, 57 do
			table.insert(charset, c)
		end
		for c = 65, 90 do
			table.insert(charset, c)
		end
		for c = 97, 122 do
			table.insert(charset, c)
		end
	end
	table.freeze(charset)
	local charsetLength = #charset

	function utilities.RandomString(size: number)
		assert(size > 0, "size cannot be 0")
		local buf = buffer.create(size + 1)
		for i = 0, size, 1 do
			buffer.writeu8(buf, i, charset[math.random(1, charsetLength)])
		end
		return buffer.tostring(buf)
	end
end

function utilities.SynchronizeIfParallel(runner: BaseScript)
	assert(
		typeof(runner) == "Instance" and runner:IsA("BaseScript"),
		"runner is not a valid Instance which inherits from BaseScript; cannot assert if the environment is a parallel one"
	)
	if runner:GetActor() then
		task.synchronize()
	end
end

function utilities.DesynchronizeIfParallel(runner: BaseScript)
	assert(
		typeof(runner) == "Instance" and runner:IsA("BaseScript"),
		"runner is not a valid Instance which inherits from BaseScript; cannot assert if the environment is a parallel one"
	)
	if runner:GetActor() then
		task.desynchronize()
	end
end

function utilities.IsParallel(runner: BaseScript)
	assert(
		typeof(runner) == "Instance" and runner:IsA("BaseScript"),
		"runner is not a valid Instance which inherits from BaseScript; cannot assert if the environment is a parallel one"
	)

	return not not runner:GetActor()
end

--[=[
    Obtains the argument count of a given lua closure. This function will **not** accept C closures

    @error "the provided closure is a C closure, cannot get argument count" -- The function provided to the function appears to be a C closure, this means that the arguments cannot be checked, as there is no info on them.

    @return number -- Returns the number of arguments the function accepts. Returns `-1` if the provided function is a vararg function i.e: `f(...)`
]=]
function utilities.GetArgumentCount(f: () -> ()): number
	assert(utilities.IsLuaClosure(f), "the provided closure is a C closure, cannot get argument count")
	local argc, isvararg = (debug.info :: (() -> (), string) -> (number, boolean))(f, "a")

	return if isvararg then -1 else argc
end

function utilities.IsCClosure(f: () -> ()): boolean
	assert(typeof(f) == "function", "argument f is not a valid closure")
	return (debug.info :: (() -> (), string) -> string)(f, "s") == "[C]"
end

function utilities.IsLuaClosure(f: () -> ()): boolean
	assert(typeof(f) == "function", "argument f is not a valid closure")
	return not utilities.IsCClosure(f)
end

function utilities.ForceCast<T>(x: any): T
	return x :: T
end

return utilities :: TypeDefinitions.FEngineUtilities

--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Utilities = require(ReplicatedFirst.EngineLibraries.Utilities)
local TypedArray = {}

function TypedArray.new<T>(defaultArray: { T }, enforcer: string | (any) -> (boolean, string?))
	assert(
		typeof(enforcer) == "string"
			or (
				typeof(enforcer) == "function"
				and Utilities.IsLuaClosure(enforcer)
				and Utilities.GetArgumentCount(enforcer) == 1
			),
		"the type to enforce must be either a string of a callable lua function that accepts one argument"
	)

	local meta = if typeof(enforcer) == "string"
		then {
			__newindex = function(self, index, newValue)
				assert(
					typeof(index) == "number",
					"cannot set value of key: an index that is not a number is not allowed into an array"
				)
				assert(index <= rawlen(self), "attempt to index outside of the bounds of the array")
				assert(typeof(newValue) == enforcer, "cannot set value of key: type mismatch")

				return rawset(self :: any, index, newValue)
			end,
		}
		else {
			__newindex = function(self, index, newValue)
				assert(
					typeof(index) == "number",
					"cannot set value of key: an index that is not a number is not allowed into an array"
				)
				assert(index <= rawlen(self), "attempt to index outside of the bounds of the array")
				local success, ret = enforcer(newValue)
				assert(success, ret)
				return rawset(self :: any, index, newValue)
			end,
		}

	return (setmetatable(defaultArray, meta) :: any) :: { T }
end

return TypedArray
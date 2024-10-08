--!strict
--[[
	WrapperFactory.lua - Part of the FEngine Roblox Framework
		- Written by @usrdottik

	Provides a way to 'inherit' from native C constructs in Roblox.
]]

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Utilities = require(ReplicatedFirst.EngineLibraries.Utilities)
local WrapperFactory = {}

local NATIVE_INHERITOR_OBTAIN_KEY = Utilities.RandomString(256)

function WrapperFactory.new<T, U>(module: T, nativeInherit: U): T & U
	assert(type(nativeInherit) == "userdata", "Expected nativeInherit to be a native C construct (userdata)")
	assert(type(module) == "table", "Expected module to be a table object.")

	return setmetatable(module :: any, {
		__index = function(self, index: any)
			if index == NATIVE_INHERITOR_OBTAIN_KEY then
				return nativeInherit
			end

			if rawget(self, index) then
				return rawget(self, index)
			end

			local s, originalNativeValue = pcall(function(...)
				return (nativeInherit :: any)[index]
			end)

			if not s then
				return (nativeInherit :: any)[index] -- We want to return the original error, regardless.
			end

			if s then
				-- functions have a little bit of a problem, normally we want them all to be namecalld,
				-- but because we are proxying our table we must push a closure
				-- that will call the original function with the first argument as the actual Players service.
				-- and then we save the closure into our proxy table, lazily keeping it up to date (For performance reasons!).

				if typeof(originalNativeValue) == "function" then
					-- print("[[WrapperFactory]] Emitting Proxy for " .. tostring(index) .. " into native inheritor.")
					rawset(
						self,
						index,
						function(clSelf, ...)
							assert(clSelf == self, "expected WrapperProxy when calling '" .. tostring(index) .. "'!")

							return (originalNativeValue :: (...any) -> ...any)(nativeInherit, ...)
						end :: any
					)
				else
					return originalNativeValue
				end
			end

			return rawget(self, index)
		end,
		__newindex = function(self, index, newValue)
			local success, _ = pcall(function()
				return self[NATIVE_INHERITOR_OBTAIN_KEY][index]
			end)

			if success then
				print(
					"[[WrapperFactory]] Overwrite of native value '"
						.. (if typeof(self[NATIVE_INHERITOR_OBTAIN_KEY]) == "Instance"
							then (self :: any):GetFullName()
							else tostring(self[NATIVE_INHERITOR_OBTAIN_KEY]))
						.. "."
						.. tostring(index)
						.. "' to value: '"
						.. tostring(newValue)
						.. "'"
				)
				self[NATIVE_INHERITOR_OBTAIN_KEY][index] = newValue
				return
			end

			rawset(self, index, newValue)
		end,
	}) :: any
end

function WrapperFactory.getNative<T>(wrappedInstance: any): T
	assert(typeof(wrappedInstance) == "table", "Expected instance to be a table object.")
	local native = wrappedInstance[NATIVE_INHERITOR_OBTAIN_KEY]
	assert(native, "This object does not have a native inheritor.")

	return native
end

function WrapperFactory.lock<T>(module: T): T
	assert(type(module) == "table", "Expected module to be a table object.")
	local idx = getmetatable(module :: any).__index
	assert(type(idx) == "function", "Expected __index of module to be a closure.")

	-- normally using table.freeze would be fine, but due to the nature of our lazy cache approach it will not do.
	-- we must override __newindex to prohibit modifications and set the __metatable field to lock it.

	return setmetatable(module :: any, {
		__index = idx,
		__newindex = function(self, index, newValue)
			local success, _ = pcall(function()
				return self[NATIVE_INHERITOR_OBTAIN_KEY][index]
			end)

			if success then
				-- print(
				-- 	"[[WrapperFactory]] Overwrite of native value '"
				-- 		.. (if typeof(self[NATIVE_INHERITOR_OBTAIN_KEY]) == "Instance"
				-- 			then self:GetFullName()
				-- 			else tostring(self[NATIVE_INHERITOR_OBTAIN_KEY]))
				-- 		.. "."
				-- 		.. tostring(index)
				-- 		.. "' to value: '"
				-- 		.. tostring(newValue)
				-- 		.. "'"
				-- )
				self[NATIVE_INHERITOR_OBTAIN_KEY][index] = newValue
				return
			end

			error("this object is readonly.")
		end,
		__metatable = "This metatable is locked!",
	})
end

return WrapperFactory

local WrapperFactory = {}

function WrapperFactory.new<T, U>(module: T, nativeInherit: U): T & U
	assert(type(nativeInherit) == "userdata", "Expected nativeInherit to be a native C construct (userdata)")
	assert(type(module) == "table", "Expected module to be a table object.")

	return setmetatable(module :: any, {
		__index = function(self, index: any)
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
					print("[[WrapperFactory]] Emitting Proxy for " .. tostring(index) .. " into native inheritor.")
					rawset(self, index, function(clSelf, ...)
						assert(clSelf == self, "expected WrapperProxy when calling '" .. tostring(index) .. "'!")

						return originalNativeValue(nativeInherit, ...)
					end)
				else
					return originalNativeValue
				end
			end

			return rawget(self, index)
		end,
	}) :: any
end

function WrapperFactory.lock<T>(module: T): T
	assert(type(module) == "table", "Expected module to be a table object.")
	local idx = getmetatable(module :: any).__index
	assert(type(idx) == "function", "Expected __index of module to be a closure.")

	-- normally using table.freeze would be fine, but due to the nature of our lazy cache approach it will not do.
	-- we must override __newindex to prohibit modifications and set the __metatable field to lock it.

	return setmetatable(module :: any, {
		__index = idx,
		__newindex = function()
			error("this table is readonly.")
		end,
		__metatable = "This metatable is locked!",
	})
end

return WrapperFactory

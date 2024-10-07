--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local TypeDefinitions = require(ReplicatedFirst.EngineLibraries.TypeDefinitions)
local WrapperFactory = require(ReplicatedFirst.EngineLibraries.Wrappers.WrapperFactory)

local instance = {}

function instance.wrap<T>(existing: T & Instance)
	assert(typeof(existing) == "Instance", "existing must be an Instance type.")

	local insn = WrapperFactory.new({} :: TypeDefinitions.FEngineInstance<T>, existing)

	local isDestroyed = false

	existing.Destroying:Connect(function()
		isDestroyed = true
	end)

	function insn:ExecuteUntilDestroyed(f: () -> (), executeEverySeconds: number)
		task.spawn(function()
			while not isDestroyed do
				pcall(f)
				task.wait(executeEverySeconds)
			end
		end)
	end

	function insn:IsClonable(): boolean
		return self.Archivable
	end

	function insn:WaitForChildOfClass<T>(className: string, timeout: number?): (T & Instance) | nil
		assert(typeof(className) == "string", "className must be a string")

		local found = self:FindFirstChildOfClass(className)
		if found then
			return found :: T & Instance
		end

		local onChildAdded: RBXScriptConnection?
		onChildAdded = self.ChildAdded:Connect(function(obj: Instance)
			if obj.ClassName == className then
				found = obj
				if onChildAdded then
					onChildAdded:Disconnect()
				end
				onChildAdded = nil
			end
		end)

		local timePassed = 0
		local warned = false
		repeat
			timePassed += task.wait()

			if not timeout and timePassed >= 5 and not warned then
				warn(
					"Infinite Yield Possible on " .. self:GetFullName() .. ":WaitForChildOfClass<" .. className .. ">()"
				)
				warned = true
			end

			if timeout and timePassed >= timeout then
				if onChildAdded and onChildAdded.Connected then
					onChildAdded:Disconnect()
				end
				break
			end
		until found

		return found :: (T & Instance) | nil
	end

	function insn:WaitForChildWhichIsA<T>(className: string, timeout: number?): (T & Instance) | nil
		assert(typeof(className) == "string", "className must be a string")

		local found = self:FindFirstChildOfClass(className)
		if found then
			return found :: T & Instance
		end

		local onChildAdded: RBXScriptConnection?
		onChildAdded = self.ChildAdded:Connect(function(obj: Instance)
			if obj:IsA(className) then
				found = obj
				if onChildAdded then
					onChildAdded:Disconnect()
				end
				onChildAdded = nil
			end
		end)

		local timePassed = 0
		local warned = false
		repeat
			timePassed += task.wait()

			if not timeout and timePassed >= 5 and not warned then
				warn(
					"Infinite Yield Possible on "
						.. self:GetFullName()
						.. ":WaitForChildWhichIsA<"
						.. className
						.. ">()"
				)
				warned = true
			end

			if timeout and timePassed >= timeout then
				if onChildAdded and onChildAdded.Connected then
					onChildAdded:Disconnect()
				end
				break
			end
		until found

		return found :: (T & Instance) | nil
	end

	function insn:HasField(fieldName: string): boolean
		assert(typeof(fieldName) == "string", "fieldName must be a string")

		local successful = pcall(function(i: Instance, s: string)
			return (i :: any)[s]
		end, insn, fieldName)

		return successful
	end

	insn = WrapperFactory.lock(insn)

	return insn
end

return instance

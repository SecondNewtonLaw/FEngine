--!strict

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FEngineEvent = require(ReplicatedFirst.EngineInternals.FEngineEvent)
local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local InstanceWrapper = require(ReplicatedFirst.EngineLibraries.Wrappers.Instance)
local WrapperFactory = require(ReplicatedFirst.EngineLibraries.Wrappers.WrapperFactory)

local networkVariable = {}

--[[
	Due to Red and Buffers not being to hold all the data one may want to serialize, this is no good, we must use raw RemoteEvent.
]]

local SetEvent

if RunService:IsServer() then
	SetEvent = Instance.new("RemoteEvent")
	SetEvent.Name = "__FEngine_Internal__NetworkVariable__Set"
	SetEvent.Parent = ReplicatedStorage

	SetEvent.OnServerEvent:Connect(function(player: Player, instance: Instance, newValue: unknown)
		if instance:GetAttribute("OwnerId") ~= player.UserId then
			warn(
				"NetworkVariable: Attempted to set value on "
					.. instance:GetFullName()
					.. " but it was not owned by "
					.. player.Name
			)
			SetEvent:FireClient(player, false)
			return
		end

		(instance :: any).Value = newValue
		SetEvent:FireClient(player, true)
	end)
else
	SetEvent = ReplicatedStorage:WaitForChild("__FEngine_Internal__NetworkVariable__Set") :: RemoteEvent
end

function networkVariable.wrap<T>(existing: T & Instance & ValueBase)
	assert(typeof(existing) == "Instance", "existing must be an Instance type.")

	local insn = WrapperFactory.new({} :: InternalTypeDefinitions.FEngineNetVar<T>, existing)

	function insn:GetValue(): T
		return (insn :: ValueBase & { Value: T }).Value
	end

	function insn:HasValue(): boolean
		return typeof(existing) == "Instance"
			and InstanceWrapper.wrap(existing):HasField("Value")
			and (insn :: Instance & { Value: T }).Value ~= nil
	end

	function insn:SetValue(newValue: T): T
		assert(
			self:IsOwned(),
			"NetworkVariable::SetValue(newValue: T) can only be called by the server and owners of the NetworkVariable"
		)
		local old = (insn :: Instance & { Value: T }).Value

		if RunService:IsServer() then
			(insn :: Instance & { Value: T }).Value = newValue
		else
			SetEvent:FireServer(existing, newValue)
			assert(
				SetEvent.OnClientEvent:Wait(),
				"failed to modify the NetworkVariable from the client. Did the player own the variable appropriately?"
			)
		end

		return old
	end

	function insn:IsOwned(): boolean
		if RunService:IsServer() then
			return true
		end

		return existing:GetAttribute("OwnerId") == Players.LocalPlayer.UserId
	end

	function insn:OnValueChanged(callback: (T) -> ())
		return (insn :: Instance & { Changed: RBXScriptSignal<T> }).Changed:Connect(callback)
	end

	insn = WrapperFactory.lock(insn)
	return insn
end

return networkVariable

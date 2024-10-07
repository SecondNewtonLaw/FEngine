local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local NetworkVariable = require(ReplicatedFirst.EngineLibraries.Wrappers.NetworkVariable)
local FEngineNetVar = {}

if RunService:IsServer() then
	local netvarContainer = Instance.new("Folder")
	netvarContainer.Name = "NetworkVariables"
	netvarContainer.Parent = ReplicatedStorage
end

local NetworkVariableContainer = if RunService:IsServer()
	then ReplicatedStorage.NetworkVariables :: Folder
	else ReplicatedStorage:WaitForChild("NetworkVariables") :: Folder

function FEngineNetVar.create<T>(
	networkVariableName: string,
	networkVariableType: "Object" | "String" | "Number" | "Integer" | "Boolean" | "CFrame" | "Vector3",
	typeAnchor: T -- Anchors T to be a specific type, allowing it to be flexible, but working.
): InternalTypeDefinitions.FEngineNetVar<T>
	assert(typeof(networkVariableName) == "string", "networkVariableName must be of type string")
	assert(typeof(networkVariableType) == "string", "networkVariableType must be of type string")

	local valueType = nil

	do
		if networkVariableType == "Object" then
			valueType = "ObjectValue"
		elseif networkVariableType == "String" then
			valueType = "StringValue"
		elseif networkVariableType == "Number" then
			valueType = "NumberValue"
		elseif networkVariableType == "Integer" then
			valueType = "IntValue"
		elseif networkVariableType == "Boolean" then
			valueType = "BoolValue"
		elseif networkVariableType == "CFrame" then
			valueType = "CFrameValue"
		elseif networkVariableType == "Vector3" then
			valueType = "Vector3Value"
		else
			error("Unknown netvar type: " .. tostring(networkVariableType))
		end
	end

	if RunService:IsServer() then
		local netvar = Instance.new(valueType)
		netvar.Name = networkVariableName
		netvar.Parent = NetworkVariableContainer
		return NetworkVariable.wrap(netvar)
	else
		local var = NetworkVariableContainer:WaitForChild(networkVariableName, 10) :: Instance?
		assert(
			var,
			"server did not create the network variable '" .. networkVariableName .. "' within a reasonable time frame"
		)

		assert(
			valueType == var.ClassName,
			"The network variable does not match in type to what was specified when creating the network variable"
		)

		return NetworkVariable.wrap(var)
	end
end

function FEngineNetVar.getAll(): { InternalTypeDefinitions.FEngineNetVar<unknown> }
	local netvars = {}

	for _, child in NetworkVariableContainer:GetChildren() do
		if not child:IsA("ValueBase") then
			warn("FEngineNetVar: network variables contained a non-ValueBase inherited child: " .. child:GetFullName())
			continue
		end

		table.insert(netvars, NetworkVariable.wrap(child))
	end

	return netvars
end

return FEngineNetVar

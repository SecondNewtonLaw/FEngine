--!strict
--[[
	Instance.lua - Part of the FEngine Roblox Framework
		- Written by @usrdottik

	Extends the workspace.CurrentCamera for added functionality, only works on clients as detailed by the assert.
]]

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

local TypeDefinitions = require(ReplicatedFirst.EngineLibraries.TypeDefinitions)
local WrapperFactory = require(ReplicatedFirst.EngineLibraries.Wrappers.WrapperFactory)

assert(
	RunService:IsClient(),
	"This wrapper only performs client-side operations and cannot be interacted with from the server."
)

local camera = WrapperFactory.new({} :: TypeDefinitions.FEngineCamera, workspace.CurrentCamera)

function camera:IsOnCameraFrustrum(object: BasePart): boolean
	assert(typeof(object) == "Instance", "Expected object to be an Instance.")
	assert(object:IsA("BasePart"), "Expected object to be a BasePart.")

	-- _ is viewportPoint (Vector3)
	local _, isInViewport = self:WorldToViewportPoint(object.Position)

	--[[
        This implementation could very well do Dot product and get away with it if we wanted to,
        but it would make the function far too complex to be writing at 2 AM (LOL)
    ]]

	return isInViewport
end

return camera

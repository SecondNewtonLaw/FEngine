--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local GameTypes = require(ReplicatedFirst.Common.GameTypes)
local FEngineModule = require(ReplicatedFirst.EngineInternals.FEngineModule)
local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local UIHelper = require(ReplicatedFirst.EngineLibraries.Helpers.UIHelper)
local InstanceWrapper = require(ReplicatedFirst.EngineLibraries.Wrappers.Instance)
local Players = require(ReplicatedFirst.EngineLibraries.Wrappers.Players)

assert(RunService:IsClient(), "This is a client module, cannot be required on the Server Side.")

local vftable = {
	Initialize = function(
		self: InternalTypeDefinitions.FEngineModuleFunctionTable<GameTypes.UIStatusService>,
		FEngineServiceProvider: InternalTypeDefinitions.FEngineServiceProvider
	)
		print("!-- loading UIStatusService --!")

		local LocalPlayer = Players.LocalPlayer

		print("waiting for variables...")

		local PlayerCharacter = Players:GetCharacterOfPlayer(LocalPlayer)
		local PlayerHumanoid = InstanceWrapper.wrap(PlayerCharacter):WaitForChildWhichIsA("Humanoid", 10) :: Humanoid

		-- UI
		local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: StarterGui
		local statusContainer = PlayerGui:WaitForChild("StatusGUI"):WaitForChild("Status")
		local HealthUI = statusContainer:WaitForChild("Health")
		local StaminaUI = statusContainer:WaitForChild("Stamina")
	
		-- Bar values

		local StaminaValue = LocalPlayer:WaitForChild("Stamina") :: NumberValue
		local MaxStaminaValue = LocalPlayer:WaitForChild("MaxStamina") :: NumberValue
		
		local TweenMap: { Health: Tween?, Stamina: Tween?, Hunger: Tween? } = {
			Health = nil,
			Stamina = nil,
			Hunger = nil,
		}

		local tweenInfo = TweenInfo.new(0.5)

		PlayerHumanoid.HealthChanged:Connect(function(newHealth: number)
			local healthBarNewSize = UIHelper.GetPercentageSize(newHealth / PlayerHumanoid.MaxHealth, 1)

			if TweenMap.Health then
				TweenMap.Health:Cancel()
			end

			TweenMap.Health = TweenService:Create(HealthUI.Filler, tweenInfo, {
				Size = healthBarNewSize,
			}):Play()
		end)

		StaminaValue.Changed:Connect(function(newValue: number)
			local staminaBarNewSize = UIHelper.GetPercentageSize(newValue / MaxStaminaValue.Value, 1)

			if TweenMap.Stamina then
				TweenMap.Stamina:Cancel()
			end

			TweenMap.Stamina = TweenService:Create(StaminaUI.Filler, tweenInfo, {
				Size = staminaBarNewSize,
			}):Play()
		end)

	end,
}

local fengine = FEngineModule.new(
	"UIStatusService",
	vftable :: InternalTypeDefinitions.FEngineModuleFunctionTable<GameTypes.UIStatusService>
) :: GameTypes.UIStatusService

return fengine

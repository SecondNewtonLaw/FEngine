--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local GameTypes = require(ReplicatedFirst.Common.GameTypes)
local SetSprintPacket = require(ReplicatedFirst.Common.Structures.SetSprintPacket)
local FEngineFastFlags = require(ReplicatedFirst.EngineInternals.FEngineFastFlags)
local FEngineModule = require(ReplicatedFirst.EngineInternals.FEngineModule)
local FEngineNetVar = require(ReplicatedFirst.EngineInternals.FEngineNetVar)
local InternalTypeDefinitions = require(ReplicatedFirst.EngineInternals.InternalTypeDefinitions)
local UIHelper = require(ReplicatedFirst.EngineLibraries.Helpers.UIHelper)
local InstanceWrapper = require(ReplicatedFirst.EngineLibraries.Wrappers.Instance)
local Players = require(ReplicatedFirst.EngineLibraries.Wrappers.Players)
local camerashaker = require(ReplicatedStorage.Packages.camerashaker)

assert(RunService:IsClient(), "This is a client module, cannot be required on the Server Side.")

local SprintFoVTween: Tween? = nil

local vftable = {
	Initialize = function(
		self: InternalTypeDefinitions.FEngineModuleFunctionTable<GameTypes.MovementService>,
		FEngineServiceProvider: InternalTypeDefinitions.FEngineServiceProvider
	)
		self.CameraShaker = camerashaker.new(Enum.RenderPriority.Camera.Value + 1, function(mCFrame: CFrame)
			workspace.CurrentCamera.CFrame *= mCFrame
		end)

		self.PlayerBridge = FEngineServiceProvider:GetBridge("PlayerBridge") :: GameTypes.PlayerBridge

		local MaxStaminaValue = Instance.new("NumberValue")
		MaxStaminaValue.Name = "MaxStamina"
		MaxStaminaValue.Value = 100
		MaxStaminaValue.Parent = Players.LocalPlayer

		local StaminaValue = Instance.new("NumberValue")
		StaminaValue.Name = "Stamina"
		StaminaValue.Value = 100
		StaminaValue.Parent = Players.LocalPlayer

		local StaminaLoss = Instance.new("NumberValue")
		StaminaLoss.Name = "StaminaLoss"
		StaminaLoss.Value = 0.0
		StaminaLoss.Parent = Players.LocalPlayer

		local IsSprinting = Instance.new("BoolValue")
		IsSprinting.Name = "IsSprinting"
		IsSprinting.Value = false
		IsSprinting.Parent = Players.LocalPlayer

		RunService.Heartbeat:Connect(function(deltaTime: number)
			StaminaValue.Value =
				math.clamp(StaminaValue.Value - deltaTime * StaminaLoss.Value, 0, MaxStaminaValue.Value)
		end)

		IsSprinting.Changed:Connect(function(newValue: boolean)
			StaminaLoss.Value += if newValue then 0.5 else -0.5
			self:SetSprint(newValue)
		end)

		local humanoid = Players:GetCharacterOfPlayer(Players.LocalPlayer):WaitForChild("Humanoid") :: Humanoid

		humanoid.Jumping:Connect(function(isJumping: boolean)
			if not isJumping then
				return
			end

			StaminaValue.Value = math.clamp(StaminaValue.Value - 5, 0, MaxStaminaValue.Value)
		end)

		UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			if gameProcessedEvent then
				return
			end

			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl then
				IsSprinting.Value = true
			end
		end)

		UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			if gameProcessedEvent then
				return
			end

			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl then
				IsSprinting.Value = false
			end
		end)

		do
			if
				FEngineFastFlags.DoesFlagExist("MovementService::EnableViewBobbing")
				and FEngineFastFlags.IsFlagEnabled("MovementService::EnableViewBobbing")
			then
				task.spawn(function()
					local RunService = game:GetService("RunService")
					local UserInputService = game:GetService("UserInputService")

					local Player = Players.LocalPlayer
					local Character = Player.Character :: Model & { Humanoid: Humanoid } or Player.CharacterAdded:Wait()
					local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

					local Camera = workspace.CurrentCamera

					local Update = Vector3.zero

					-- Calculates by how much the screen should be tilted; BasePart's Acceleration,
					local function CalculateTiltAngle(isTilt: boolean)
						assert(Character.PrimaryPart, "This should never occur")

						if isTilt then
							return 4 -- Fixed value for tilting, else too extreme.
						end

						return math.pi / 2 / Character.PrimaryPart.AssemblyLinearVelocity.Magnitude
					end

					-- Caculates the intensity of the viewbobbing applied when walking
					local function CalculateBobbingAmount()
						assert(Character.PrimaryPart, "This should never occur")

						return Character.PrimaryPart.AssemblyLinearVelocity.Magnitude / 75
					end

					local TimeScale = math.clamp(Humanoid.WalkSpeed / 16, 0.5, 2) -- speed of the walk bobbing

					local function lerp(a: Vector3, b: Vector3, c: number)
						return a + (b - a) * c
					end

					local isJumping = false

					Humanoid.Jumping:Connect(function(a0: boolean)
						isJumping = true
					end)

					local reinitializeMutex = false

					local function ReinitializeViewBobbing()
						if reinitializeMutex then
							return
						end

						reinitializeMutex = true
						Character = (Player.Character :: Model & { Humanoid: Humanoid }) or Player.CharacterAdded:Wait()
						Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
						Update = Vector3.zero

						reinitializeMutex = false
					end

					local function updateCamera(deltaTime)
						if Humanoid.Health <= 0 then
							ReinitializeViewBobbing()
							return
						end

						local MouseDelta = UserInputService:GetMouseDelta().X

						Update = lerp(
							Update,
							Vector3.new(
								math.clamp(MouseDelta, -CalculateTiltAngle(true), CalculateTiltAngle(true)),
								math.random(-CalculateTiltAngle(false), CalculateTiltAngle(false)),
								math.random(-CalculateTiltAngle(false), CalculateTiltAngle(false))
							),
							0.15 * deltaTime * 60
						)

						local Walking = Humanoid.MoveDirection.Magnitude > 0.01

						local WalkBobbing = Walking
								and (Vector3.new(
									math.sin(time() * Humanoid.WalkSpeed * 0.5) * CalculateBobbingAmount() * TimeScale,
									math.sin(time() * Humanoid.WalkSpeed * 0.3) * CalculateBobbingAmount() * TimeScale,
									math.sin(time() * Humanoid.WalkSpeed * 0.7) * CalculateBobbingAmount() * TimeScale
								))
							or Vector3.new(0, 0, 0)

						if isJumping then
							if not Walking then
								-- Nothing to multiply, we must add it ourselves.
								WalkBobbing = (
									Vector3.new(
										math.sin(time() * Humanoid.WalkSpeed * 0.5)
											* CalculateBobbingAmount()
											* TimeScale,
										0,
										0
									)
								)
							end

							WalkBobbing = Vector3.new(WalkBobbing.X * -1.5, WalkBobbing.Y, WalkBobbing.Z)
						end

						Camera.CFrame = Camera.CFrame
							* CFrame.fromEulerAnglesXYZ(
								math.rad(WalkBobbing.X),
								math.rad(WalkBobbing.Y),
								math.rad(WalkBobbing.Z)
							)
							* CFrame.fromEulerAnglesXYZ(0, 0, math.rad(Update.X))
					end

					RunService.RenderStepped:Connect(updateCamera)
				end)
			end
		end
	end,

	SetSprint = function(self: GameTypes.MovementService, enableSprint: boolean)
		--[[
			TODO:
				- Smooth FOV changing
				- Smoother sprinting
				- View Bobbing
		]]

		if
			FEngineFastFlags.DoesFlagExist("MovementService::SmoothFoV")
			and FEngineFastFlags.IsFlagEnabled("MovementService::SmoothFoV")
		then
			if SprintFoVTween then
				SprintFoVTween:Cancel()
			end

			SprintFoVTween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
				FieldOfView = if enableSprint then 90 else 70,
			})

			if SprintFoVTween then
				SprintFoVTween:Play()
			end
		end

		if enableSprint then
			(Players:GetCharacterOfPlayer(Players.LocalPlayer):WaitForChild("Humanoid") :: Humanoid).WalkSpeed = 30
		else
			(Players:GetCharacterOfPlayer(Players.LocalPlayer):WaitForChild("Humanoid") :: Humanoid).WalkSpeed = 16
		end
	end,
} :: InternalTypeDefinitions.FEngineModuleFunctionTable<GameTypes.MovementService>

local fengine = FEngineModule.new(
	"MovementService",
	vftable :: InternalTypeDefinitions.FEngineModuleFunctionTable<GameTypes.MovementService>
) :: GameTypes.MovementService

return fengine

--[=[
    Notice: This script runs outside of FEngine, no modules will be prepared, this script is meant to be used for implementations previous to migrating to FEngine or third party scripts that are outside of FEngine's control.
]=]

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local libs = ReplicatedFirst:WaitForChild("EngineLibraries")

-- Fly.lua
local RunService = game:GetService("RunService")

return function(toggles, connections, notify, LocalPlayer)
    return function(state)
        toggles.Fly = state
        notify("Fly " .. (state and "Enabled ✅" or "Disabled ❌"))
        if state then
            connections.fly = RunService.RenderStepped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    pcall(function()
                        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
                    end)
                end
            end)
        else
            if connections.fly then connections.fly:Disconnect(); connections.fly = nil end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end
        end
    end
end

-- InfiniteJump.lua
local UserInputService = game:GetService("UserInputService")

return function(toggles, connections, notify, LocalPlayer)
    return function(state)
        toggles.InfiniteJump = state
        notify("Infinite Jump " .. (state and "Enabled ✅" or "Disabled ❌"))
        if state then
            connections.jump = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    pcall(function()
                        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                end
            end)
        else
            if connections.jump then connections.jump:Disconnect(); connections.jump = nil end
        end
    end
end

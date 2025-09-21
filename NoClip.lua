-- NoClip.lua
local RunService = game:GetService("RunService")

return function(toggles, connections, notify, LocalPlayer)
    return function(state)
        toggles.NoClip = state
        notify("NoClip " .. (state and "Enabled ✅" or "Disabled ❌"))
        if state then
            connections.noclip = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function() part.CanCollide = false end)
                        end
                    end
                end
            end)
        else
            if connections.noclip then connections.noclip:Disconnect(); connections.noclip = nil end
        end
    end
end

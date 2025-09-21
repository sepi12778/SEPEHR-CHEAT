-- Speed.lua
return function(toggles, notify, LocalPlayer)
    return function(state)
        toggles.Speed = state
        notify("Speed " .. (state and "Enabled ✅" or "Disabled ❌"))
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            pcall(function()
                LocalPlayer.Character.Humanoid.WalkSpeed = state and 50 or 16
            end)
        end
    end
end

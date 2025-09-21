-- Invisibility.lua
return function(toggles, notify, LocalPlayer)
    return function(state)
        toggles.Invisibility = state
        notify("Invisibility " .. (state and "Enabled ✅" or "Disabled ❌"))
        if LocalPlayer.Character then
            local targetTransparency = state and 1 or 0
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    pcall(function() part.Transparency = targetTransparency end)
                end
            end
        end
    end
end

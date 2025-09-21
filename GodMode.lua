-- GodMode.lua
return function(toggles, connections, notify, LocalPlayer)
    return function(state)
        toggles.GodMode = state
        notify("God Mode " .. (state and "Enabled ✅" or "Disabled ❌"))
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if state then
                pcall(function()
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                    connections.god = humanoid.HealthChanged:Connect(function(newHealth)
                        if newHealth < humanoid.MaxHealth then
                            task.wait()
                            pcall(function() humanoid.Health = humanoid.MaxHealth end)
                        end
                    end)
                end)
            else
                if connections.god then connections.god:Disconnect(); connections.god = nil end
                pcall(function()
                    humanoid.MaxHealth = 100
                    humanoid.Health = 100
                end)
            end
        end
    end
end

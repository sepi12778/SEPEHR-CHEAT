-- AntiAFK.lua
local VirtualUser = game:GetService("VirtualUser")

return function(toggles, connections, notify, LocalPlayer)
    return function(state)
        toggles.AntiAFK = state
        notify("Anti-AFK " .. (state and "Enabled ✅" or "Disabled ❌"))
        if state then
            connections.afk = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
                notify("Anti-AFK movement performed")
            end)
        else
            if connections.afk then connections.afk:Disconnect(); connections.afk = nil end
        end
    end
end

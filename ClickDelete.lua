-- ClickDelete.lua
return function(toggles, connections, notify, LocalPlayer)
    return function(state)
        toggles.ClickDelete = state
        notify("Click Delete " .. (state and "Enabled ✅" or "Disabled ❌"))
        if state then
            local mouse = LocalPlayer:GetMouse()
            connections.click = mouse.Button1Down:Connect(function()
                if mouse.Target and mouse.Target.Parent ~= workspace then
                    pcall(function() mouse.Target:Destroy() end)
                end
            end)
        else
            if connections.click then connections.click:Disconnect(); connections.click = nil end
        end
    end
end

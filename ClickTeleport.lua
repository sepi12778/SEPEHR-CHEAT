-- ClickTeleport.lua
local TweenService = game:GetService("TweenService")
local clickTPDebounce = false

return function(toggles, connections, notify, LocalPlayer)
    return function(state)
        toggles.ClickTeleport = state
        notify("Click Teleport " .. (state and "Enabled ✅" or "Disabled ❌"))

        if state then  
            local mouse = LocalPlayer:GetMouse()  
            connections.clickTP = mouse.Button1Down:Connect(function()  
                if not toggles.ClickTeleport or clickTPDebounce then return end  
                local character = LocalPlayer.Character  
                if not character then return end  
                local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")  
                if not hrp then return end  
                local hit = mouse.Hit  
                if not hit then return end  
                local targetPos = hit.p  
                local MAX_DISTANCE = 500  
                local TWEEN_TIME = 0.2  
                local DEBOUNCE_TIME = 0.2  
                local distance = (hrp.Position - targetPos).Magnitude  
                if distance > MAX_DISTANCE then  
                    notify("Destination is too far!", true)  
                    return   
                end  
                
                clickTPDebounce = true  
                local safeCFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))  
                local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)  
                local tween = TweenService:Create(hrp, tweenInfo, {CFrame = safeCFrame})  
                tween:Play()  
                
                task.wait(DEBOUNCE_TIME)  
                clickTPDebounce = false  
            end)  
        else  
            if connections.clickTP then  
                connections.clickTP:Disconnect()  
                connections.clickTP = nil  
            end  
        end
    end
end

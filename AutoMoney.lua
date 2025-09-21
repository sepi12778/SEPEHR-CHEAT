-- AutoMoney.lua
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(toggles, notify)
    local autoMoneyConnection = nil
    local autoMoneyRemote = nil
    local autoMoneyArgs = nil

    local function SetAutoMoneyRemote(remote, args)
        if not remote or not args then
            notify("Invalid remote or arguments for Auto Money.", true)
            return
        end
        autoMoneyRemote = remote
        autoMoneyArgs = args
        notify("Auto Money remote set to: " .. remote:GetFullName(), false)

        if toggles.AutoMoney then  
            -- Restart the function with the new remote
            if autoMoneyConnection then autoMoneyConnection:Disconnect(); autoMoneyConnection = nil end
        end
    end

    local function findAndSetBestMoneyRemote()
        -- ... (کد کامل تابع findAndSetBestMoneyRemote از اسکریپت اصلی اینجا قرار می‌گیرد) ...
    end

    local function toggleAutoMoney(state)
        toggles.AutoMoney = state
        notify("Auto Money " .. (state and "Enabled ✅" or "Disabled ❌"))

        if state then  
            if not autoMoneyRemote or not autoMoneyArgs then  
                local found = findAndSetBestMoneyRemote()  
                if not found then  
                    notify("Auto Money could not start. Use Hack Panel to set a remote manually.", true)  
                    toggles.AutoMoney = false  
                    pcall(function() game:GetService("CoreGui").SEPEHRMODMenuV.MainFrame.Scroll["Auto-Money (AI)"].Checkbox.Check.Visible = false end)  
                    return  
                end  
            end  
            
            autoMoneyConnection = RunService.Heartbeat:Connect(function()  
                if not toggles.AutoMoney then   
                    if autoMoneyConnection then  
                        autoMoneyConnection:Disconnect()  
                        autoMoneyConnection = nil  
                    end  
                    return   
                end  
                
                pcall(function()  
                    if autoMoneyRemote:IsA("RemoteEvent") then autoMoneyRemote:FireServer(unpack(autoMoneyArgs))  
                    elseif autoMoneyRemote:IsA("RemoteFunction") then autoMoneyRemote:InvokeServer(unpack(autoMoneyArgs)) end  
                end)  
                task.wait(0.05)   
            end)  
        else  
            if autoMoneyConnection then  
                autoMoneyConnection:Disconnect()  
                autoMoneyConnection = nil  
            end  
        end
    end

    return toggleAutoMoney, SetAutoMoneyRemote
end

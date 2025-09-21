-- ESP.lua
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local ESPBoxes = {}
local ESPLines = {}

local function createBox(player)
    local box = Instance.new("Frame")
    box.Name = "ESP_Box_"..player.Name
    box.Size = UDim2.new(0,100,0,200)
    box.BorderColor3 = Color3.fromRGB(255,0,0)
    box.BorderSizePixel = 2
    box.BackgroundTransparency = 1
    box.Parent = CoreGui.SEPEHRMODMenuV
    box.ZIndex = 10
    return box
end

local function createLine(player)
    local line = Instance.new("Frame")
    line.Name = "ESP_Line_"..player.Name
    line.Size = UDim2.new(0,2,0,0)
    line.BackgroundColor3 = Color3.fromRGB(255,0,0)
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5,1)
    line.Parent = CoreGui.SEPEHRMODMenuV
    line.ZIndex = 10
    return line
end

return function(toggles, notify)
    local function toggleESP(state)
        toggles.ESP = state
        notify("ESP "..(state and "Enabled ✅" or "Disabled ❌"))
        if not state then
            for _, box in pairs(ESPBoxes) do if box and box.Parent then box:Destroy() end end
            for _, line in pairs(ESPLines) do if line and line.Parent then line:Destroy() end end
            ESPBoxes = {}
            ESPLines = {}
        end
    end

    local function updateESP()
        if toggles.ESP then
            for player, box in pairs(ESPBoxes) do
                if not player or not player.Parent or not Players:FindFirstChild(player.Name) then
                    if box and box.Parent then box:Destroy() end
                    ESPBoxes[player] = nil
                    if ESPLines[player] and ESPLines[player].Parent then ESPLines[player]:Destroy(); ESPLines[player]=nil end
                end
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local root = player.Character.HumanoidRootPart
                    local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)

                    if onScreen then  
                        local box = ESPBoxes[player] or createBox(player)  
                        ESPBoxes[player] = box  
                        local head = player.Character:FindFirstChild("Head")  
                        if head then  
                            local headPos = head.Position + Vector3.new(0, 1.5, 0)   
                            local rootPos = root.Position - Vector3.new(0, 3, 0)  
                            local topVec, _ = workspace.CurrentCamera:WorldToScreenPoint(headPos)  
                            local bottomVec, _ = workspace.CurrentCamera:WorldToScreenPoint(rootPos)  
                            local height = math.abs(topVec.Y - bottomVec.Y)  
                            local width = height / 2  
                            box.Size = UDim2.fromOffset(width, height)  
                            box.Position = UDim2.fromOffset(topVec.X - width / 2, topVec.Y)  
                            box.Visible = true  
                        end  
                        
                        local line = ESPLines[player] or createLine(player)  
                        ESPLines[player] = line  
                        local viewportSize = workspace.CurrentCamera.ViewportSize  
                        line.Position = UDim2.new(0.5, 0, 1, 0)   
                        local angle = math.atan2(screenPos.Y - viewportSize.Y, screenPos.X - viewportSize.X / 2)  
                        line.Rotation = math.deg(angle) + 90  
                        line.Size = UDim2.new(0, 2, 0, (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(viewportSize.X / 2, viewportSize.Y)).Magnitude)  
                        line.Visible = true  
                    else  
                        if ESPBoxes[player] then ESPBoxes[player].Visible = false end  
                        if ESPLines[player] then ESPLines[player].Visible = false end  
                    end  
                else  
                    if ESPBoxes[player] then ESPBoxes[player]:Destroy(); ESPBoxes[player] = nil end  
                    if ESPLines[player] then ESPLines[player]:Destroy(); ESPLines[player] = nil end  
                end  
            end  
        end
    end

    return toggleESP, updateESP
end

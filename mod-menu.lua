-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Local Variables
local LocalPlayer = Players.LocalPlayer
local connections = {}
local oldNamecall

-- Notification Function
local function notify(msg, err)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "SEPEHR MOD Menu" .. (err and " | Error" or " | Info"),
            Text = tostring(msg),
            Duration = 5
        })
    end)
end

-- Toggles State
local toggles = {
    Fly = false,
    Speed = false,
    InfiniteJump = false,
    NoClip = false,
    GodMode = false,
    Invisibility = false,
    AntiAFK = false,
    ClickDelete = false,
    ESP = false,
    AutoMoney = false,
    HackPanel = false,
    ClickTeleport = false,
    PlayerTP = false,
    TeleportOthers = false -- <<-- NEW
}

-- Feature Functions
local function toggleFly(state)
    toggles.Fly = state
    notify("Fly " .. (state and "Enabled ✅" or "Disabled ❌"))
    if state then
        connections.fly = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
                end)
            end
        end)
    else
        if connections.fly then connections.fly:Disconnect(); connections.fly = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            pcall(function()
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
    end
end

local function toggleSpeed(state)
    toggles.Speed = state
    notify("Speed " .. (state and "Enabled ✅" or "Disabled ❌"))
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = state and 50 or 16
        end)
    end
end

local function toggleInfiniteJump(state)
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

local function toggleNoClip(state)
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

local function toggleGodMode(state)
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

local function toggleInvisibility(state)
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

local function toggleAntiAFK(state)
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

local function toggleClickDelete(state)
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

local clickTPDebounce = false
local function toggleClickTeleport(state)
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

-- ESP System
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

RunService.RenderStepped:Connect(function()
    if toggles.ESP then
        for player, box in pairs(ESPBoxes) do
            if not player or not player.Parent or not Players:FindFirstChild(player.Name) then
                if box and box.Parent then box:Destroy() end
                ESPBoxes[player] = nil
                if ESPLines[player] and ESPLines[player].Parent then ESPLines[player]:Destroy(); ESPLines[player]=nil end
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
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
end)

-- Auto-Money System
local autoMoneyConnection = nil
local autoMoneyRemote = nil
local autoMoneyArgs = nil

function SetAutoMoneyRemote(remote, args)
    if not remote or not args then
        notify("Invalid remote or arguments for Auto Money.", true)
        return
    end
    autoMoneyRemote = remote
    autoMoneyArgs = args
    notify("Auto Money remote set to: " .. remote:GetFullName(), false)
    
    if toggles.AutoMoney then
        toggleAutoMoney(false) 
        toggleAutoMoney(true)  
    end
end

local function findAndSetBestMoneyRemote()
    notify("AI is searching for money remotes...", false)
    local keywords = {"money", "cash", "claim", "reward", "give", "farm", "auto", "collect", "get", "buy"}
    local potentialRemotes = {}
    
    for _, service in ipairs({ReplicatedStorage, workspace}) do
        for _, remote in ipairs(service:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                for _, keyword in ipairs(keywords) do
                    if remote.Name:lower():find(keyword) then
                        table.insert(potentialRemotes, remote)
                        break 
                    end
                end
            end
        end
    end
    
    if #potentialRemotes == 0 then
        notify("AI couldn't find any potential money remotes.", true)
        return false
    end

    notify("Found " .. #potentialRemotes .. " potential remotes. AI is now testing them...", false)
    
    local testArgs = { {1000000000}, {"All"}, {true}, {} }
    
    for _, remote in ipairs(potentialRemotes) do
        for _, args in ipairs(testArgs) do
            local success = pcall(function()
                if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args))
                else remote:InvokeServer(unpack(args)) end
            end)
            if success then
                notify("AI found a working remote: " .. remote.Name .. ". Setting it for Auto-Money.", false)
                SetAutoMoneyRemote(remote, args)
                return true
            end
            task.wait(0.1) 
        end
    end
    
    notify("AI tested all remotes, but none seemed to work reliably.", true)
    return false
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
                pcall(function() CoreGui.SEPEHRMODMenuV.MainFrame.Scroll["Auto-Money (AI)"].Checkbox.Check.Visible = false end)
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

-- Player Teleport Panel
local playerTPFrame = nil
local frozenPlayers = {}

local function freezePlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            notify(targetPlayer.Name .. " has been frozen.", false)
        end
        for _, part in pairs(targetPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
        frozenPlayers[targetPlayer] = true
    else
        notify("Could not freeze player. Character not found.", true)
    end
end

local function unfreezePlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character and frozenPlayers[targetPlayer] then
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50 
            notify(targetPlayer.Name .. " has been unfrozen.", false)
        end
        for _, part in pairs(targetPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
        frozenPlayers[targetPlayer] = nil
    elseif not frozenPlayers[targetPlayer] then
        notify(targetPlayer.Name .. " was not frozen.", true)
    else
        notify("Could not unfreeze player. Character not found.", true)
    end
end

local function togglePlayerTP(state)
    toggles.PlayerTP = state
    pcall(function() CoreGui.SEPEHRMODMenuV.MainFrame.Scroll["Player Menu"].Checkbox.Check.Visible = state end)

    if state then
        if playerTPFrame and playerTPFrame.Parent then playerTPFrame:Destroy() end

        playerTPFrame = Instance.new("Frame")
        playerTPFrame.Name = "PlayerTPFrame"
        playerTPFrame.Size = UDim2.new(0, 250, 0, 320)
        playerTPFrame.Position = UDim2.new(0.5, -125, 0.5, -160)
        playerTPFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        playerTPFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
        playerTPFrame.BorderSizePixel = 1
        playerTPFrame.Active = true
        playerTPFrame.Draggable = true
        playerTPFrame.Parent = CoreGui.SEPEHRMODMenuV
        playerTPFrame.ZIndex = 20

        local corner = Instance.new("UICorner", playerTPFrame)
        corner.CornerRadius = UDim.new(0, 10)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        title.Text = "Player Menu"
        title.TextColor3 = Color3.fromRGB(255, 0, 0)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 18
        title.Parent = playerTPFrame

        local titleCorner = Instance.new("UICorner", title)
        titleCorner.CornerRadius = UDim.new(0, 10)
        
        local closeBtn = Instance.new("TextButton", title)
        closeBtn.Size = UDim2.new(0, 25, 0, 25)
        closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255,50,50)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.TextSize = 16
        local cbCorner = Instance.new("UICorner", closeBtn)
        cbCorner.CornerRadius = UDim.new(0, 4)
        closeBtn.MouseButton1Click:Connect(function() togglePlayerTP(false) end)

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -10, 1, -135)
        scroll.Position = UDim2.new(0, 5, 0, 35)
        scroll.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 6
        scroll.Parent = playerTPFrame

        local scrollCorner = Instance.new("UICorner", scroll)
        scrollCorner.CornerRadius = UDim.new(0, 8)

        local layout = Instance.new("UIListLayout", scroll)
        layout.Padding = UDim.new(0, 5)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local selectedPlayer = nil

        local buttonContainer = Instance.new("Frame", playerTPFrame)
        buttonContainer.Size = UDim2.new(1, -10, 0, 80)
        buttonContainer.Position = UDim2.new(0, 5, 1, -85)
        buttonContainer.BackgroundTransparency = 1
        
        local gridLayout = Instance.new("UIGridLayout", buttonContainer)
        gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
        gridLayout.CellSize = UDim2.new(0.5, -5, 0.5, -5)

        local tpBtn = Instance.new("TextButton", buttonContainer)
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        tpBtn.Text = "Teleport"
        tpBtn.TextColor3 = Color3.new(1,1,1)
        tpBtn.Font = Enum.Font.SourceSansBold
        tpBtn.TextSize = 16
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 8)

        local refreshBtn = Instance.new("TextButton", buttonContainer)
        refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        refreshBtn.Text = "Refresh"
        refreshBtn.TextColor3 = Color3.new(1,1,1)
        refreshBtn.Font = Enum.Font.SourceSansBold
        refreshBtn.TextSize = 16
        Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 8)

        local freezeBtn = Instance.new("TextButton", buttonContainer)
        freezeBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
        freezeBtn.Text = "Freeze"
        freezeBtn.TextColor3 = Color3.new(1,1,1)
        freezeBtn.Font = Enum.Font.SourceSansBold
        freezeBtn.TextSize = 16
        Instance.new("UICorner", freezeBtn).CornerRadius = UDim.new(0, 8)

        local unfreezeBtn = Instance.new("TextButton", buttonContainer)
        unfreezeBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
        unfreezeBtn.Text = "Unfreeze"
        unfreezeBtn.TextColor3 = Color3.new(1,1,1)
        unfreezeBtn.Font = Enum.Font.SourceSansBold
        unfreezeBtn.TextSize = 16
        Instance.new("UICorner", unfreezeBtn).CornerRadius = UDim.new(0, 8)

        local function refreshPlayerList()
            for _, child in pairs(scroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            local playerButtons = {}
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local btn = Instance.new("TextButton")
                    btn.Name = plr.Name
                    btn.Size = UDim2.new(1, -5, 0, 25)
                    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
                    btn.TextColor3 = Color3.new(1,1,1)
                    btn.Text = plr.Name
                    btn.Font = Enum.Font.SourceSans
                    btn.TextSize = 16
                    btn.Parent = scroll
                    table.insert(playerButtons, btn)
                    
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

                    btn.MouseButton1Click:Connect(function()
                        selectedPlayer = plr
                        for _, b in pairs(playerButtons) do
                            b.BackgroundColor3 = Color3.fromRGB(70,70,70)
                        end
                        btn.BackgroundColor3 = Color3.fromRGB(0,120,200)
                        notify("Selected player: " .. plr.Name)
                    end)
                end
            end
            scroll.CanvasSize = UDim2.new(0,0,0, #playerButtons * 30)
        end

        refreshPlayerList()
        refreshBtn.MouseButton1Click:Connect(refreshPlayerList)

        tpBtn.MouseButton1Click:Connect(function()
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local target = selectedPlayer.Character.HumanoidRootPart
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0,3,0)
                    notify("Teleported to " .. selectedPlayer.Name)
                end
            else
                notify("Could not teleport. Player not selected or has no character.", true)
            end
        end)
        
        freezeBtn.MouseButton1Click:Connect(function()
            if selectedPlayer then
                freezePlayer(selectedPlayer)
            else
                notify("No player selected.", true)
            end
        end)

        unfreezeBtn.MouseButton1Click:Connect(function()
            if selectedPlayer then
                unfreezePlayer(selectedPlayer)
            else
                notify("No player selected.", true)
            end
        end)
        
        local playerAddedConn = Players.PlayerAdded:Connect(refreshPlayerList)
        local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
            if frozenPlayers[player] then
                frozenPlayers[player] = nil
            end
            if selectedPlayer == player then
                selectedPlayer = nil
            end
            refreshPlayerList()
        end)

        connections.playerTPConns = {playerAddedConn, playerRemovingConn}

    else
        if playerTPFrame and playerTPFrame.Parent then
            playerTPFrame:Destroy()
            playerTPFrame = nil
        end
        if connections.playerTPConns then
            for _, conn in ipairs(connections.playerTPConns) do conn:Disconnect() end
            connections.playerTPConns = nil
        end
        for player, _ in pairs(frozenPlayers) do
            unfreezePlayer(player)
        end
        frozenPlayers = {}
    end
end

-- ================== NEW FEATURE: TELEPORT OTHER PLAYERS ==================
local tpOthersFrame = nil

local function toggleTeleportOthers(state)
    toggles.TeleportOthers = state
    pcall(function() CoreGui.SEPEHRMODMenuV.MainFrame.Scroll["Teleport Other Players"].Checkbox.Check.Visible = state end)

    if state then
        if tpOthersFrame and tpOthersFrame.Parent then tpOthersFrame:Destroy() end

        tpOthersFrame = Instance.new("Frame")
        tpOthersFrame.Name = "TeleportOthersFrame"
        tpOthersFrame.Size = UDim2.new(0, 300, 0, 400)
        tpOthersFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
        tpOthersFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tpOthersFrame.BorderColor3 = Color3.fromRGB(0, 170, 0)
        tpOthersFrame.BorderSizePixel = 1
        tpOthersFrame.Active = true
        tpOthersFrame.Draggable = true
        tpOthersFrame.Parent = CoreGui.SEPEHRMODMenuV
        tpOthersFrame.ZIndex = 21

        Instance.new("UICorner", tpOthersFrame).CornerRadius = UDim.new(0, 10)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        title.Text = "Teleport Others"
        title.TextColor3 = Color3.fromRGB(0, 255, 0)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 18
        title.Parent = tpOthersFrame
        Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

        local closeBtn = Instance.new("TextButton", title)
        closeBtn.Size = UDim2.new(0, 25, 0, 25)
        closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255,50,50)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.TextSize = 16
        local cbCorner = Instance.new("UICorner", closeBtn)
        cbCorner.CornerRadius = UDim.new(0, 4)
        closeBtn.MouseButton1Click:Connect(function() toggleTeleportOthers(false) end)

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -10, 0, 200)
        scroll.Position = UDim2.new(0, 5, 0, 35)
        scroll.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 6
        scroll.Parent = tpOthersFrame
        Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)

        local layout = Instance.new("UIListLayout", scroll)
        layout.Padding = UDim.new(0, 5)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local selectedPlayer = nil

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(1, -10, 0, 35)
        tpBtn.Position = UDim2.new(0, 5, 0, 245)
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        tpBtn.Text = "Teleport Selected Player"
        tpBtn.TextColor3 = Color3.new(1,1,1)
        tpBtn.Font = Enum.Font.SourceSansBold
        tpBtn.TextSize = 16
        tpBtn.Parent = tpOthersFrame
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 8)

        local xBox = Instance.new("TextBox")
        xBox.Size = UDim2.new(1, -10, 0, 25)
        xBox.Position = UDim2.new(0, 5, 0, 290)
        xBox.PlaceholderText = "Coordinate X"
        xBox.TextColor3 = Color3.new(1,1,1)
        xBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
        xBox.Font = Enum.Font.SourceSans
        xBox.TextSize = 16
        xBox.ClearTextOnFocus = false
        xBox.Parent = tpOthersFrame
        Instance.new("UICorner", xBox).CornerRadius = UDim.new(0, 6)

        local yBox = Instance.new("TextBox")
        yBox.Size = UDim2.new(1, -10, 0, 25)
        yBox.Position = UDim2.new(0, 5, 0, 320)
        yBox.PlaceholderText = "Coordinate Y"
        yBox.TextColor3 = Color3.new(1,1,1)
        yBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
        yBox.Font = Enum.Font.SourceSans
        yBox.TextSize = 16
        yBox.ClearTextOnFocus = false
        yBox.Parent = tpOthersFrame
        Instance.new("UICorner", yBox).CornerRadius = UDim.new(0, 6)

        local zBox = Instance.new("TextBox")
        zBox.Size = UDim2.new(1, -10, 0, 25)
        zBox.Position = UDim2.new(0, 5, 0, 350)
        zBox.PlaceholderText = "Coordinate Z"
        zBox.TextColor3 = Color3.new(1,1,1)
        zBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
        zBox.Font = Enum.Font.SourceSans
        zBox.TextSize = 16
        zBox.ClearTextOnFocus = false
        zBox.Parent = tpOthersFrame
        Instance.new("UICorner", zBox).CornerRadius = UDim.new(0, 6)

        local function refreshPlayerList()
            local playerButtons = {}
            for _, child in pairs(scroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -5, 0, 25)
                    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
                    btn.TextColor3 = Color3.new(1,1,1)
                    btn.Text = plr.Name
                    btn.Font = Enum.Font.SourceSans
                    btn.TextSize = 16
                    btn.Parent = scroll
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                    table.insert(playerButtons, btn)
                    
                    btn.MouseButton1Click:Connect(function()
                        selectedPlayer = plr
                        for _, b in pairs(playerButtons) do
                            b.BackgroundColor3 = Color3.fromRGB(70,70,70)
                        end
                        btn.BackgroundColor3 = Color3.fromRGB(0,120,200)
                        notify("Selected player for teleport: " .. plr.Name)
                    end)
                end
            end
            scroll.CanvasSize = UDim2.new(0,0,0, #playerButtons * 30)
        end

        refreshPlayerList()
        local pAdded = Players.PlayerAdded:Connect(refreshPlayerList)
        local pRemoved = Players.PlayerRemoving:Connect(function(plr)
            if selectedPlayer == plr then selectedPlayer = nil end
            refreshPlayerList()
        end)
        connections.tpOthersConns = {pAdded, pRemoved}

        tpBtn.MouseButton1Click:Connect(function()
            if not selectedPlayer then
                notify("Please select a player first.", true)
                return
            end
            if not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                notify("Selected player has no character to teleport.", true)
                return
            end

            local x = tonumber(xBox.Text)
            local y = tonumber(yBox.Text)
            local z = tonumber(zBox.Text)
            
            if x and y and z then
                local hrp = selectedPlayer.Character.HumanoidRootPart
                local hum = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
                
                if hum then
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                end
                
                pcall(function()
                    hrp.Anchored = true
                    hrp.CFrame = CFrame.new(x, y, z)
                end)
                notify(selectedPlayer.Name .. " teleported and frozen at " .. tostring(Vector3.new(x,y,z)), false)
            else
                notify("Invalid coordinates. Please enter numbers only.", true)
            end
        end)

    else
        if tpOthersFrame and tpOthersFrame.Parent then
            tpOthersFrame:Destroy()
            tpOthersFrame = nil
        end
        if connections.tpOthersConns then
            for _, conn in pairs(connections.tpOthersConns) do conn:Disconnect() end
            connections.tpOthersConns = nil
        end
    end
end
-- ================= END OF NEW FEATURE =================


-- GUI Setup
if CoreGui:FindFirstChild("SEPEHRMODMenuV") then
    CoreGui:FindFirstChild("SEPEHRMODMenuV"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SEPEHRMODMenuV"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MainFrame"
menuFrame.Size = UDim2.new(0.9, 0, 0.88, 0)
menuFrame.Position = UDim2.new(0.05, 0, 0.06, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
menuFrame.BorderSizePixel = 2
menuFrame.Active = true
menuFrame.Draggable = true
menuFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", menuFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel", menuFrame)
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 0, 44)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "SEPEHR MOD Menu V (Mobile)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
TitleLabel.TextSize = 22

local ScrollingFrame = Instance.new("ScrollingFrame", menuFrame)
ScrollingFrame.Name = "Scroll"
ScrollingFrame.Position = UDim2.new(0, 0, 0, 44)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -104)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.ScrollBarThickness = 10
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)

local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function makeToggle(text, callback, order)
    local btn = Instance.new("TextButton")
    btn.Name = text
    btn.Parent = ScrollingFrame
    btn.Size = UDim2.new(1, -24, 0, 44)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Font = Enum.Font.SourceSans
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order

    local checkbox = Instance.new("Frame", btn)
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, 26, 0, 26)
    checkbox.Position = UDim2.new(1, -34, 0.5, -13)
    checkbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    checkbox.BorderColor3 = Color3.fromRGB(255, 0, 0)
    checkbox.BorderSizePixel = 2
    local cbcorner = Instance.new("UICorner", checkbox)
    cbcorner.CornerRadius = UDim.new(0, 4)

    local checkmark = Instance.new("Frame", checkbox)
    checkmark.Name = "Check"
    checkmark.Size = UDim2.new(1, -8, 1, -8)
    checkmark.Position = UDim2.new(0, 4, 0, 4)
    checkmark.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    checkmark.BorderSizePixel = 0
    checkmark.Visible = false

    btn.MouseButton1Click:Connect(function()
        checkmark.Visible = not checkmark.Visible
        pcall(callback, checkmark.Visible)
    end)
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    return btn
end

makeToggle("Fly", toggleFly, 1)
makeToggle("High Speed", toggleSpeed, 2)
makeToggle("Infinite Jump", toggleInfiniteJump, 3)
makeToggle("God Mode", toggleGodMode, 4)
makeToggle("NoClip", toggleNoClip, 5)
makeToggle("Invisibility", toggleInvisibility, 6)
makeToggle("Anti-AFK", toggleAntiAFK, 7)
makeToggle("Click Delete", toggleClickDelete, 8)
makeToggle("Click Teleport", toggleClickTeleport, 9)
makeToggle("ESP (Box+Line)", toggleESP, 10)
makeToggle("Player Menu", togglePlayerTP, 11)
makeToggle("Teleport Other Players", toggleTeleportOthers, 12) -- <<-- NEW
makeToggle("Auto-Money (AI)", toggleAutoMoney, 13)
makeToggle("Hack Panel (Advanced)", toggleHackPanel, 14)


-- Footer & Hide/Open Buttons
local FooterFrame = Instance.new("Frame", menuFrame)
FooterFrame.Size = UDim2.new(1, 0, 0, 50)
FooterFrame.Position = UDim2.new(0, 0, 1, -50)
FooterFrame.BackgroundTransparency = 1

local HideButton = Instance.new("TextButton", FooterFrame)
HideButton.Size = UDim2.new(0.5, -10, 1, -10)
HideButton.Position = UDim2.new(0.25, 0, 0.5, 0)
HideButton.AnchorPoint = Vector2.new(0.5, 0.5)
HideButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HideButton.Font = Enum.Font.SourceSansBold
HideButton.Text = "[Hide]"
HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideButton.TextSize = 16
local hc = Instance.new("UICorner", HideButton)
hc.CornerRadius = UDim.new(0, 6)

local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 160, 0, 44)
OpenButton.Position = UDim2.new(0.5, -80, 0.02, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
OpenButton.BorderSizePixel = 1
OpenButton.Text = "Open SEPEHR MOD Menu"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 16
OpenButton.Visible = false
local openCorner = Instance.new("UICorner", OpenButton)
openCorner.CornerRadius = UDim.new(0, 8)

HideButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    OpenButton.Visible = true
end)
OpenButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = true
    OpenButton.Visible = false
end)

-- Hack Panel (Advanced Features)
local hackFrame, spyConnection
local allRemotes = {}
local spyHistory = {} 

local function formatArgs(args)
    local s = {}
    for i, v in ipairs(args) do
        local t = typeof(v)
        if t == "string" then
            s[i] = string.format('"%s"', tostring(v):gsub('"', '\\"'):gsub("\n", "\\n"))
        elseif t == "Instance" then
            s[i] = "game:" .. v:GetFullName()
        elseif t == "Vector3" then
            s[i] = string.format("Vector3.new(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z)
        elseif t == "CFrame" then
            s[i] = "CFrame.new(...)"
        elseif t == "nil" then
            s[i] = "nil"
        elseif t == "table" then
            s[i] = HttpService:JSONEncode(v) 
        else
            s[i] = tostring(v)
        end
    end
    return table.concat(s, ", ")
end

local function parseArgs(argString)
    argString = argString:gsub("^%s*", ""):gsub("%s*$", "") 
    if argString == "" then return {} end
    
    local f = loadstring("return {" .. argString .. "}")
    if not f then return nil, "Syntax Error" end
    
    local env = getfenv()
    setfenv(f, env)

    local success, result = pcall(f)
    if not success then return nil, tostring(result) end
    return result
end

local function fireRemote(remote, args)
    if not remote or not remote.Parent then
        notify("Remote does not exist anymore.", true)
        return
    end
    notify("Firing: " .. remote.Name)
    pcall(function()
        if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args))
        else remote:InvokeServer(unpack(args)) end
    end)
end

local function addSpyEntry(liveSpyPage, remote, args, argsString)
    if not hackFrame or not hackFrame.Parent then return end

    local remoteFrame = Instance.new("Frame", liveSpyPage)
    remoteFrame.Size = UDim2.new(1, -10, 0, 90) 
    remoteFrame.BackgroundColor3 = remote:IsA("RemoteEvent") and Color3.fromRGB(40,40,60) or Color3.fromRGB(60,40,40)
    
    local remoteName = Instance.new("TextLabel", remoteFrame)
    remoteName.Size = UDim2.new(1, -10, 0, 25)
    remoteName.Position = UDim2.new(0, 5, 0, 0)
    remoteName.BackgroundTransparency = 1
    remoteName.TextColor3 = Color3.fromRGB(255, 100, 0)
    remoteName.Text = remote:GetFullName()
    remoteName.TextXAlignment = Enum.TextXAlignment.Left
    remoteName.Font = Enum.Font.Code
    
    local argsBox = Instance.new("TextBox", remoteFrame)
    argsBox.Size = UDim2.new(1, -10, 0, 30)
    argsBox.Position = UDim2.new(0, 5, 0, 25)
    argsBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    argsBox.TextColor3 = Color3.fromRGB(200,200,200)
    argsBox.Font = Enum.Font.Code
    argsBox.Text = argsString
    argsBox.ClearTextOnFocus = false
    argsBox.TextXAlignment = Enum.TextXAlignment.Left
    
    local reFireBtn = Instance.new("TextButton", remoteFrame)
    reFireBtn.Size = UDim2.new(0, 90, 0, 28)
    reFireBtn.Position = UDim2.new(0, 5, 1, -30)
    reFireBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    reFireBtn.Text = "Re-Fire"
    reFireBtn.TextColor3 = Color3.fromRGB(255,255,255)
    reFireBtn.MouseButton1Click:Connect(function()
        local newArgs, err = parseArgs(argsBox.Text)
        if newArgs then fireRemote(remote, newArgs) else notify("Invalid args: "..err, true) end
    end)
    
    local setAutoBtn = Instance.new("TextButton", remoteFrame)
    setAutoBtn.Size = UDim2.new(0, 150, 0, 28)
    setAutoBtn.Position = UDim2.new(0, 105, 1, -30)
    setAutoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    setAutoBtn.Text = "Set Auto-Money"
    setAutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
    setAutoBtn.MouseButton1Click:Connect(function()
        local newArgs, err = parseArgs(argsBox.Text)
        if newArgs then SetAutoMoneyRemote(remote, newArgs) else notify("Invalid args: "..err, true) end
    end)
    
    liveSpyPage.CanvasPosition = Vector2.new(0, liveSpyPage.UIListLayout.AbsoluteContentSize.Y)
end

local function toggleHackPanel(state)
    toggles.HackPanel = state
    pcall(function() menuFrame.Scroll["Hack Panel (Advanced)"].Checkbox.Check.Visible = state end)
    
    if state then
        if hackFrame and hackFrame.Parent then hackFrame:Destroy() end
        
        hackFrame = Instance.new("Frame")
        hackFrame.Name = "HackPanel"
        hackFrame.Size = UDim2.new(0.95, 0, 0.9, 0)
        hackFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        hackFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        hackFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        hackFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
        hackFrame.BorderSizePixel = 2
        hackFrame.Active = true
        hackFrame.Draggable = true
        hackFrame.Parent = ScreenGui
        local hfCorner = Instance.new("UICorner", hackFrame); hfCorner.CornerRadius = UDim.new(0, 8)
        
        local title = Instance.new("TextLabel", hackFrame)
        title.Size = UDim2.new(1, 0, 0, 40); title.BackgroundTransparency = 1; title.Font = Enum.Font.SourceSansBold; title.Text = "SEPEHR HACK PANEL"; title.TextColor3 = Color3.fromRGB(0, 255, 255); title.TextSize = 20

        local closeBtn = Instance.new("TextButton", hackFrame)
        closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -35, 0, 5); closeBtn.BackgroundColor3 = Color3.fromRGB(255,50,50); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255,255,255); closeBtn.Font = Enum.Font.SourceSansBold; closeBtn.TextSize = 18; local cbCorner = Instance.new("UICorner", closeBtn); cbCorner.CornerRadius = UDim.new(0, 4)
        closeBtn.MouseButton1Click:Connect(function() toggleHackPanel(false) end)

        local tabFrame = Instance.new("Frame", hackFrame); tabFrame.Size = UDim2.new(1, 0, 0, 35); tabFrame.Position = UDim2.new(0, 0, 0, 40); tabFrame.BackgroundTransparency = 1
        local tabLayout = Instance.new("UIListLayout", tabFrame); tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; tabLayout.Padding = UDim.new(0, 10)

        local contentFrame = Instance.new("Frame", hackFrame); contentFrame.Size = UDim2.new(1, -10, 1, -80); contentFrame.Position = UDim2.new(0, 5, 0, 75); contentFrame.BackgroundTransparency = 1
        
        local remoteListPage = Instance.new("ScrollingFrame", contentFrame); remoteListPage.Name = "RemoteList"; remoteListPage.Size = UDim2.new(1, 0, 1, -40); remoteListPage.BackgroundColor3 = Color3.fromRGB(15,15,15); remoteListPage.AutomaticCanvasSize = Enum.AutomaticSize.Y; remoteListPage.ScrollBarThickness = 8
        local rlLayout = Instance.new("UIListLayout", remoteListPage); rlLayout.Padding = UDim.new(0, 5)

        local searchBox = Instance.new("TextBox", contentFrame); searchBox.Size = UDim2.new(1, 0, 0, 35); searchBox.Position = UDim2.new(0, 0, 1, -35); searchBox.PlaceholderText = "Search Remotes..."; searchBox.Font = Enum.Font.SourceSans; searchBox.TextSize = 16; searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40); searchBox.TextColor3 = Color3.fromRGB(220,220,220)

        local liveSpyPage = Instance.new("ScrollingFrame", contentFrame); liveSpyPage.Name = "LiveSpy"; liveSpyPage.Size = UDim2.new(1, 0, 1, 0); liveSpyPage.BackgroundColor3 = Color3.fromRGB(15,15,15); liveSpyPage.AutomaticCanvasSize = Enum.AutomaticSize.Y; liveSpyPage.ScrollBarThickness = 8; liveSpyPage.Visible = false
        local lsLayout = Instance.new("UIListLayout", liveSpyPage); lsLayout.Padding = UDim.new(0, 5); liveSpyPage.UIListLayout = lsLayout
        
        local activeTabColor, inactiveTabColor = Color3.fromRGB(0, 150, 150), Color3.fromRGB(40, 40, 40)
        local tab1 = Instance.new("TextButton", tabFrame); tab1.Name = "RemoteListTab"; tab1.Size = UDim2.new(0.4, 0, 1, 0); tab1.Text = "Remote List"; tab1.Font = Enum.Font.SourceSansBold; tab1.TextColor3 = Color3.fromRGB(255,255,255); tab1.BackgroundColor3 = activeTabColor
        local tab2 = Instance.new("TextButton", tabFrame); tab2.Name = "LiveSpyTab"; tab2.Size = UDim2.new(0.4, 0, 1, 0); tab2.Text = "Live Spy"; tab2.Font = Enum.Font.SourceSansBold; tab2.TextColor3 = Color3.fromRGB(255,255,255); tab2.BackgroundColor3 = inactiveTabColor

        tab1.MouseButton1Click:Connect(function() remoteListPage.Visible, searchBox.Visible, liveSpyPage.Visible = true, true, false; tab1.BackgroundColor3, tab2.BackgroundColor3 = activeTabColor, inactiveTabColor end)
        tab2.MouseButton1Click:Connect(function() remoteListPage.Visible, searchBox.Visible, liveSpyPage.Visible = false, false, true; tab1.BackgroundColor3, tab2.BackgroundColor3 = inactiveTabColor, activeTabColor end)
        
        for _, entry in ipairs(spyHistory) do
            addSpyEntry(liveSpyPage, entry.remote, entry.args, entry.argsString)
        end
        
        local function populateRemotes(filter)
            filter = filter and filter:lower() or ""; for _, v in ipairs(remoteListPage:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
            for _, remote in ipairs(allRemotes) do
                if filter == "" or remote:GetFullName():lower():find(filter) then
                    local remoteFrame = Instance.new("Frame"); remoteFrame.Size = UDim2.new(1, 0, 0, 90); remoteFrame.BackgroundColor3 = remote:IsA("RemoteEvent") and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(50, 40, 40); remoteFrame.Parent = remoteListPage; local rfCorner = Instance.new("UICorner", remoteFrame)
                    local remoteName = Instance.new("TextLabel", remoteFrame); remoteName.Size = UDim2.new(1, -10, 0, 25); remoteName.Position = UDim2.new(0, 5, 0, 0); remoteName.BackgroundTransparency = 1; remoteName.TextColor3 = Color3.fromRGB(0, 255, 255); remoteName.Text = remote:GetFullName(); remoteName.Font = Enum.Font.Code; remoteName.TextXAlignment = Enum.TextXAlignment.Left
                    local argsBox = Instance.new("TextBox", remoteFrame); argsBox.Size = UDim2.new(1, -10, 0, 30); argsBox.Position = UDim2.new(0, 5, 0, 25); argsBox.PlaceholderText = "Arguments, e.g., 1000, 'hello', true"; argsBox.Font = Enum.Font.Code; argsBox.TextSize = 14; argsBox.ClearTextOnFocus = false
                    local fireBtn = Instance.new("TextButton", remoteFrame); fireBtn.Size = UDim2.new(0, 80, 0, 28); fireBtn.Position = UDim2.new(0, 5, 1, -30); fireBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0); fireBtn.Text = "Fire"; fireBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    fireBtn.MouseButton1Click:Connect(function() local args, err = parseArgs(argsBox.Text); if args then fireRemote(remote, args) else notify("Invalid Args: " .. err, true) end end)
                    local setAutoBtn = Instance.new("TextButton", remoteFrame); setAutoBtn.Size = UDim2.new(0, 150, 0, 28); setAutoBtn.Position = UDim2.new(0, 95, 1, -30); setAutoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0); setAutoBtn.Text = "Set as Auto-Money"; setAutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    setAutoBtn.MouseButton1Click:Connect(function() local args, err = parseArgs(argsBox.Text); if args then SetAutoMoneyRemote(remote, args) else notify("Cannot set Auto-Money. Invalid Args: " .. err, true) end end)
                end
            end
        end

        if #allRemotes == 0 then 
            local locations = {ReplicatedStorage, workspace, Players, Lighting, CoreGui}
            for _, loc in ipairs(locations) do
                if loc then for _, obj in ipairs(loc:GetDescendants()) do if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then table.insert(allRemotes, obj) end end end
            end
            notify("Found " .. #allRemotes .. " remotes.", false)
        end
        populateRemotes()
        searchBox.FocusLost:Connect(function(enterPressed) if enterPressed then populateRemotes(searchBox.Text) end end)
        searchBox:GetPropertyChangedSignal("Text"):Connect(function() if searchBox.Text == "" then populateRemotes() end end)

        if not getrawmetatable then
            notify("Warning: Your executor does not support getrawmetatable. Remote spy is disabled.", true)
        else
            if spyConnection then return end 
            local mt = getrawmetatable(game)
            oldNamecall = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if (method == "FireServer" or method == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                    local args = {...}
                    local argsString = formatArgs(args)
                    
                    table.insert(spyHistory, {remote = self, args = args, argsString = argsString})
                    
                    if #spyHistory > 150 then
                        table.remove(spyHistory, 1)
                        if hackFrame and hackFrame.Parent and liveSpyPage:FindFirstChildOfClass("Frame") then
                            liveSpyPage:FindFirstChildOfClass("Frame"):Destroy()
                        end
                    end
                    
                    if hackFrame and hackFrame.Parent and liveSpyPage.Visible then
                        task.spawn(addSpyEntry, liveSpyPage, self, args, argsString)
                    end
                end
                return oldNamecall(self, ...)
            end)
            spyConnection = {mt = mt, old = oldNamecall}
        end
    else
        if hackFrame then hackFrame:Destroy(); hackFrame = nil end
    end
end

notify("SEPEHR MOD Menu loaded successfully!")

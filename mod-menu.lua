-- ===========================
-- SEPEHR MOD Menu V (AI-Enhanced Edition)
-- نسخه اصلاح شده توسط دستیار هوش مصنوعی - پنل هک پیشرفته و AutoMoney قابل اعتماد
-- ===========================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local connections = {}

-- =============================================
-- Notification helper
-- =============================================
local function notify(msg, err)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "SEPEHR MOD Menu" .. (err and " | Error" or ""),
            Text = msg,
            Duration = 5
        })
    end)
end

-- =============================================
-- Feature toggles
-- =============================================
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
    HackPanel = false
}

-- =============================================
-- Player Features (بدون تغییر)
-- =============================================

-- Fly
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
        if connections.fly then connections.fly:Disconnect() connections.fly = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            pcall(function()
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
    end
end

-- Speed
local function toggleSpeed(state)
    toggles.Speed = state
    notify("Speed " .. (state and "Enabled ✅" or "Disabled ❌"))
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = state and 50 or 16
        end)
    end
end

-- Infinite Jump
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
        if connections.jump then connections.jump:Disconnect() connections.jump = nil end
    end
end

-- NoClip
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
        if connections.noclip then connections.noclip:Disconnect() connections.noclip = nil end
    end
end

-- God Mode
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
            if connections.god then connections.god:Disconnect() connections.god = nil end
            pcall(function()
                humanoid.MaxHealth = 100
                humanoid.Health = 100
            end)
        end
    end
end

-- Invisibility
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

-- Anti-AFK
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
        if connections.afk then connections.afk:Disconnect() connections.afk = nil end
    end
end

-- Click Delete
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
        if connections.click then connections.click:Disconnect() connections.click = nil end
    end
end

-- =============================================
-- ESP (بدون تغییر)
-- =============================================
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
                if ESPLines[player] and ESPLines[player].Parent then ESPLines[player]:Destroy() ESPLines[player]=nil end
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
                if ESPBoxes[player] then ESPBoxes[player]:Destroy() ESPBoxes[player] = nil end
                if ESPLines[player] then ESPLines[player]:Destroy() ESPLines[player] = nil end
            end
        end
    end
end)

-- =============================================
-- Auto Money - REWORKED
-- =============================================
local autoMoneyConnection = nil
local autoMoneyRemote = nil
local autoMoneyArgs = nil

-- این تابع حالا از پنل هک فراخوانی می‌شود
function SetAutoMoneyRemote(remote, args)
    if not remote or not args then
        notify("Invalid remote or arguments for Auto Money.", true)
        return
    end
    autoMoneyRemote = remote
    autoMoneyArgs = args
    notify("Auto Money remote set to: " .. remote:GetFullName(), false)
    
    -- اگر AutoMoney روشن بود، لوپ را با ریموت جدید آپدیت کن
    if toggles.AutoMoney then
        toggleAutoMoney(false) -- stop old loop
        toggleAutoMoney(true)  -- start new loop
    end
end

local function toggleAutoMoney(state)
    toggles.AutoMoney = state
    notify("Auto Money " .. (state and "Enabled ✅" or "Disabled ❌"))

    if state then
        if not autoMoneyRemote or not autoMoneyArgs then
            notify("Auto Money remote is not set! Use Hack Panel to set it.", true)
            toggles.AutoMoney = false -- Turn it back off
            -- find the button and untoggle it visually
            pcall(function()
                CoreGui.SEPEHRMODMenuV.MainFrame.Scroll["Auto Money (Advanced)"].Check.Visible = false
            end)
            return
        end

        autoMoneyConnection = RunService.Heartbeat:Connect(function()
            if not toggles.AutoMoney then return end
            pcall(function()
                if autoMoneyRemote:IsA("RemoteEvent") then
                    autoMoneyRemote:FireServer(unpack(autoMoneyArgs))
                elseif autoMoneyRemote:IsA("RemoteFunction") then
                    autoMoneyRemote:InvokeServer(unpack(autoMoneyArgs))
                end
            end)
            task.wait(0.05) -- Fire interval
        end)
    else
        if autoMoneyConnection then
            autoMoneyConnection:Disconnect()
            autoMoneyConnection = nil
        end
    end
end

-- =============================================
-- GUI Setup
-- =============================================
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
ScrollingFrame.Size = UDim2.new(1, 0, 1, -104) -- Adjusted size
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
makeToggle("ESP (Box+Line)", toggleESP, 9)
makeToggle("Auto Money (Advanced)", toggleAutoMoney, 10)

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

-- =============================================
-- HACK PANEL (REMOTE SPY) - COMPLETELY REWORKED
-- =============================================
local hackFrame, spyConnection
local allRemotes = {}

local function formatArgs(args)
    local s = {}
    for i, v in ipairs(args) do
        local t = typeof(v)
        if t == "string" then
            s[i] = string.format('"%s"', tostring(v):gsub('"', '\\"'))
        elseif t == "Instance" then
            s[i] = "game:" .. v:GetFullName()
        elseif t == "Vector3" then
            s[i] = string.format("Vector3.new(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z)
        elseif t == "CFrame" then
            s[i] = "CFrame.new()" -- Simple representation
        else
            s[i] = tostring(v)
        end
    end
    return table.concat(s, ", ")
end

local function parseArgs(argString)
    local f = loadstring("return {" .. argString .. "}")
    if not f then return nil, "Syntax Error" end
    local success, result = pcall(f)
    if not success then return nil, tostring(result) end
    return result
end

local function toggleHackPanel(state)
    toggles.HackPanel = state
    pcall(function()
        menuFrame.Scroll["Hack Panel (Advanced)"].Checkbox.Check.Visible = state
    end)
    
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
        local hfCorner = Instance.new("UICorner", hackFrame)
        hfCorner.CornerRadius = UDim.new(0, 8)
        
        local title = Instance.new("TextLabel", hackFrame)
        title.Size = UDim2.new(1, 0, 0, 40)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.SourceSansBold
        title.Text = "SEPEHR HACK PANEL"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.TextSize = 20

        local closeBtn = Instance.new("TextButton", hackFrame)
        closeBtn.Size = UDim2.new(0, 30, 0, 30)
        closeBtn.Position = UDim2.new(1, -35, 0, 5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255,50,50)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.TextSize = 18
        local cbCorner = Instance.new("UICorner", closeBtn)
        cbCorner.CornerRadius = UDim.new(0, 4)
        closeBtn.MouseButton1Click:Connect(function() toggleHackPanel(false) end)

        -- Tabs
        local tabFrame = Instance.new("Frame", hackFrame)
        tabFrame.Size = UDim2.new(1, 0, 0, 35)
        tabFrame.Position = UDim2.new(0, 0, 0, 40)
        tabFrame.BackgroundTransparency = 1
        local tabLayout = Instance.new("UIListLayout", tabFrame)
        tabLayout.FillDirection = Enum.FillDirection.Horizontal
        tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabLayout.Padding = UDim.new(0, 10)

        local contentFrame = Instance.new("Frame", hackFrame)
        contentFrame.Size = UDim2.new(1, -10, 1, -80)
        contentFrame.Position = UDim2.new(0, 5, 0, 75)
        contentFrame.BackgroundTransparency = 1
        
        -- Content Pages
        local remoteListPage = Instance.new("ScrollingFrame", contentFrame)
        remoteListPage.Name = "RemoteList"
        remoteListPage.Size = UDim2.new(1, 0, 1, -40)
        remoteListPage.BackgroundColor3 = Color3.fromRGB(15,15,15)
        remoteListPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        remoteListPage.ScrollBarThickness = 8
        local rlLayout = Instance.new("UIListLayout", remoteListPage)
        rlLayout.Padding = UDim.new(0, 5)

        local searchBox = Instance.new("TextBox", contentFrame)
        searchBox.Size = UDim2.new(1, 0, 0, 35)
        searchBox.Position = UDim2.new(0, 0, 1, -35)
        searchBox.PlaceholderText = "Search Remotes..."
        searchBox.Font = Enum.Font.SourceSans
        searchBox.TextSize = 16
        searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
        searchBox.TextColor3 = Color3.fromRGB(220,220,220)

        local liveSpyPage = Instance.new("ScrollingFrame", contentFrame)
        liveSpyPage.Name = "LiveSpy"
        liveSpyPage.Size = UDim2.new(1, 0, 1, 0)
        liveSpyPage.BackgroundColor3 = Color3.fromRGB(15,15,15)
        liveSpyPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        liveSpyPage.ScrollBarThickness = 8
        liveSpyPage.Visible = false
        local lsLayout = Instance.new("UIListLayout", liveSpyPage)
        lsLayout.Padding = UDim.new(0, 5)

        -- Tab Buttons
        local activeTabColor = Color3.fromRGB(0, 150, 150)
        local inactiveTabColor = Color3.fromRGB(40, 40, 40)

        local tab1 = Instance.new("TextButton", tabFrame)
        tab1.Name = "RemoteListTab"
        tab1.Size = UDim2.new(0.4, 0, 1, 0)
        tab1.Text = "Remote List"
        tab1.Font = Enum.Font.SourceSansBold
        tab1.TextColor3 = Color3.fromRGB(255,255,255)
        tab1.BackgroundColor3 = activeTabColor
        
        local tab2 = Instance.new("TextButton", tabFrame)
        tab2.Name = "LiveSpyTab"
        tab2.Size = UDim2.new(0.4, 0, 1, 0)
        tab2.Text = "Live Spy"
        tab2.Font = Enum.Font.SourceSansBold
        tab2.TextColor3 = Color3.fromRGB(255,255,255)
        tab2.BackgroundColor3 = inactiveTabColor

        tab1.MouseButton1Click:Connect(function()
            remoteListPage.Visible = true
            searchBox.Visible = true
            liveSpyPage.Visible = false
            tab1.BackgroundColor3 = activeTabColor
            tab2.BackgroundColor3 = inactiveTabColor
        end)
        tab2.MouseButton1Click:Connect(function()
            remoteListPage.Visible = false
            searchBox.Visible = false
            liveSpyPage.Visible = true
            tab1.BackgroundColor3 = inactiveTabColor
            tab2.BackgroundColor3 = activeTabColor
        end)

        -- Populate Remote List
        local function populateRemotes(filter)
            filter = filter and filter:lower() or ""
            for _, v in ipairs(remoteListPage:GetChildren()) do
                if v:IsA("Frame") then v:Destroy() end
            end
            
            for _, remote in ipairs(allRemotes) do
                if filter == "" or remote:GetFullName():lower():find(filter) then
                    local remoteFrame = Instance.new("Frame")
                    remoteFrame.Size = UDim2.new(1, 0, 0, 90)
                    remoteFrame.BackgroundColor3 = remote:IsA("RemoteEvent") and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(50, 40, 40)
                    remoteFrame.Parent = remoteListPage
                    local rfCorner = Instance.new("UICorner", remoteFrame)

                    local remoteName = Instance.new("TextLabel", remoteFrame)
                    remoteName.Size = UDim2.new(1, -10, 0, 25)
                    remoteName.Position = UDim2.new(0, 5, 0, 0)
                    remoteName.BackgroundTransparency = 1
                    remoteName.TextColor3 = Color3.fromRGB(0, 255, 255)
                    remoteName.Text = remote:GetFullName()
                    remoteName.Font = Enum.Font.Code
                    remoteName.TextXAlignment = Enum.TextXAlignment.Left

                    local argsBox = Instance.new("TextBox", remoteFrame)
                    argsBox.Size = UDim2.new(1, -10, 0, 30)
                    argsBox.Position = UDim2.new(0, 5, 0, 25)
                    argsBox.PlaceholderText = "Arguments, e.g., 1000, 'hello', true"
                    argsBox.Font = Enum.Font.Code
                    argsBox.TextSize = 14
                    argsBox.ClearTextOnFocus = false
                    
                    local fireBtn = Instance.new("TextButton", remoteFrame)
                    fireBtn.Size = UDim2.new(0, 80, 0, 28)
                    fireBtn.Position = UDim2.new(0, 5, 1, -30)
                    fireBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
                    fireBtn.Text = "Fire"
                    fireBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    fireBtn.MouseButton1Click:Connect(function()
                        local args, err = parseArgs(argsBox.Text)
                        if args then
                            notify("Firing: " .. remote.Name)
                            pcall(function()
                                if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args))
                                else remote:InvokeServer(unpack(args)) end
                            end)
                        else
                            notify("Invalid Arguments: " .. err, true)
                        end
                    end)
                    
                    local setAutoBtn = Instance.new("TextButton", remoteFrame)
                    setAutoBtn.Size = UDim2.new(0, 150, 0, 28)
                    setAutoBtn.Position = UDim2.new(0, 95, 1, -30)
                    setAutoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                    setAutoBtn.Text = "Set as Auto-Money"
                    setAutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    setAutoBtn.MouseButton1Click:Connect(function()
                         local args, err = parseArgs(argsBox.Text)
                         if args then
                            SetAutoMoneyRemote(remote, args)
                         else
                            notify("Cannot set Auto-Money. Invalid Arguments: " .. err, true)
                         end
                    end)
                end
            end
        end

        -- Find all remotes once
        allRemotes = {}
        local locations = {ReplicatedStorage, workspace, Players, Lighting, CoreGui}
        for _, loc in ipairs(locations) do
            if loc then
                for _, obj in ipairs(loc:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        table.insert(allRemotes, obj)
                    end
                end
            end
        end
        notify("Found " .. #allRemotes .. " remotes.", false)
        populateRemotes()
        searchBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then populateRemotes(searchBox.Text) end
        end)
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
             if searchBox.Text == "" then populateRemotes() end
        end)

        -- Live Spy Logic
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if (method == "FireServer" or method == "InvokeServer") then
                local args = {...}
                if liveSpyPage.Visible then
                    local remoteFrame = Instance.new("Frame", liveSpyPage)
                    remoteFrame.Size = UDim2.new(1, -10, 0, 60)
                    remoteFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    local remoteName = Instance.new("TextLabel", remoteFrame)
                    remoteName.Size = UDim2.new(1, -10, 0.5, 0)
                    remoteName.Position = UDim2.new(0, 5, 0, 0)
                    remoteName.BackgroundTransparency = 1
                    remoteName.TextColor3 = Color3.fromRGB(255, 100, 0)
                    remoteName.Text = self:GetFullName()
                    remoteName.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local argsBox = Instance.new("TextBox", remoteFrame)
                    argsBox.Size = UDim2.new(1, -10, 0.5, -5)
                    argsBox.Position = UDim2.new(0, 5, 0.5, 0)
                    argsBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
                    argsBox.TextColor3 = Color3.fromRGB(200,200,200)
                    argsBox.Font = Enum.Font.Code
                    argsBox.Text = formatArgs(args)
                    argsBox.ClearTextOnFocus = false
                    
                    if #liveSpyPage:GetChildren() > 100 then liveSpyPage:GetChildren()[1]:Destroy() end
                end
            end
            return oldNamecall(self, ...)
        end)
        spyConnection = {mt = mt, old = oldNamecall}
    else
        if hackFrame then hackFrame:Destroy() hackFrame = nil end
        if spyConnection then
            pcall(function()
                setreadonly(spyConnection.mt, true)
                spyConnection.mt.__namecall = spyConnection.old
                spyConnection = nil
            end)
        end
    end
end

makeToggle("Hack Panel (Advanced)", toggleHackPanel, 11)

notify("SEPEHR MOD Menu AI-Enhanced loaded successfully!")

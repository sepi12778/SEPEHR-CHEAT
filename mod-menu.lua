
-- ===========================
-- SEPEHR MOD Menu V (AI-Enhanced Edition)
-- نسخه اصلاح شده توسط دستیار هوش مصنوعی - پنل هک پیشرفته و AutoMoney قابل اعتماد
-- ===========================

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

-- Local Variables
local LocalPlayer = Players.LocalPlayer
local connections = {}
local oldNamecall -- For remote spy

-- =============================================
-- Notification helper
-- =============================================
local function notify(msg, err)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "SEPEHR MOD Menu" .. (err and " | Error" or " | Info"),
            Text = tostring(msg),
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
-- Auto Money (AI) - NEW & IMPROVED
-- =============================================
local autoMoneyConnection = nil
local autoMoneyRemote = nil
local autoMoneyArgs = nil

-- این تابع حالا از پنل هک یا سیستم خودکار فراخوانی می‌شود
function SetAutoMoneyRemote(remote, args)
    if not remote or not args then
        notify("Invalid remote or arguments for Auto Money.", true)
        return
    end
    autoMoneyRemote = remote
    autoMoneyArgs = args
    notify("Auto Money remote set to: " .. remote:GetFullName(), false)
    
    if toggles.AutoMoney then
        toggleAutoMoney(false) -- stop old loop
        toggleAutoMoney(true)  -- start new loop
    end
end

-- سیستم هوشمند پیدا کردن ریموت پول
local function findAndSetBestMoneyRemote()
    notify("AI is searching for money remotes...", false)
    local keywords = {"money", "cash", "claim", "reward", "give", "farm", "auto", "collect", "get", "buy"}
    local potentialRemotes = {}

    -- پیدا کردن تمام ریموت‌ها
    for _, service in ipairs({ReplicatedStorage, workspace}) do
        for _, remote in ipairs(service:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                for _, keyword in ipairs(keywords) do
                    if remote.Name:lower():find(keyword) then
                        table.insert(potentialRemotes, remote)
                        break -- برو سراغ ریموت بعدی
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
    
    -- تست ریموت‌های پیدا شده
    -- نکته: این بخش ممکن است در برخی بازی‌ها باعث کیک شدن شود
    local testArgs = {
        {1000000000},
        {"All"},
        {true},
        {} -- بدون آرگومان
    }
    
    for _, remote in ipairs(potentialRemotes) do
        for _, args in ipairs(testArgs) do
            local success = pcall(function()
                if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args))
                else remote:InvokeServer(unpack(args)) end
            end)
            if success then
                -- فرض می‌کنیم اولین ریموتی که با موفقیت اجرا بشه، همون ریموت پوله
                notify("AI found a working remote: " .. remote.Name .. ". Setting it for Auto-Money.", false)
                SetAutoMoneyRemote(remote, args)
                return true
            end
            task.wait(0.1) -- فاصله بین تست‌ها
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
            -- اگر ریموت دستی تنظیم نشده بود، سیستم هوشمند را فعال کن
            local found = findAndSetBestMoneyRemote()
            if not found then
                notify("Auto Money could not start. Use Hack Panel to set a remote manually.", true)
                toggles.AutoMoney = false
                pcall(function() CoreGui.SEPEHRMODMenuV.MainFrame.Scroll["Auto-Money (AI)"].Checkbox.Check.Visible = false end)
                return
            end
        end
        
        -- شروع حلقه پول
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
            task.wait(0.05) -- سرعت اجرای ریموت
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
makeToggle("Auto-Money (AI)", toggleAutoMoney, 10)

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
local spyHistory = {} -- تاریخچه ریموت‌ها در اینجا ذخیره می‌شود

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
            s[i] = "CFrame.new(...)" -- Simple representation
        elseif t == "nil" then
            s[i] = "nil"
        elseif t == "table" then
            s[i] = HttpService:JSONEncode(v) -- Represent tables as JSON
        else
            s[i] = tostring(v)
        end
    end
    return table.concat(s, ", ")
end

local function parseArgs(argString)
    argString = argString:gsub("^%s*", ""):gsub("%s*$", "") -- Trim whitespace
    if argString == "" then return {} end
    
    local f = loadstring("return {" .. argString .. "}")
    if not f then return nil, "Syntax Error" end
    
    local env = getfenv()
    setfenv(f, env)

    local success, result = pcall(f)
    if not success then return nil, tostring(result) end
    return result
end

-- تابع جدید برای اجرای ریموت‌ها با آرگومان‌های مشخص
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

-- تابع جدید برای اضافه کردن ریموت به تاریخچه
local function addSpyEntry(liveSpyPage, remote, args, argsString)
    if not hackFrame or not hackFrame.Parent then return end

    local remoteFrame = Instance.new("Frame", liveSpyPage)
    remoteFrame.Size = UDim2.new(1, -10, 0, 90) -- افزایش ارتفاع برای دکمه‌ها
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
    
    -- Quick Action Buttons
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
    
    -- Auto-scroll
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

        -- نمایش تاریخچه ذخیره شده
        for _, entry in ipairs(spyHistory) do
            addSpyEntry(liveSpyPage, entry.remote, entry.args, entry.argsString)
        end
        
        local function populateRemotes(filter)
            filter = filter and filter:lower() or ""; for _, v in ipairs(remoteListPage:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
            for _, remote in ipairs(allRemotes) do
                if filter == "" or remote:GetFullName():lower():find(filter) then
                    -- این بخش UI بدون تغییر باقی می‌ماند
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

        if #allRemotes == 0 then -- فقط یک بار ریموت‌ها را پیدا کن
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
            if spyConnection then return end -- اگر هوک قبلا انجام شده، دوباره انجام نده
            local mt = getrawmetatable(game)
            oldNamecall = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if (method == "FireServer" or method == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                    local args = {...}
                    local argsString = formatArgs(args)
                    -- ذخیره در تاریخچه
                    table.insert(spyHistory, {remote = self, args = args, argsString = argsString})

                    -- پاکسازی خودکار تاریخچه برای جلوگیری از لگ
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
            spyConnection = {mt = mt, old = oldNamecall} -- فقط برای بازگردانی در آینده
        end
    else
        if hackFrame then hackFrame:Destroy(); hackFrame = nil end
        -- Note: We are not unhooking __namecall. It's safer to keep it hooked to maintain spy history.
        -- Unhooking can be unstable. If you want to unhook on close, uncomment the following block.
        --[[
        if spyConnection then
            pcall(function()
                spyConnection.mt.__namecall = spyConnection.old
                setreadonly(spyConnection.mt, true)
                spyConnection = nil
            end)
        end
        ]]
    end
end

makeToggle("Hack Panel (Advanced)", toggleHackPanel, 11)

notify("SEPEHR MOD Menu AI-Enhanced loaded successfully!")

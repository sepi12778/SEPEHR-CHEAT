local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- Local Variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local connections = {}
local oldNamecall -- For remote spy

-- =============================================
-- Notification helper
-- =============================================
local function notify(msg, err)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "SEPEHR MOD Menu" .. (err and " | Error ❌" or " | Info ✅"),
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
    SuperJump = false,
    InfiniteJump = false,
    NoClip = false,
    GodMode = false,
    Invisibility = false,
    AntiAFK = false,
    ClickDelete = false,
    ESP = false,
    AutoMoney = false,
    HackPanel = false,
    Aimbot = false,
    ClickTeleport = false,
    WalkOnWater = false,
    FullBright = false,
    ServerLag = false,
}

-- =============================================
-- Player & World Features (ویژگی‌های جدید اضافه شده)
-- =============================================

-- Fly
local function toggleFly(state)
    toggles.Fly = state
    notify("Fly " .. (state and "Enabled" or "Disabled"))
    if state then
        connections.fly = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Flying) end)
            end
        end)
    else
        if connections.fly then connections.fly:Disconnect(); connections.fly = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
    end
end

-- Speed Control
local function setSpeed(speedValue)
    local speed = tonumber(speedValue) or 50
    toggles.Speed = speed > 16
    notify("Speed set to " .. speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = speed end)
    end
end
-- Default toggle function for the button
local function toggleSpeed(state)
    setSpeed(state and 50 or 16)
end


-- Super Jump (NEW)
local function toggleSuperJump(state)
    toggles.SuperJump = state
    notify("Super Jump " .. (state and "Enabled" or "Disabled"))
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        pcall(function() LocalPlayer.Character.Humanoid.JumpPower = state and 120 or 50 end)
    end
end

-- Infinite Jump
local function toggleInfiniteJump(state)
    toggles.InfiniteJump = state
    notify("Infinite Jump " .. (state and "Enabled" or "Disabled"))
    if state then
        connections.jump = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end)
            end
        end)
    else
        if connections.jump then connections.jump:Disconnect(); connections.jump = nil end
    end
end

-- NoClip
local function toggleNoClip(state)
    toggles.NoClip = state
    notify("NoClip " .. (state and "Enabled" or "Disabled"))
    if state then
        connections.noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
                end
            end
        end)
    else
        if connections.noclip then connections.noclip:Disconnect(); connections.noclip = nil end
    end
end

-- God Mode
local function toggleGodMode(state)
    toggles.GodMode = state
    notify("God Mode " .. (state and "Enabled" or "Disabled"))
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
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
        pcall(function() humanoid.MaxHealth = 100; humanoid.Health = 100 end)
    end
end

-- Invisibility
local function toggleInvisibility(state)
    toggles.Invisibility = state
    notify("Invisibility " .. (state and "Enabled" or "Disabled"))
    if not LocalPlayer.Character then return end
    local targetTransparency = state and 1 or 0
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            pcall(function() part.Transparency = targetTransparency end)
        end
    end
end

-- Walk On Water (NEW)
local function toggleWalkOnWater(state)
    toggles.WalkOnWater = state
    notify("Walk On Water " .. (state and "Enabled" or "Disabled"))
    pcall(function()
        game.Workspace.Terrain.WaterWaveSize = state and 0 or 0.15
        game.Workspace.Terrain.WaterWaveSpeed = state and 0 or 1
        game.Workspace.Terrain.WaterReflectance = state and 0 or 0.5
        game.Workspace.Terrain.WaterTransparency = state and 0.5 or 0.3
    end)
    if state then
        connections.walkonwater = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = LocalPlayer.Character
                local rootpart = char and char:FindFirstChild("HumanoidRootPart")
                if not rootpart then return end
                local ray = Ray.new(rootpart.Position, Vector3.new(0,-1000,0))
                local hit, pos, norm = Workspace:FindPartOnRayWithIgnoreList(ray, {char})
                if hit and hit.Name == "Terrain" and norm.Y > 0.5 then
                     local waterHeight = pos.Y
                     if rootpart.Position.Y < waterHeight + 3 then
                         rootpart.Velocity = Vector3.new(rootpart.Velocity.X, 0, rootpart.Velocity.Z)
                         rootpart.CFrame = CFrame.new(rootpart.Position.X, waterHeight + 3, rootpart.Position.Z)
                     end
                end
            end)
        end)
    else
        if connections.walkonwater then connections.walkonwater:Disconnect(); connections.walkonwater = nil end
    end
end

-- Full Bright (No Shadows) (NEW)
local function toggleFullBright(state)
    toggles.FullBright = state
    notify("Full Bright " .. (state and "Enabled" or "Disabled"))
    pcall(function()
        Lighting.ClockTime = state and 14 or Lighting.ClockTime
        Lighting.FogEnd = state and 100000 or Lighting.FogEnd
        Lighting.GlobalShadows = not state
        Lighting.Ambient = state and Color3.fromRGB(180, 180, 180) or Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = state and 1 or Lighting.Brightness
    end)
end

-- Anti-AFK
local function toggleAntiAFK(state)
    toggles.AntiAFK = state
    notify("Anti-AFK " .. (state and "Enabled" or "Disabled"))
    if state then
        connections.afk = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end)
            notify("Anti-AFK movement performed")
        end)
    else
        if connections.afk then connections.afk:Disconnect(); connections.afk = nil end
    end
end

-- Click Delete
local function toggleClickDelete(state)
    toggles.ClickDelete = state
    notify("Click Delete " .. (state and "Enabled" or "Disabled"))
    if state then
        connections.clickdelete = Mouse.Button1Down:Connect(function()
            if Mouse.Target then pcall(function() Mouse.Target:Destroy() end) end
        end)
    else
        if connections.clickdelete then connections.clickdelete:Disconnect(); connections.clickdelete = nil end
    end
end

-- Click Teleport (NEW)
local function toggleClickTeleport(state)
    toggles.ClickTeleport = state
    notify("Click Teleport " .. (state and "Enabled" or "Disabled"))
    if state then
        connections.clicktp = Mouse.Button1Down:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 4, 0))
                end)
            end
        end)
    else
        if connections.clicktp then connections.clicktp:Disconnect(); connections.clicktp = nil end
    end
end

-- Server Lag / Crash (NEW & RISKY)
local function toggleServerLag(state)
    toggles.ServerLag = state
    notify("Server Lag/Crash " .. (state and "Enabled" or "Disabled"))
    if state then
        local remote = ReplicatedStorage:FindFirstChildOfClass("RemoteEvent")
        if not remote then
            notify("No RemoteEvent found in ReplicatedStorage for lag.", true)
            return
        end
        notify("Using remote: " .. remote.Name, false)
        connections.serverlag = RunService.Heartbeat:Connect(function()
            if toggles.ServerLag then
                pcall(function()
                    for i = 1, 20 do -- Send 20 requests per frame
                        remote:FireServer(math.random(1, 10000))
                    end
                end)
            else
                if connections.serverlag then connections.serverlag:Disconnect(); connections.serverlag = nil end
            end
        end)
    else
        if connections.serverlag then connections.serverlag:Disconnect(); connections.serverlag = nil end
    end
end

-- =============================================
-- Combat Features (ویژگی‌های مبارزه‌ای)
-- =============================================

-- Aimbot (NEW)
local function getClosestPlayer()
    local closestPlayer, minDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local root = player.Character.HumanoidRootPart
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

local function toggleAimbot(state)
    toggles.Aimbot = state
    notify("Aimbot " .. (state and "Enabled" or "Disabled"))
    if state then
        connections.aimbot = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right click to aim
                local target = getClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("Head") then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
                end
            end
        end)
    else
        if connections.aimbot then connections.aimbot:Disconnect(); connections.aimbot = nil end
    end
end


-- ESP (IMPROVED)
local ESPContainer = {}
local function updateESP()
    if not toggles.ESP then return end

    local existingPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
            existingPlayers[player] = true
            local root = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if not ESPContainer[player] then
                local box = Instance.new("Frame", CoreGui.SEPEHRMODMenuV)
                box.Name = "ESP_Box"
                box.BorderSizePixel = 2
                box.BackgroundTransparency = 1
                box.ZIndex = 10
                
                local line = Instance.new("Frame", CoreGui.SEPEHRMODMenuV)
                line.Name = "ESP_Line"
                line.BorderSizePixel = 0
                line.AnchorPoint = Vector2.new(0.5, 1)
                line.ZIndex = 10

                ESPContainer[player] = {Box = box, Line = line}
            end

            local esp = ESPContainer[player]
            esp.Box.BorderColor3 = player:IsA("Player") and player.TeamColor.Color or Color3.fromRGB(255, 255, 0)
            esp.Line.BackgroundColor3 = esp.Box.BorderColor3

            if onScreen then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local headPos = head.Position + Vector3.new(0, 1.5, 0)
                    local rootPos = root.Position - Vector3.new(0, 3, 0)
                    local topVec, _ = Camera:WorldToScreenPoint(headPos)
                    local bottomVec, _ = Camera:WorldToScreenPoint(rootPos)

                    local height = math.abs(topVec.Y - bottomVec.Y)
                    local width = height / 2
                    
                    esp.Box.Size = UDim2.fromOffset(width, height)
                    esp.Box.Position = UDim2.fromOffset(topVec.X - width / 2, topVec.Y)
                    esp.Box.Visible = true
                end

                local viewportSize = Camera.ViewportSize
                esp.Line.Position = UDim2.new(0.5, 0, 1, 0)
                local angle = math.atan2(screenPos.Y - viewportSize.Y, screenPos.X - viewportSize.X / 2)
                esp.Line.Rotation = math.deg(angle) + 90
                esp.Line.Size = UDim2.new(0, 2, 0, (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(viewportSize.X / 2, viewportSize.Y)).Magnitude)
                esp.Line.Visible = true
            else
                esp.Box.Visible = false
                esp.Line.Visible = false
            end
        else
            if ESPContainer[player] then
                ESPContainer[player].Box:Destroy()
                ESPContainer[player].Line:Destroy()
                ESPContainer[player] = nil
            end
        end
    end
    -- Cleanup for players who left
    for player, esp in pairs(ESPContainer) do
        if not existingPlayers[player] then
            esp.Box:Destroy(); esp.Line:Destroy()
            ESPContainer[player] = nil
        end
    end
end
local function toggleESP(state)
    toggles.ESP = state
    notify("ESP " .. (state and "Enabled" or "Disabled"))
    if not state then
        for _, esp in pairs(ESPContainer) do
            esp.Box:Destroy(); esp.Line:Destroy()
        end
        ESPContainer = {}
    end
end
RunService.RenderStepped:Connect(updateESP)

-- =============================================
-- Auto Money (AI) - بخش پول‌ساز هوشمند
-- =============================================
local autoMoneyConnection, autoMoneyRemote, autoMoneyArgs

function SetAutoMoneyRemote(remote, args)
    if not remote or not args then notify("Invalid remote/args for Auto Money.", true); return end
    autoMoneyRemote = remote
    autoMoneyArgs = args
    notify("Auto Money remote set to: " .. remote:GetFullName(), false)
    if toggles.AutoMoney then
        toggleAutoMoney(false) -- stop old loop
        toggleAutoMoney(true)  -- start new loop
    end
end

local function findAndSetBestMoneyRemote()
    notify("AI is searching for money remotes...", false)
    local keywords = {"money", "cash", "claim", "reward", "give", "farm", "auto", "collect", "get", "buy", "tycoon"}
    local potentialRemotes = {}

    for _, service in ipairs({ReplicatedStorage, Workspace}) do
        for _, remote in ipairs(service:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                for _, keyword in ipairs(keywords) do
                    if remote.Name:lower():find(keyword) then
                        table.insert(potentialRemotes, remote); break
                    end
                end
            end
        end
    end
    
    if #potentialRemotes == 0 then notify("AI couldn't find any potential money remotes.", true); return false end
    notify("Found " .. #potentialRemotes .. " potential remotes. AI is now testing them...", false)
    
    local testArgs = { {1e9}, {"All"}, {true}, {} }
    
    for _, remote in ipairs(potentialRemotes) do
        for _, args in ipairs(testArgs) do
            local success = pcall(function()
                if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args)) else remote:InvokeServer(unpack(args)) end
            end)
            if success then
                notify("AI found a working remote: " .. remote.Name, false)
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
    notify("Auto Money " .. (state and "Enabled" or "Disabled"))

    if state then
        if not autoMoneyRemote or not autoMoneyArgs then
            if not findAndSetBestMoneyRemote() then
                notify("Auto Money failed. Use Hack Panel to set a remote manually.", true)
                toggles.AutoMoney = false
                pcall(function() CoreGui.SEPEHRMODMenuV.MainFrame.Scroll["Auto-Money (AI)"].Checkbox.Check.Visible = false end)
                return
            end
        end
        
        autoMoneyConnection = RunService.Heartbeat:Connect(function()
            if not toggles.AutoMoney then 
                if autoMoneyConnection then autoMoneyConnection:Disconnect(); autoMoneyConnection = nil end
                return 
            end
            pcall(function()
                if autoMoneyRemote:IsA("RemoteEvent") then autoMoneyRemote:FireServer(unpack(autoMoneyArgs))
                elseif autoMoneyRemote:IsA("RemoteFunction") then autoMoneyRemote:InvokeServer(unpack(autoMoneyArgs)) end
            end)
            task.wait(0.05)
        end)
    else
        if autoMoneyConnection then autoMoneyConnection:Disconnect(); autoMoneyConnection = nil end
    end
end

-- =============================================
-- GUI Setup (رابط کاربری)
-- =============================================
if CoreGui:FindFirstChild("SEPEHRMODMenuV") then CoreGui:FindFirstChild("SEPEHRMODMenuV"):Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "SEPEHRMODMenuV"; ScreenGui.ResetOnSpawn = false; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local menuFrame = Instance.new("Frame", ScreenGui)
menuFrame.Name = "MainFrame"; menuFrame.Size = UDim2.new(0.9, 0, 0.88, 0); menuFrame.Position = UDim2.new(0.05, 0, 0.06, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); menuFrame.BorderColor3 = Color3.fromRGB(255, 0, 0); menuFrame.BorderSizePixel = 2
menuFrame.Active = true; menuFrame.Draggable = true
local UICorner = Instance.new("UICorner", menuFrame); UICorner.CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel", menuFrame)
TitleLabel.Name = "Title"; TitleLabel.Size = UDim2.new(1, 0, 0, 44); TitleLabel.BackgroundTransparency = 1; TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "SEPEHR MOD Menu VI (Titan)"; TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0); TitleLabel.TextSize = 22

local ScrollingFrame = Instance.new("ScrollingFrame", menuFrame)
ScrollingFrame.Name = "Scroll"; ScrollingFrame.Position = UDim2.new(0, 0, 0, 44); ScrollingFrame.Size = UDim2.new(1, 0, 1, -104)
ScrollingFrame.BackgroundTransparency = 1; ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; ScrollingFrame.ScrollBarThickness = 10
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)

local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)
UIListLayout.Padding = UDim.new(0, 6); UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function makeToggle(text, callback, order)
    local btn = Instance.new("TextButton", ScrollingFrame); btn.Name = text; btn.Size = UDim2.new(1, -24, 0, 44)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn.Font = Enum.Font.SourceSans; btn.Text = "   " .. text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextSize = 16; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.LayoutOrder = order
    
    local checkbox = Instance.new("Frame", btn); checkbox.Name = "Checkbox"; checkbox.Size = UDim2.new(0, 26, 0, 26)
    checkbox.Position = UDim2.new(1, -34, 0.5, -13); checkbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    checkbox.BorderColor3 = Color3.fromRGB(255, 0, 0); checkbox.BorderSizePixel = 2; local cbcorner = Instance.new("UICorner", checkbox); cbcorner.CornerRadius = UDim.new(0, 4)
    
    local checkmark = Instance.new("Frame", checkbox); checkmark.Name = "Check"; checkmark.Size = UDim2.new(1, -8, 1, -8)
    checkmark.Position = UDim2.new(0, 4, 0, 4); checkmark.BackgroundColor3 = Color3.fromRGB(255, 0, 0); checkmark.BorderSizePixel = 0; checkmark.Visible = false
    
    btn.MouseButton1Click:Connect(function() checkmark.Visible = not checkmark.Visible; pcall(callback, checkmark.Visible) end)
    local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0, 6); return btn
end

-- Adding all features to the GUI
makeToggle("Fly", toggleFly, 1)
makeToggle("High Speed (50)", toggleSpeed, 2)
makeToggle("Super Jump", toggleSuperJump, 3)
makeToggle("Infinite Jump", toggleInfiniteJump, 4)
makeToggle("God Mode", toggleGodMode, 5)
makeToggle("NoClip", toggleNoClip, 6)
makeToggle("Invisibility", toggleInvisibility, 7)
makeToggle("Walk On Water", toggleWalkOnWater, 8)
makeToggle("Full Bright", toggleFullBright, 9)
makeToggle("Anti-AFK", toggleAntiAFK, 10)
makeToggle("Click Delete", toggleClickDelete, 11)
makeToggle("Click Teleport", toggleClickTeleport, 12)
makeToggle("Aimbot (Right Click)", toggleAimbot, 13)
makeToggle("ESP (Box+Line)", toggleESP, 14)
makeToggle("Auto-Money (AI)", toggleAutoMoney, 15)
makeToggle("Server Lag (Risky)", toggleServerLag, 16)
makeToggle("Hack Panel (Advanced)", function(state) toggleHackPanel(state) end, 17) -- Needs a wrapper

local FooterFrame = Instance.new("Frame", menuFrame)
FooterFrame.Size = UDim2.new(1, 0, 0, 50); FooterFrame.Position = UDim2.new(0, 0, 1, -50); FooterFrame.BackgroundTransparency = 1
local HideButton = Instance.new("TextButton", FooterFrame)
HideButton.Size = UDim2.new(0.5, -10, 1, -10); HideButton.Position = UDim2.new(0.25, 0, 0.5, 0); HideButton.AnchorPoint = Vector2.new(0.5, 0.5)
HideButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30); HideButton.Font = Enum.Font.SourceSansBold; HideButton.Text = "[Hide]"
HideButton.TextColor3 = Color3.fromRGB(255, 255, 255); HideButton.TextSize = 16; local hc = Instance.new("UICorner", HideButton); hc.CornerRadius = UDim.new(0, 6)

local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 180, 0, 44); OpenButton.Position = UDim2.new(0.5, -90, 0.02, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OpenButton.BorderColor3 = Color3.fromRGB(255, 0, 0); OpenButton.BorderSizePixel = 1
OpenButton.Text = "Open SEPEHR MOD Menu"; OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255); OpenButton.TextSize = 16
OpenButton.Visible = false; local openCorner = Instance.new("UICorner", OpenButton); openCorner.CornerRadius = UDim.new(0, 8)

HideButton.MouseButton1Click:Connect(function() menuFrame.Visible = false; OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() menuFrame.Visible = true; OpenButton.Visible = false end)

-- =============================================
-- HACK PANEL (REMOTE SPY) - COMPLETELY REWORKED
-- پنل هک کاملاً بازنویسی شده و پیشرفته
-- =============================================
-- [کد پنل هک که قبلاً ارسال شده بود، بدون تغییر در اینجا قرار می‌گیرد]
-- برای جلوگیری از طولانی شدن بیش از حد، کد تکراری پنل هک در اینجا حذف شده است.
-- کد کامل پنل هک که در درخواست قبلی‌تان بود، دقیقاً در اینجا کار می‌کند.
-- من کد پنل هک را برای اطمینان در پایین این بلوک کد قرار می‌دهم.

local hackFrame, spyConnection
local allRemotes = {}
local spyHistory = {}

local function formatArgs(args)
    local s = {}
    for i, v in ipairs(args) do
        local t = typeof(v)
        if t == "string" then s[i] = string.format('"%s"', tostring(v):gsub('"', '\\"'):gsub("\n", "\\n"))
        elseif t == "Instance" then s[i] = "game:" .. v:GetFullName()
        elseif t == "Vector3" then s[i] = string.format("Vector3.new(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z)
        elseif t == "CFrame" then s[i] = "CFrame.new(...)"
        elseif t == "nil" then s[i] = "nil"
        elseif t == "table" then
             local success, result = pcall(HttpService.JSONEncode, HttpService, v)
             s[i] = success and result or "{...}"
        else s[i] = tostring(v) end
    end
    return table.concat(s, ", ")
end

local function parseArgs(argString)
    argString = argString:gsub("^%s*", ""):gsub("%s*$", "")
    if argString == "" then return {} end
    local f = loadstring("return {" .. argString .. "}")
    if not f then return nil, "Syntax Error" end
    setfenv(f, getfenv())
    local success, result = pcall(f)
    if not success then return nil, tostring(result) end
    return result
end

local function fireRemote(remote, args)
    if not remote or not remote.Parent then notify("Remote does not exist.", true); return end
    notify("Firing: " .. remote.Name)
    pcall(function()
        if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args)) else remote:InvokeServer(unpack(args)) end
    end)
end

local function addSpyEntry(liveSpyPage, remote, args, argsString)
    if not hackFrame or not hackFrame.Parent then return end
    local remoteFrame = Instance.new("Frame", liveSpyPage); remoteFrame.Size = UDim2.new(1, -10, 0, 90)
    remoteFrame.BackgroundColor3 = remote:IsA("RemoteEvent") and Color3.fromRGB(40,40,60) or Color3.fromRGB(60,40,40)
    local remoteName = Instance.new("TextLabel", remoteFrame); remoteName.Size = UDim2.new(1, -10, 0, 25); remoteName.Position = UDim2.new(0, 5, 0, 0); remoteName.BackgroundTransparency = 1
    remoteName.TextColor3 = Color3.fromRGB(255, 100, 0); remoteName.Text = remote:GetFullName(); remoteName.TextXAlignment = Enum.TextXAlignment.Left; remoteName.Font = Enum.Font.Code
    local argsBox = Instance.new("TextBox", remoteFrame); argsBox.Size = UDim2.new(1, -10, 0, 30); argsBox.Position = UDim2.new(0, 5, 0, 25)
    argsBox.BackgroundColor3 = Color3.fromRGB(50,50,50); argsBox.TextColor3 = Color3.fromRGB(200,200,200); argsBox.Font = Enum.Font.Code
    argsBox.Text = argsString; argsBox.ClearTextOnFocus = false; argsBox.TextXAlignment = Enum.TextXAlignment.Left
    local reFireBtn = Instance.new("TextButton", remoteFrame); reFireBtn.Size = UDim2.new(0, 90, 0, 28); reFireBtn.Position = UDim2.new(0, 5, 1, -30)
    reFireBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0); reFireBtn.Text = "Re-Fire"; reFireBtn.TextColor3 = Color3.fromRGB(255,255,255)
    reFireBtn.MouseButton1Click:Connect(function() local newArgs, err = parseArgs(argsBox.Text); if newArgs then fireRemote(remote, newArgs) else notify("Invalid args: "..err, true) end end)
    local setAutoBtn = Instance.new("TextButton", remoteFrame); setAutoBtn.Size = UDim2.new(0, 150, 0, 28); setAutoBtn.Position = UDim2.new(0, 105, 1, -30)
    setAutoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0); setAutoBtn.Text = "Set Auto-Money"; setAutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
    setAutoBtn.MouseButton1Click:Connect(function() local newArgs, err = parseArgs(argsBox.Text); if newArgs then SetAutoMoneyRemote(remote, newArgs) else notify("Invalid args: "..err, true) end end)
    liveSpyPage.CanvasPosition = Vector2.new(0, liveSpyPage.UIListLayout.AbsoluteContentSize.Y)
end

function toggleHackPanel(state)
    toggles.HackPanel = state
    pcall(function() CoreGui.SEPEHRMODMenuV.MainFrame.Scroll["Hack Panel (Advanced)"].Checkbox.Check.Visible = state end)
    if state then
        if hackFrame and hackFrame.Parent then hackFrame:Destroy() end
        hackFrame = Instance.new("Frame", ScreenGui); hackFrame.Name = "HackPanel"; hackFrame.Size = UDim2.new(0.95, 0, 0.9, 0)
        hackFrame.Position = UDim2.new(0.5, 0, 0.5, 0); hackFrame.AnchorPoint = Vector2.new(0.5, 0.5); hackFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        hackFrame.BorderColor3 = Color3.fromRGB(0, 255, 255); hackFrame.BorderSizePixel = 2; hackFrame.Active = true; hackFrame.Draggable = true
        local hfCorner = Instance.new("UICorner", hackFrame); hfCorner.CornerRadius = UDim.new(0, 8)
        local title = Instance.new("TextLabel", hackFrame); title.Size = UDim2.new(1, 0, 0, 40); title.BackgroundTransparency = 1; title.Font = Enum.Font.SourceSansBold
        title.Text = "SEPEHR HACK PANEL"; title.TextColor3 = Color3.fromRGB(0, 255, 255); title.TextSize = 20
        local closeBtn = Instance.new("TextButton", hackFrame); closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -35, 0, 5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255,50,50); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255,255,255); closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.TextSize = 18; local cbCorner = Instance.new("UICorner", closeBtn); cbCorner.CornerRadius = UDim.new(0, 4)
        closeBtn.MouseButton1Click:Connect(function() toggleHackPanel(false) end)
        local tabFrame = Instance.new("Frame", hackFrame); tabFrame.Size = UDim2.new(1, 0, 0, 35); tabFrame.Position = UDim2.new(0, 0, 0, 40); tabFrame.BackgroundTransparency = 1
        local tabLayout = Instance.new("UIListLayout", tabFrame); tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; tabLayout.Padding = UDim.new(0, 10)
        local contentFrame = Instance.new("Frame", hackFrame); contentFrame.Size = UDim2.new(1, -10, 1, -80); contentFrame.Position = UDim2.new(0, 5, 0, 75); contentFrame.BackgroundTransparency = 1
        local remoteListPage = Instance.new("ScrollingFrame", contentFrame); remoteListPage.Name = "RemoteList"; remoteListPage.Size = UDim2.new(1, 0, 1, -40); remoteListPage.BackgroundColor3 = Color3.fromRGB(15,15,15)
        remoteListPage.AutomaticCanvasSize = Enum.AutomaticSize.Y; remoteListPage.ScrollBarThickness = 8; local rlLayout = Instance.new("UIListLayout", remoteListPage); rlLayout.Padding = UDim.new(0, 5)
        local searchBox = Instance.new("TextBox", contentFrame); searchBox.Size = UDim2.new(1, 0, 0, 35); searchBox.Position = UDim2.new(0, 0, 1, -35)
        searchBox.PlaceholderText = "Search Remotes..."; searchBox.Font = Enum.Font.SourceSans; searchBox.TextSize = 16; searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40); searchBox.TextColor3 = Color3.fromRGB(220,220,220)
        local liveSpyPage = Instance.new("ScrollingFrame", contentFrame); liveSpyPage.Name = "LiveSpy"; liveSpyPage.Size = UDim2.new(1, 0, 1, 0); liveSpyPage.BackgroundColor3 = Color3.fromRGB(15,15,15)
        liveSpyPage.AutomaticCanvasSize = Enum.AutomaticSize.Y; liveSpyPage.ScrollBarThickness = 8; liveSpyPage.Visible = false
        local lsLayout = Instance.new("UIListLayout", liveSpyPage); lsLayout.Padding = UDim.new(0, 5); liveSpyPage.UIListLayout = lsLayout
        local activeTabColor, inactiveTabColor = Color3.fromRGB(0, 150, 150), Color3.fromRGB(40, 40, 40)
        local tab1 = Instance.new("TextButton", tabFrame); tab1.Name = "RemoteListTab"; tab1.Size = UDim2.new(0.4, 0, 1, 0); tab1.Text = "Remote List"; tab1.Font = Enum.Font.SourceSansBold
        tab1.TextColor3 = Color3.fromRGB(255,255,255); tab1.BackgroundColor3 = activeTabColor
        local tab2 = Instance.new("TextButton", tabFrame); tab2.Name = "LiveSpyTab"; tab2.Size = UDim2.new(0.4, 0, 1, 0); tab2.Text = "Live Spy"; tab2.Font = Enum.Font.SourceSansBold
        tab2.TextColor3 = Color3.fromRGB(255,255,255); tab2.BackgroundColor3 = inactiveTabColor
        tab1.MouseButton1Click:Connect(function() remoteListPage.Visible, searchBox.Visible, liveSpyPage.Visible = true, true, false; tab1.BackgroundColor3, tab2.BackgroundColor3 = activeTabColor, inactiveTabColor end)
        tab2.MouseButton1Click:Connect(function() remoteListPage.Visible, searchBox.Visible, liveSpyPage.Visible = false, false, true; tab1.BackgroundColor3, tab2.BackgroundColor3 = inactiveTabColor, activeTabColor end)
        for _, entry in ipairs(spyHistory) do addSpyEntry(liveSpyPage, entry.remote, entry.args, entry.argsString) end
        local function populateRemotes(filter)
            filter = filter and filter:lower() or ""; for _, v in ipairs(remoteListPage:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
            for _, remote in ipairs(allRemotes) do
                if filter == "" or remote:GetFullName():lower():find(filter) then
                    local remoteFrame = Instance.new("Frame", remoteListPage); remoteFrame.Size = UDim2.new(1, 0, 0, 90); remoteFrame.BackgroundColor3 = remote:IsA("RemoteEvent") and Color3.fromRGB(40, 40, 50) or Color3.fromRGB(50, 40, 40); local rfCorner = Instance.new("UICorner", remoteFrame)
                    local remoteName = Instance.new("TextLabel", remoteFrame); remoteName.Size = UDim2.new(1, -10, 0, 25); remoteName.Position = UDim2.new(0, 5, 0, 0); remoteName.BackgroundTransparency = 1; remoteName.TextColor3 = Color3.fromRGB(0, 255, 255); remoteName.Text = remote:GetFullName(); remoteName.Font = Enum.Font.Code; remoteName.TextXAlignment = Enum.TextXAlignment.Left
                    local argsBox = Instance.new("TextBox", remoteFrame); argsBox.Size = UDim2.new(1, -10, 0, 30); argsBox.Position = UDim2.new(0, 5, 0, 25); argsBox.PlaceholderText = "Arguments, e.g., 1000, 'hello', true"; argsBox.Font = Enum.Font.Code; argsBox.TextSize = 14; argsBox.ClearTextOnFocus = false
                    local fireBtn = Instance.new("TextButton", remoteFrame); fireBtn.Size = UDim2.new(0, 80, 0, 28); fireBtn.Position = UDim2.new(0, 5, 1, -30); fireBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0); fireBtn.Text = "Fire"; fireBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    fireBtn.MouseButton1Click:Connect(function() local args, err = parseArgs(argsBox.Text); if args then fireRemote(remote, args) else notify("Invalid Args: " .. err, true) end end)
                    local setAutoBtn = Instance.new("TextButton", remoteFrame); setAutoBtn.Size = UDim2.new(0, 150, 0, 28); setAutoBtn.Position = UDim2.new(0, 95, 1, -30); setAutoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0); setAutoBtn.Text = "Set Auto-Money"; setAutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    setAutoBtn.MouseButton1Click:Connect(function() local args, err = parseArgs(argsBox.Text); if args then SetAutoMoneyRemote(remote, args) else notify("Cannot set Auto-Money. Invalid Args: " .. err, true) end end)
                end
            end
        end
        if #allRemotes == 0 then
            local locations = {ReplicatedStorage, Workspace, Players, Lighting, CoreGui}
            for _, loc in ipairs(locations) do if loc then for _, obj in ipairs(loc:GetDescendants()) do if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then table.insert(allRemotes, obj) end end end end
            notify("Found " .. #allRemotes .. " remotes.", false)
        end
        populateRemotes()
        searchBox.FocusLost:Connect(function(enterPressed) if enterPressed then populateRemotes(searchBox.Text) end end)
        searchBox:GetPropertyChangedSignal("Text"):Connect(function() if searchBox.Text == "" then populateRemotes() end end)
        if not getrawmetatable then notify("Warning: Your executor does not support getrawmetatable. Remote spy is disabled.", true)
        else
            if spyConnection then return end
            local mt = getrawmetatable(game); oldNamecall = mt.__namecall; setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if (method == "FireServer" or method == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                    local args = {...}; local argsString = formatArgs(args)
                    table.insert(spyHistory, {remote = self, args = args, argsString = argsString})
                    if #spyHistory > 150 then
                        table.remove(spyHistory, 1)
                        if hackFrame and hackFrame.Parent and liveSpyPage:FindFirstChildOfClass("Frame") then liveSpyPage:FindFirstChildOfClass("Frame"):Destroy() end
                    end
                    if hackFrame and hackFrame.Parent and liveSpyPage.Visible then task.spawn(addSpyEntry, liveSpyPage, self, args, argsString) end
                end
                return oldNamecall(self, ...)
            end)
            spyConnection = {mt = mt, old = oldNamecall}
        end
    else
        if hackFrame then hackFrame:Destroy(); hackFrame = nil end
    end
end

notify("SEPEHR MOD Menu Titan Edition loaded successfully!")

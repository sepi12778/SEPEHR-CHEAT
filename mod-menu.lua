-- Mod Menu v5.0 [Professional + Full Features + ESP + Animated Cash + Aimbot]
-- Updated by AI Assistant

-- Services
local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera

-- GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ModMenu"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 350, 0, 620) -- Increased height for new buttons
main.Position = UDim2.new(0.33,0,0.15,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
main.BorderSizePixel = 0

-- Gradient for main frame
local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(40,40,40)), ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,25))}

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "SEPEHR CHEAT"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Helper Functions
local function createButton(name,text,y)
	local btn = Instance.new("TextButton", main)
	btn.Name = name
	btn.Size = UDim2.new(0,310,0,30)
	btn.Position = UDim2.new(0,20,0,y)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = text
	btn.AutoButtonColor = false -- Set to false for better manual control
	-- Hover Effect
	btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(70,70,70) end)
	btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50,50,50) end)
	return btn
end

local function createBox(placeholder,y)
	local box = Instance.new("TextBox", main)
	box.Size = UDim2.new(0,310,0,30)
	box.Position = UDim2.new(0,20,0,y)
	box.BackgroundColor3 = Color3.fromRGB(50,50,50)
	box.PlaceholderText = placeholder
	box.TextColor3 = Color3.fromRGB(255,255,255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.ClearTextOnFocus = true
	-- Hover Effect
	box.Focused:Connect(function() box.BackgroundColor3 = Color3.fromRGB(70,70,70) end)
	box.FocusLost:Connect(function() box.BackgroundColor3 = Color3.fromRGB(50,50,50) end)
	return box
end

-- Toggles
local noclip, infJump, godMode, oneHit, killAura, espActive, aimbot, walkOnWater = false,false,false,false,false,false,false,false

-- Buttons (Re-ordered and new ones added)
local yPos = 50
local btnNoclip = createButton("NoClip","NoClip: OFF", yPos); yPos = yPos + 40
local btnInfJump = createButton("InfJump","Infinite Jump: OFF", yPos); yPos = yPos + 40
local btnGodMode = createButton("GodMode","God Mode: OFF", yPos); yPos = yPos + 40
local btnOneHit = createButton("OneHit","One Hit Kill: OFF", yPos); yPos = yPos + 40
local btnKillAura = createButton("KillAura","Kill Aura: OFF", yPos); yPos = yPos + 40
local btnAimbot = createButton("Aimbot","Aimbot: OFF (Hold E)", yPos); yPos = yPos + 40
local btnESP = createButton("ESP","ESP: OFF", yPos); yPos = yPos + 40
local btnWalkOnWater = createButton("WalkOnWater","Walk on Water: OFF", yPos); yPos = yPos + 40
local btnFly = createButton("Fly","Fly GUI", yPos); yPos = yPos + 40
local btnTP = createButton("Teleport","Teleport to Player", yPos); yPos = yPos + 40
local btnKillAll = createButton("KillAll","Kill All Players", yPos); yPos = yPos + 40
local btnSetCash = createButton("SetCash","Increase All Currencies", yPos); yPos = yPos + 40
local btnBtools = createButton("Btools", "Btools (Build Tools)", yPos); yPos = yPos + 40

-- Boxes
local speedBox = createBox("Speed Modifier",yPos); yPos = yPos + 40
local jumpBox = createBox("Jump Modifier",yPos)

-- Minimize
local minimize = createButton("Minimize","Minimize", yPos + 40)
minimize.TextColor3 = Color3.fromRGB(255,255,0)
local minimizedBtn = Instance.new("TextButton", gui)
minimizedBtn.Size = UDim2.new(0,120,0,40)
minimizedBtn.Position = UDim2.new(0,10,1,-60)
minimizedBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
minimizedBtn.TextColor3 = Color3.fromRGB(0,255,0)
minimizedBtn.Text = "ModMenu"
minimizedBtn.Font = Enum.Font.GothamBold
minimizedBtn.TextSize = 14
minimizedBtn.Visible = false
minimizedBtn.Draggable = true

-- Currency List
local currencies = {"Sheckles","Bonds","Inchor","Doorknobs","Pages","Brainrots",
"Game Bucks","Gems","Coins","Cash","Tokens","Stars","Crystals","Essences",
"Shards","Credits","Diamonds","Tickets","Points"}

-- ESP Folder
local espFolder = Instance.new("Folder", gui)
espFolder.Name = "ESPFolder"

-- Helper Function: Pop-up Alert
local function alert(msg,color)
	local lbl = Instance.new("TextLabel", main)
	lbl.Size = UDim2.new(0,280,0,25)
	lbl.Position = UDim2.new(0, (main.Size.X.Offset - 280) / 2, 0, 40)
	lbl.BackgroundColor3 = color
	lbl.TextColor3 = Color3.fromRGB(255,255,255)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.Text = msg
	lbl.TextXAlignment = Enum.TextXAlignment.Center
	lbl.TextTransparency = 0
    
    -- Animation
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(lbl, tweenInfo, {Position = UDim2.new(lbl.Position.X.Scale, lbl.Position.X.Offset, 0, -30), TextTransparency=1, BackgroundTransparency=1})
	tween:Play()
	tween.Completed:Connect(function() lbl:Destroy() end)
end

-- =================================================== --
-- =================== FUNCTIONS ===================== --
-- =================================================== --

-- NoClip
btnNoclip.MouseButton1Click:Connect(function()
	noclip = not noclip
	btnNoclip.Text = noclip and "NoClip: ON" or "NoClip: OFF"
	alert("NoClip "..(noclip and "Enabled" or "Disabled"), Color3.fromRGB(0,150,255))
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") and not noclip then part.CanCollide = true end
		end
    end
end)
RunService.Stepped:Connect(function()
	if noclip and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

-- Infinite Jump
btnInfJump.MouseButton1Click:Connect(function()
	infJump = not infJump
	btnInfJump.Text = infJump and "Infinite Jump: ON" or "Infinite Jump: OFF"
	alert("Infinite Jump "..(infJump and "Enabled" or "Disabled"), Color3.fromRGB(0,150,255))
end)
UserInputService.JumpRequest:Connect(function()
	if infJump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
		player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Speed / Jump Modifier
speedBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
	local val = tonumber(speedBox.Text)
	if val and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
		player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
		alert("WalkSpeed Set: "..val, Color3.fromRGB(0,255,0))
	end
end)
jumpBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
	local val = tonumber(jumpBox.Text)
	if val and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
		player.Character:FindFirstChildOfClass("Humanoid").JumpPower = val
		alert("JumpPower Set: "..val, Color3.fromRGB(0,255,0))
	end
end)

-- Fly
btnFly.MouseButton1Click:Connect(function()
	local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nicuse/RobloxScripts/main/Fly.lua"))()
    end)
    if success then
	    alert("Fly Enabled", Color3.fromRGB(255,100,0))
    else
        alert("Fly script failed to load!", Color3.fromRGB(255,0,0))
    end
end)

-- Teleport
btnTP.MouseButton1Click:Connect(function()
    -- Create a simple input frame instead of the deprecated PromptInput
    local inputFrame = Instance.new("Frame", gui)
    inputFrame.Size = UDim2.new(0, 300, 0, 100)
    inputFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
    inputFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    inputFrame.BorderSizePixel = 2
    inputFrame.BorderColor3 = Color3.fromRGB(80,80,80)

    local inputLabel = Instance.new("TextLabel", inputFrame)
    inputLabel.Size = UDim2.new(1, -20, 0, 30)
    inputLabel.Position = UDim2.new(0, 10, 0, 5)
    inputLabel.BackgroundTransparency = 1
    inputLabel.TextColor3 = Color3.fromRGB(255,255,255)
    inputLabel.Text = "Enter Player Name:"
    inputLabel.Font = Enum.Font.Gotham
    
    local inputBox = Instance.new("TextBox", inputFrame)
    inputBox.Size = UDim2.new(1, -20, 0, 30)
    inputBox.Position = UDim2.new(0, 10, 0, 35)
    inputBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    inputBox.TextColor3 = Color3.fromRGB(255,255,255)
    inputBox.Font = Enum.Font.Gotham
    inputBox.Text = ""

    local submitBtn = Instance.new("TextButton", inputFrame)
    submitBtn.Size = UDim2.new(0, 80, 0, 25)
    submitBtn.Position = UDim2.new(1, -90, 1, -30)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    submitBtn.Text = "Teleport"
    submitBtn.Font = Enum.Font.GothamBold

    submitBtn.MouseButton1Click:Connect(function()
        local targetName = inputBox.Text
        if targetName ~= "" then
            local target = Players:FindFirstChild(targetName)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
                alert("Teleported to "..targetName, Color3.fromRGB(255,150,0))
            else
                alert("Player not found or dead", Color3.fromRGB(255,0,0))
            end
        end
        inputFrame:Destroy()
    end)
end)

-- Kill All
btnKillAll.MouseButton1Click:Connect(function()
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            -- A more reliable way is to use RemoteEvents if the game has them, but this is the client-side method
			p.Character:FindFirstChildOfClass("Humanoid").Health = 0
		end
	end
	alert("Kill All Executed (Client-Side)", Color3.fromRGB(255,0,0))
end)

-- God Mode
btnGodMode.MouseButton1Click:Connect(function()
	godMode = not godMode
	btnGodMode.Text = godMode and "God Mode: ON" or "God Mode: OFF"
	alert("God Mode "..(godMode and "Enabled" or "Disabled"), Color3.fromRGB(0,255,0))
    if godMode then
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").MaxHealth = math.huge
            player.Character:FindFirstChildOfClass("Humanoid").Health = math.huge
        end
    else
         if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            -- Reset health to default (this might need game-specific logic)
            player.Character:FindFirstChildOfClass("Humanoid").MaxHealth = 100
            player.Character:FindFirstChildOfClass("Humanoid").Health = 100
        end
    end
end)

-- One Hit Kill (This is very game-dependent and often doesn't work)
btnOneHit.MouseButton1Click:Connect(function()
	oneHit = not oneHit
	btnOneHit.Text = oneHit and "One Hit Kill: ON" or "One Hit Kill: OFF"
	alert("One Hit Kill "..(oneHit and "Enabled" or "Disabled"), Color3.fromRGB(255,0,0))
    -- Note: This is a placeholder. Real One Hit Kill requires exploiting game-specific weapon damage scripts or remote events.
end)

-- Kill Aura
btnKillAura.MouseButton1Click:Connect(function()
	killAura = not killAura
	btnKillAura.Text = killAura and "Kill Aura: ON" or "Kill Aura: OFF"
	alert("Kill Aura "..(killAura and "Enabled" or "Disabled"), Color3.fromRGB(255,0,0))
end)
RunService.Heartbeat:Connect(function() -- Use Heartbeat for physics-related checks
	if killAura and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		for _,p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Team ~= player.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				if (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude < 15 then
					p.Character:FindFirstChildOfClass("Humanoid").Health = 0
				end
			end
		end
	end
end)

-- Set Cash Animated
btnSetCash.MouseButton1Click:Connect(function()
	-- Reusing the teleport input frame for amount
    local inputFrame = Instance.new("Frame", gui)
    inputFrame.Size = UDim2.new(0, 300, 0, 100)
    inputFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
    inputFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    inputFrame.BorderSizePixel = 2
    inputFrame.BorderColor3 = Color3.fromRGB(80,80,80)

    local inputLabel = Instance.new("TextLabel", inputFrame)
    inputLabel.Size = UDim2.new(1, -20, 0, 30)
    inputLabel.Position = UDim2.new(0, 10, 0, 5)
    inputLabel.BackgroundTransparency = 1
    inputLabel.TextColor3 = Color3.fromRGB(255,255,255)
    inputLabel.Text = "Enter Amount:"
    inputLabel.Font = Enum.Font.Gotham
    
    local inputBox = Instance.new("TextBox", inputFrame)
    inputBox.Size = UDim2.new(1, -20, 0, 30)
    inputBox.Position = UDim2.new(0, 10, 0, 35)
    inputBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    inputBox.TextColor3 = Color3.fromRGB(255,255,255)
    inputBox.Font = Enum.Font.Gotham
    inputBox.Text = "1000000" -- Default value

    local submitBtn = Instance.new("TextButton", inputFrame)
    submitBtn.Size = UDim2.new(0, 80, 0, 25)
    submitBtn.Position = UDim2.new(1, -90, 1, -30)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    submitBtn.Text = "Set"
    submitBtn.Font = Enum.Font.GothamBold

    submitBtn.MouseButton1Click:Connect(function()
        local amount = tonumber(inputBox.Text)
        if not amount then inputFrame:Destroy(); return end
        
        local stats = player:FindFirstChild("leaderstats")
        if stats then
            for _,v in pairs(stats:GetChildren()) do
                if (v:IsA("IntValue") or v:IsA("NumberValue")) and table.find(currencies,v.Name) then
                    local current = v.Value
                    local goal = amount
                    spawn(function()
                        for i = current, goal, math.max(1, math.floor((goal-current)/50)) do
                            v.Value = i
                            task.wait(0.01)
                        end
                        v.Value = goal
                        alert(v.Name.." Increased to "..goal, Color3.fromRGB(0,255,0))
                    end)
                end
            end
        else
            alert("Leaderstats not found!", Color3.fromRGB(255,0,0))
        end
        inputFrame:Destroy()
    end)
end)

-- ESP Toggle
btnESP.MouseButton1Click:Connect(function()
	espActive = not espActive
	btnESP.Text = espActive and "ESP: ON" or "ESP: OFF"
	alert("ESP "..(espActive and "Enabled" or "Disabled"), Color3.fromRGB(0,150,255))
    if not espActive then -- Clear all ESP elements when turned off
        espFolder:ClearAllChildren()
    end
end)

-- ESP Render (Name + Box + Line)
RunService.RenderStepped:Connect(function()
    if not espActive then return end

    -- Cleanup old ESP elements
    for _,v in pairs(espFolder:GetChildren()) do
        local playerName = string.gsub(v.Name, "(Name|Box|Line)$", "")
        if not Players:FindFirstChild(playerName) then
            v:Destroy()
        end
    end

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
			local hrp = p.Character.HumanoidRootPart
			local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			
			if onScreen then
                local teamColor = p.Team and p.Team.TeamColor.Color or Color3.fromRGB(0,255,0) -- Use team color if available

				-- Name
				local nameTag = espFolder:FindFirstChild(p.Name.."Name") or Instance.new("BillboardGui", espFolder)
                nameTag.Name = p.Name.."Name"
                nameTag.Adornee = hrp
                nameTag.Size = UDim2.new(0,100,0,50)
                nameTag.AlwaysOnTop = true
                nameTag.ClipsDescendants = true
                
                local label = nameTag:FindFirstChild("Label") or Instance.new("TextLabel", nameTag)
                label.Name = "Label"
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.TextColor3 = teamColor
                label.TextStrokeTransparency = 0.5
                label.Text = p.Name
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
				
				-- Box
				local box = espFolder:FindFirstChild(p.Name.."Box") or Instance.new("Frame", espFolder)
				box.Name = p.Name.."Box"
				box.BorderSizePixel = 2
				box.BackgroundTransparency = 1
				box.BorderColor3 = teamColor
				box.Size = UDim2.new(0,50,0,80) -- Adjusted for character proportions
				box.Position = UDim2.new(0, screenPos.X - 25, 0, screenPos.Y - 40)
				box.Visible = true
				
				-- Line
				local line = espFolder:FindFirstChild(p.Name.."Line") or Instance.new("Frame", espFolder)
				line.Name = p.Name.."Line"
				line.BackgroundColor3 = teamColor
				line.BorderSizePixel = 0
				
                local mousePos = UserInputService:GetMouseLocation()
				local dx = screenPos.X - mousePos.X
				local dy = screenPos.Y - mousePos.Y
				line.Size = UDim2.new(0, math.sqrt(dx*dx + dy*dy), 0, 1)
				line.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
				line.Rotation = math.deg(math.atan2(dy, dx))
				line.Visible = true
			else
                -- Destroy if off-screen
                if espFolder:FindFirstChild(p.Name.."Name") then espFolder[p.Name.."Name"]:Destroy() end
                if espFolder:FindFirstChild(p.Name.."Box") then espFolder[p.Name.."Box"]:Destroy() end
                if espFolder:FindFirstChild(p.Name.."Line") then espFolder[p.Name.."Line"]:Destroy() end
			end
		else
            -- Destroy if player is dead or doesn't exist
            if espFolder:FindFirstChild(p.Name.."Name") then espFolder[p.Name.."Name"]:Destroy() end
            if espFolder:FindFirstChild(p.Name.."Box") then espFolder[p.Name.."Box"]:Destroy() end
            if espFolder:FindFirstChild(p.Name.."Line") then espFolder[p.Name.."Line"]:Destroy() end
        end
	end
end)

-- =================================================== --
-- ================= NEW FUNCTIONS =================== --
-- =================================================== --

-- Aimbot (Hold E to activate)
btnAimbot.MouseButton1Click:Connect(function()
    aimbot = not aimbot
    btnAimbot.Text = aimbot and "Aimbot: ON (Hold E)" or "Aimbot: OFF"
    alert("Aimbot "..(aimbot and "Enabled" or "Disabled"), Color3.fromRGB(255,100,0))
end)

local aimbotTarget = nil
UserInputService.InputBegan:Connect(function(input)
    if aimbot and input.KeyCode == Enum.KeyCode.E then
        local closestPlayer, closestDist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Team ~= player.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local dist = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < closestDist then
                    closestPlayer, closestDist = p, dist
                end
            end
        end
        aimbotTarget = closestPlayer
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        aimbotTarget = nil
    end
end)
RunService.RenderStepped:Connect(function()
    if aimbotTarget and aimbotTarget.Character and aimbotTarget.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimbotTarget.Character.HumanoidRootPart.Position)
    end
end)

-- Walk on Water
btnWalkOnWater.MouseButton1Click:Connect(function()
    walkOnWater = not walkOnWater
    btnWalkOnWater.Text = walkOnWater and "Walk on Water: ON" or "Walk on Water: OFF"
    alert("Walk on Water "..(walkOnWater and "Enabled" or "Disabled"), Color3.fromRGB(0,200,200))
end)

local waterPart = nil
RunService.Stepped:Connect(function()
    if walkOnWater and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local ray = Ray.new(player.Character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0))
        local hit, pos, normal = workspace:FindPartOnRay(ray, player.Character)
        if hit and hit.Name:match("Water") or hit and hit.Material == Enum.Material.Water then -- Checks for parts named Water or with water material
            if not waterPart then
                waterPart = Instance.new("Part", workspace)
                waterPart.Name = "WaterWalkPart"
                waterPart.Anchored = true
                waterPart.CanCollide = true
                waterPart.Transparency = 1
                waterPart.Size = Vector3.new(20, 1, 20)
            end
            waterPart.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position.X, hit.Position.Y, player.Character.HumanoidRootPart.Position.Z)
        elseif waterPart then
            waterPart:Destroy()
            waterPart = nil
        end
    elseif waterPart then
        waterPart:Destroy()
        waterPart = nil
    end
end)

-- Btools
btnBtools.MouseButton1Click:Connect(function()
    local tools = {"Hammer", "Clone", "Delete"}
    for _, toolName in pairs(tools) do
        local tool = Instance.new("HopperBin")
        tool.Name = toolName
        tool.BinType = Enum.BinType[toolName]
        tool.Parent = player.Backpack
    end
    alert("Btools Added to Backpack", Color3.fromRGB(200,200,0))
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    VirtualUser:ClickButton2(Vector2.new())
    alert("Anti-AFK Triggered", Color3.fromRGB(150,150,150))
end)

-- Click Teleport (Hold Left Alt + Click)
local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
    end
end)


-- =================================================== --
-- ================ MINIMIZE/RESTORE ================= --
-- =================================================== --

minimize.MouseButton1Click:Connect(function()
	main.Visible = false
	minimizedBtn.Visible = true
end)
minimizedBtn.MouseButton1Click:Connect(function()
	main.Visible = true
	minimizedBtn.Visible = false
end)

-- Mod Menu v4.2 [Professional + Full Features + ESP + Animated Cash]
local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ModMenu"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 540)
main.Position = UDim2.new(0.33,0,0.2,0)
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
title.Text = "Mod Menu v4.2"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Helper Functions
local function createButton(name,text,y)
	local btn = Instance.new("TextButton", main)
	btn.Name = name
	btn.Size = UDim2.new(0,280,0,30)
	btn.Position = UDim2.new(0,20,0,y)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = text
	btn.AutoButtonColor = true
	-- Hover Effect
	btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(70,70,70) end)
	btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50,50,50) end)
	return btn
end

local function createBox(placeholder,y)
	local box = Instance.new("TextBox", main)
	box.Size = UDim2.new(0,280,0,30)
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

-- Buttons
local btnNoclip = createButton("NoClip","NoClip: OFF",50)
local btnInfJump = createButton("InfJump","Infinite Jump: OFF",90)
local btnFly = createButton("Fly","Fly GUI",130)
local btnTP = createButton("Teleport","Teleport to Player",170)
local btnKillAll = createButton("KillAll","Kill All Players",210)
local btnGodMode = createButton("GodMode","God Mode: OFF",250)
local btnOneHit = createButton("OneHit","One Hit Kill: OFF",290)
local btnKillAura = createButton("KillAura","Kill Aura: OFF",330)
local btnSetCash = createButton("SetCash","Increase All Currencies",370)
local btnESP = createButton("ESP","ESP: OFF",410)

-- Boxes
local speedBox = createBox("Speed Modifier",450)
local jumpBox = createBox("Jump Modifier",490)

-- Minimize
local minimize = createButton("Minimize","Minimize",530)
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

-- Toggles
local noclip, infJump, godMode, oneHit, killAura, espActive = false,false,false,false,false,false

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
	lbl.Size = UDim2.new(0,260,0,25)
	lbl.Position = UDim2.new(0,20,0,math.random(50,450))
	lbl.BackgroundColor3 = color
	lbl.TextColor3 = Color3.fromRGB(255,255,255)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.Text = msg
	lbl.TextTransparency = 0
	game:GetService("TweenService"):Create(lbl,TweenInfo.new(0.5),{TextTransparency=1,BackgroundTransparency=1}):Play()
	delay(2,function() lbl:Destroy() end)
end

-- FUNCTIONS

-- NoClip
btnNoclip.MouseButton1Click:Connect(function()
	noclip = not noclip
	btnNoclip.Text = noclip and "NoClip: ON" or "NoClip: OFF"
	alert("NoClip "..(noclip and "Enabled" or "Disabled"), Color3.fromRGB(0,150,255))
end)
RunService.Stepped:Connect(function()
	if noclip and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide=false end
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
	if infJump and player.Character then
		player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Speed / Jump Modifier
speedBox.FocusLost:Connect(function()
	local val = tonumber(speedBox.Text)
	if val and player.Character then
		player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
		alert("WalkSpeed Set: "..val, Color3.fromRGB(0,255,0))
	end
end)
jumpBox.FocusLost:Connect(function()
	local val = tonumber(jumpBox.Text)
	if val and player.Character then
		player.Character:FindFirstChildOfClass("Humanoid").JumpPower = val
		alert("JumpPower Set: "..val, Color3.fromRGB(0,255,0))
	end
end)

-- Fly
btnFly.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Universal-Fly-V3-16477"))()
	alert("Fly Enabled", Color3.fromRGB(255,100,0))
end)

-- Teleport
btnTP.MouseButton1Click:Connect(function()
	local targetName = player:PromptInput("Enter Player Name to Teleport:","")
	if targetName and targetName~="" then
		local target = Players:FindFirstChild(targetName)
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
			alert("Teleported to "..targetName, Color3.fromRGB(255,150,0))
		end
	end
end)

-- Kill All
btnKillAll.MouseButton1Click:Connect(function()
	for _,p in pairs(Players:GetPlayers()) do
		if p~=player and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
			p.Character:FindFirstChildOfClass("Humanoid").Health=0
		end
	end
	alert("Kill All Executed", Color3.fromRGB(255,0,0))
end)

-- God Mode
btnGodMode.MouseButton1Click:Connect(function()
	godMode = not godMode
	btnGodMode.Text = godMode and "God Mode: ON" or "God Mode: OFF"
	alert("God Mode "..(godMode and "Enabled" or "Disabled"), Color3.fromRGB(0,255,0))
end)
RunService.Stepped:Connect(function()
	if godMode and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
		player.Character:FindFirstChildOfClass("Humanoid").Health = player.Character:FindFirstChildOfClass("Humanoid").MaxHealth
	end
end)

-- One Hit Kill
btnOneHit.MouseButton1Click:Connect(function()
	oneHit = not oneHit
	btnOneHit.Text = oneHit and "One Hit Kill: ON" or "One Hit Kill: OFF"
	alert("One Hit Kill "..(oneHit and "Enabled" or "Disabled"), Color3.fromRGB(255,0,0))
end)

-- Kill Aura
btnKillAura.MouseButton1Click:Connect(function()
	killAura = not killAura
	btnKillAura.Text = killAura and "Kill Aura: ON" or "Kill Aura: OFF"
	alert("Kill Aura "..(killAura and "Enabled" or "Disabled"), Color3.fromRGB(255,0,0))
end)
RunService.RenderStepped:Connect(function()
	if killAura and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		for _,p in pairs(Players:GetPlayers()) do
			if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				if (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude<15 then
					p.Character:FindFirstChildOfClass("Humanoid").Health=0
				end
			end
		end
	end
end)

-- Set Cash Animated
btnSetCash.MouseButton1Click:Connect(function()
	local amount = tonumber(player:PromptInput("Enter Amount for All Currencies:","1000"))
	if not amount then return end
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		for _,v in pairs(stats:GetChildren()) do
			if (v:IsA("IntValue") or v:IsA("NumberValue")) and table.find(currencies,v.Name) then
				local current = v.Value
				local goal = amount
				spawn(function()
					for i = current, goal, math.max(1, math.floor((goal-current)/50)) do
						v.Value = i
						wait(0.01)
					end
					v.Value = goal
					alert(v.Name.." Increased to "..goal, Color3.fromRGB(0,255,0))
				end)
			end
		end
	end
end)

-- ESP Toggle
btnESP.MouseButton1Click:Connect(function()
	espActive = not espActive
	btnESP.Text = espActive and "ESP: ON" or "ESP: OFF"
	alert("ESP "..(espActive and "Enabled" or "Disabled"), Color3.fromRGB(0,150,255))
end)

-- ESP Render (Name + Box + Line)
RunService.RenderStepped:Connect(function()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			
			if espActive and onScreen then
				-- Name
				local nameTag = espFolder:FindFirstChild(p.Name.."Name")
				if not nameTag then
					local txt = Instance.new("BillboardGui", espFolder)
					txt.Name = p.Name.."Name"
					txt.Adornee = hrp
					txt.Size = UDim2.new(0,100,0,50)
					txt.AlwaysOnTop = true
					local label = Instance.new("TextLabel", txt)
					label.Size = UDim2.new(1,0,1,0)
					label.BackgroundTransparency = 1
					label.TextColor3 = Color3.fromRGB(0,255,0)
					label.TextStrokeTransparency = 0
					label.Text = p.Name
					label.Font = Enum.Font.GothamBold
					label.TextSize = 14
				end
				
				-- Box
				local box = espFolder:FindFirstChild(p.Name.."Box")
				if not box then
					box = Instance.new("Frame")
					box.Name = p.Name.."Box"
					box.BorderSizePixel = 2
					box.BackgroundTransparency = 1
					box.BorderColor3 = Color3.fromRGB(0,255,0)
					box.Parent = gui
				end
				box.Size = UDim2.new(0,50,0,50)
				box.Position = UDim2.new(0, screenPos.X-25,0,screenPos.Y-25)
				box.Visible = true
				
				-- Line
				local line = espFolder:FindFirstChild(p.Name.."Line")
				if not line then
					line = Instance.new("Frame")
					line.Name = p.Name.."Line"
					line.BackgroundColor3 = Color3.fromRGB(0,255,0)
					line.BorderSizePixel = 0
					line.Parent = gui
				end
				local playerPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
				local dx = screenPos.X - playerPos.X
				local dy = screenPos.Y - playerPos.Y
				line.Size = UDim2.new(0, math.sqrt(dx*dx + dy*dy), 0, 2)
				line.Position = UDim2.new(0, playerPos.X, 0, playerPos.Y)
				line.Rotation = math.deg(math.atan2(dy, dx))
				line.Visible = true
			else
				-- Destroy ESP if not active
				if espFolder:FindFirstChild(p.Name.."Name") then espFolder[p.Name.."Name"]:Destroy() end
				if espFolder:FindFirstChild(p.Name.."Box") then espFolder[p.Name.."Box"]:Destroy() end
				if espFolder:FindFirstChild(p.Name.."Line") then espFolder[p.Name.."Line"]:Destroy() end
			end
		end
	end
end)

-- Minimize / Restore
minimize.MouseButton1Click:Connect(function()
	main.Visible = false
	minimizedBtn.Visible = true
end)
minimizedBtn.MouseButton1Click:Connect(function()
	main.Visible = true
	minimizedBtn.Visible = false
end)

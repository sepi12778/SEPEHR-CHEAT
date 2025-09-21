
-- Services (سرویس‌های اصلی)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Local Variables (متغیرهای محلی)
local LocalPlayer = Players.LocalPlayer
local connections = {}
local oldNamecall

-- Notification Function (تابع نمایش اعلان)
local function notify(msg, err)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "SEPEHR MOD Menu" .. (err and " | Error" or " | Info"),
            Text = tostring(msg),
            Duration = 5
        })
    end)
end

-- Toggles State (وضعیت فعال/غیرفعال بودن مودها)
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
    TeleportOthers = false
}

-- ===== بارگذاری مودهای جداگانه =====
-- توجه: این بخش فرض می‌کند که تمام اسکریپت‌های دیگر در همان محل اسکریپت اصلی قرار دارند.
-- اگر از یک loader استفاده می‌کنید، شاید نیاز به تغییر مسیرها باشد.

local toggleFly = require(script.Parent.Fly)
local toggleSpeed = require(script.Parent.Speed)
local toggleInfiniteJump = require(script.Parent.InfiniteJump)
local toggleNoClip = require(script.Parent.NoClip)
local toggleGodMode = require(script.Parent.GodMode)
local toggleInvisibility = require(script.Parent.Invisibility)
local toggleAntiAFK = require(script.Parent.AntiAFK)
local toggleClickDelete = require(script.Parent.ClickDelete)
local toggleClickTeleport = require(script.Parent.ClickTeleport)
local espModule = require(script.Parent.ESP)
local autoMoneyModule = require(script.Parent.AutoMoney)
local playerTPModule = require(script.Parent.PlayerTP)
local teleportOthersModule = require(script.Parent.TeleportOthers)
local hackPanelModule = require(script.Parent.HackPanel)

-- مقداردهی اولیه مودها
toggleFly = toggleFly(toggles, connections, notify, LocalPlayer)
toggleSpeed = toggleSpeed(toggles, notify, LocalPlayer)
toggleInfiniteJump = toggleInfiniteJump(toggles, connections, notify, LocalPlayer)
toggleNoClip = toggleNoClip(toggles, connections, notify, LocalPlayer)
toggleGodMode = toggleGodMode(toggles, connections, notify, LocalPlayer)
toggleInvisibility = toggleInvisibility(toggles, notify, LocalPlayer)
toggleAntiAFK = toggleAntiAFK(toggles, connections, notify, LocalPlayer)
toggleClickDelete = toggleClickDelete(toggles, connections, notify, LocalPlayer)
toggleClickTeleport = toggleClickTeleport(toggles, connections, notify, LocalPlayer)
local toggleESP, updateESP = espModule(toggles, notify)
local toggleAutoMoney, SetAutoMoneyRemote = autoMoneyModule(toggles, notify)
local togglePlayerTP = playerTPModule(toggles, connections, notify, LocalPlayer)
local toggleTeleportOthers = teleportOthersModule(toggles, connections, notify, LocalPlayer)
local toggleHackPanel = hackPanelModule(toggles, notify, SetAutoMoneyRemote)

-- اجرای بروزرسانی‌های مداوم
RunService.RenderStepped:Connect(updateESP)

-- GUI Setup (ساخت منو)
-- (کد کامل GUI که در اسکریپت اصلی شما بود، باید اینجا قرار بگیرد)
-- ... [کد کامل بخش "GUI Setup" تا انتهای اسکریپت اصلی را اینجا کپی کنید] ...
-- به دلیل طولانی بودن، من فقط توابع `makeToggle` را نمایش می‌دهم.

-- GUI Setup
if CoreGui:FindFirstChild("SEPEHRMODMenuV") then
    CoreGui:FindFirstChild("SEPEHRMODMenuV"):Destroy()
end

-- [ ... تمام کد ساخت GUI از اسکریپت اصلی شما در اینجا قرار می‌گیرد ... ]
-- ...
-- ...
-- makeToggle("Fly", toggleFly, 1)
-- makeToggle("High Speed", toggleSpeed, 2)
-- makeToggle("Infinite Jump", toggleInfiniteJump, 3)
-- makeToggle("God Mode", toggleGodMode, 4)
-- ... و غیره برای تمام دکمه‌ها

notify("SEPEHR MOD Menu loaded successfully!")


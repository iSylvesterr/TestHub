--[[
    Auto Hunt Event Hub
    Fitur: Auto hunt event seperti Shark Hunt yang muncul secara otomatis
    
    Cara pakai:
    1. Execute script ini
    2. Toggle "Auto Hunt Event" di GUI
    3. Script akan otomatis detect dan hunt event
]]

local AutoHuntHub = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Settings
AutoHuntHub.Settings = {
    Enabled = false,
    TeleportSpeed = 200, -- Speed saat teleport ke event
    AutoCollectRewards = true,
    NotifyOnEvent = true,
    EventTypes = {
        ["Shark Hunt"] = true,
        -- Tambahkan event lain di sini
    }
}

-- Current Event Data
AutoHuntHub.CurrentEvent = nil
AutoHuntHub.IsHunting = false

-- Event List yang terdeteksi
AutoHuntHub.EventCache = {}

--[[
    Fungsi untuk detect event dari ReplicatedStorage atau Workspace
]]
function AutoHuntHub:DetectEvents()
    -- Cari event di ReplicatedStorage atau di folder khusus game
    -- Sesuaikan dengan struktur game kamu
    
    local eventData = nil
    
    -- Contoh: Cek di ReplicatedStorage
    pcall(function()
        local events = ReplicatedStorage:FindFirstChild("Events")
        if events then
            for _, child in pairs(events:GetChildren()) do
                if child:IsA("ModuleScript") then
                    local success, data = pcall(function()
                        return require(child)
                    end)
                    
                    if success and data and data.Name then
                        -- Simpan event data
                        AutoHuntHub.EventCache[data.Name] = data
                    end
                end
            end
        end
    end)
    
    -- Cek workspace untuk active events
    pcall(function()
        local workspace = game:GetService("Workspace")
        local eventFolder = workspace:FindFirstChild("ActiveEvents") or workspace:FindFirstChild("Events")
        
        if eventFolder then
            for _, event in pairs(eventFolder:GetChildren()) do
                if event:IsA("Model") or event:IsA("Folder") then
                    -- Event ditemukan!
                    return event
                end
            end
        end
    end)
    
    return eventData
end

--[[
    Fungsi untuk parse event data seperti Shark Hunt
]]
function AutoHuntHub:ParseEventData(eventModule)
    local success, data = pcall(function()
        return require(eventModule)
    end)
    
    if success and data then
        return {
            Name = data.Name,
            Icon = data.Icon,
            Description = data.Description,
            Tier = data.Tier,
            Duration = data.Duration,
            Coordinates = data.Coordinates,
            AreaConfiguration = data.AreaConfiguration,
            Modifiers = data.Modifiers
        }
    end
    
    return nil
end

--[[
    Teleport ke koordinat event
]]
function AutoHuntHub:TeleportToCoordinate(position)
    if not position or typeof(position) ~= "Vector3" then
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Method 1: Instant teleport
    hrp.CFrame = CFrame.new(position)
    
    -- Method 2: Smooth teleport (uncomment jika mau smooth)
    --[[
    local tweenInfo = TweenInfo.new(
        (hrp.Position - position).Magnitude / AutoHuntHub.Settings.TeleportSpeed,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    tween.Completed:Wait()
    ]]
    
    return true
end

--[[
    Hunt event di semua koordinat
]]
function AutoHuntHub:HuntEvent(eventData)
    if not eventData or not eventData.Coordinates then
        return
    end
    
    AutoHuntHub.IsHunting = true
    
    if AutoHuntHub.Settings.NotifyOnEvent then
        AutoHuntHub:Notify("Event Detected", "Hunting: " .. (eventData.Name or "Unknown Event"))
    end
    
    -- Loop through semua koordinat
    for i, coord in ipairs(eventData.Coordinates) do
        if not AutoHuntHub.Settings.Enabled then
            break
        end
        
        AutoHuntHub:Notify("Teleporting", string.format("Location %d/%d", i, #eventData.Coordinates))
        
        -- Teleport ke koordinat
        AutoHuntHub:TeleportToCoordinate(coord)
        
        -- Wait untuk collect/interact
        wait(2)
        
        -- Auto collect rewards jika ada
        if AutoHuntHub.Settings.AutoCollectRewards then
            AutoHuntHub:CollectNearbyRewards()
        end
        
        -- Wait sebentar sebelum ke lokasi berikutnya
        wait(1)
    end
    
    AutoHuntHub.IsHunting = false
    AutoHuntHub:Notify("Complete", "Event hunt selesai!")
end

--[[
    Collect rewards yang ada di sekitar player
]]
function AutoHuntHub:CollectNearbyRewards()
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Cari items/rewards dalam radius
    local radius = 50
    
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("reward") or obj.Name:lower():find("loot") or obj.Name:lower():find("item")) then
            local distance = (obj.Position - hrp.Position).Magnitude
            
            if distance <= radius then
                -- Teleport ke item
                pcall(function()
                    firetouchinterest(hrp, obj, 0)
                    wait(0.1)
                    firetouchinterest(hrp, obj, 1)
                end)
            end
        end
    end
end

--[[
    Notification system
]]
function AutoHuntHub:Notify(title, message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = 3
    })
end

--[[
    Monitor untuk event baru
]]
function AutoHuntHub:StartEventMonitor()
    spawn(function()
        while wait(5) do -- Check setiap 5 detik
            if AutoHuntHub.Settings.Enabled and not AutoHuntHub.IsHunting then
                -- Detect events
                local event = AutoHuntHub:DetectEvents()
                
                if event then
                    local eventData = AutoHuntHub:ParseEventData(event)
                    
                    if eventData and AutoHuntHub.Settings.EventTypes[eventData.Name] then
                        -- Hunt event ini
                        AutoHuntHub:HuntEvent(eventData)
                    end
                end
            end
        end
    end)
end

--[[
    Manual trigger untuk hunt event dengan data custom
]]
function AutoHuntHub:HuntCustomEvent(eventData)
    if not eventData then
        -- Contoh: Shark Hunt event
        eventData = {
            Name = "Shark Hunt",
            Icon = "rbxassetid://74938397479780",
            Description = "Shark Hunt",
            Tier = 4,
            Duration = 1800,
            Coordinates = {
                Vector3.new(1.64999, -1.3500, 2095.72),
                Vector3.new(1369.94, -1.3500, 930.125),
                Vector3.new(-1585.5, -1.3500, 1242.87),
                Vector3.new(-1896.8, -1.3500, 2634.37)
            }
        }
    end
    
    AutoHuntHub:HuntEvent(eventData)
end

--[[
    Create GUI
]]
function AutoHuntHub:CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoHuntHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.CoreGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Add corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.BorderSizePixel = 0
    Title.Text = "🦈 Auto Hunt Event Hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Toggle Auto Hunt
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
    ToggleButton.Position = UDim2.new(0.05, 0, 0, 70)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ToggleButton.Text = "Auto Hunt: OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = MainFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleButton
    
    -- Manual Hunt Button
    local ManualButton = Instance.new("TextButton")
    ManualButton.Name = "ManualButton"
    ManualButton.Size = UDim2.new(0.9, 0, 0, 40)
    ManualButton.Position = UDim2.new(0.05, 0, 0, 120)
    ManualButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    ManualButton.Text = "🦈 Hunt Shark Event"
    ManualButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ManualButton.TextSize = 16
    ManualButton.Font = Enum.Font.GothamBold
    ManualButton.Parent = MainFrame
    
    local ManualCorner = Instance.new("UICorner")
    ManualCorner.CornerRadius = UDim.new(0, 8)
    ManualCorner.Parent = ManualButton
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(0.9, 0, 0, 60)
    StatusLabel.Position = UDim2.new(0.05, 0, 0, 170)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    StatusLabel.Text = "Status: Idle\nWaiting for events..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusLabel
    
    -- Settings Frame
    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Name = "SettingsFrame"
    SettingsFrame.Size = UDim2.new(0.9, 0, 0, 100)
    SettingsFrame.Position = UDim2.new(0.05, 0, 0, 240)
    SettingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SettingsFrame.Parent = MainFrame
    
    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 8)
    SettingsCorner.Parent = SettingsFrame
    
    -- Auto Collect Toggle
    local AutoCollectToggle = Instance.new("TextButton")
    AutoCollectToggle.Name = "AutoCollectToggle"
    AutoCollectToggle.Size = UDim2.new(0.9, 0, 0, 35)
    AutoCollectToggle.Position = UDim2.new(0.05, 0, 0, 10)
    AutoCollectToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    AutoCollectToggle.Text = "✓ Auto Collect Rewards"
    AutoCollectToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoCollectToggle.TextSize = 14
    AutoCollectToggle.Font = Enum.Font.Gotham
    AutoCollectToggle.Parent = SettingsFrame
    
    local AutoCollectCorner = Instance.new("UICorner")
    AutoCollectCorner.CornerRadius = UDim.new(0, 6)
    AutoCollectCorner.Parent = AutoCollectToggle
    
    -- Notify Toggle
    local NotifyToggle = Instance.new("TextButton")
    NotifyToggle.Name = "NotifyToggle"
    NotifyToggle.Size = UDim2.new(0.9, 0, 0, 35)
    NotifyToggle.Position = UDim2.new(0.05, 0, 0, 55)
    NotifyToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    NotifyToggle.Text = "✓ Notifications"
    NotifyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifyToggle.TextSize = 14
    NotifyToggle.Font = Enum.Font.Gotham
    NotifyToggle.Parent = SettingsFrame
    
    local NotifyCorner = Instance.new("UICorner")
    NotifyCorner.CornerRadius = UDim.new(0, 6)
    NotifyCorner.Parent = NotifyToggle
    
    -- Draggable
    local dragging, dragInput, dragStart, startPos
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Button Functions
    ToggleButton.MouseButton1Click:Connect(function()
        AutoHuntHub.Settings.Enabled = not AutoHuntHub.Settings.Enabled
        
        if AutoHuntHub.Settings.Enabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            ToggleButton.Text = "Auto Hunt: ON"
            StatusLabel.Text = "Status: Active\nMonitoring for events..."
            AutoHuntHub:Notify("Auto Hunt", "Enabled!")
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            ToggleButton.Text = "Auto Hunt: OFF"
            StatusLabel.Text = "Status: Idle\nWaiting for events..."
            AutoHuntHub:Notify("Auto Hunt", "Disabled!")
        end
    end)
    
    ManualButton.MouseButton1Click:Connect(function()
        AutoHuntHub:Notify("Manual Hunt", "Starting Shark Hunt...")
        StatusLabel.Text = "Status: Hunting\nShark Event in progress..."
        AutoHuntHub:HuntCustomEvent()
        wait(2)
        StatusLabel.Text = "Status: Idle\nWaiting for events..."
    end)
    
    AutoCollectToggle.MouseButton1Click:Connect(function()
        AutoHuntHub.Settings.AutoCollectRewards = not AutoHuntHub.Settings.AutoCollectRewards
        
        if AutoHuntHub.Settings.AutoCollectRewards then
            AutoCollectToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            AutoCollectToggle.Text = "✓ Auto Collect Rewards"
        else
            AutoCollectToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            AutoCollectToggle.Text = "✗ Auto Collect Rewards"
        end
    end)
    
    NotifyToggle.MouseButton1Click:Connect(function()
        AutoHuntHub.Settings.NotifyOnEvent = not AutoHuntHub.Settings.NotifyOnEvent
        
        if AutoHuntHub.Settings.NotifyOnEvent then
            NotifyToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            NotifyToggle.Text = "✓ Notifications"
        else
            NotifyToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            NotifyToggle.Text = "✗ Notifications"
        end
    end)
    
    return ScreenGui
end

--[[
    Initialize
]]
function AutoHuntHub:Init()
    -- Create GUI
    AutoHuntHub:CreateGUI()
    
    -- Start event monitor
    AutoHuntHub:StartEventMonitor()
    
    -- Welcome notification
    AutoHuntHub:Notify("Auto Hunt Hub", "Script loaded! Toggle untuk mulai.")
end

-- Start the hub
AutoHuntHub:Init()

return AutoHuntHub

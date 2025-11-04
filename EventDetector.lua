--[[
    Event Detector Module
    Mendeteksi berbagai jenis event yang muncul di game
]]

local EventDetector = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Event templates untuk berbagai jenis event
EventDetector.EventTemplates = {
    ["Shark Hunt"] = {
        Name = "Shark Hunt",
        Icon = "rbxassetid://74938397479780",
        Description = "Shark Hunt Event",
        Tier = 4,
        Duration = 1800,
        Coordinates = {
            Vector3.new(1.64999, -1.3500, 2095.72),
            Vector3.new(1369.94, -1.3500, 930.125),
            Vector3.new(-1585.5, -1.3500, 1242.87),
            Vector3.new(-1896.8, -1.3500, 2634.37)
        },
        DetectionMethod = "RemoteEvent", -- atau "Workspace", "GUI"
        RemotePath = "Events.SharkHunt"
    },
    
    -- Tambahkan event lain di sini
    -- Template untuk event baru:
    --[[
    ["Event Name"] = {
        Name = "Event Name",
        Icon = "rbxassetid://...",
        Description = "Event Description",
        Tier = 1,
        Duration = 600,
        Coordinates = {
            Vector3.new(x, y, z),
            -- tambahkan koordinat lainnya
        },
        DetectionMethod = "Workspace",
        WorkspacePath = "Events.EventName"
    }
    ]]
}

--[[
    Detect event by checking ReplicatedStorage
]]
function EventDetector:CheckReplicatedStorage()
    local detectedEvents = {}
    
    pcall(function()
        -- Cari folder Events
        local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
        if not eventsFolder then return end
        
        -- Loop semua children
        for _, child in pairs(eventsFolder:GetDescendants()) do
            if child:IsA("ModuleScript") then
                local success, eventData = pcall(function()
                    return require(child)
                end)
                
                if success and eventData and eventData.Name then
                    table.insert(detectedEvents, eventData)
                end
            end
        end
    end)
    
    return detectedEvents
end

--[[
    Detect event by checking Workspace
]]
function EventDetector:CheckWorkspace()
    local detectedEvents = {}
    
    pcall(function()
        -- Cari active events di workspace
        local workspaceFolders = {
            "ActiveEvents",
            "Events", 
            "GameEvents",
            "WorldEvents"
        }
        
        for _, folderName in ipairs(workspaceFolders) do
            local folder = Workspace:FindFirstChild(folderName)
            
            if folder then
                for _, event in pairs(folder:GetChildren()) do
                    if event:IsA("Model") or event:IsA("Folder") then
                        -- Extract event info dari model
                        local eventInfo = {
                            Name = event.Name,
                            Model = event,
                            Coordinates = {}
                        }
                        
                        -- Cari koordinat dari parts dalam model
                        for _, part in pairs(event:GetDescendants()) do
                            if part:IsA("BasePart") and (part.Name:find("Spawn") or part.Name:find("Location")) then
                                table.insert(eventInfo.Coordinates, part.Position)
                            end
                        end
                        
                        table.insert(detectedEvents, eventInfo)
                    end
                end
            end
        end
    end)
    
    return detectedEvents
end

--[[
    Detect event by checking Player GUI (untuk event notifications)
]]
function EventDetector:CheckPlayerGUI(player)
    local detectedEvents = {}
    
    pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Cari GUI yang menampilkan event notifications
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text:lower()
                
                -- Check jika ada keyword event
                if text:find("event") or text:find("hunt") then
                    -- Parse event name dari text
                    for eventName, template in pairs(EventDetector.EventTemplates) do
                        if text:find(eventName:lower()) then
                            table.insert(detectedEvents, template)
                        end
                    end
                end
            end
        end
    end)
    
    return detectedEvents
end

--[[
    Listen untuk RemoteEvent yang trigger event
]]
function EventDetector:ListenForRemoteEvents(callback)
    pcall(function()
        local remotes = ReplicatedStorage:GetDescendants()
        
        for _, remote in pairs(remotes) do
            if remote:IsA("RemoteEvent") and (remote.Name:find("Event") or remote.Name:find("Hunt")) then
                remote.OnClientEvent:Connect(function(...)
                    local args = {...}
                    
                    -- Check jika ini event data
                    if type(args[1]) == "table" and args[1].Name then
                        callback(args[1])
                    end
                end)
            end
        end
    end)
end

--[[
    Main detection function
    Returns: table of detected events
]]
function EventDetector:ScanForEvents()
    local allEvents = {}
    
    -- Method 1: Check ReplicatedStorage
    local rsEvents = EventDetector:CheckReplicatedStorage()
    for _, event in ipairs(rsEvents) do
        table.insert(allEvents, event)
    end
    
    -- Method 2: Check Workspace
    local wsEvents = EventDetector:CheckWorkspace()
    for _, event in ipairs(wsEvents) do
        table.insert(allEvents, event)
    end
    
    -- Method 3: Check PlayerGUI
    local player = game.Players.LocalPlayer
    local guiEvents = EventDetector:CheckPlayerGUI(player)
    for _, event in ipairs(guiEvents) do
        table.insert(allEvents, event)
    end
    
    return allEvents
end

--[[
    Get event by name from templates
]]
function EventDetector:GetEventTemplate(eventName)
    return EventDetector.EventTemplates[eventName]
end

--[[
    Add custom event template
]]
function EventDetector:AddEventTemplate(eventName, eventData)
    EventDetector.EventTemplates[eventName] = eventData
end

--[[
    Monitor untuk event secara continuous
]]
function EventDetector:StartMonitoring(callback, interval)
    interval = interval or 5 -- Default 5 detik
    
    spawn(function()
        while wait(interval) do
            local events = EventDetector:ScanForEvents()
            
            if #events > 0 then
                callback(events)
            end
        end
    end)
end

return EventDetector

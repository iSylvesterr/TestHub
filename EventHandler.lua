--[[
    Event Handler Module
    Menangani hunting, teleportation, dan completion logic untuk events
]]

local EventHandler = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- State
EventHandler.CurrentEvent = nil
EventHandler.IsActive = false
EventHandler.HuntProgress = 0

--[[
    Teleport player ke koordinat dengan berbagai method
]]
function EventHandler:Teleport(position, method)
    method = method or "instant" -- "instant", "tween", "walk"
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    if method == "instant" then
        -- Instant teleport
        hrp.CFrame = CFrame.new(position)
        
    elseif method == "tween" then
        -- Smooth tween teleport
        local distance = (hrp.Position - position).Magnitude
        local speed = 200 -- units per second
        local duration = distance / speed
        
        local tweenInfo = TweenInfo.new(
            duration,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        )
        
        local goal = {CFrame = CFrame.new(position)}
        local tween = TweenService:Create(hrp, tweenInfo, goal)
        
        tween:Play()
        tween.Completed:Wait()
        
    elseif method == "walk" then
        -- Walk to position using Humanoid
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:MoveTo(position)
            humanoid.MoveToFinished:Wait()
        end
    end
    
    return true
end

--[[
    Collect items/rewards di sekitar player
]]
function EventHandler:CollectNearby(radius)
    radius = radius or 50
    
    local character = LocalPlayer.Character
    if not character then return 0 end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    
    local collected = 0
    
    -- Keywords untuk item yang bisa di-collect
    local itemKeywords = {
        "reward", "loot", "item", "pickup", "collect",
        "coin", "money", "gem", "treasure", "fish",
        "shark", "catch"
    }
    
    -- Scan workspace untuk items
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local distance = (obj.Position - hrp.Position).Magnitude
            
            if distance <= radius then
                -- Check jika nama mengandung keyword
                local objName = obj.Name:lower()
                for _, keyword in ipairs(itemKeywords) do
                    if objName:find(keyword) then
                        -- Try to collect
                        pcall(function()
                            -- Method 1: Fire touch interest
                            firetouchinterest(hrp, obj, 0)
                            wait(0.05)
                            firetouchinterest(hrp, obj, 1)
                            
                            collected = collected + 1
                        end)
                        
                        pcall(function()
                            -- Method 2: Teleport item to player
                            obj.CFrame = hrp.CFrame
                        end)
                        
                        break
                    end
                end
            end
        end
    end
    
    return collected
end

--[[
    Interact dengan object (untuk NPCs, buttons, dll)
]]
function EventHandler:InteractWith(object)
    if not object then return false end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Try different interaction methods
    local success = false
    
    -- Method 1: ClickDetector
    pcall(function()
        local clickDetector = object:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            fireclickdetector(clickDetector)
            success = true
        end
    end)
    
    -- Method 2: ProximityPrompt
    pcall(function()
        local prompt = object:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
            success = true
        end
    end)
    
    -- Method 3: Touch
    pcall(function()
        if object:IsA("BasePart") then
            firetouchinterest(hrp, object, 0)
            wait(0.1)
            firetouchinterest(hrp, object, 1)
            success = true
        end
    end)
    
    return success
end

--[[
    Find dan interact dengan NPCs atau quest givers
]]
function EventHandler:FindAndInteractNPC(npcName)
    local npcs = workspace:GetDescendants()
    
    for _, obj in pairs(npcs) do
        if obj:IsA("Model") and obj.Name:lower():find(npcName:lower()) then
            -- Teleport ke NPC
            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                EventHandler:Teleport(primaryPart.Position + Vector3.new(0, 0, 5))
                wait(0.5)
                
                -- Interact
                EventHandler:InteractWith(obj)
                return true
            end
        end
    end
    
    return false
end

--[[
    Hunt event dengan progress tracking
]]
function EventHandler:HuntEvent(eventData, options)
    options = options or {}
    
    -- Default options
    local settings = {
        teleportMethod = options.teleportMethod or "instant",
        waitTime = options.waitTime or 2,
        collectRadius = options.collectRadius or 50,
        autoCollect = options.autoCollect ~= false,
        onProgress = options.onProgress or function() end,
        onComplete = options.onComplete or function() end
    }
    
    if not eventData or not eventData.Coordinates then
        return false
    end
    
    EventHandler.IsActive = true
    EventHandler.CurrentEvent = eventData
    EventHandler.HuntProgress = 0
    
    local totalLocations = #eventData.Coordinates
    
    -- Hunt semua lokasi
    for i, coord in ipairs(eventData.Coordinates) do
        if not EventHandler.IsActive then
            break
        end
        
        -- Update progress
        EventHandler.HuntProgress = (i - 1) / totalLocations * 100
        settings.onProgress(i, totalLocations, EventHandler.HuntProgress)
        
        -- Teleport ke lokasi
        local success = EventHandler:Teleport(coord, settings.teleportMethod)
        
        if success then
            -- Wait untuk load area
            wait(settings.waitTime)
            
            -- Auto collect jika enabled
            if settings.autoCollect then
                local collected = EventHandler:CollectNearby(settings.collectRadius)
                
                if collected > 0 then
                    print(string.format("Collected %d items at location %d", collected, i))
                end
            end
            
            -- Wait sebentar sebelum next location
            wait(1)
        end
    end
    
    -- Complete
    EventHandler.HuntProgress = 100
    EventHandler.IsActive = false
    settings.onComplete()
    
    return true
end

--[[
    Stop current hunt
]]
function EventHandler:StopHunt()
    EventHandler.IsActive = false
    EventHandler.CurrentEvent = nil
    EventHandler.HuntProgress = 0
end

--[[
    Get current hunt status
]]
function EventHandler:GetStatus()
    return {
        isActive = EventHandler.IsActive,
        currentEvent = EventHandler.CurrentEvent,
        progress = EventHandler.HuntProgress
    }
end

--[[
    Auto farm fish/sharks di lokasi tertentu
]]
function EventHandler:FarmAtLocation(position, duration)
    duration = duration or 60 -- Default 60 detik
    
    -- Teleport ke location
    EventHandler:Teleport(position)
    
    local startTime = tick()
    local totalCollected = 0
    
    -- Farm loop
    while tick() - startTime < duration do
        -- Collect nearby
        local collected = EventHandler:CollectNearby(100)
        totalCollected = totalCollected + collected
        
        -- Wait sebelum next collection
        wait(1)
    end
    
    return totalCollected
end

--[[
    Smart hunting - cari lokasi dengan paling banyak items
]]
function EventHandler:SmartHunt(eventData)
    if not eventData or not eventData.Coordinates then
        return false
    end
    
    local locationScores = {}
    
    -- Scan setiap lokasi untuk count items
    for i, coord in ipairs(eventData.Coordinates) do
        EventHandler:Teleport(coord)
        wait(2)
        
        -- Count nearby items
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            local itemCount = 0
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local distance = (obj.Position - hrp.Position).Magnitude
                    if distance <= 100 and obj.Name:lower():find("fish") or obj.Name:lower():find("shark") then
                        itemCount = itemCount + 1
                    end
                end
            end
            
            locationScores[i] = itemCount
        end
    end
    
    -- Sort lokasi by score
    local sortedLocations = {}
    for i, score in pairs(locationScores) do
        table.insert(sortedLocations, {index = i, score = score, position = eventData.Coordinates[i]})
    end
    
    table.sort(sortedLocations, function(a, b)
        return a.score > b.score
    end)
    
    -- Hunt lokasi dengan score tertinggi
    for _, loc in ipairs(sortedLocations) do
        if EventHandler.IsActive then
            print(string.format("Hunting location %d with score %d", loc.index, loc.score))
            EventHandler:Teleport(loc.position)
            wait(2)
            EventHandler:CollectNearby(100)
            wait(3)
        end
    end
    
    return true
end

return EventHandler

--[[
    Quick Start Script
    Load semua modules dan start auto hunt hub
    
    Cara pakai:
    1. Execute script ini
    2. GUI akan muncul
    3. Toggle "Auto Hunt: ON" untuk mulai
]]

print("🦈 Loading Auto Hunt Event Hub...")

-- Load semua modules
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/yourrepo/main/Config.lua"))()
local EventDetector = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/yourrepo/main/EventDetector.lua"))()
local EventHandler = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/yourrepo/main/EventHandler.lua"))()
local AutoHuntHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/yourrepo/main/AutoHuntHub.lua"))()

--[[
    ATAU jika file ada locally:
    
    local Config = require(script.Parent.Config)
    local EventDetector = require(script.Parent.EventDetector)
    local EventHandler = require(script.Parent.EventHandler)
    local AutoHuntHub = require(script.Parent.AutoHuntHub)
]]

print("✅ Auto Hunt Event Hub loaded successfully!")
print("📖 Tutorial:")
print("   1. Toggle 'Auto Hunt: ON' di GUI")
print("   2. Script akan auto detect dan hunt events")
print("   3. Atau click 'Hunt Shark Event' untuk manual test")

-- Example: Add custom event
--[[
AutoHuntHub.AddCustomEvent = function(eventName, eventData)
    Config.CustomEvents[eventName] = eventData
    Config.Events.EnabledEvents[eventName] = true
end

-- Contoh menambahkan event baru:
AutoHuntHub.AddCustomEvent("My Event", {
    Name = "My Event",
    Icon = "rbxassetid://...",
    Description = "My Custom Event",
    Tier = 3,
    Duration = 900,
    Coordinates = {
        Vector3.new(100, 10, 200),
        Vector3.new(300, 10, 400),
    }
})
]]

-- Return hub untuk access functions
return AutoHuntHub

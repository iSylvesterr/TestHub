--[[
    Configuration File
    Sesuaikan settings di sini untuk customize behavior auto hunt
]]

local Config = {}

-- === GENERAL SETTINGS ===
Config.General = {
    -- Enable/disable auto hunt saat script load
    AutoStartEnabled = false,
    
    -- Scan interval untuk detect events (dalam detik)
    ScanInterval = 5,
    
    -- Show notifications
    ShowNotifications = true,
    
    -- Debug mode (print info ke console)
    DebugMode = false
}

-- === TELEPORT SETTINGS ===
Config.Teleport = {
    -- Method: "instant", "tween", atau "walk"
    Method = "instant",
    
    -- Speed untuk tween teleport (units per second)
    TweenSpeed = 200,
    
    -- Wait time setelah teleport (untuk load area)
    WaitAfterTeleport = 2,
    
    -- Enable anti-AFK (auto move sedikit untuk prevent kick)
    AntiAFK = true
}

-- === COLLECTION SETTINGS ===
Config.Collection = {
    -- Auto collect rewards
    Enabled = true,
    
    -- Radius untuk collect items (studs)
    Radius = 50,
    
    -- Keywords untuk detect items yang bisa di-collect
    ItemKeywords = {
        "reward", "loot", "item", "pickup", "collect",
        "coin", "money", "gem", "treasure", "fish",
        "shark", "catch", "prize"
    },
    
    -- Collect interval (detik)
    CollectInterval = 1
}

-- === EVENT SETTINGS ===
Config.Events = {
    -- Daftar event yang mau di-auto hunt
    -- Set ke true untuk enable, false untuk disable
    EnabledEvents = {
        ["Shark Hunt"] = true,
        -- Tambahkan event lain di sini
        -- ["Event Name"] = true,
    },
    
    -- Priority event (hunt ini duluan jika ada multiple events)
    PriorityOrder = {
        "Shark Hunt",
        -- Tambahkan event lain sesuai priority
    },
    
    -- Wait time di setiap lokasi event (detik)
    LocationWaitTime = 2,
    
    -- Max hunt duration per event (detik, 0 = unlimited)
    MaxDuration = 0,
    
    -- Retry jika gagal hunt
    RetryOnFail = true,
    RetryAttempts = 3,
    RetryDelay = 5
}

-- === DETECTION SETTINGS ===
Config.Detection = {
    -- Method untuk detect events
    Methods = {
        ReplicatedStorage = true,
        Workspace = true,
        PlayerGUI = true,
        RemoteEvents = true
    },
    
    -- Paths untuk cari events di game
    SearchPaths = {
        ReplicatedStorage = {"Events", "GameEvents", "WorldEvents"},
        Workspace = {"ActiveEvents", "Events", "GameEvents", "WorldEvents"}
    }
}

-- === SMART HUNT SETTINGS ===
Config.SmartHunt = {
    -- Enable smart hunting (prioritize lokasi dengan most items)
    Enabled = false,
    
    -- Scan semua lokasi sebelum hunt
    PreScanLocations = false,
    
    -- Min items untuk consider lokasi worth hunting
    MinItemThreshold = 3
}

-- === SAFETY SETTINGS ===
Config.Safety = {
    -- Stop hunt jika health dibawah threshold
    StopOnLowHealth = true,
    MinHealthPercent = 30,
    
    -- Avoid area dengan enemies
    AvoidEnemies = false,
    EnemyDetectionRadius = 100,
    
    -- Return to safe position setelah hunt
    ReturnToSafeSpot = false,
    SafeSpotPosition = Vector3.new(0, 50, 0)
}

-- === GUI SETTINGS ===
Config.GUI = {
    -- Show GUI saat load
    ShowOnLoad = true,
    
    -- GUI Position (Scale)
    Position = {
        X = {Scale = 0.5, Offset = -150},
        Y = {Scale = 0.5, Offset = -200}
    },
    
    -- GUI Size
    Size = {
        Width = 300,
        Height = 400
    },
    
    -- Theme colors
    Theme = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(50, 150, 200),
        Success = Color3.fromRGB(50, 200, 50),
        Error = Color3.fromRGB(200, 50, 50),
        Text = Color3.fromRGB(255, 255, 255)
    },
    
    -- Transparency
    Transparency = 0
}

-- === CUSTOM EVENT DATA ===
-- Tambahkan event data custom di sini
Config.CustomEvents = {
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
        }
    },
    
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
            Vector3.new(x2, y2, z2),
            -- tambahkan koordinat lainnya
        }
    }
    ]]
}

-- === WEBHOOK SETTINGS (Optional) ===
Config.Webhook = {
    -- Enable webhook notifications
    Enabled = false,
    
    -- Discord webhook URL
    URL = "",
    
    -- Notify on events
    NotifyOnEventStart = true,
    NotifyOnEventComplete = true,
    NotifyOnError = true
}

-- === PERFORMANCE SETTINGS ===
Config.Performance = {
    -- Reduce lag dengan limit FPS
    LimitFPS = false,
    TargetFPS = 60,
    
    -- Disable rendering saat hunt
    DisableRendering = false,
    
    -- Reduce draw distance
    ReduceDrawDistance = false,
    DrawDistance = 100
}

--[[
    Helper function untuk save/load config
]]
function Config:Save()
    -- Implement save to file jika diperlukan
    -- Bisa pakai writefile jika executor support
    pcall(function()
        if writefile then
            local encoded = game:GetService("HttpService"):JSONEncode(Config)
            writefile("AutoHuntConfig.json", encoded)
        end
    end)
end

function Config:Load()
    -- Implement load from file jika diperlukan
    pcall(function()
        if readfile and isfile and isfile("AutoHuntConfig.json") then
            local decoded = game:GetService("HttpService"):JSONDecode(readfile("AutoHuntConfig.json"))
            
            -- Merge dengan current config
            for category, settings in pairs(decoded) do
                if Config[category] then
                    for key, value in pairs(settings) do
                        Config[category][key] = value
                    end
                end
            end
        end
    end)
end

-- Load config saat startup
Config:Load()

return Config

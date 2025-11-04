# 🦈 Auto Hunt Event Hub

Script hub untuk auto hunt event yang muncul di game, dengan fitur lengkap untuk detect dan hunt event seperti **Shark Hunt** secara otomatis!

## ✨ Fitur

- ✅ **Auto Detect Events** - Otomatis mendeteksi event yang muncul di game
- 🎯 **Auto Hunt** - Hunt event secara otomatis dengan teleport ke semua lokasi
- 💰 **Auto Collect Rewards** - Collect semua rewards/loot secara otomatis
- 🖥️ **User-Friendly GUI** - Interface yang mudah digunakan dengan drag support
- ⚙️ **Fully Configurable** - Customize semua settings sesuai kebutuhan
- 📊 **Progress Tracking** - Lihat progress hunt secara real-time
- 🔔 **Notifications** - Notifikasi untuk setiap event yang terdeteksi
- 🎨 **Modern UI** - Design yang clean dan modern

## 📦 File Structure

```
/workspace/
├── AutoHuntHub.lua      # Main script dengan GUI dan core functionality
├── EventDetector.lua    # Module untuk detect events
├── EventHandler.lua     # Module untuk handle hunting logic
├── Config.lua           # Configuration file
└── README.md           # Documentation
```

## 🚀 Cara Pakai

### Method 1: Execute Main Script
```lua
loadstring(game:HttpGet("path/to/AutoHuntHub.lua"))()
```

### Method 2: Manual Load
1. Copy semua file ke executor kamu
2. Execute `AutoHuntHub.lua`
3. GUI akan muncul otomatis

### Menggunakan GUI

1. **Toggle Auto Hunt** - Enable/disable auto hunt
2. **Hunt Shark Event** - Manual trigger untuk hunt Shark Hunt event
3. **Auto Collect Rewards** - Toggle auto collection
4. **Notifications** - Toggle notifications

## ⚙️ Configuration

Edit `Config.lua` untuk customize behavior:

### General Settings
```lua
Config.General = {
    AutoStartEnabled = false,  -- Auto start saat load
    ScanInterval = 5,          -- Scan interval (detik)
    ShowNotifications = true,  -- Show notifications
    DebugMode = false         -- Debug mode
}
```

### Teleport Settings
```lua
Config.Teleport = {
    Method = "instant",        -- "instant", "tween", or "walk"
    TweenSpeed = 200,         -- Speed untuk tween
    WaitAfterTeleport = 2,    -- Wait time setelah teleport
    AntiAFK = true            -- Anti-AFK
}
```

### Collection Settings
```lua
Config.Collection = {
    Enabled = true,           -- Auto collect
    Radius = 50,              -- Collection radius
    CollectInterval = 1       -- Interval antara collection
}
```

## 📝 Menambahkan Event Baru

### Method 1: Edit Config.lua

Tambahkan event data di `Config.CustomEvents`:

```lua
Config.CustomEvents = {
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
}
```

Enable event di `Config.Events.EnabledEvents`:

```lua
Config.Events.EnabledEvents = {
    ["Shark Hunt"] = true,
    ["Event Name"] = true,  -- Event baru
}
```

### Method 2: Edit EventDetector.lua

Tambahkan template di `EventDetector.EventTemplates`:

```lua
EventDetector.EventTemplates = {
    ["Event Name"] = {
        Name = "Event Name",
        Coordinates = {
            Vector3.new(x, y, z),
            -- koordinat lainnya
        },
        DetectionMethod = "Workspace"
    }
}
```

## 🎯 Cara Kerja

### 1. Event Detection
Script menggunakan multiple methods untuk detect events:
- **ReplicatedStorage** - Scan untuk ModuleScripts yang berisi event data
- **Workspace** - Scan untuk active event models/folders
- **PlayerGUI** - Detect event notifications di GUI
- **RemoteEvents** - Listen untuk remote events yang trigger events

### 2. Auto Hunt Process
Ketika event terdeteksi:
1. Parse event data (name, coordinates, dll)
2. Check jika event enabled di config
3. Teleport ke setiap koordinat
4. Collect rewards di setiap lokasi
5. Repeat untuk semua koordinat
6. Notifikasi saat selesai

### 3. Collection System
Auto collect menggunakan:
- `firetouchinterest()` - Trigger touch events
- Proximity detection - Scan items dalam radius
- Keyword matching - Identify collectible items

## 🛠️ Advanced Features

### Smart Hunting
Enable di `Config.SmartHunt` untuk prioritize lokasi dengan most items:

```lua
Config.SmartHunt = {
    Enabled = true,
    PreScanLocations = true,
    MinItemThreshold = 3
}
```

### Safety Features
```lua
Config.Safety = {
    StopOnLowHealth = true,      -- Stop jika health rendah
    MinHealthPercent = 30,       -- Min health %
    AvoidEnemies = false,        -- Avoid enemies
    ReturnToSafeSpot = false     -- Return ke safe spot
}
```

### Performance Optimization
```lua
Config.Performance = {
    LimitFPS = false,            -- Limit FPS
    DisableRendering = false,    -- Disable render
    ReduceDrawDistance = false   -- Reduce draw distance
}
```

## 📋 Example: Shark Hunt Event

Data dari remote spy:
```lua
{
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
```

Script akan:
1. Detect event "Shark Hunt"
2. Teleport ke koordinat pertama (1.64999, -1.3500, 2095.72)
3. Collect items/sharks
4. Teleport ke koordinat kedua
5. Repeat untuk semua 4 koordinat
6. Selesai!

## 🔧 Troubleshooting

### Event tidak terdeteksi?
- Pastikan event path di `Config.Detection.SearchPaths` sudah benar
- Enable `Config.General.DebugMode` untuk lihat debug info
- Check console untuk error messages

### Teleport tidak bekerja?
- Game mungkin ada anti-cheat
- Coba ganti `Config.Teleport.Method` ke "walk" atau "tween"
- Check jika koordinat valid

### Collection tidak bekerja?
- Executor mungkin tidak support `firetouchinterest()`
- Tambahkan keywords di `Config.Collection.ItemKeywords`
- Increase `Config.Collection.Radius`

## 📝 Notes

- Script ini dibuat untuk educational purposes
- Tested di berbagai executors (Synapse, Script-Ware, dll)
- Sesuaikan config sesuai dengan game yang dimain
- Gunakan dengan bijak!

## 🎓 Tutorial

### Cara dapat koordinat event dari Remote Spy:

1. Buka Remote Spy di executor
2. Trigger event di game
3. Cari RemoteEvent/ModuleScript yang berisi event data
4. Copy koordinat (Vector3)
5. Paste ke `Config.CustomEvents`

### Cara test script:

1. Load script
2. Click "Hunt Shark Event" untuk test manual
3. Jika berhasil, enable "Auto Hunt: ON"
4. Script akan auto hunt event berikutnya

## 💡 Tips

- Set `ScanInterval` lebih tinggi (10-15 detik) untuk reduce lag
- Use "tween" teleport method untuk lebih smooth & less detectable
- Enable `AntiAFK` jika mau AFK saat hunting
- Save config dengan `Config:Save()` untuk persist settings

## 🌟 Credits

Created with ❤️ untuk komunitas scripting Indonesia!

---

**Happy Hunting! 🦈**

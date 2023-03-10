--- Redline Rewrite
--
--[[
             :**:             
           :+*%%*+:           
         :+=.+--+.=+:         
       :+=. :#  #: .=+:       
     :+=.   *-  -*   .=+:     
   :+=     :#    #:     =+:   
  -@*:::.  *:    :*  .:::*@-  
   :*#=:-=+%--::--%+=-:=#*:   
     :+=.  #-:--:-#  .=+:     
       :+=.-+    +-.=+:       
         :++%:  :%++:         
           :*#..#*:           
             :++:             
]]


--- Check for an already open Redline instance
if ( shared.REDLINE ) then
    -- If there is one, notify the main instance that it's loaded and return
    --[[shared.REDLINE.Notify({
        Title = 'Already running!';
        Message = 'Redline is already running. Destroy the current active instance by pressing [END].';
        Duration = 5;
        Type = 'Warning';
    })
    return]]
else
    shared.REDLINE = {}
end


--- Redline Globals 
local RLGlobals = {} -- Variables that will be used across nearly every file - way more preferable to use a table vs a bunch of locals  
RLGlobals.FIRST = false -- If this is the first time Redline is being ran on this exploit
RLGlobals.VERSION = 'v1.0.0' -- Current redline version
RLGlobals.ASSETS = 'REDLINERW/Assets/' -- Path to assets folder 
RLGlobals.ActiveColor = Color3.new(1, 0, 0) -- Global RGB / "active" color
RLGlobals.Resolution = nil -- Current window resolution 
RLGlobals.Identifier = '' 
do 
    local id = ''
    for i = 1, 5 do 
        id = id .. utf8.char( math.random(50, 2000) )
    end
    RLGlobals.Identifier = id
end


-- Compatibility checks 
local isSynV3 = setconnectionenabled and isluaconnection and true or false

local isLuau = pcall(function() 
    for a, b in {} do end
end)

local pairs, ipairs = pairs, ipairs 

if ( isLuau ) then
    -- speed boost 
    pairs = function(t) 
        return t
    end
    ipairs = function(t)
        return t
    end
end

-- Function aliases
local isexecclosure = is_synapse_function or isexecutorclosure or isourclosure or checkclosure or isfluxusfunction
local iswindowfocused = isrbxactive or iswindowactive or iswindowfocused
local gethui = gethui or get_hidden_gui or function(screenGui) 
    if ( typeof(syn) == 'table' and typeof(syn.protect_gui) == 'function' ) then
        syn.protect_gui(screenGui) 
    end
    screenGui.Parent = game.CoreGui 
end 
local getcustomasset = getcustomasset or getsynasset or getexecutorasset
local tpqueue = (syn or fluxus or getfenv()).queue_on_teleport or queueonteleport
local request = ( typeof(syn) == 'table' and syn.request ) or ( typeof(fluxus) == 'table' and fluxus.request ) or ( request or http_request )

-- Filesystem
if ( not isfolder('REDLINERW') ) then
    makefolder('REDLINERW')
    
    REDLINE.FIRST = true 
end

-- kinda bad practice, but it's simple and expansible 
for _, folder in ipairs( {'Profiles', 'Themes', 'Plugins', 'Assets', 'Assets/Sounds', 'Assets/Images'} ) do  
    local path = 'REDLINERW/' .. folder
    
    if ( not isfolder(path) ) then
        makefolder(path) 
    end
end

-- assets
do 
    local assets = {
        --- Images 
        -- Emblem
        'Images/emblem_Prism.png';
        'Images/emblem_Text.png';
        
        --- Sounds
        -- Gui controls
        'Sounds/guiCtrl_Menu.mp3'; -- Menu open / close sound for stuff like dropdowns, modmenus, and modules 
        'Sounds/guiCtrl_Toggle.mp3'; -- Click sound for stuff like dropdowns, modules, tabs, toggles, and more 
        
        -- Main gui sfx
        'Sounds/main_Open.mp3'; -- The "sliding" sound effect that plays when the main UI is opened 
        'Sounds/main_Shutdown.mp3'; -- The shutdown sound effect 
        'Sounds/main_Startup.mp3'; -- The startup sound effect 
        
        -- Notifications
        'Sounds/notif_Error.mp3';
        'Sounds/notif_Friend.mp3';
        'Sounds/notif_Generic.mp3';
        'Sounds/notif_Success.mp3';
        'Sounds/notif_Warning.mp3';
    }
    
    local url = 'https://raw.githubusercontent.com/topitbopit/Redline/main/Assets/'
    
    --[[
    local hashes = request({
        Url = url .. '/hashes.txt',
        Method = 'GET'
    })    
    if ( hashes.Success ) then
        
    else
        
    end
    
    
    for _, asset in ipairs(assets) do 
        local fullPath = 'REDLINERW/Assets/' .. asset
        if ( not isfile(fullPath) ) then
            local req = request({
                Url = url,
                Method = 'GET'
            })
            if ( req.Success ) then 
                writefile(fullPath, req.Body)
            else
                warn('Couldn\'t download ' .. asset .. '!')
            end
        end
    end]]
end

-- Game load check
if ( not game:IsLoaded() ) then 
    game.Loaded:Wait() 
end

-- Service variables
local ctxService    = game:GetService('ContextActionService')
local debrisService = game:GetService('Debris')
local guiService    = game:GetService('GuiService')
local httpService   = game:GetService('HttpService')
local inputManager  = game:GetService('VirtualInputManager')
local inputService  = game:GetService('UserInputService')
local playerService = game:GetService('Players')
local runService    = game:GetService('RunService')
local tweenService  = game:GetService('TweenService')

--- Config
local ActiveConfig = {
    -- Config stuff
    ['ConfigVer'] = 1; -- Internal version number, don't change
    -- Window binds 
    ['UiBinds'] = {
        ['Toggle'] = 'RightShift'; -- Keybind for UI toggling
        ['Destroy'] = 'End'; -- Keybind for exiting redline entirely 
    };
    
    -- Misc UI settings 
    ['Interface'] = {
        ['FeedbackSounds'] = true; -- if certain sounds like clicks and wooshes are played on interaction
        ['NotifSounds'] = true; -- if notification sounds get played
        ['MenuTitleStyle'] = 'Normal'; -- the "style" of the menu titles (Normal / Bold)
        ['RGBSpeed'] = 1; -- how fast RGB cycling is done 
        ['TabbarStyle'] = 'Standard'; -- the width of the tab bar (Standard / Long)
    };
    
    ['Modules'] = {}; -- settings for modules 
    ['Widgets'] = {}; -- settings for widgets 
} 

if ( isfile('REDLINERW/config.json') ) then
    local contentsStr = readfile('REDLINERW/config.json')
    local contentsJson = httpService:JSONDecode(contentsStr)
    
    local missingSettings = false
        
    for k, v in pairs( ActiveConfig ) do 
        if ( contentsJson[k] ~= nil ) then
            ActiveConfig[k] = contentsJson[k] 
        else
            missingSettings = true  
        end
    end
    
    if ( missingSettings ) then
        writefile('REDLINERW/config.json', httpService:JSONEncode( ActiveConfig ))
    end
else
    writefile('REDLINERW/config.json', httpService:JSONEncode( ActiveConfig ))
end


--- Imports
local Tween = import('src/Imports/tween.lua')
local Logs = import('src/Imports/logs.lua')
local ui = import('src/Imports/ui.lua')

if ( not ui ) then
    return
end

--- Character system 
local charSystem = {} -- connections

-- client vars
local localPlayer = playerService.LocalPlayer
local localRayParams = RaycastParams.new()
localRayParams.FilterType = Enum.RaycastFilterType.Blacklist

local localRoot, localHumanoid, localChar do 
    localChar = localPlayer.Character
    
    if ( localChar ) then 
        localRoot = localChar:FindFirstChild('HumanoidRootPart')
        localHumanoid = localChar:FindFirstChild('Humanoid')
        
        localRayParams.FilterDescendantsInstances = { localChar }
    end
    
    charSystem.CharUpdate = localPlayer.CharacterAdded:Connect(function(newChar) 
        localRoot = newChar:WaitForChild('HumanoidRootPart')
        localHumanoid = newChar:WaitForChild('Humanoid')
        localRayParams.FilterDescendantsInstances = { newChar }
        
        localChar = newChar 
    end)
end
local localCamera do 
    localCamera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
    
    charSystem.CameraUpdate = workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function() 
        localCamera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
    end)
end
local localTeam do 
    localTeam = localPlayer.Team
    
    charSystem.TeamUpdate = localPlayer:GetPropertyChangedSignal('Team'):Connect(function() 
        localTeam = localPlayer.Team
    end)
end

-- other players
local playerManagers = {} 
local playerNames = {} 

do 
    local function addManager(player: Player)
        local manager = {}
        
        -- get existing stuff
        local char = player.Character
        if ( char ) then
            manager.Char = char
            manager.Head = char:FindFirstChild('Head')
            manager.Humanoid = char:FindFirstChild('Humanoid')
            manager.Root = char:FindFirstChild('HumanoidRootPart')
        end
        manager.Team = player.Team 
        manager.Player = player
        
        -- get new stuff
        manager.CharUpdCon = player.CharacterAdded:Connect(function( newChar ) 
            manager.Char = newChar 
            manager.Head = newChar:WaitForChild('Head')
            manager.Humanoid = newChar:WaitForChild('Humanoid')
            manager.Root = newChar:WaitForChild('HumanoidRootPart')
        end)
        
        manager.TeamUpdCon = player:GetPropertyChangedSignal('Team'):Connect(function() 
            manager.Team = player.Team 
        end)

        playerManagers[ player.Name ] = manager
        playerNames[ #playerNames + 1 ] = player.Name 
        
        return manager
    end

    local function delManager(player: Player)
        local name = player.Name 
        local manager = playerManagers[ name ]
        
        if ( not manager ) then
            warn('[REDLINE:CharSystem] Couldn\'t find player manager, re-checking (1)')

            for _, m in pairs( playerManagers )  do   
                if ( m.Player == player ) then
                    manager = m
                    break
                end 
            end
            
            if ( not manager ) then
                return warn('[REDLINE:CharSystem] Couldn\'t find player manager! (2)')
            end
        end

        manager.Char = nil
        manager.Hum = nil
        manager.Head = nil
        manager.Root = nil
        
        manager.CharUpdCon:Disconnect()
        manager.TeamUpdCon:Disconnect()

        playerManagers[ name ] = nil
        
        local i = table.find(playerNames, player.Name)
        if ( i ) then
            table.remove(playerNames, i) 
        
        end 
    end

    charSystem.playerLeave = playerService.PlayerRemoving:Connect(delManager)
    charSystem.playerJoin = playerService.PlayerAdded:Connect(addManager)
    
    for _, p in ipairs( playerService:GetPlayers() ) do 
        if ( p ~= localPlayer ) then
            addManager(p)
        end
    end 
end


--- UI
do
    ui:Connect('OnDestroy', function() 
        for i, v in pairs( charSystem ) do 
            v:Disconnect()
        end
        
        Tween.CleanImport()
        Logs.CleanImport()
    end)
end

do
    -- Modules
    local Modules = ui:AddTab('Modules')
        :Select( true )
    
    
    do          
        --local Combat = Modules:AddModuleMenu('Combat')
        
        --[[
        do 
            local Aimbot = Combat:AddModule('Aimbot')
            local Autoclick = Combat:AddModule('Autoclick')
            local Clickbot = Combat:AddModule('Clickbot')
            local Hitbox = Combat:AddModule('Hitboxes')
            local Triggerbot = Combat:AddModule('Triggerbot')
        end]]
        
        --[[local Player = Modules:AddModuleMenu('Player')
        do 
            Player:AddModule('Anti AFK')
            Player:AddModule('Anti crash')
            Player:AddModule('Anti fling')
            Player:AddModule('Anti warp')
            Player:AddModule('Fake lag')
            Player:AddModule('Flashback')
            Player:AddModule('Safe min')
        end]]
        
        local Movement = Modules:AddModuleMenu('Movement')
        do 
            local Modules = {}
            Modules.AirJump = import('src/Modules/Movement/AirJump.lua')
            Modules.ClickTP = import('src/Modules/Movement/ClickTP.lua')
            Modules.Speed = import('src/Modules/Movement/Speed.lua')
            --[[
            Movement:AddModule('Blink')
            
            Movement:AddModule('Dash')
            Movement:AddModule('Flight')
            Movement:AddModule('Glide')
            Movement:AddModule('High jump')
            Movement:AddModule('Jetpack')
            Movement:AddModule('Long jump')
            Movement:AddModule('Noclip')
            Movement:AddModule('Nofall')
            Movement:AddModule('Noslow')
            Movement:AddModule('Parkour')
            Movement:AddModule('Phasewalk')
            Movement:AddModule('Speed')
            Movement:AddModule('Step')]]
        end
        
        --[[task.spawn(function()
            local bus = Modules:AddModuleMenu('Bus'):AddModule('bus'):SetTooltip('bus')
            do 
                local function addEsp(model) 
                    local anchor = Instance.new('Part')
                    anchor.Anchored = true
                    anchor.CFrame = model:GetPivot()
                    anchor.Transparency = 1
                    anchor.Parent = model 
                    
                    local gui = Instance.new('BillboardGui')
                    gui.AlwaysOnTop = true
                    gui.Size = UDim2.fromOffset(5, 5)
                    gui.Adornee = anchor 
                    gui.Parent = anchor 
                    
                    local frame = Instance.new('Frame')
                    frame.BackgroundColor3 = Color3.new(1, 0, 1)
                    frame.Size = UDim2.fromScale(1, 1)
                    frame.Parent = gui
                    
                    if ( model.TreeClass.Value == 'SpookyNeon' ) then
                        frame.BackgroundColor3 = Color3.new(0, 1, 1)
                    end
                end
                
                local function getTrees() 
                    local t = {}
                    
                    for _, region in ipairs( workspace:GetChildren() ) do 
                        if ( region.Name == 'TreeRegion' ) then
                            for _, tree in ipairs( region:GetChildren() ) do 
                                local class = tree:FindFirstChild('TreeClass')
                                if ( class and class.Value:match('Spooky') ) then
                                    t[#t + 1] = tree
                                end
                            end 
                        end
                    end
                    
                    return t 
                end
                
                local check = bus:AddButton('check')
                check:SetTooltip('checks if there\'s spook wood in your server')
                check:Connect('OnClick', function() 
                    local trees = getTrees()
                    
                    if ( #trees > 0 ) then
                        ui:Notify({
                            Title = 'yea',
                            Message = 'found spook wood 🤑',
                            Type = 'Success',
                            Duration = 3
                        })
                    else
                        ui:Notify({
                            Title = 'nop',
                            Message = 'no spook wood :(',
                            Type = 'Warning',
                            Duration = 3
                        })
                    end
                end)
                
                local esp = bus:AddButton('highlight')
                esp:SetTooltip('highlights all spook wood')
                esp:Connect('OnClick', function() 
                    local trees = getTrees()
                    
                    if ( #trees > 0 ) then
                        for _, tree in ipairs( trees ) do 
                            addEsp(tree)
                        end
                    end
                end)
            end
        end)]]
        
        local Render = Modules:AddModuleMenu('Render')
        do 
            local Modules = {} 
            Modules.Crosshair = import('src/Modules/Render/Crosshair.lua')
            
            --[[Render:AddModule('ESP')
            Render:AddModule('Freecam')
            Render:AddModule('Fullbright')
            Render:AddModule('Radar')
            Render:AddModule('Whitescreen')
            Render:AddModule('Zoom')]]
        end
        
        --[[local Interface = Modules:AddModuleMenu('Interface')
        do 
            Interface:AddModule('Modlist')
            -- Interface:AddModule('Jeff')
            -- Interface:AddModule('Join notifier')
            -- Interface:AddModule('Watermark')
        end]]
        
        --[[local Server = Modules:AddModuleMenu('Server')
        do 
            Server:AddModule('Auto reconnect')
            Server:AddModule('Auto serverhop')
        end]]
        
        --[[local Misc = Modules:AddModuleMenu('Misc')
        do 
            Misc:AddModule('Animspeed')
            Misc:AddModule('Nodelay')
            Misc:AddModule('Notrip')
            Misc:AddModule('Velocity')
            Misc:AddModule('Waypoints')
        end]]
    end
        
        
    -- Widgets
    -- local Widgets = ui:AddTab('Widgets') -- jigsaw icon?

    -- Profiles
    -- local Profiles = ui:AddTab('Profiles')

    -- Themes
    -- local Themes = ui:AddTab('Themes') -- paint brush / bucket icon 

    -- Friends
    -- local Friends = ui:AddTab('Friends') -- person icon 

    -- Settings
    local Settings = ui:AddTab('Settings') -- cog icon / wrench icon  
end

if ( RLGlobals.FIRST ) then 
    ui:Notify({
        Title = 'Redline ' .. RLGlobals.VERSION;
        Message = string.format( 'It looks like it\'s your first time using Redline! Press %s to begin.', ActiveConfig.UiBinds.Toggle ),
        Duration = 3,
        Type = 'Success'
    })
else 
    ui:Notify({
        Title = 'Redline ' .. RLGlobals.VERSION;
        Message = string.format( 'Finished loading. Press %s to begin', ActiveConfig.UiBinds.Toggle ),
        Duration = 3,
        Type = 'Generic'
    })
end
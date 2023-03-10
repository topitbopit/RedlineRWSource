-- Packed using RedlinePack v1.1.0
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
local Tween = (function() -- src/Imports/tween.lua
    --[[ 
    Import: Tween
    Description: Provides several functions for easily tweening instances, ranging 
    from customizable to extremely simple
    Version: v1.0.0
    ]]
    
    
    
    -- yea this whole thing is kinda bloated but atleast it looks nice + works 
    
    local TweenImport = {}
    do
        local EasingStyle = Enum.EasingStyle
        local EasingDirection = Enum.EasingDirection
        
        local styleLinear = EasingStyle.Linear
        local styleExp = EasingStyle.Exponential        
        
        --- DURATED (duration-able? duratable? durationized?)
        -- Lets you pass a duration, automatically handles easing 
        
        -- Linearly tween `instance` using `properties`, with a duration of `duration`
        function TweenImport.Linear(instance: Instance, properties: table, duration: number) 
            local thisTween = tweenService:Create(
                instance,
                TweenInfo.new(duration, styleLinear),
                properties
            )
            
            thisTween:Play()
            
            return thisTween
        end
        -- Exponentially tween `instance` using `properties`, with a duration of `duration`
        function TweenImport.Exp(instance: Instance, properties: table, duration: number) 
            local thisTween = tweenService:Create(
                instance,
                TweenInfo.new(duration, styleExp),
                properties
            )
            
            thisTween:Play()
            
            return thisTween
        end
        -- Quadratically tween `instance` using `properties`, with a duration of `duration`
        function TweenImport.Quad(instance: Instance, properties: table, duration: number) 
            local thisTween = tweenService:Create(
                instance,
                TweenInfo.new(duration),
                properties
            )
            
            thisTween:Play()
            
            return thisTween
        end
        
        --- SIMPLE
        -- Automatically handles easing and duration
        
        -- Exponentially tween `instance` using `properties`, with a duration of 0.3
        function TweenImport.Quick(instance: Instance, properties: table) 
            local thisTween = tweenService:Create(
                instance,
                TweenInfo.new(0.3, styleExp),
                properties
            )
            
            thisTween:Play()
            
            return thisTween
        end
        
        --- CUSTOM
        -- Lets you pass a duration, easing style, and easing direction 
        
        -- Tween `instance` using `properties`, with a duration of `duration` and easingstyle of `style`
        function TweenImport.Custom(instance: Instance, properties: table, duration: number, style: string) 
            local thisTween = tweenService:Create(
                instance,
                TweenInfo.new(duration, EasingStyle[style]),
                properties
            )
            
            thisTween:Play()
            
            return thisTween
        end
        
        -- Tween `instance` using `properties`, with a duration of `duration`, easingstyle of `style`, and easingdirection of `direction`
        function TweenImport.FullCustom(instance: Instance, properties: table, duration: number, style: string, direction: string) 
            local thisTween = tweenService:Create(
                instance,
                TweenInfo.new(duration, EasingStyle[style], EasingDirection[direction]),
                properties
            )
            
            thisTween:Play()
            
            return thisTween
        end
        
        function TweenImport.CleanImport() 
            TweenImport = nil
        end
    end
    
    return TweenImport
end)()
local Logs = (function() -- src/Imports/logs.lua
    --[[ 
    Import: Logs
    Description: Provides an interface to log errors, warnings, and information
    Version: v1.0.0
    ]]
    
    local logs = {}
    
    --[[local LogObject = {} do 
        LogObject.Type = 'Info'
        LogObject.Time = tick()
        LogObject.Message = ''
        
        function LogObject.new() 
            
        end
    end]]
    
    local LogsImport = {}
    do 
        LogsImport.__index = LogsImport
        
        -- Logging functions
        function LogsImport:Info(LogMessage: string) 
            table.insert(self.Logs, {
                Type = 'Info',
                Time = tick(),
                Log = LogMessage
            })
        end
        
        function LogsImport:Success(LogSuccess: success) 
            table.insert(self.Logs, {
                Type = 'Success',
                Time = tick(),
                Log = LogSuccess
            })
        end
        
        function LogsImport:Warning(LogWarning: string) 
            table.insert(self.Logs, {
                Type = 'Warning',
                Time = tick(),
                Log = LogWarning
            })
        end
        
        function LogsImport:Error(LogError: string) 
            table.insert(self.Logs, {
                Type = 'Error',
                Time = tick(),
                Log = LogError
            })
        end
        
        
        -- Log interaction functions
        function LogsImport:GetLogs() 
            return self.Logs 
        end
        
        function LogsImport:GetLog(index: number) 
            local log = self.Logs[index]
            return ('(%s) [%s] %s | %s'):format(self.Name, log.Time, log.Type, log.Log)
        end
        
        function LogsImport:FormatLog(log: table) 
            return ('(%s) [%s] %s | %s'):format(self.Name, log.Time, log.Type, log.Log)
        end
        
        function LogsImport:ClearLogs() 
            table.clear(self.Logs)
        end
        
        -- Destructor function
        function LogsImport:Destroy()
            table.remove(logs, table.find(logs, self))
            
            self.Logs = nil
            setmetatable(self, nil)    
        end
        
        -- Constructor function
        function LogsImport.new(LogName: string) 
            local self = setmetatable({}, LogsImport)
            self.Name = LogName
            self.Logs = {}
            table.insert(logs, self)
            
            return self
        end
        
        -- CleanImport
        function LogsImport.CleanImport()
            for _, log in ipairs(logs) do 
                log:Destroy()
            end 
            LogsImport = nil
        end
    end
    
    
    return LogsImport
end)()
local ui = (function() -- src/Imports/ui.lua
    --[[ 
    Import: Interface
    Description: Handles interface construction, handling, etc.
    Version: v1.0.0
    ]]
    
    
    --- Util functions
    local function round( num, place ) 
        return math.floor( ( num + ( place * 0.5 ) ) / place ) * place 
    end
    
    local ThemeLogs = Logs.new('ThemeHandler')
    
    local InterfaceTheme = {} do 
        ThemeLogs:Info('Loading interface theme')
        
        -- Setup the default theme to grab undefined values from 
        local defaultTheme = {
            --- File specifications
            ["ColorFormat"] = "RGB"; -- The format every entry in Theme takes
            ["ThemeVersion"] = 1; -- Reserved for future compatibility
            --- Font settings 
            ["TextSize"] = 14; -- Base textsize 
            ["Font"] = 'Gotham'; -- The main font used
            --- Extra theme settings
            ["SpecialOutlines"] = true; -- Make some outlines use gradients instead of the Outline color
            
            ["Theme"] = {
                ["Window"]       = {20, 20, 25}; -- Main window background color 
                ["Outline"]      = {64, 64, 69}; -- Main outline color 
                
                ["Shade1"]       = {30, 30, 35}; -- Shade1, used for menu / setting "headers" + tabs
                ["Shade2"]       = {25, 25, 30}; -- Shade2, used for modules / section breaks
                ["Shade3"]       = {20, 20, 25}; -- Shade3, typically used for module settings
                ["Shade4"]       = {15, 15, 20}; -- Shade4, used for dropdown settings in module settings
                
                ["Text_Shade1"]  = {240, 240, 240}; -- Bright text color - headers + tabs 
                ["Text_Shade2"]  = {220, 220, 220}; -- Normal text color - module
                ["Text_Shade3"]  = {200, 200, 200}; -- Dimmed text color - module settings
                ["Text_Stroke"]  = {0, 0, 5}; -- Text outline color 
                
                ["Primary"]      = {255, 0, 123}; -- Primary color, used for some outlines
                ["Secondary"]    = {229, 23, 8}; -- Secondary color, used for some outlines
                
                ["Enabled"]      = {255, 0, 123}; -- Typically the same as Primary, used for certain objects like the module highlight and hotkey label
            };
        }
        
        
        --- PRE PROCESSING
        local contentsStr -- Theme contents as a string 
        local contentsJson -- Theme contents as a table 
        local isBetaJsonc = false -- If the theme is in the beta format
        local updateTheme = false -- Flag to see if updating the file is necessary
        
        -- Check if theres an existing theme file
        if ( isfile('REDLINERW/theme.json') ) then
            ThemeLogs:Info('Found theme.json')
            
            -- Set contentsStr 
            contentsStr = readfile('REDLINERW/theme.json')
            
            -- Remove comments in case it's a beta theme
            if ( contentsStr:match('//') ) then
                contentsStr = contentsStr:gsub('//[^\n]+', '')
            end
            
            local success 
            success, contentsJson = pcall(httpService.JSONDecode, httpService, contentsStr)  -- Try to convert contents to JSON
                
            -- Check to see if JSON decoding worked
            if ( success ) then 
                ThemeLogs:Success('JSON decoding theme.json succeeded')
                
                -- If so, check if its a beta theme
                if ( typeof(contentsJson.theme) == 'table' and contentsJson.theme.Generic_Outline ) then
                    ThemeLogs:Info('Detected theme as beta')
                    
                    local oldTheme = contentsJson.theme -- Get the beta theme 
                    local newVersion = { -- Convert it to a newer version 
                        ColorFormat = 'RGB';
                        ThemeVersion = 1;
                        Font = oldTheme.Font;
                        TextSize = 14;
                        
                        Theme = {
                            Window = oldTheme.Generic_Window;
                            
                            Shade1 = oldTheme.Generic_Menu;
                            Shade2 = oldTheme.Generic_Module;
                            Shade3 = oldTheme.Generic_Setting;
                            Shade4 = oldTheme.Generic_Dropdown;
                            
                            Text_Shade2 = oldTheme.Text_Shade2;
                            Text_Stroke = oldTheme.Text_Outline;
                            
                            Primary = oldTheme.Generic_Outline.Color or oldTheme.Generic_Enabled.Color;
                            Secondary = oldTheme.Generic_Outline.Color2 or oldTheme.Generic_Enabled.Color;
                            
                            Enabled = oldTheme.Generic_Enabled.Color;
                        };
                    }
                    
                    writefile('REDLINERW/theme.json', httpService:JSONEncode(newVersion)) -- Write it 
                    ThemeLogs:Success('Wrote updated theme to theme.json')
                    
                    contentsJson = newVersion -- Store the contents
                end
                
            else -- If it didn't, mark the theme to be updated and resort to the default theme
                ThemeLogs:Error('decoding theme.json failed!')
                
                updateTheme = true 
                contentsJson = defaultTheme
            end
        else
            -- If there isn't a theme file, create it
            ThemeLogs:Warning('Didn\'t find theme.json')
            
            writefile('REDLINERW/theme.json', httpService:JSONEncode(defaultTheme))
            contentsJson = defaultTheme -- Then set contentsJson directly
            
            ThemeLogs:Success('Wrote default theme to theme.json')
        end
        
        --- FILL MISSING ENTRIES 
        -- First make sure it isn't already marked
        if ( not updateTheme ) then 
            
            for name, val in pairs(defaultTheme) do -- Go through main entries (font, textsize, etc.)
                if ( contentsJson[name] == nil ) then -- Check if this entry is missing
                    updateTheme = true -- Flag the theme as outdated
                    contentsJson[name] = val -- Set to the proper value 
                end         
            end
            
            local thisTheme = contentsJson.Theme -- Localize the current theme being loaded
            for key, entry in pairs(defaultTheme.Theme) do -- Go through theme entries (outline color, text color, etc.)
                if ( thisTheme[key] == nil ) then -- Check for missing keys 
                    updateTheme = true
                    thisTheme[key] = entry
                end
            end
        end 
        
        --- UPDATE CHECK
        if ( updateTheme ) then
            ThemeLogs:Success('Wrote fixed theme to theme.json')
            writefile('REDLINERW/theme.json', httpService:JSONEncode(contentsJson))
        end
        
        --- FINALIZE
        -- Convert color entries into Color3s
        local colorFunc = contentsJson.ColorFormat == 'HSV' and Color3.fromHSV or Color3.fromRGB 
        for key, color in pairs( contentsJson.Theme ) do
            contentsJson[key] = colorFunc(color[1], color[2], color[3])
        end
        contentsJson.Theme = nil
        
        InterfaceTheme = contentsJson
        
        ThemeLogs:Success('Finished theme processing')
    end
    
    --- Preload custom assets
    local CustomAssets = {} 
    
    do 
        local assets = {
            --- Images 
            -- Emblem
            'Images/emblem_Prism.png';
            'Images/emblem_Text.png';
            
            --- Sounds
            -- Gui controls
            'Sounds/guiCtrl_Menu.mp3';
            'Sounds/guiCtrl_Toggle.mp3';
            
            -- Main gui sfx
            'Sounds/main_Open.mp3';
            'Sounds/main_Shutdown.mp3';
            'Sounds/main_Startup.mp3';
            
            -- Notifications
            'Sounds/notif_Error.mp3';
            'Sounds/notif_Friend.mp3';
            'Sounds/notif_Generic.mp3';
            'Sounds/notif_Success.mp3';
            'Sounds/notif_Warning.mp3';
        }
        
        for _, k in ipairs( assets ) do 
            CustomAssets[k] = getcustomasset( RLGlobals.ASSETS .. k )
        end
    end
    
    --- Important UI variables
    local SelectedTab = 'Modules' -- Modules, Widgets, Profiles, Themes, Friends, Settings
    
    RLGlobals.Resolution = guiService:GetScreenResolution() + guiService:GetGuiInset()
    
    local ui -- library 
    local instances = {} -- main ui instances 
    local windowTabs = {} -- contains tabs
    local moduleMenus = {} -- contains moduleMenus
    local rgbInstances = {}
    local hotkeys = {} -- hotkeys for the hotkey handler
    
    
    --- UiClasses 
    local UiClasses = {} do 
        --- RLBase
        -- The base class for all elements 
        local RLBase = (function() -- src/UiClasses/RLBase.lua
            --- RLBase
            -- The base class for all elements 
            local RLBase = {} do 
                --- Setup
                RLBase.__index = RLBase
                RLBase.class = 'RLBase'
                RLBase.rli = true -- rli = redline instance
                --- Interaction
                
                -- Connects the function `callback` to the event `eventName`.
                -- Pass callback as nil to disconnect the connection.
                function RLBase:Connect( eventName: string, callback )
                    if ( typeof(callback) == 'function' ) then
                        self.events[eventName] = callback 
                        
                    elseif ( callback == nil ) then
                        self.events[eventName] = nil 
                    end
                    
                    return self 
                end
                
                -- Fires the event `eventName` with args `...`
                -- **This is not meant for normal use, and is only used within the 
                -- interface library.**
                function RLBase:Fire( eventName: string, ... ) 
                    local callback = self.events[eventName]
                    
                    if ( callback ) then
                        task.spawn(callback, ...)
                    end
                    
                    return self 
                end
                
                -- Connects the function `callback` to the **internal** event `eventName`.
                -- Pass callback as nil to disconnect the connection.
                -- **This is not meant for normal use, and is only used within the 
                -- interface library.**
                function RLBase:ConnectInternal (eventName: string, callback )
                    if ( typeof(callback) == 'function' ) then
                        self.eventsInternal[eventName] = callback 
                        
                    elseif ( callback == nil ) then
                        self.eventsInternal[eventName] = nil 
                    end
                    
                    return self 
                end
                
                -- Fires the **internal** event `eventName` with args `...`
                -- **This is not meant for normal use, and is only used within the 
                -- interface library.**
                function RLBase:FireInternal( eventName: string, ... ) 
                    local callback = self.eventsInternal[eventName]
                    
                    if ( callback ) then
                        task.spawn(callback, ...)
                    end
                    
                    return self 
                end
                
                -- Gets this instance's parent
                function RLBase:GetParent()
                    return self.parent 
                end
                
                -- Returns an array containing this instance's children 
                function RLBase:GetChildren() 
                    return self.children
                end
                
                -- Returns the child with the matching name
                function RLBase:GetChild( ChildName: string ) 
                    for _, c in ipairs( self.children ) do 
                        if ( c.name == ChildName ) then
                            return c  
                        end
                    end
                end
                
                --- Constructor 
                function RLBase.new()
                    --- Setup 
                    local this = setmetatable({}, RLBase)
                    this.children = {}
                    this.events = {} 
                    this.eventsInternal = {} 
                    this.parent = nil
                    
                    --- Finalization
                    return this
                end
                
                --- Destructor
                function RLBase:Destroy() 
                    -- Unlink from parent 
                    if ( self.parent ) then 
                        local parentChildren = self.parent.children 
                        table.remove(parentChildren, table.find(parentChildren, self))
                        
                        self.parent = nil
                    end
                    
                    -- Destroy all children 
                    if ( self.children ) then 
                        for _, c in ipairs( self.children ) do 
                            c:Destroy() 
                        end
                        
                        self.children = nil 
                    end
                    
                    -- Destroy all UI instances
                    if ( self.objects ) then 
                        for _, o in pairs( self.objects ) do 
                            o:Destroy()
                        end
                        
                        self.objects = nil
                    end
                    
                    -- Destroy all connections
                    if ( self.connections ) then 
                        for _, c in pairs( self.connections ) do 
                            c:Disconnect()
                        end
                        
                        self.connections = nil
                    end
                    
                    -- Set everything to nil 
                    self.events = nil
                    self.eventsInternal = nil
                    
                    setmetatable(self, nil)
                end
            end
            
            return RLBase 
        end)()
        UiClasses.RLBase = RLBase
        
        --- RLTab : RLBase
        -- Class for window tabs
        local RLTab: RLBase = (function() -- src/UiClasses/RLTab.lua
            --- RLTab : RLBase
            -- Class for window tabs
            local RLTab: RLBase = {} do 
                --- Setup
                RLTab.__index = RLTab
                RLTab.class = 'RLTab'
                setmetatable(RLTab, RLBase)
                 
                --- Interaction
                function RLTab:IsSelected() 
                    return self.SelectState
                end
                
                function RLTab:Select( NoSound: boolean ) 
                    local objects = self.objects
                    local selfIndex = self.index
                    
                    for _, tab in ipairs( windowTabs ) do 
                        if ( tab.SelectState == true ) then 
                            tab:Deselect()
                        end
                        
                        local idxOffset = tab.index - selfIndex
                        Tween.FullCustom( tab.objects.Window, {
                            Position = UDim2.fromScale(idxOffset, 0)  
                        }, 0.3, 'Circular', 'InOut' )
                    end
                    
                    self.SelectState = true
                    Tween.Quick(objects.Selection, {
                        Size = UDim2.fromScale(1, 1)
                    })
                    
                    if ( NoSound ~= true ) then 
                        objects.ToggleSound:Play()
                    end 
                    
                    return self
                end
                
                function RLTab:Deselect() 
                    local objects = self.objects
                    
                    self.SelectState = false 
                    
                    Tween.Quick(objects.Selection, {
                        Size = UDim2.fromScale(0, 1)
                    })
                    return self
                end
                
                --- Element
                function RLTab:GetModuleMenu( MenuName: string ) 
                    for _, menu in ipairs( self.children ) do 
                        if ( menu.name == MenuName ) then
                            return menu 
                        end
                    end 
                end
                
                function RLTab:AddModuleMenu( MenuName: string ) 
                    local index = #self.children
                    local this = UiClasses.RLModuleMenu.new( self, MenuName, '', 100 + (index * 20) )
                    table.insert( moduleMenus, this )
                    
                    local rowMax = math.floor( (RLGlobals.Resolution.X - 200) / 250 )
                    local xPosition = ( (300 * (index % rowMax)) + 100 )
                    local yPosition = ( (200 * math.floor(index / rowMax)) + 200 )
                    
                    local main = this.objects.Main
                    main.Position = UDim2.fromOffset( xPosition, yPosition )
                    main.Parent = self.objects.Window
                    
                    return this
                end
                
                --- Constructor
                function RLTab.new( Parent: table, TabName: string ) 
                    --- Setup 
                    local this = RLBase.new()
                    setmetatable(this, RLTab)
                    this.HoverState = false
                    this.SelectState = false
                    this.index = #windowTabs
                    this.name = TabName 
                    this.parent = Parent
                    
                    --- Objects
                    local objects = {}
                    do
                        -- objects.Window
                        do 
                            local Window = Instance.new('TextLabel')
                            Window.BackgroundTransparency = 1
                            Window.Font = InterfaceTheme.Font
                            Window.Position = UDim2.fromScale(this.index, 0)
                            Window.Size = UDim2.fromScale(1, 1)
                            Window.Text = ''
                            Window.ZIndex = 1
                            
                            Window.Parent = instances.Main
                            objects.Window = Window
                        end
                        
                        -- objects.TabButton
                        do 
                            local TabButton = Instance.new('TextButton')
                            TabButton.AutoButtonColor = false 
                            TabButton.BackgroundColor3 = InterfaceTheme.Shade1
                            TabButton.BorderSizePixel = 0 
                            TabButton.ClipsDescendants = true
                            TabButton.Modal = true 
                            TabButton.Size = UDim2.new(0, 100, 1, 0)
                            TabButton.Text = ''
                            TabButton.TextTransparency = 1  
                            TabButton.ZIndex = 301
                            
                            
                            TabButton.Parent = instances.TabContainer
                            objects.TabButton = TabButton
                        end
                        
                        -- objects.Label
                        do
                            local Label = Instance.new('TextLabel')
                            Label.BackgroundTransparency = 1
                            Label.Font = InterfaceTheme.Font
                            Label.Size = UDim2.fromScale(1, 1)
                            Label.Text = TabName
                            Label.TextColor3 = InterfaceTheme.Text_Shade1
                            Label.TextSize = InterfaceTheme.TextSize
                            Label.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Label.TextStrokeTransparency = 0.5
                            Label.TextXAlignment = 'Center'
                            Label.TextYAlignment = 'Center'
                            Label.ZIndex = 301
                            
                            Label.Parent = objects.TabButton
                            objects.Label = Label
                        end
                        
                        -- objects.Selection
                        do 
                            local Selection = Instance.new('Frame')
                            Selection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            Selection.BackgroundTransparency = 0.95
                            Selection.BorderSizePixel = 0
                            Selection.ClipsDescendants = true
                            Selection.Size = UDim2.fromScale(0, 1)
                            Selection.ZIndex = 302
                            
                            local Side = Instance.new('Frame')
                            Side.BackgroundColor3 = InterfaceTheme.Primary
                            Side.BorderSizePixel = 0
                            Side.Size = UDim2.new(0, 2, 1, 0)
                            Side.ZIndex = 302
                            
                            Side.Parent = Selection
                            Selection.Parent = objects.TabButton
                            objects.Selection = Selection
                        end
                        
                        -- objects.Hover
                        do 
                            local Hover = Instance.new('Frame')
                            Hover.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            Hover.BackgroundTransparency = 1
                            Hover.BorderSizePixel = 0
                            Hover.Size = UDim2.fromScale(1, 1)
                            Hover.ZIndex = 301 
                            
                            Hover.Parent = objects.TabButton
                            objects.Hover = Hover
                        end
                        
                        -- objects.ToggleSound
                        do 
                            local ToggleSound = Instance.new('Sound')
                            ToggleSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            ToggleSound.SoundId = CustomAssets['Sounds/guiCtrl_Toggle.mp3']
                            
                            ToggleSound.Parent = objects.TabButton
                            objects.ToggleSound = ToggleSound 
                        end
                    end
                    
                    --- Events
                    do
                        objects.TabButton.MouseEnter:Connect(function() 
                            this.HoverState = true
                            
                            Tween.Quick(objects.Hover, {
                                BackgroundTransparency = 0.985
                            })
                        end)
                        
                        objects.TabButton.MouseLeave:Connect(function() 
                            this.HoverState = false 
                            
                            Tween.Quick(objects.Hover, {
                                BackgroundTransparency = 1
                            })
                        end)
                        
                        objects.TabButton.MouseButton1Click:Connect(function() 
                            if ( not this:IsSelected() ) then 
                                this:Select()
                            end
                        end)
                    end
                    
                    --- Finalize
                    this.objects = objects
                    table.insert(windowTabs, this)
                    return this 
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLTab
        end)()
        UiClasses.RLTab = RLTab 
        
        --- RLBaseMenu : RLBase
        -- Base class for certain menu elements, like ModuleMenus
        local RLBaseMenu: RLBase = (function() -- src/UiClasses/RLBaseMenu.lua
            --- RLBaseMenu : RLBase
            -- Base class for certain menu elements, like ModuleMenus
            local RLBaseMenu: RLBase = {} do 
                --- Setup
                RLBaseMenu.__index = RLBaseMenu
                RLBaseMenu.class = 'RLBaseMenu' 
                setmetatable(RLBaseMenu, RLBase)
                
                --- Interaction
                function RLBaseMenu:IsOpen() 
                    return self.MenuState 
                end
                
                --- Constructor
                function RLBaseMenu.new( Parent: table, MenuName: string, IconId: string, ZIndex: number )
                    ZIndex = ZIndex or 100
                    
                    --- Setup 
                    local this = RLBase.new()
                    setmetatable(this, RLBaseMenu)
                    table.insert(Parent.children, this)
                    this.DragState = false
                    this.MenuState = true 
                    this.MovedState = false
                    this.connections = {}
                    this.name = MenuName 
                    this.parent = Parent
                    this.zindex = ZIndex 
                    
                    --- Objects
                    local objects = {}
                    do
                        -- objects.Main
                        do 
                            local Main = Instance.new('Frame')
                            Main.AutomaticSize = 'Y'
                            Main.BackgroundColor3 = InterfaceTheme.Shade2
                            Main.BorderSizePixel = 0
                            Main.Size = UDim2.fromOffset(250, 30) --UDim2.new(0.15, 0, 0, 30)
                            Main.ZIndex = ZIndex
                            --[[
                            local Constraint = Instance.new('UISizeConstraint')
                            Constraint.MaxSize = Vector2.new(250, 9e5)
                            Constraint.MinSize = Vector2.new(150, 0)
                            Constraint.Parent = Main]]
                            
                            objects.Main = Main
                        end
                        
                        -- objects.MainOutline
                        do 
                            local MainOutline = Instance.new('UIStroke')
                            MainOutline.Color = Color3.new(1, 1, 1)
                            MainOutline.Thickness = 1
                            
                            MainOutline.Parent = objects.Main
                            objects.MainOutline = MainOutline
                        end
                        
                        -- objects.MainOutlineG
                        do 
                            if ( InterfaceTheme.SpecialOutlines ) then 
                                local MainOutlineG = Instance.new('UIGradient')
                                MainOutlineG.Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, InterfaceTheme.Primary),
                                    ColorSequenceKeypoint.new(1, InterfaceTheme.Secondary)
                                })
                                MainOutlineG.Enabled = true
                                MainOutlineG.Rotation = 0      
                                        
                                MainOutlineG.Parent = objects.MainOutline
                                objects.MainOutlineG = MainOutlineG 
                            else
                                objects.MainOutline.Color = InterfaceTheme.Outline 
                            end
                        end
                        
                        -- objects.Container
                        do 
                            local Container = Instance.new('ScrollingFrame')
                            Container.AutomaticSize = 'Y'
                            Container.BackgroundTransparency = 1 
                            Container.BorderColor3 = InterfaceTheme.Outline
                            Container.BorderSizePixel = 1
                            Container.BottomImage = 'rbxassetid://9416839567'
                            Container.ClipsDescendants = true --ASFDASFASF
                            Container.MidImage = 'rbxassetid://9416839567'
                            Container.Position = UDim2.fromOffset(0, 31)
                            Container.ScrollBarImageTransparency = 0.4
                            Container.ScrollBarThickness = 0 -- 3 when scrolling 
                            Container.ScrollingEnabled = false -- true when scrolling 
                            Container.Size = UDim2.new(1, 0, 0, -31)
                            Container.TopImage = 'rbxassetid://9416839567'
                            Container.Visible = true
                            Container.ZIndex = ZIndex -- - 1 maybe?
                            
                            local Layout = Instance.new('UIListLayout')
                            Layout.VerticalAlignment = 'Top'
                            Layout.HorizontalAlignment = 'Left'
                            Layout.FillDirection = 'Vertical'
                            Layout.Parent = Container
                            
                            Container.Parent = objects.Main
                            objects.Container = Container 
                        end
                        
                        -- objects.Header
                        do 
                            local Header = Instance.new('Frame')
                            Header.BackgroundColor3 = InterfaceTheme.Shade1
                            Header.BorderSizePixel = 0
                            Header.Size = UDim2.new(1, 0, 0, 30)
                            Header.ZIndex = ZIndex + 1 
                            
                            Header.Parent = objects.Main
                            objects.Header = Header 
                        end
                        
                        -- objects.HeaderOutline
                        do 
                            local HeaderOutline = Instance.new('UIStroke')
                            HeaderOutline.Color = Color3.new(1, 1, 1)
                            HeaderOutline.Thickness = 1
                            
                            HeaderOutline.Parent = objects.Header
                            objects.HeaderOutline = HeaderOutline
                        end
                        
                        -- objects.HeaderOutlineG
                        do 
                            if ( InterfaceTheme.SpecialOutlines ) then 
                                local HeaderOutlineG = Instance.new('UIGradient')
                                HeaderOutlineG.Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, InterfaceTheme.Primary),
                                    ColorSequenceKeypoint.new(1, InterfaceTheme.Secondary)
                                })
                                HeaderOutlineG.Enabled = true
                                HeaderOutlineG.Rotation = 0      
                                        
                                HeaderOutlineG.Parent = objects.HeaderOutline
                                objects.HeaderOutlineG = HeaderOutlineG 
                            else
                                objects.HeaderOutline.Color = InterfaceTheme.Outline 
                            end
                        end
                        
                        -- objects.ClickSensor
                        do 
                            local ClickSensor = Instance.new('TextButton')
                            ClickSensor.AutoButtonColor = false 
                            ClickSensor.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            ClickSensor.BackgroundTransparency = 1
                            ClickSensor.BorderSizePixel = 0
                            ClickSensor.Size = UDim2.fromScale(1, 1)
                            ClickSensor.Text = '' 
                            ClickSensor.TextTransparency = 1 
                            ClickSensor.ZIndex = ZIndex + 1
                            
                            ClickSensor.Parent = objects.Header
                            objects.ClickSensor = ClickSensor
                        end
                        
                        -- objects.HeaderIcon
                        do 
                            local HeaderIcon = Instance.new('ImageLabel')
                            HeaderIcon.BackgroundTransparency = 1
                            HeaderIcon.Image = IconId
                            HeaderIcon.ImageColor3 = Color3.fromRGB(250, 250, 255)
                            HeaderIcon.Position = UDim2.fromOffset(7, 7) -- offset = (Header height - icon height) / 2
                            HeaderIcon.Size = UDim2.fromOffset(16, 16)
                            HeaderIcon.ZIndex = ZIndex + 1
                            
                            HeaderIcon.Parent = objects.Header 
                            objects.HeaderIcon = HeaderIcon
                        end
                        
                        -- objects.HeaderLabel
                        do 
                            local HeaderLabel = Instance.new('TextLabel')
                            HeaderLabel.BackgroundTransparency = 1
                            HeaderLabel.Font = InterfaceTheme.Font
                            HeaderLabel.Size = UDim2.fromScale(1, 1)
                            HeaderLabel.Text = MenuName
                            HeaderLabel.TextColor3 = InterfaceTheme.Text_Shade1
                            HeaderLabel.TextSize = InterfaceTheme.TextSize
                            HeaderLabel.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            HeaderLabel.TextStrokeTransparency = 0.5
                            HeaderLabel.TextXAlignment = 'Center'
                            HeaderLabel.TextYAlignment = 'Center'
                            HeaderLabel.ZIndex = ZIndex + 1 
                            
                            if ( ActiveConfig.Interface.MenuTitleStyle == 'Bold' ) then
                                HeaderLabel.RichText = true 
                                HeaderLabel.Text = string.format('<b>%s</b>', MenuName:upper())
                            end
                            
                            HeaderLabel.Parent = objects.Header
                            objects.HeaderLabel = HeaderLabel
                        end
                    end
                    
                    --- Events
                    do
                        objects.ClickSensor.MouseEnter:Connect(function() 
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 0.985
                            })
                        end)
                        
                        objects.ClickSensor.MouseLeave:Connect(function() 
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 1
                            })
                        end)
                        
                        objects.ClickSensor.MouseButton1Down:Connect(function() 
                            if ( this.DragState ) then
                                local dragCon = this.connections.dragCon 
                                local dragEnd = this.connections.dragEnd
                                
                                if ( dragCon ) then 
                                    dragCon:Disconnect()
                                end
                                if ( dragEnd ) then
                                    dragEnd:Disconnect() 
                                end
                            end
                            
                            this.MovedState = true
                            this.DragState = true
                            
                            local startRoot = objects.Main.AbsolutePosition + guiService:GetGuiInset()
                            local startMouse = inputService:GetMouseLocation()
                            
                            this.connections.dragCon = inputService.InputChanged:Connect(function() 
                                local newMouse  = inputService:GetMouseLocation()
                                local finalVec2 = ( startRoot + (newMouse - startMouse) )
                                local finalUDim2 = UDim2.fromOffset(finalVec2.X, finalVec2.Y)
                                
                                Tween.Quick(objects.Main, {
                                    Position = finalUDim2
                                })
                            end)
                            
                            this.connections.dragEnd = inputService.InputEnded:Connect(function(input) 
                                if ( input.UserInputType.Name == 'MouseButton1' ) then
                                    this.DragState = false 
                            
                                    local dragCon = this.connections.dragCon 
                                    local dragEnd = this.connections.dragEnd
                                    
                                    if ( dragCon ) then 
                                        dragCon:Disconnect()
                                    end
                                    if ( dragEnd ) then
                                        dragEnd:Disconnect() 
                                    end
                                end
                            end)
                        end)
                    end
                    
                    --- Finalize
                    this.objects = objects
                    return this 
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLBaseMenu 
        end)()
        UiClasses.RLBaseMenu = RLBaseMenu 
        
        --- RLModuleMenu : RLBaseMenu
        -- Container for modules
        local RLModuleMenu: RLBaseMenu = (function() -- src/UiClasses/RLModuleMenu.lua
            --- RLModuleMenu : RLBaseMenu
            -- Container for modules
            local RLModuleMenu: RLBaseMenu = {} do 
                --- Setup 
                RLModuleMenu.__index = RLModuleMenu
                RLModuleMenu.class = 'RLModuleMenu'
                setmetatable(RLModuleMenu, RLBaseMenu)
                
                --- Interaction
                function RLModuleMenu:ToggleMenu() 
                    self.MenuState = not self.MenuState
                    
                    local objects = self.objects 
                    local container = objects.Container
                              
                    if ( self.MenuState ) then
                        Tween.Quick(objects.Arrow, {
                            Rotation = 180
                        })
                        
                        objects.Container.Visible = true
                        objects.Main.AutomaticSize = 'Y'
                        
                        objects.OpenSound:Play()
                    else
                        Tween.Quick(objects.Arrow, {
                            Rotation = 0
                        })
                        
                        objects.Container.Visible = false
                        objects.Main.AutomaticSize = 'None'
                        
                        objects.OpenSound:Play()
                    end
                end
                
                --- Element
                function RLModuleMenu:AddModule(ModuleName: string, DisableHotkey: boolean) 
                    local this = UiClasses.RLModule.new(self, ModuleName, self.zindex)
                    
                    if ( DisableHotkey ~= true ) then
                        local hotkey = this:AddHotkey('Hotkey')
                        hotkey:SetTooltip(string.format('Toggles %s when this key is pressed', ModuleName))
                        hotkey:MakeLink(this, 'Toggle')
                        this.LinkedHotkey = hotkey
                    end
                    
                    this.objects.Main.Parent = self.objects.Container 
                    
                    return this
                end
                
                --- Constructor
                function RLModuleMenu.new( Parent: table, MenuName: string, IconId: string, ZIndex: number ) 
                    IconId = IconId or ''
                    
                    --- Setup
                    local this = RLBaseMenu.new(Parent, MenuName, IconId, ZIndex)
                    setmetatable(this, RLModuleMenu)           
                    this.index = #Parent.children - 1
                    
                    --- Objects
                    local objects = this.objects 
                    do 
                        -- objects.Arrow
                        do 
                            local Arrow = Instance.new('ImageLabel')
                            Arrow.AnchorPoint = Vector2.new(1, 0)
                            Arrow.BackgroundTransparency = 1
                            Arrow.Image = 'rbxassetid://10667805858'
                            Arrow.ImageColor3 = Color3.fromRGB(250, 250, 255)
                            Arrow.Position = UDim2.new(1, -8, 0, 8)
                            Arrow.ResampleMode = 'Pixelated' -- not sure if this is needed
                            Arrow.Rotation = 180 
                            Arrow.Size = UDim2.fromOffset(14, 14)
                            Arrow.ZIndex = ZIndex + 1
                            
                            Arrow.Parent = objects.Header 
                            objects.Arrow = Arrow
                        end
                        
                        -- objects.OpenSound
                        do 
                            local OpenSound = Instance.new('Sound')
                            OpenSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            OpenSound.PlaybackSpeed = 1.5
                            OpenSound.SoundId = CustomAssets['Sounds/guiCtrl_Menu.mp3']
                            
                            OpenSound.Parent = objects.Main
                            objects.OpenSound = OpenSound 
                        end
                    end
                    
                    --- Events 
                    do
                        objects.ClickSensor.MouseButton2Click:Connect(function() 
                            this:ToggleMenu()
                        end)
                    end
                    
                    --- Finalization 
                    return this 
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLModuleMenu
        end)()
        UiClasses.RLModuleMenu = RLModuleMenu
    
        --- RLModule : RLBase
        -- Class for modules
        local RLModule: RLBase = (function() -- src/UiClasses/RLModule.lua
            --- RLModule : RLBase
            -- Class for modules
            local RLModule: RLBase = {} do 
                --- Setup
                RLModule.__index = RLModule
                RLModule.class = 'RLModule'
                setmetatable(RLModule, RLBase)
                
                --- Interaction
                -- Menu
                function RLModule:Open() -- Expand 
                    self.MenuState = true
                    
                    self:Fire('OnOpen')
                    self:FireInternal('OnMenuStateChange', true)
                    
                    local objects = self.objects
                    Tween.Quick(objects.Arrow, {
                        Rotation = 180
                    })
                    objects.OpenSound:Play()
                    objects.Container.Visible = true
                    objects.Main.AutomaticSize = 'Y'
                end
                
                function RLModule:Close() -- Collapse 
                    self.MenuState = false
                    
                    self:Fire('OnClose')
                    self:FireInternal('OnMenuStateChange', false)
                    
                    local objects = self.objects
                    Tween.Quick(objects.Arrow, {
                        Rotation = 0
                    })
                    objects.OpenSound:Play()
                    objects.Container.Visible = false
                    objects.Main.AutomaticSize = 'None'
                end
                
                function RLModule:ToggleMenu() 
                    local toggled = not self.MenuState
                    
                    if ( toggled ) then
                        self:Open()
                    else
                        self:Close()
                    end
                    
                    return self 
                end
                
                function RLModule:IsMenuToggled() 
                    return self.MenuState
                end
                
                -- Toggling 
                function RLModule:Enable( NoSound: boolean ) 
                    self.ToggleState = true
                    
                    self:Fire('OnEnable')
                    self:Fire('OnToggle', true)
                    ui:Fire('OnModuleEnable', self)
                    
                    local objects = self.objects
                    Tween.Quick(objects.Selection, {
                        Size = UDim2.fromScale(1, 1)
                    })
                    if ( NoSound ~= true ) then 
                        objects.ToggleSound:Play()
                    end
                    
                    return self
                end
                
                function RLModule:Disable( NoSound: boolean ) 
                    self.ToggleState = false
                    
                    self:Fire('OnDisable')
                    self:Fire('OnToggle', false)
                    ui:Fire('OnModuleDisable', self)
                    
                    local objects = self.objects
                    Tween.Quick(objects.Selection, {
                        Size = UDim2.fromScale(0, 1)
                    })
                    
                    if ( NoSound ~= true ) then 
                        objects.ToggleSound:Play()
                    end
                    
                    return self
                end
                
                function RLModule:Toggle() 
                    local toggled = not self.ToggleState
                    
                    if ( toggled ) then
                        self:Enable()
                    else
                        self:Disable()
                    end
                    
                    return self 
                end
                
                function RLModule:Reset() 
                    if ( self:IsEnabled() ) then 
                        self:Toggle()
                        self:Toggle()
                    end
                    
                    return self 
                end
                
                function RLModule:SetState( Toggled: boolean ) 
                    if ( Toggled ) then
                        if ( not self.ToggleState ) then
                            self:Enable()
                        end
                    else
                        if ( self.ToggleState ) then
                            self:Disable()
                        end
                    end
                    
                    return self
                end
                
                function RLModule:GetState() 
                    return self.ToggleState
                end
                
                -- Misc 
                function RLModule:SetHotkey( Hotkey: any ) 
                    if ( self.LinkedHotkey ) then
                        self.LinkedHotkey:SetHotkey( Hotkey )  
                    end
                    
                    return self 
                end
                
                function RLModule:SetTooltip( Text: string ) 
                    self.tooltip = Text
                    
                    return self
                end
                
                RLModule.GetValue = RLModule.GetState 
                RLModule.IsEnabled = RLModule.GetState
                
                RLModule.SetValue = RLModule.SetState 
                
                --- Element
                function RLModule:AddToggle( SettingName: string ) 
                    local this = UiClasses.RLSettingToggle.new(self, SettingName, self.zindex + 1 )
                    
                    this.objects.Main.Parent = self.objects.Container 
                    
                    return this
                end
                
                function RLModule:AddButton( SettingName: string ) 
                    local this = UiClasses.RLSettingButton.new(self, SettingName, self.zindex + 1 )
                    
                    this.objects.Main.Parent = self.objects.Container 
                    
                    return this
                end
                
                function RLModule:AddSlider( SettingName: string ) 
                    local this = UiClasses.RLSettingSlider.new(self, SettingName, self.zindex + 1 )
                    
                    this.objects.Main.Parent = self.objects.Container 
                    
                    return this
                end
                
                function RLModule:AddDropdown( SettingName: string ) 
                    local this = UiClasses.RLSettingDropdown.new(self, SettingName, self.zindex + 1 )
                    
                    this.objects.Main.Parent = self.objects.Container 
                    
                    return this
                end
                
                function RLModule:AddHotkey( SettingName: string ) 
                    local this = UiClasses.RLSettingHotkey.new(self, SettingName, self.zindex + 1 )
                                
                    this.objects.Main.Parent = self.objects.Container 
                    
                    return this
                end
                
                function RLModule:AddCarousel( SettingName: string ) 
                    local this = UiClasses.RLSettingCarousel.new(self, SettingName, self.zindex + 1 )
                                
                    this.objects.Main.Parent = self.objects.Container 
                    
                    return this
                end
                
                --- Constructor 
                function RLModule.new( Parent: table, ModuleName: string, ZIndex: number )
                    --- Setup
                    local this = RLBase.new()
                    setmetatable(this, RLModule)
                    table.insert(Parent.children, this)
                    
                    -- properties
                    this.name = ModuleName 
                    this.parent = Parent
                    this.zindex = ZIndex 
                    this.connections = {}
                    
                    -- states 
                    this.HoverState = false
                    this.MenuState = false 
                    this.ToggleState = false
                    
                    --- Objects
                    local objects = {}
                    do 
                        -- objects.Main
                        do
                            local Main = Instance.new('Frame')
                            Main.AutomaticSize = 'None'
                            Main.BackgroundColor3 = InterfaceTheme.Shade2
                            Main.BorderSizePixel = 0 
                            Main.Size = UDim2.new(1, 0, 0, 24)
                            Main.ZIndex = ZIndex
                            
                            objects.Main = Main
                        end
                        
                        -- objects.Selection
                        do 
                            local Selection = Instance.new('Frame')
                            Selection.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            Selection.BackgroundTransparency = 0.95
                            Selection.BorderSizePixel = 0
                            Selection.ClipsDescendants = true
                            Selection.Size = UDim2.fromOffset(0, 24)
                            Selection.ZIndex = ZIndex + 2
                            
                            local Side = Instance.new('Frame')
                            Side.BackgroundColor3 = InterfaceTheme.Primary
                            Side.BorderSizePixel = 0
                            Side.Size = UDim2.fromOffset(2, 24)
                            Side.ZIndex = ZIndex + 2
                            
                            Side.Parent = Selection
                            Selection.Parent = objects.Main
                            objects.Selection = Selection
                        end
                        
                        -- objects.ClickSensor
                        do 
                            local ClickSensor = Instance.new('TextButton')
                            ClickSensor.AutoButtonColor = false 
                            ClickSensor.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            ClickSensor.BackgroundTransparency = 1
                            ClickSensor.BorderSizePixel = 0
                            ClickSensor.Size = UDim2.new(1, 0, 0, 24)
                            ClickSensor.Text = '' 
                            ClickSensor.TextTransparency = 1 
                            ClickSensor.ZIndex = ZIndex + 1
                            
                            ClickSensor.Parent = objects.Main
                            objects.ClickSensor = ClickSensor
                        end
                        
                        -- objects.Arrow
                        do 
                            local Arrow = Instance.new('ImageLabel')
                            Arrow.AnchorPoint = Vector2.new(1, 0)
                            Arrow.BackgroundTransparency = 1
                            Arrow.Image = 'rbxassetid://10771256737'
                            Arrow.ImageColor3 = Color3.fromRGB(250, 250, 255)
                            Arrow.Position = UDim2.new(1, -5, 0, 5) -- offset = (Header height - icon height) / 2
                            Arrow.Size = UDim2.fromOffset(14, 14)
                            Arrow.ZIndex = ZIndex + 1
                            
                            Arrow.Parent = objects.Main 
                            objects.Arrow = Arrow
                        end
                        
                        -- objects.Label
                        do 
                            local Label = Instance.new('TextLabel')
                            Label.BackgroundTransparency = 1
                            Label.Font = InterfaceTheme.Font
                            Label.Position = UDim2.fromOffset(5, 0)
                            Label.Size = UDim2.new(1, -5, 0, 24)
                            Label.Text = ModuleName 
                            Label.TextColor3 = InterfaceTheme.Text_Shade2
                            Label.TextSize = InterfaceTheme.TextSize
                            Label.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Label.TextStrokeTransparency = 0.5
                            Label.TextXAlignment = 'Left'
                            Label.TextYAlignment = 'Center'
                            Label.ZIndex = ZIndex + 1
                            
                            Label.Parent = objects.Main
                            objects.Label = Label
                        end
                        
                        -- objects.Container
                        do 
                            local Container = Instance.new('ScrollingFrame')
                            Container.AutomaticSize = 'Y'
                            Container.BackgroundTransparency = 1 
                            Container.BorderSizePixel = 0
                            Container.BottomImage = 'rbxassetid://9416839567'
                            Container.ClipsDescendants = true --ASFDASFASF 
                            Container.MidImage = 'rbxassetid://9416839567'
                            Container.Position = UDim2.fromOffset(0, 24)
                            Container.ScrollBarImageTransparency = 0.4
                            Container.ScrollBarThickness = 0
                            Container.ScrollingEnabled = false 
                            Container.Size = UDim2.new(1, 0, 0, 24)
                            Container.TopImage = 'rbxassetid://9416839567'
                            Container.Visible = false
                            Container.ZIndex = ZIndex
                            
                            local Layout = Instance.new('UIListLayout')
                            Layout.VerticalAlignment = 'Top'
                            Layout.HorizontalAlignment = 'Left'
                            Layout.FillDirection = 'Vertical'
                            Layout.Parent = Container
                            
                            Container.Parent = objects.Main
                            objects.Container = Container 
                            objects.Layout = Layout
                        end
                        
                        -- objects.ToggleSound
                        do 
                            local ToggleSound = Instance.new('Sound')
                            ToggleSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            ToggleSound.SoundId = CustomAssets['Sounds/guiCtrl_Toggle.mp3']
                            
                            ToggleSound.Parent = objects.Main
                            objects.ToggleSound = ToggleSound 
                        end
                        
                        -- objects.OpenSound
                        do 
                            local OpenSound = Instance.new('Sound')
                            OpenSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            OpenSound.PlaybackSpeed = 1.5
                            OpenSound.SoundId = CustomAssets['Sounds/guiCtrl_Menu.mp3']
                            
                            OpenSound.Parent = objects.Main
                            objects.OpenSound = OpenSound 
                        end
                    end
                    
                    --- Events
                    do 
                        objects.ClickSensor.MouseButton1Click:Connect(function() 
                            this:Toggle()
                        end)
                        
                        objects.ClickSensor.MouseButton2Click:Connect(function() 
                            this:ToggleMenu()
                        end)
                        
                        objects.ClickSensor.MouseEnter:Connect(function() 
                            this.HoverState = true
                            
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 0.985
                            })
                            Tween.Quick(objects.Label, {
                                Position = UDim2.fromOffset(7, 0),
                                Size = UDim2.new(1, -7, 1, 0)
                            })
                            
                            if ( this.tooltip ) then 
                                instances.Tooltip:Show(this)
                            end
                        end)
                        
                        objects.ClickSensor.MouseLeave:Connect(function() 
                            this.HoverState = false
                            
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 1
                            })
                            Tween.Quick(objects.Label, {
                                Position = UDim2.fromOffset(5, 0),
                                Size = UDim2.new(1, -5, 1, 0)
                            })
                            
                            if ( this.tooltip ) then 
                                instances.Tooltip:Hide(this)
                            end
                        end)
                    end
                    
                    --- Finalization
                    this.objects = objects 
                    return this
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLModule
        end)()
        UiClasses.RLModule = RLModule
        
        --- RLTooltip : RLBase
        -- Class for tooltips
        local RLTooltip: RLBase = (function() -- src/UiClasses/RLTooltip.lua
            --- RLTooltip : RLBase
            -- Class for tooltips
            local RLTooltip: RLBase = {} do 
                --- Setup
                RLTooltip.__index = RLTooltip
                RLTooltip.class = 'RLTooltip'
                setmetatable(RLTooltip, RLBase)
                
                --- Interaction
                function RLTooltip:Show( Parent: any ) 
                    self.parentRef = Parent
                    
                    self:SetDesc( Parent.tooltip )
                    self:SetTitle( Parent.name )
                    
                    local objects = self.objects
                    local tooltip = objects.Tooltip
                                
                    local updateCn = self.connections.posUpd
                    if ( updateCn ) then
                        return self
                    end
                    
                    self.connections.posUpd = runService.Heartbeat:Connect(function() 
                        local mousePos = inputService:GetMouseLocation()
                        
                        tooltip.Position = UDim2.fromOffset(mousePos.X + 35, mousePos.Y + 35)
                        tooltip.Visible = true 
                    end)
                    
                    return self
                end
                
                function RLTooltip:Hide( Parent: any ) 
                    if ( self.parentRef ~= Parent ) then
                        return self
                    end 
                    
                    local objects = self.objects
                    local cons = self.connections 
                    
                    local tooltip = objects.Tooltip
                    
                    local updateCn = cons.posUpd
                    if ( updateCn ) then
                        updateCn:Disconnect() 
                        cons.posUpd = nil 
                    end
                    
                    tooltip.Visible = false
                    
                    return self
                end
                function RLTooltip:SetTitle( TitleText: string ) 
                    self.objects.Title.Text = TitleText 
                    
                    return self 
                end
                
                function RLTooltip:SetDesc( DescText: string )
                    local baseSize = UDim2.fromOffset(165, 26)
                    local addedSize = UDim2.fromOffset(0, 5)
                    
                    local objects = self.objects
                    local Tooltip = objects.Tooltip
                    local Description = objects.Description
                    
                    Description.MaxVisibleGraphemes = #Description.Text
                    Description.Text = DescText 
                    
                    Tween.Quick(Description, {
                        MaxVisibleGraphemes = #DescText
                    })
                    
                    Tooltip.Size = baseSize
                    
                    for i = 1, 100 do -- for i loop is used instead of a while loop incase a description will never fit 
                        if ( Description.TextFits ) then
                            break 
                        end
                        
                        Tooltip.Size += addedSize
                    end
                    Tooltip.Size += addedSize 
                    
                    return self 
                end
                
                --- Constructor
                function RLTooltip.new() 
                    --- Setup
                    local this = RLBase.new()
                    setmetatable(this, RLTooltip)
                    local connections = {} 
                    
                    --- Objects
                    local objects = {}
                    do 
                        -- objects.Tooltip
                        do 
                            local Tooltip = Instance.new('Frame')
                            Tooltip.BackgroundColor3 = InterfaceTheme.Shade2
                            Tooltip.BackgroundTransparency = 0.2
                            Tooltip.BorderSizePixel = 0
                            Tooltip.Size = UDim2.fromOffset(165, 85)
                            Tooltip.Visible = false
                            Tooltip.ZIndex = 7000
                            
                            Tooltip.Parent = instances.Main 
                            objects.Tooltip = Tooltip
                        end
                        
                        -- objects.MainOutline
                        do 
                            local MainOutline = Instance.new('UIStroke')
                            MainOutline.Color = Color3.new(1, 1, 1)
                            MainOutline.Thickness = 1
                            
                            MainOutline.Parent = objects.Tooltip
                            objects.MainOutline = MainOutline
                        end
                        
                        -- objects.MainOutlineG
                        do 
                            if ( InterfaceTheme.SpecialOutlines ) then 
                                local MainOutlineG = Instance.new('UIGradient')
                                MainOutlineG.Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, InterfaceTheme.Primary),
                                    ColorSequenceKeypoint.new(1, InterfaceTheme.Secondary)
                                })
                                MainOutlineG.Enabled = true
                                MainOutlineG.Rotation = 0      
                                        
                                MainOutlineG.Parent = objects.MainOutline
                                objects.MainOutlineG = MainOutlineG 
                            else
                                objects.MainOutline.Color = InterfaceTheme.Outline 
                            end
                        end
                        
                        -- objects.Header
                        do
                            local Header = Instance.new('Frame')
                            Header.BackgroundColor3 = InterfaceTheme.Shade1
                            Header.BackgroundTransparency = 0.25
                            Header.BorderSizePixel = 0
                            Header.Size = UDim2.new(1, 0, 0, 26)
                            Header.Visible = true
                            Header.ZIndex = 7001
                            
                            Header.Parent = objects.Tooltip 
                            objects.Header = Header
                        end
                        
                        -- objects.HeaderOutline
                        do 
                            local HeaderOutline = Instance.new('UIStroke')
                            HeaderOutline.Color = Color3.new(1, 1, 1)
                            HeaderOutline.Thickness = 1
                            
                            HeaderOutline.Parent = objects.Header
                            objects.HeaderOutline = HeaderOutline
                        end
                        
                        -- objects.HeaderOutlineG
                        do 
                            if ( InterfaceTheme.SpecialOutlines ) then 
                                local HeaderOutlineG = Instance.new('UIGradient')
                                HeaderOutlineG.Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, InterfaceTheme.Primary),
                                    ColorSequenceKeypoint.new(1, InterfaceTheme.Secondary)
                                })
                                HeaderOutlineG.Enabled = true
                                HeaderOutlineG.Rotation = 0      
                                        
                                HeaderOutlineG.Parent = objects.HeaderOutline
                                objects.HeaderOutlineG = HeaderOutlineG 
                            else
                                objects.HeaderOutline.Color = InterfaceTheme.Outline 
                            end
                        end
                        
                        -- objects.Title 
                        do 
                            local Title = Instance.new('TextLabel')
                            Title.BackgroundTransparency = 1
                            Title.Font = InterfaceTheme.Font
                            Title.Size = UDim2.fromScale(1, 1)
                            Title.Text = 'Placeholder text'  
                            Title.TextColor3 = InterfaceTheme.Text_Shade1
                            Title.TextSize = InterfaceTheme.TextSize
                            Title.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Title.TextStrokeTransparency = 0.5
                            Title.TextXAlignment = 'Center'
                            Title.TextYAlignment = 'Center'
                            Title.ZIndex = 7001
                            
                            Title.Parent = objects.Header
                            objects.Title = Title
                        end
                        
                        -- objects.Description 
                        do 
                            local Description = Instance.new('TextLabel')
                            Description.BackgroundTransparency = 1
                            Description.Font = InterfaceTheme.Font
                            Description.Position = UDim2.fromOffset(5, 31)
                            Description.Size = UDim2.new(1, -10, 1, -36)
                            Description.Text = 'Placeholder text'  
                            Description.TextColor3 = InterfaceTheme.Text_Shade2
                            Description.TextSize = InterfaceTheme.TextSize
                            Description.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Description.TextStrokeTransparency = 0.5
                            Description.TextWrapped = true 
                            Description.TextXAlignment = 'Left'
                            Description.TextYAlignment = 'Top'
                            Description.ZIndex = 7000
                            
                            Description.Parent = objects.Tooltip
                            objects.Description = Description
                        end
                    end
                    
                    --- Finalization 
                    this.objects = objects
                    this.connections = connections
                    return this 
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLTooltip
        end)()
        UiClasses.RLTooltip = RLTooltip
        
        --- RLNotif : RLBase
        -- Class for notifs 
        local RLNotif: RLBase = (function() -- src/UiClasses/RLNotif.lua
            --- RLNotif : RLBase
            -- Class for notifs 
            local RLNotif: RLBase = {} do 
                --- Setup
                RLNotif.__index = RLNotif
                RLNotif.class = 'RLNotif'
                setmetatable(RLNotif, RLBase)
                
                --- Interaction 
                do 
                    local soundSwitch = {
                        Error = 'Sounds/notif_Error.mp3';
                        Friend = 'Sounds/notif_Friend.mp3';
                        Generic = 'Sounds/notif_Generic.mp3';
                        Success = 'Sounds/notif_Success.mp3';
                        Warning = 'Sounds/notif_Warning.mp3';
                    } 
                    local iconSwitch = {
                        Generic = 'rbxassetid://11140658143';
                        Friend = 'rbxassetid://11140661564';
                        Warning = 'rbxassetid://11140659388';
                        
                        Error = 'rbxassetid://11140659388';
                        Success = 'rbxassetid://11140658143';
                    }
                    
                    function RLNotif:SetType( newType: string ) 
                        local objects = self.objects
                        
                        objects.Sound.SoundId = CustomAssets[ soundSwitch[ newType ] ]
                        objects.Icon.Image = iconSwitch[ newType ]
                        
                        return self 
                    end
                    
                    function RLNotif:SetTitle( TitleText: string ) 
                        local addedSize = UDim2.fromOffset(5, 0)
                        
                        local objects = self.objects
                        local Main = objects.Main
                        local Title = objects.Title
                        
                        Title.Text = TitleText 
                        
                        for i = 1, 20 do 
                            if ( Title.TextFits ) then
                                break 
                            end
                            
                            Main.Size += addedSize
                        end
                        
                        Main.Size += addedSize
                        
                        Title.MaxVisibleGraphemes = 0
                        Tween.Quick(Title, {
                            MaxVisibleGraphemes = #TitleText
                        })
                        
                        return self 
                    end
                    
                    function RLNotif:SetDesc( DescText: string )
                        local addedSize = UDim2.fromOffset(5, 0)
                        
                        local objects = self.objects
                        local Main = objects.Main
                        local Description = objects.Description
                        
                        Description.Text = DescText 
                        
                        for i = 1, 20 do 
                            if ( Description.TextFits ) then
                                break 
                            end
                            
                            Main.Size += addedSize
                        end
                        
                        Main.Size += addedSize 
                        
                        Description.MaxVisibleGraphemes = 0
                        Tween.Quick(Description, {
                            MaxVisibleGraphemes = #DescText
                        })
                        
                        return self 
                    end
                end
                --- Constructor
                function RLNotif.new() 
                    --- Setup
                    local this = RLBase.new()
                    setmetatable(this, RLNotif)
                    
                    --- Objects
                    local objects = {}
                    do 
                        -- objects.Main
                        do 
                            local Main = Instance.new('Frame')
                            Main.AnchorPoint = Vector2.new(1, 1)
                            Main.BackgroundColor3 = InterfaceTheme.Shade2
                            Main.BackgroundTransparency = 0.2
                            Main.BorderSizePixel = 0
                            Main.Size = UDim2.fromOffset(200, 100)
                            Main.Visible = false
                            Main.ZIndex = 7000
                            
                            Main.Parent = instances.ScreenGui 
                            objects.Main = Main
                        end
                        
                        -- objects.MainOutline
                        do 
                            local MainOutline = Instance.new('UIStroke')
                            MainOutline.Color = Color3.new(1, 1, 1)
                            MainOutline.Thickness = 1
                            
                            MainOutline.Parent = objects.Main
                            objects.MainOutline = MainOutline
                        end
                        
                        -- objects.MainOutlineG
                        do 
                            if ( InterfaceTheme.SpecialOutlines ) then 
                                local MainOutlineG = Instance.new('UIGradient')
                                MainOutlineG.Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, InterfaceTheme.Primary),
                                    ColorSequenceKeypoint.new(1, InterfaceTheme.Secondary)
                                })
                                MainOutlineG.Enabled = true
                                MainOutlineG.Rotation = 0      
                                        
                                MainOutlineG.Parent = objects.MainOutline
                                objects.MainOutlineG = MainOutlineG 
                            else
                                objects.MainOutline.Color = InterfaceTheme.Outline 
                            end
                        end
                        
                        -- objects.Header
                        do
                            local Header = Instance.new('Frame')
                            Header.BackgroundColor3 = InterfaceTheme.Shade1
                            Header.BackgroundTransparency = 0.25
                            Header.BorderSizePixel = 0
                            Header.Size = UDim2.new(1, 0, 0, 26)
                            Header.Visible = true
                            Header.ZIndex = 7001
                            
                            Header.Parent = objects.Main 
                            objects.Header = Header
                        end
                        
                        -- objects.HeaderOutline
                        do 
                            local HeaderOutline = Instance.new('UIStroke')
                            HeaderOutline.Color = Color3.new(1, 1, 1)
                            HeaderOutline.Thickness = 1
                            
                            HeaderOutline.Parent = objects.Header
                            objects.HeaderOutline = HeaderOutline
                        end
                        
                        -- objects.HeaderOutlineG
                        do 
                            if ( InterfaceTheme.SpecialOutlines ) then 
                                local HeaderOutlineG = Instance.new('UIGradient')
                                HeaderOutlineG.Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, InterfaceTheme.Primary),
                                    ColorSequenceKeypoint.new(1, InterfaceTheme.Secondary)
                                })
                                HeaderOutlineG.Enabled = true
                                HeaderOutlineG.Rotation = 0      
                                        
                                HeaderOutlineG.Parent = objects.HeaderOutline
                                objects.HeaderOutlineG = HeaderOutlineG 
                            else
                                objects.HeaderOutline.Color = InterfaceTheme.Outline 
                            end
                        end
                        
                        -- objects.Icon
                        do 
                            local Icon = Instance.new('ImageLabel')
                            Icon.BackgroundTransparency = 1
                            Icon.Image = 'rbxassetid://11140658143' -- Generic: 11140658143 Warning: 11140659388 Person: 11140661564
                            Icon.ImageColor3 = InterfaceTheme.Enabled 
                            Icon.Position = UDim2.fromOffset(3, 3)
                            Icon.Size = UDim2.fromOffset(20, 20)
                            Icon.ZIndex = 7001 
                            
                            local Gradient = Instance.new('UIGradient')
                            Gradient.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.new(1.0, 1.0, 1.0)),
                                ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 0.7))
                            })
                            Gradient.Rotation = 90
                            Gradient.Parent = Icon
                            
                            Icon.Parent = objects.Header
                            objects.Icon = Icon
                        end
                        
                        -- objects.Title 
                        do 
                            local Title = Instance.new('TextLabel')
                            Title.BackgroundTransparency = 1
                            Title.Font = InterfaceTheme.Font
                            Title.Position = UDim2.fromOffset(26, 0)
                            Title.Size = UDim2.new(1, -26, 1, 0)
                            Title.Text = 'Placeholder text'  
                            Title.TextColor3 = InterfaceTheme.Text_Shade1
                            Title.TextSize = InterfaceTheme.TextSize
                            Title.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Title.TextStrokeTransparency = 0.5
                            Title.TextXAlignment = 'Left'
                            Title.TextYAlignment = 'Center'
                            Title.ZIndex = 7001
                            
                            Title.Parent = objects.Header
                            objects.Title = Title
                        end
                        
                        -- objects.Description 
                        do 
                            local Description = Instance.new('TextLabel')
                            Description.BackgroundTransparency = 1
                            Description.Font = InterfaceTheme.Font
                            Description.Position = UDim2.fromOffset(5, 31)
                            Description.Size = UDim2.new(1, -10, 1, -36)
                            Description.Text = 'Placeholder text'  
                            Description.TextColor3 = InterfaceTheme.Text_Shade2
                            Description.TextSize = InterfaceTheme.TextSize
                            Description.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Description.TextStrokeTransparency = 0.5
                            Description.TextWrapped = true 
                            Description.TextXAlignment = 'Left'
                            Description.TextYAlignment = 'Top'
                            Description.ZIndex = 7000
                            
                            Description.Parent = objects.Main
                            objects.Description = Description
                        end
                        -- objects.Sound
                        do 
                            local Sound = Instance.new('Sound')
                            Sound.Volume = ActiveConfig.Interface.NotifSounds and 1 or 0 
                            Sound.SoundId = CustomAssets['Sounds/notif_Generic.mp3']
                            
                            Sound.Parent = objects.Main
                            objects.Sound = Sound 
                        end
                        
                    end
                    
                    --- Finalization 
                    this.objects = objects
                    return this 
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLNotif
        end)()
        UiClasses.RLNotif = RLNotif
        
        --- RLBaseSetting : RLBase 
        -- Base class used for certain settings, like toggles, sliders etc.
        local RLBaseSetting: RLBase = (function() -- src/UiClasses/Settings/RLBaseSetting.lua
            --- RLBaseSetting : RLBase 
            -- Base class used for certain settings, like toggles, sliders etc.
            local RLBaseSetting: RLBase = {} do 
                --- Setup
                RLBaseSetting.__index = RLBaseSetting
                RLBaseSetting.class = 'RLBaseSetting'
                setmetatable(RLBaseSetting, RLBase)
                
                --- Interaction
                function RLBaseSetting:MakePrimary() 
                    self.primary = true 
                    
                    return self
                end
                
                function RLBaseSetting:IsPrimary() -- i swear these functions are useful
                    return self.primary
                end
                
                function RLBaseSetting:LinkToOption( Option: RLDropdownItem  ) -- link this module to a dropdown option
                    local linkedOptions = self.LinkedOptions
                    
                    
                    if ( Option ) then
                        table.insert( Option.LinkedObjs, self )
                        table.insert( linkedOptions, Option ) 
                        
                        local main = self.objects.Main 
                        
                        main.Visible = false 
                        for _, option in ipairs( linkedOptions ) do 
                            if ( option:GetState() == true ) then
                                main.Visible = true
                                break  
                            end
                        end
                        
                    else
                        for _, option in ipairs( linkedOptions ) do 
                            table.remove( option.LinkedObjs, table.find( option.LinkedObjs, self ) )
                        end
                        
                        table.clear( linkedOptions )
                    end
                    
                    return self 
                end
                
                RLBaseSetting.SetTooltip = UiClasses.RLModule.SetTooltip 
                
                --- Constructor 
                function RLBaseSetting.new( Parent: table, SettingName: string, ZIndex: number, NoneState: number )
                    --- Setup 
                    local this = RLBase.new()
                    setmetatable(this, RLBaseSetting)
                    table.insert(Parent.children, this)
                    
                    NoneState = NoneState or 0 
                    -- states
                    this.HoverState = false 
                    -- RLBase props 
                    this.name = SettingName 
                    this.parent = Parent
                    -- setting props 
                    this.LinkedOptions = {} 
                    this.primary = false
                    this.tooltip = nil
                    this.tooltipShowing = false
                    this.zindex = ZIndex 
                    
                    
                    --- Objects
                    if ( NoneState > 2 ) then -- no objects + connections
                        return this    
                    end
                    
                    local objects = {}
                    do 
                        -- objects.Main
                        do
                            local Main = Instance.new('Frame')
                            Main.BackgroundColor3 = InterfaceTheme.Shade3
                            Main.BorderSizePixel = 0 
                            Main.Size = UDim2.new(1, 0, 0, 24)
                            Main.ZIndex = ZIndex
                            
                            objects.Main = Main
                        end
                        
                        -- objects.ClickSensor
                        do 
                            local ClickSensor = Instance.new('TextButton')
                            ClickSensor.AutoButtonColor = false 
                            ClickSensor.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            ClickSensor.BackgroundTransparency = 1
                            ClickSensor.BorderSizePixel = 0
                            ClickSensor.Size = UDim2.fromScale(1, 1)
                            ClickSensor.Text = '' 
                            ClickSensor.TextTransparency = 1 
                            ClickSensor.ZIndex = ZIndex + 1
                            
                            ClickSensor.Parent = objects.Main
                            objects.ClickSensor = ClickSensor
                        end
                        
                        -- objects.Label
                        do 
                            local Label = Instance.new('TextLabel')
                            Label.BackgroundTransparency = 1
                            Label.Font = InterfaceTheme.Font
                            Label.Position = UDim2.fromOffset(8, 0)
                            Label.Size = UDim2.new(1, -8, 1, 0)
                            Label.Text = SettingName  
                            Label.TextColor3 = InterfaceTheme.Text_Shade3
                            Label.TextSize = InterfaceTheme.TextSize - 2 
                            Label.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Label.TextStrokeTransparency = 0.5
                            Label.TextXAlignment = 'Left'
                            Label.TextYAlignment = 'Center'
                            Label.ZIndex = ZIndex
                            
                            Label.Parent = objects.Main
                            objects.Label = Label
                        end
                    end
                    
                    if ( NoneState > 1 ) then -- no connections 
                        this.objects = objects
                        return this  
                    end
                    
                    --- Events
                    do 
                        objects.ClickSensor.MouseEnter:Connect(function() 
                            this.HoverState = true
                            --this.objects.Sound:Play()
                            
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 0.985
                            })
                            Tween.Quick(objects.Label, {
                                Position = UDim2.fromOffset(10, 0),
                                Size = UDim2.new(1, -10, 1, 0)
                            })
                            
                            if ( this.tooltip ) then 
                                instances.Tooltip:Show(this)
                            end
                        end)
                        
                        objects.ClickSensor.MouseLeave:Connect(function() 
                            this.HoverState = false
                            
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 1
                            })
                            Tween.Quick(objects.Label, {
                                Position = UDim2.fromOffset(8, 0),
                                Size = UDim2.new(1, -8, 1, 0)
                            })
                            
                            if ( this.tooltip ) then 
                                instances.Tooltip:Hide(this)
                            end
                        end)
                    end
                    
                    --- Finalization 
                    this.objects = objects 
                    return this
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLBaseSetting
        end)()
        UiClasses.RLBaseSetting = RLBaseSetting
        
        --- RLSettingSlider : RLBaseSetting 
        -- A one dimensional slider that lets you choose a single number from a min to max 
        local RLSettingSlider: RLBaseSetting = (function() -- src/UiClasses/Settings/RLSettingSlider.lua
            --- RLSettingSlider : RLBaseSetting 
            -- A one dimensional slider that lets you choose a single number from a min to max 
            local RLSettingSlider: RLBaseSetting = {} do 
                --- Setup
                RLSettingSlider.__index = RLSettingSlider
                RLSettingSlider.class = 'RLSettingSlider'
                setmetatable(RLSettingSlider, RLBaseSetting)
                
                --- Interaction
                function RLSettingSlider:GetValue( newValue: number ) 
                    return self.sVal 
                end
                
                -- Takes in a new value, processes it, and sets the slider's value to the processed value
                function RLSettingSlider:SetValue( newValue: number ) 
                    newValue = round( math.clamp( newValue, self.sMin, self.sMax ), self.sStep )
                    
                    if ( self.sVal == newValue ) then
                        return self
                    end 
                    
                    self.sVal = newValue 
                    self:Fire( 'OnUpdate', newValue )
                    
                    if ( self:IsPrimary() ) then
                        self.parent:Fire( 'OnPrimaryChange', newValue ) 
                    end
                    
                    local objects = self.objects 
                    Tween.Quick(objects.Fill, {
                        Size = UDim2.fromScale( ( newValue - self.sMin ) / ( self.sMax - self.sMin ), 1 )
                    })
                    objects.Value.Text = self.sFormat:format( newValue )
                    
                    return self
                end
                
                -- Sets a slider's value to an already processed value
                function RLSettingSlider:SetFinishedValue( newValue: number ) 
                    if ( self.sVal == newValue ) then
                        return self
                    end 
                    
                    self.sVal = newValue 
                    self:Fire( 'OnUpdate', newValue )
                    
                    if ( self:IsPrimary() ) then
                        self.parent:Fire( 'OnPrimaryChange', newValue ) 
                    end
                    
                    local objects = self.objects 
                    Tween.Quick(objects.Fill, {
                        Size = UDim2.fromScale( ( newValue - self.sMin ) / ( self.sMax - self.sMin ), 1 )
                    })
                    objects.Value.Text = self.sFormat:format( newValue )
                    
                    return self
                end
                
                -- Set a slider's minimum, maximum, step, and value
                function RLSettingSlider:SetSettings( newValues: table ) 
                    local newMin = newValues.Min or 0
                    local newMax = newValues.Max or 100
                    local newStep = newValues.Step or 1 
                    local newVal = newValues.Val or 0 
                    
                    local newFormat
                    do 
                        local stepStr = tostring(newStep)
                        
                        local pattern = '%d'
                        if ( pattern:format(newStep) == stepStr ) then
                            newFormat = pattern
                        else
                            for i = 1, 10 do 
                                pattern = '%.' .. i .. 'f'
                                if ( pattern:format(newStep) == stepStr ) then
                                    newFormat = pattern
                                    break
                                end
                            end
                        end
                    end
                    newFormat = newFormat or '%.3f'
                    
                    self.sMin = newMin 
                    self.sMax = newMax
                    self.sStep = newStep  
                    self.sFormat = newFormat
                    
                    return self:SetValue(newVal)
                end
                
                -- Set's a slider's step to newStep. Use only when there is no alternative, as SetSettings is heavily preferred
                function RLSettingSlider:SetStep( newStep: number ) 
                    local newFormat
                    do 
                        local stepStr = tostring(newStep)
                        
                        local pattern = '%d'
                        if ( pattern:format(newStep) == stepStr ) then
                            newFormat = pattern
                        else
                            for i = 1, 10 do 
                                pattern = '%.' .. i .. 'f'
                                if ( pattern:format(newStep) == stepStr ) then
                                    newFormat = pattern
                                    break
                                end
                            end
                        end
                    end
                    
                    self.sStep = newStep 
                    self.sFormat = newFormat or '%.3f'
                                
                    return self:SetValue( self.sVal )
                end
                
                -- Set's a slider's minimum to newMin. Use only when there is no alternative, as SetSettings is heavily preferred
                function RLSettingSlider:SetMinimum( newMin: number ) 
                    self.sMin = newMin 
                    
                    return self:SetValue( self.sVal )
                end
                
                -- Set's a slider's maximum to newMax. Use only when there is no alternative, as SetSettings is heavily preferred
                function RLSettingSlider:SetMaximum( newMax: number ) 
                    self.sMin = newMax 
                    
                    return self:SetValue( self.sVal )
                end
                
                --- Constructor
                function RLSettingSlider.new( Parent: table, SettingName: string, ZIndex: number ) 
                    --- Setup
                    local this = RLBaseSetting.new( Parent, SettingName, ZIndex, 2 )
                    setmetatable( this, RLSettingSlider )
                    this.sMin = 0
                    this.sMax = 100 
                    this.sStep = 1
                    this.sVal = 0
                    this.sFormat = '%d'
                    
                    this.connections = {} 
                    this.SlideState = false
                    
                    --- Objects
                    local objects = {}
                    do 
                        -- objects.Main
                        do
                            local Main = Instance.new('Frame')
                            Main.BackgroundColor3 = InterfaceTheme.Shade3
                            Main.BorderSizePixel = 0 
                            Main.ClipsDescendants = true 
                            Main.Size = UDim2.new(1, 0, 0, 24)
                            Main.ZIndex = ZIndex
                            
                            objects.Main = Main
                        end
                        
                        -- objects.ClickSensor
                        do 
                            local ClickSensor = Instance.new('TextButton')
                            ClickSensor.AutoButtonColor = false 
                            ClickSensor.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            ClickSensor.BackgroundTransparency = 1
                            ClickSensor.BorderSizePixel = 0
                            ClickSensor.Size = UDim2.fromScale(1, 1)
                            ClickSensor.Text = '' 
                            ClickSensor.TextTransparency = 1 
                            ClickSensor.ZIndex = ZIndex + 1
                            
                            ClickSensor.Parent = objects.Main
                            objects.ClickSensor = ClickSensor
                        end
                        
                        -- objects.Input
                        do 
                            local Input = Instance.new('TextBox')
                            Input.Active = true 
                            Input.BackgroundColor3 = InterfaceTheme.Shade3
                            Input.BackgroundTransparency = 0.2
                            Input.BorderSizePixel = 0
                            Input.BorderSizePixel = Color3.new(1, 1, 1) 
                            Input.ClearTextOnFocus = true
                            Input.Font = InterfaceTheme.Font
                            Input.PlaceholderText = 'Enter a new value' 
                            Input.Size = UDim2.fromScale(1, 1)
                            Input.Text = Input.PlaceholderText
                            Input.TextColor3 = InterfaceTheme.Text_Shade3
                            Input.TextSize = InterfaceTheme.TextSize - 2 
                            Input.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Input.TextStrokeTransparency = 0.5
                            Input.TextXAlignment = 'Center'
                            Input.TextYAlignment = 'Center'
                            Input.Visible = false 
                            Input.ZIndex = ZIndex + 2
                            
                            Input.Parent = objects.Main
                            objects.Input = Input
                        end
                        
                        
                        -- objects.PromptSound
                        do 
                            local PromptSound = Instance.new('Sound')
                            PromptSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            PromptSound.PlaybackSpeed = 1.5
                            PromptSound.SoundId = CustomAssets['Sounds/guiCtrl_Menu.mp3']
                            
                            PromptSound.Parent = objects.Input
                            objects.PromptSound = PromptSound 
                        end
                        
                        -- objects.CloseSound
                        do 
                            local CloseSound = Instance.new('Sound')
                            CloseSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            CloseSound.SoundId = CustomAssets['Sounds/guiCtrl_Toggle.mp3']
                            
                            CloseSound.Parent = objects.Input
                            objects.CloseSound = CloseSound 
                        end
                        
                        -- objects.Slider
                        do 
                            local Slider = Instance.new('Frame')
                            Slider.BackgroundColor3 = InterfaceTheme.Shade1
                            Slider.BorderColor3 = InterfaceTheme.Outline
                            Slider.BorderSizePixel = 1
                            Slider.ClipsDescendants = true 
                            Slider.Position = UDim2.fromOffset(5, 6)
                            Slider.Size = UDim2.new(1, -10, 0, 12)
                            Slider.Visible = true
                            Slider.ZIndex = ZIndex + 1
                            
                            Slider.Parent = objects.Main
                            objects.Slider = Slider
                        end
                        
                        -- objects.Fill
                        do 
                            local Fill = Instance.new('Frame')
                            Fill.BackgroundColor3 = InterfaceTheme.Enabled
                            Fill.BackgroundTransparency = 0
                            Fill.BorderSizePixel = 0
                            Fill.Position = UDim2.fromOffset(0, 0)
                            Fill.Size = UDim2.fromScale(0, 1)
                            Fill.ZIndex = ZIndex + 1 
                            
                            local Gradient = Instance.new('UIGradient')
                            Gradient.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.new(1.0, 1.0, 1.0)),
                                ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 0.7))
                            })
                            Gradient.Rotation = 90
                            Gradient.Parent = Fill
                            
                            Fill.Parent = objects.Slider
                            objects.Fill = Fill 
                        end
                        
                        -- objects.Dimmer
                        do 
                            local Dimmer = Instance.new('Frame')
                            Dimmer.BackgroundColor3 = InterfaceTheme.Shade3
                            Dimmer.BackgroundTransparency = 0.3 
                            Dimmer.BorderSizePixel = 0
                            Dimmer.Size = UDim2.fromScale(1, 1)
                            Dimmer.ZIndex = ZIndex + 1
                            
                            Dimmer.Parent = objects.Main
                            objects.Dimmer = Dimmer 
                        end
                        
                        -- objects.Label
                        do 
                            local Label = Instance.new('TextLabel')
                            Label.BackgroundTransparency = 1
                            Label.Font = InterfaceTheme.Font
                            Label.Position = UDim2.fromOffset(8, 0)
                            Label.Size = UDim2.new(0.6, -8, 1, 0)
                            Label.Text = SettingName  
                            Label.TextColor3 = InterfaceTheme.Text_Shade3
                            Label.TextSize = InterfaceTheme.TextSize - 2 
                            Label.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Label.TextStrokeTransparency = 0.5
                            Label.TextXAlignment = 'Left'
                            Label.TextYAlignment = 'Center'
                            Label.ZIndex = ZIndex + 1
                            
                            Label.Parent = objects.Main
                            objects.Label = Label
                        end
                        
                        -- objects.Value
                        do 
                            local Value = Instance.new('TextLabel')
                            Value.AnchorPoint = Vector2.new(1, 0)
                            Value.BackgroundTransparency = 1
                            Value.Font = InterfaceTheme.Font
                            Value.Position = UDim2.new(1, -5, 0, 0)
                            Value.Size = UDim2.new(0, 20, 1, 0)
                            Value.Text = '0'  
                            Value.TextColor3 = InterfaceTheme.Text_Shade3
                            Value.TextSize = InterfaceTheme.TextSize - 2 
                            Value.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Value.TextStrokeTransparency = 0.5
                            Value.TextXAlignment = 'Right'
                            Value.TextYAlignment = 'Center'
                            Value.ZIndex = ZIndex + 1
                            
                            Value.Parent = objects.Main
                            objects.Value = Value
                        end
                    end
                    
                    --- Events
                    do 
                        objects.Slider.InputBegan:Connect(function( input )
                            if ( input.UserInputType.Name ~= 'MouseButton1' ) then
                                return
                            end
                            
                            if ( this.SlideState ) then
                                local slideCon = this.connections.slideCon 
                                local slideEnd = this.connections.slideEnd
                                
                                if ( slideCon ) then 
                                    slideCon:Disconnect()
                                end
                                if ( slideEnd ) then
                                    slideEnd:Disconnect() 
                                end
                            end
                            
                            this.SlideState = true
                            
                            local sliderStart = objects.ClickSensor.AbsolutePosition + guiService:GetGuiInset()
                            local sliderWidth = objects.Slider.AbsoluteSize.X
                            
                            this.connections.slideCon = inputService.InputChanged:Connect(function() 
                                local mouseCur = inputService:GetMouseLocation().X - 4 -- for some reason the mouse position is offset from the slider, subtracting 4 fixes it
                                
                                -- get mouse position relative to the slider position
                                local mouseRelative = mouseCur - sliderStart.X
                                -- divide by the slider width to get a value from 0 to 1, and clamp it
                                local rangeValue = math.clamp(mouseRelative / sliderWidth, 0, 1)
                                -- scale value from min to max, accounting for the min value
                                local scaledValue = rangeValue * ( this.sMax - this.sMin ) + this.sMin
                                -- round the value to the step 
                                local roundedValue = round(scaledValue, this.sStep)
                                
                                this:SetFinishedValue(roundedValue)
                            end)
                            
                            this.connections.slideEnd = inputService.InputEnded:Connect(function(input) 
                                if ( input.UserInputType.Name == 'MouseButton1' ) then
                                    this.SlideState = false 
                            
                                    local slideCon = this.connections.slideCon 
                                    local slideEnd = this.connections.slideEnd
                                    
                                    if ( slideCon ) then 
                                        slideCon:Disconnect()
                                    end
                                    if ( slideEnd ) then
                                        slideEnd:Disconnect() 
                                    end
                                end
                            end)
                            
                            do 
                                local mouseCur = inputService:GetMouseLocation().X - 4 
                                -- get mouse position relative to the slider position
                                local mouseRelative = mouseCur - sliderStart.X
                                -- divide by the slider width to get a value from 0 to 1, and clamp it
                                local rangeValue = math.clamp(mouseRelative / sliderWidth, 0, 1)
                                -- scale value from min to max, accounting for the min value
                                local scaledValue = rangeValue * ( this.sMax - this.sMin ) + this.sMin
                                -- round the value to the step 
                                local roundedValue = round(scaledValue, this.sStep)
                                
                                this:SetFinishedValue(roundedValue)
                            end
                        end)
                        
                        objects.ClickSensor.MouseButton2Click:Connect(function() 
                            local input = objects.Input
                            input.Position = UDim2.fromScale(0, -1)
                            input.Visible = true
                            
                            objects.PromptSound:Play()
                            
                            input.MaxVisibleGraphemes = 0
                            Tween.Quick(input, {
                                MaxVisibleGraphemes = #input.Text
                            })
                            
                            Tween.Quick(input, {
                                Position = UDim2.fromScale(0, 0)
                            })
                            
                            input:CaptureFocus()
                        end)
                        
                        objects.ClickSensor.MouseEnter:Connect(function() 
                            this.HoverState = true
                            
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 0.985
                            })
                            Tween.Quick(objects.Dimmer, {
                                BackgroundTransparency = 1
                            })
                            
                            Tween.Quick(objects.Label, {
                                TextTransparency = 1,
                                TextStrokeTransparency = 1,
                                Position = UDim2.fromOffset(10, 0),
                                Size = UDim2.new(1, -10, 1, 0)
                            })
                            Tween.Quick(objects.Value, {
                                AnchorPoint = Vector2.new(0.5, 0),
                                Position = UDim2.fromScale(0.5, 0)
                            })
                            objects.Value.TextXAlignment = 'Center'
                            
                            if ( this.tooltip ) then 
                                instances.Tooltip:Show(this)
                            end
                        end)
                        
                        objects.ClickSensor.MouseLeave:Connect(function() 
                            this.HoverState = false
                            
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 1
                            })
                            Tween.Quick(objects.Dimmer, {
                                BackgroundTransparency = 0.3
                            })
                            
                            Tween.Quick(objects.Label, {
                                TextTransparency = 0,
                                TextStrokeTransparency = 0.5,
                                Position = UDim2.fromOffset(8, 0),
                                Size = UDim2.new(1, -8, 1, 0)
                            })
                            Tween.Quick(objects.Value, {
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.new(1, -5, 0, 0)
                            })
                            objects.Value.TextXAlignment = 'Right'
                            
                            if ( this.tooltip ) then 
                                instances.Tooltip:Hide(this)
                            end
                        end)
                        
                        do
                            --local lastScroll = tick()
                            --local raw = this:GetValue()
                            
                            objects.ClickSensor.InputChanged:Connect(function( input ) 
                                if ( input.UserInputType.Name == 'MouseWheel' ) then
                                    local scrollAmnt = input.Position.Z * math.max( this.sStep, 1 )
                                    
                                    this:SetValue( this.sVal + scrollAmnt )
                                    
                                    --[[local nowScroll = tick()
                                    
                                    if ( nowScroll - lastScroll > 0.3 ) then
                                        -- new scroll
                                        raw = this:GetValue()
                                    end
                                    
                                    lastScroll = nowScroll
                                                                
                                    local scroll = input.Position.Z * this.sStep 
                                    raw += scroll
                                    
                                    this:SetValue( raw )]]
                                end
                            end)
                            
                        end
                        
                        objects.Input.FocusLost:Connect(function( enter ) 
                            if ( not enter ) then
                                return 
                            end 
                            
                            local input = objects.Input
                            local text = input.Text:match('^%s*(.-)%s*$') -- trim whitespace at each edge
                            local num = tonumber(text)
                            
                            if ( num ) then                     
                                this:SetValue(num)
                                
                            elseif ( text ~= '' ) then 
                                input.Text = 'Invalid input'
                                task.wait(1)
                            end
                            
                            objects.CloseSound:Play()
                            
                            Tween.Quick(input, {
                                MaxVisibleGraphemes = 0
                            })
                            
                            Tween.Quick(input, {
                                Position = UDim2.fromScale(0, -1)
                            }).Completed:Wait()
                            
                            input.Text = 'Enter a new value'
                            input.Visible = false
                        end)
                    end
                    
                    --- Finalization 
                    this.objects = objects 
                    return this 
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLSettingSlider
        end)()
        UiClasses.RLSettingSlider = RLSettingSlider
        
        --- RLSettingToggle : RLBaseSetting
        -- A single boolean toggle. *May* support implicit hotkey binding
        local RLSettingToggle: RLBaseSetting = (function() -- src/UiClasses/Settings/RLSettingToggle.lua
            --- RLSettingToggle : RLBaseSetting
            -- A single boolean toggle. *May* support implicit hotkey binding in the future
            local RLSettingToggle: RLBaseSetting = {} do 
                --- Setup
                RLSettingToggle.__index = RLSettingToggle
                RLSettingToggle.class = 'RLSettingToggle'
                setmetatable(RLSettingToggle, RLBaseSetting)
                
                --- Interaction
                RLSettingToggle.GetState = UiClasses.RLModule.GetState
                RLSettingToggle.GetValue = UiClasses.RLModule.GetState 
                RLSettingToggle.IsEnabled = UiClasses.RLModule.GetState
                
                RLSettingToggle.Toggle = UiClasses.RLModule.Toggle
                RLSettingToggle.Reset = UiClasses.RLModule.Reset 
                
                RLSettingToggle.SetState = UiClasses.RLModule.SetState
                RLSettingToggle.SetValue = UiClasses.RLModule.SetState 
                
                function RLSettingToggle:Enable() 
                    self.ToggleState = true
                    
                    self:Fire('OnEnable')
                    self:Fire( 'OnToggle', true )
                    
                    if ( self:IsPrimary() ) then
                        self.parent:Fire( 'OnPrimaryChange', true ) 
                    end
                    
                    local objects = self.objects
                    Tween.Quick(objects.Fill, {
                        BackgroundTransparency = 0
                    })
                    
                    return self
                end
                
                function RLSettingToggle:Disable() 
                    self.ToggleState = false
                    
                    self:Fire('OnDisable')
                    self:Fire( 'OnToggle', false )
                    
                    if ( self:IsPrimary() ) then
                        self.parent:Fire( 'OnPrimaryChange', false ) 
                    end
                    
                    local objects = self.objects
                    Tween.Quick(objects.Fill, {
                        BackgroundTransparency = 1
                    })
                    
                    return self
                end
                
                --- Constructor
                function RLSettingToggle.new( Parent: table, SettingName: string, ZIndex: number ) 
                    --- Setup
                    local this = RLBaseSetting.new( Parent, SettingName, ZIndex )
                    setmetatable( this, RLSettingToggle )
                    -- states 
                    this.ToggleState = false
                    
                    --- Objects
                    local objects = this.objects
                    do 
                        -- objects.Toggle
                        do 
                            local Toggle = Instance.new('Frame')
                            Toggle.AnchorPoint = Vector2.new(1, 1)
                            Toggle.BackgroundColor3 = InterfaceTheme.Shade1
                            Toggle.BorderColor3 = InterfaceTheme.Outline
                            Toggle.BorderSizePixel = 1
                            Toggle.Position = UDim2.new(1, -6, 1, -6)
                            Toggle.Size = UDim2.fromOffset(12, 12)
                            Toggle.Visible = true
                            Toggle.ZIndex = ZIndex
                            
                            Toggle.Parent = objects.Main
                            objects.Toggle = Toggle
                        end
                        
                        -- objects.Fill
                        do 
                            local Fill = Instance.new('Frame')
                            Fill.BackgroundColor3 = InterfaceTheme.Enabled
                            Fill.BackgroundTransparency = 1 
                            Fill.BorderSizePixel = 0
                            Fill.Position = UDim2.fromOffset(1, 1)
                            Fill.Size = UDim2.new(1, -2, 1, -2)
                            Fill.ZIndex = ZIndex
                            
                            local Gradient = Instance.new('UIGradient')
                            Gradient.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.new(1.0, 1.0, 1.0)),
                                ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 0.7))
                            })
                            Gradient.Rotation = 90
                            Gradient.Parent = Fill
                            
                            Fill.Parent = objects.Toggle
                            objects.Fill = Fill 
                        end
                    end
                    
                    --- Events
                    do 
                        objects.ClickSensor.MouseButton1Click:Connect(function() 
                            this:Toggle()
                        end)
                        
                        objects.ClickSensor.MouseButton2Click:Connect(function() 
                            --this:ToggleMenu()
                        end)
                    end
                    
                    --- Finalization 
                    return this 
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLSettingToggle
        end)()
        UiClasses.RLSettingToggle = RLSettingToggle
        
        --- RLSettingButton : RLBaseSetting
        -- A simple clickable button
        local RLSettingButton: RLSettingButton = (function() -- src/UiClasses/Settings/RLSettingButton.lua
            --- RLSettingButton : RLBaseSetting
            -- A simple clickable button
            local RLSettingButton: RLSettingButton = {} do 
                --- Setup
                RLSettingButton.__index = RLSettingButton
                RLSettingButton.class = 'RLSettingButton'
                setmetatable(RLSettingButton, RLBaseSetting)
                
                --- Interaction
                RLSettingButton.Toggle = UiClasses.RLModule.Toggle
                
                function RLSettingButton:Click() 
                    self:Fire('OnClick')
                    
                    local icon = self.objects.Icon
                    icon.ImageColor3 = InterfaceTheme.Enabled 
                    Tween.Quad(icon, {
                        ImageColor3 = Color3.fromRGB(250, 250, 255)
                    }, 0.5)
                    
                    return self
                end
                
                --- Constructor
                function RLSettingButton.new(Parent: table, SettingName: string, ZIndex: number) 
                    --- Setup
                    local this = RLBaseSetting.new(Parent, SettingName, ZIndex)
                    setmetatable(this, RLSettingButton)
                                
                    --- Objects
                    local objects = this.objects
                    do 
                        -- objects.Icon
                        do 
                            local Icon = Instance.new('ImageLabel')
                            --Icon.BackgroundColor3 = InterfaceTheme.Shade1
                            --Icon.BorderColor3 = InterfaceTheme.Outline
                            Icon.BorderSizePixel = 1
                            Icon.AnchorPoint = Vector2.new(1, 0)
                            Icon.BackgroundTransparency = 1
                            Icon.Image = 'rbxassetid://10945377432'
                            Icon.ImageColor3 = Color3.fromRGB(250, 250, 255)
                            Icon.Position = UDim2.new(1, -5, 0, 4)
                            Icon.Size = UDim2.fromOffset(16, 16)
                            Icon.Visible = true
                            Icon.ZIndex = ZIndex 
                            
                            Icon.Parent = objects.Main
                            objects.Icon = Icon
                        end
                    end
                    
                    --- Events
                    do 
                        objects.ClickSensor.MouseButton1Click:Connect(function() 
                            this:Click()
                        end)
                    end
                    
                    --- Finalization 
                    return this 
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLSettingButton
        end)()
        UiClasses.RLSettingButton = RLSettingButton
        
        --- RLSettingDropdown : RLBaseSetting
        -- A dropdown menu letting you select a single item from a list of options 
        local RLSettingDropdown: RLBaseSetting = (function() -- src/UiClasses/Settings/RLSettingDropdown.lua
            --- RLSettingDropdown : RLBaseSetting
            -- A dropdown menu letting you select a single item from a list of options 
            local RLSettingDropdown: RLBaseSetting = {} do 
                --- Setup
                RLSettingDropdown.__index = RLSettingDropdown
                RLSettingDropdown.class = 'RLSettingDropdown'
                setmetatable(RLSettingDropdown, RLBaseSetting)
                
                --- Interaction
                function RLSettingDropdown:Open() -- Expand 
                    self.MenuState = true
                    
                    self:Fire('OnOpen')
                                
                    local objects = self.objects
                    Tween.Quick(objects.Arrow, {
                        Rotation = 180
                    })
                    objects.OpenSound:Play()
                    objects.Container.Visible = true
                    objects.Main.AutomaticSize = 'Y'
                end
                
                function RLSettingDropdown:Close() -- Collapse 
                    self.MenuState = false
                    
                    self:Fire('OnClose')
                    
                    local objects = self.objects
                    Tween.Quick(objects.Arrow, {
                        Rotation = 0
                    })
                    objects.OpenSound:Play()
                    objects.Container.Visible = false
                    objects.Main.AutomaticSize = 'None'
                end
                
                function RLSettingDropdown:ToggleMenu() 
                    local toggled = not self.MenuState
                    
                    if ( toggled ) then
                        self:Open()
                    else
                        self:Close()
                    end
                    
                    return self 
                end
                
                function RLSettingDropdown:IsMenuToggled() 
                    return self.MenuState
                end
                
                function RLSettingDropdown:GetValue() 
                    return self.selection
                end
                
                function RLSettingDropdown:SelectOption( OptionName: string ) 
                    for _, item in ipairs( self.children ) do 
                        if ( item.name == OptionName ) then
                            if ( not item:IsSelected() ) then 
                                item:Select( true ) 
                            end
                        else
                            if ( item:IsSelected() ) then 
                                item:Deselect( true ) 
                            end
                        end
                    end 
                    
                    return self 
                end
                
                function RLSettingDropdown:GetOption( OptionName: string ) 
                    for _, c in ipairs( self.children ) do 
                        if ( c.name == OptionName ) then
                            return c 
                        end
                    end
                end
                
                RLSettingDropdown.GetSelection = RLSettingDropdown.GetValue
                RLSettingDropdown.Select = RLSettingDropdown.SelectOption
                RLSettingDropdown.SetSelection = RLSettingDropdown.SelectOption
                
                --- Element
                function RLSettingDropdown:AddOption( OptionName: string ) 
                    local this = UiClasses.RLDropdownItem.new(self, OptionName, self.zindex + 1 )
                    
                    this.objects.Main.Parent = self.objects.Container 
                    
                    return this
                end
                
                --- Constructor 
                function RLSettingDropdown.new( Parent: table, SettingName: string, ZIndex: number )
                    --- Setup
                    local this = RLBaseSetting.new(Parent, SettingName, ZIndex + 1)
                    setmetatable(this, RLSettingDropdown)
                    -- properties
                    this.connections = {}
                    
                    -- states 
                    this.HoverState = false
                    this.MenuState = false 
                    this.ToggleState = false
                    
                    --- Objects
                    local objects = this.objects
                    do 
                        --[[ objects.Selection
                        do 
                            local Selection = Instance.new('Frame')
                            Selection.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            Selection.BackgroundTransparency = 0.95
                            Selection.BorderSizePixel = 0
                            Selection.ClipsDescendants = true
                            Selection.Size = UDim2.fromOffset(0, 24)
                            Selection.ZIndex = ZIndex + 2
                            
                            local Side = Instance.new('Frame')
                            Side.BackgroundColor3 = InterfaceTheme.Primary
                            Side.BorderSizePixel = 0
                            Side.Size = UDim2.fromOffset(2, 24)
                            Side.ZIndex = ZIndex + 2
                            
                            Side.Parent = Selection
                            Selection.Parent = objects.Main
                            objects.Selection = Selection
                        end]]
                        
                        -- objects.Arrow
                        do 
                            local Arrow = Instance.new('ImageLabel')
                            Arrow.AnchorPoint = Vector2.new(1, 0)
                            Arrow.BackgroundTransparency = 1
                            Arrow.Image = 'rbxassetid://10667805858'
                            Arrow.ImageColor3 = Color3.fromRGB(250, 250, 255)
                            Arrow.Position = UDim2.new(1, -5, 0, 5) -- offset = (Header height - icon height) / 2
                            Arrow.Size = UDim2.fromOffset(14, 14)
                            Arrow.ZIndex = ZIndex + 1
                            -- Arrow.Rotation = 180 
                            
                            Arrow.Parent = objects.Main 
                            objects.Arrow = Arrow
                        end
                        
                        -- objects.Container
                        do 
                            local Container = Instance.new('ScrollingFrame')
                            Container.AutomaticSize = 'Y'
                            Container.BackgroundTransparency = 1 
                            Container.BorderSizePixel = 0
                            Container.BottomImage = 'rbxassetid://9416839567'
                            Container.ClipsDescendants = true 
                            Container.MidImage = 'rbxassetid://9416839567'
                            Container.Position = UDim2.fromOffset(0, 24)
                            Container.ScrollBarImageTransparency = 0.4
                            Container.ScrollBarThickness = 0
                            Container.ScrollingEnabled = false 
                            Container.Size = UDim2.new(1, 0, 0, 24)
                            Container.TopImage = 'rbxassetid://9416839567'
                            Container.Visible = false
                            Container.ZIndex = ZIndex
                            
                            local Layout = Instance.new('UIListLayout')
                            Layout.VerticalAlignment = 'Top'
                            Layout.HorizontalAlignment = 'Left'
                            Layout.FillDirection = 'Vertical'
                            Layout.Parent = Container
                            
                            Container.Parent = objects.Main
                            objects.Container = Container 
                            objects.Layout = Layout
                        end
                        
                        -- objects.ToggleSound
                        do 
                            local ToggleSound = Instance.new('Sound')
                            ToggleSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            ToggleSound.SoundId = CustomAssets['Sounds/guiCtrl_Toggle.mp3']
                            
                            ToggleSound.Parent = objects.Main
                            objects.ToggleSound = ToggleSound 
                        end
                        
                        -- objects.OpenSound
                        do 
                            local OpenSound = Instance.new('Sound')
                            OpenSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            OpenSound.PlaybackSpeed = 1.5
                            OpenSound.SoundId = CustomAssets['Sounds/guiCtrl_Menu.mp3']
                            
                            OpenSound.Parent = objects.Main
                            objects.OpenSound = OpenSound 
                        end
                    end
                    
                    --- Events
                    do 
                        objects.ClickSensor.MouseButton1Click:Connect(function() 
                            this:ToggleMenu()
                        end)
                        
                        objects.ClickSensor.MouseButton2Click:Connect(function() 
                            this:ToggleMenu()
                        end)
                        
                    end
                    
                    --- Finalization
                    return this
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLSettingDropdown
        end)()
        UiClasses.RLSettingDropdown = RLSettingDropdown
        
        --- RLDropdownItem : RLBase
        -- The item class for dropdown menus 
        local RLDropdownItem: RLBase = (function() -- src/UiClasses/Settings/RLDropdownitem.lua
            --- RLDropdownItem : RLBase
            -- The item class for dropdown menus 
            local RLDropdownItem: RLBase = {} do 
                --- Setup
                RLDropdownItem.__index = RLDropdownItem
                RLDropdownItem.class = 'RLDropdownItem'
                setmetatable(RLDropdownItem, RLBase)
                
                --- Interaction
                function RLDropdownItem:GetValue() 
                    return self.SelectState
                end
                
                function RLDropdownItem:Select( NoSound: boolean ) 
                    self.SelectState = true
                    
                    self.parent.selection = self.name
                    self.parent:Fire('OnSelection', self.name)
                    
                    for _, obj in ipairs( self.LinkedObjs ) do 
                        local main = obj.objects.Main 
                        
                        main.Visible = true
                    end
                    
                    
                    local objects = self.objects
                    Tween.Quick(objects.Selection, {
                        Size = UDim2.fromScale(1, 1)
                    })
                    
                    if ( NoSound ~= true ) then 
                        objects.SelectSound:Play()
                    end
                                
                    return self
                end
                
                function RLDropdownItem:Deselect(NoSound: boolean) 
                    self.SelectState = false
                    
                    self.parent:Fire('OnDeselection', self.name)
                    for _, obj in ipairs( self.LinkedObjs ) do 
                        local main = obj.objects.Main 
                        
                        main.Visible = false 
                        for _, option in ipairs( obj.LinkedOptions ) do 
                            if ( option:GetState() == true ) then
                                main.Visible = true
                                break  
                            end
                        end
                    end
                    
                    local objects = self.objects
                    Tween.Quick(objects.Selection, {
                        Size = UDim2.fromScale(0, 1)
                    })
                    
                    if ( NoSound ~= true ) then 
                        objects.SelectSound:Play()
                    end
                    
                    return self
                end
                
                RLDropdownItem.Enable = RLDropdownItem.Select
                RLDropdownItem.Disable = RLDropdownItem.Deselect
                
                RLDropdownItem.GetState = RLDropdownItem.GetValue
                RLDropdownItem.IsSelected = RLDropdownItem.GetValue 
                
                RLDropdownItem.SetTooltip = UiClasses.RLModule.SetTooltip
                
                --- Constructor 
                function RLDropdownItem.new(Parent: table, SettingName: string, ZIndex: number)
                    --- Setup
                    local this = RLBase.new()
                    setmetatable(this, RLDropdownItem)
                    table.insert(Parent.children, this)
                    -- properties
                    this.LinkedObjs = {}
                    this.name = SettingName 
                    this.parent = Parent
                    this.zindex = ZIndex 
                    
                    -- states 
                    this.HoverState = false
                    this.SelectState = false 
                    
                    --- Objects
                    local objects = {}
                    do 
                        -- objects.Main
                        do
                            local Main = Instance.new('Frame')
                            Main.AutomaticSize = 'None'
                            Main.BackgroundColor3 = InterfaceTheme.Shade4
                            Main.BorderSizePixel = 0 
                            Main.Size = UDim2.new(1, 0, 0, 24)
                            Main.ZIndex = ZIndex
                            
                            objects.Main = Main
                        end
                        
                        -- objects.Selection
                        do 
                            local Selection = Instance.new('Frame')
                            Selection.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            Selection.BackgroundTransparency = 0.95
                            Selection.BorderSizePixel = 0
                            Selection.ClipsDescendants = true
                            Selection.Size = UDim2.fromOffset(0, 24)
                            Selection.ZIndex = ZIndex + 2
                            
                            local Side = Instance.new('Frame')
                            Side.BackgroundColor3 = InterfaceTheme.Primary
                            Side.BorderSizePixel = 0
                            Side.Size = UDim2.fromOffset(2, 24)
                            Side.ZIndex = ZIndex + 2
                            
                            Side.Parent = Selection
                            Selection.Parent = objects.Main
                            objects.Selection = Selection
                        end
                        
                        -- objects.ClickSensor
                        do 
                            local ClickSensor = Instance.new('TextButton')
                            ClickSensor.AutoButtonColor = false 
                            ClickSensor.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            ClickSensor.BackgroundTransparency = 1
                            ClickSensor.BorderSizePixel = 0
                            ClickSensor.Size = UDim2.new(1, 0, 0, 24)
                            ClickSensor.Text = '' 
                            ClickSensor.TextTransparency = 1 
                            ClickSensor.ZIndex = ZIndex + 1
                            
                            ClickSensor.Parent = objects.Main
                            objects.ClickSensor = ClickSensor
                        end
                        
                        -- objects.Label
                        do 
                            local Label = Instance.new('TextLabel')
                            Label.BackgroundTransparency = 1
                            Label.Font = InterfaceTheme.Font
                            Label.Position = UDim2.fromOffset(11, 0)
                            Label.Size = UDim2.new(1, -11, 0, 24)
                            Label.Text = SettingName 
                            Label.TextColor3 = InterfaceTheme.Text_Shade3
                            Label.TextSize = InterfaceTheme.TextSize - 2 
                            Label.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Label.TextStrokeTransparency = 0.5
                            Label.TextXAlignment = 'Left'
                            Label.TextYAlignment = 'Center'
                            Label.ZIndex = ZIndex + 1
                            
                            Label.Parent = objects.Main
                            objects.Label = Label
                        end
                        
                        -- objects.SelectSound
                        do 
                            local SelectSound = Instance.new('Sound')
                            SelectSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            SelectSound.SoundId = CustomAssets['Sounds/guiCtrl_Toggle.mp3']
                            
                            SelectSound.Parent = objects.Main
                            objects.SelectSound = SelectSound 
                        end
                    end
                    
                    --- Events
                    do 
                        objects.ClickSensor.MouseButton1Click:Connect(function() 
                            if ( this:IsSelected() ) then
                                return
                            end
                            
                            for _, item in ipairs( this.parent.children ) do 
                                if ( item.class == 'RLDropdownItem' and item:IsSelected() ) then
                                    item:Deselect( true ) 
                                end
                            end 
                            
                            this:Select( true )
                        end)
                        
                        objects.ClickSensor.MouseEnter:Connect(function() 
                            this.HoverState = true
                            
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 0.985
                            })
                            Tween.Quick(objects.Label, {
                                Position = UDim2.fromOffset(13, 0),
                                Size = UDim2.new(1, -13, 1, 0)
                            })
                            
                            if ( this.tooltip ) then 
                                instances.Tooltip:Show(this)
                            end
                        end)
                        
                        objects.ClickSensor.MouseLeave:Connect(function() 
                            this.HoverState = false
                            
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 1
                            })
                            Tween.Quick(objects.Label, {
                                Position = UDim2.fromOffset(11, 0),
                                Size = UDim2.new(1, -11, 1, 0)
                            })
                            
                            if ( this.tooltip ) then 
                                instances.Tooltip:Hide(this)
                            end
                        end)
                    end
                    
                    --- Finalization
                    this.objects = objects 
                    return this
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLDropdownItem
        end)()
        UiClasses.RLDropdownItem = RLDropdownItem
        
        --- RLSettingHotkey : RLBaseSetting
        -- A simple keybind selector. Now supports mouse buttons - unbinding is done via the right-click unbind menu
        local RLSettingHotkey: RLBaseSetting = (function() -- src/UiClasses/Settings/RLSettingHotkey.lua
            --- RLSettingHotkey : RLBaseSetting
            -- A simple keybind selector. Now supports mouse buttons - unbinding is done via the right-click unbind menu
            local RLSettingHotkey: RLBaseSetting = {} do 
                --- Setup
                RLSettingHotkey.__index = RLSettingHotkey
                RLSettingHotkey.class = 'RLSettingHotkey'
                setmetatable(RLSettingHotkey, RLBaseSetting)
                
                --- Interaction
                function RLSettingHotkey:Focus() 
                    local time = 0
                    local dots = 0
                    
                    local hotkeyLabel = self.objects.Hotkey
                    local connections = self.connections
                    
                    Tween.Quick(hotkeyLabel, {
                        TextColor3 = InterfaceTheme.Enabled
                    })
                    
                    hotkeyLabel.Text = ' Press any key '
                    
                    --[[connections.idleAnim = runService.Heartbeat:Connect(function(deltaTime) 
                        time += deltaTime 
                        
                        if ( time > 0 ) then
                            time -= 0.2
                            dots += 1
                            
                            local dotCount = (dots % 3) + 1
                            hotkeyLabel.Text = string.format(' Press any key ', string.rep( '.', dotCount ))
                        end
                    end)]]
                    
                    connections.keyRead = inputService.InputBegan:Connect(function(input) 
                        
                        Tween.Quick(hotkeyLabel, {
                            TextColor3 = InterfaceTheme.Text_Shade3
                        })
                        
                        self:SetHotkeyInternal( input.KeyCode, input.UserInputType )
                        
                        --connections.keyRead:Disconnect()
                    end)
                end
                
                function RLSettingHotkey:SetHotkeyInternal( keyCode: KeyCode, inputType: UserInputType ) 
                    -- disconnect the input getter connection
                    local keyRead = self.connections.keyRead
                    if ( keyRead and keyRead.Connected ) then
                        keyRead:Disconnect()    
                    end
                    
                    -- localize hotkey label since it'll be modified frequently
                    local hotkeyLabel = self.objects.Hotkey
                    
                    -- check for an existing bind, unbind it if one exists
                    if ( self.CurrentHotkey ) then
                        local index = table.find(hotkeys, self.CurrentHotkey)
                        
                        if ( index ) then
                            table.remove(hotkeys, index)
                        end
                    end
                    
                    local newHotkey = {} -- the hotkey object storing info about the hotkey
                    local finalBindValue -- the final value that'll be displayed
                    
                    -- check the input type 
                    if ( inputType.Name == 'Keyboard' ) then
                        -- a key is being bound, make sure that it's valid 
                        if ( keyCode.Name ~= 'Unknown' and keyCode.Name ~= 'Escape' ) then 
                            -- if it is then set the bind to this key 
                            newHotkey.key = keyCode
                            finalBindValue = keyCode.Name 
                        end
                    else
                        -- if its not a keyboard input its likely some type of mouse input, make sure that it's valid
                        if ( inputType.Name ~= 'None' ) then 
                            newHotkey.input = inputType
                            finalBindValue = inputType.Name 
                        end
                    end
                     
                    if ( finalBindValue ) then 
                        -- since hotkeys can both be bound to modules or be standalone just for getting an input
                        -- to support both, check for an existing linked control
                        if ( self.LinkedInstance ) then 
                            -- if there is one, set parameters for it and insert it into the hotkeys list 
                            -- .callback and .parent let a pseudo namecall thing be done instead of making a new function every time like beta redline
                            newHotkey.callback = self.LinkedFunction 
                            newHotkey.parent = self.LinkedInstance
                            newHotkey.set = time() -- time is more precise than os.time(), but less precise than tick() (which is needed for this to even work)
                            
                            table.insert(hotkeys, newHotkey)
                            self.CurrentHotkey = newHotkey
                        else
                            -- since this is a standalone hotkey nothing has to be done 
                        end
                        
                        -- set the label text
                        hotkeyLabel.Text = string.format(' %s ', finalBindValue) 
                        -- set the current hotkey 
                        self.CurrentHotkey = newHotkey
                        
                        self:Fire('OnBind', newHotkey.key or newHotkey.input, finalBindValue)
                    else
                        -- there is no bind, set text to none and remove the hotkey 
                        hotkeyLabel.Text = ' None '
                        
                        self:Fire('OnBind', nil)
                        self.CurrentHotkey = nil
                    end
                
                    return self
                end
                
                function RLSettingHotkey:SetHotkey( newKey: any ) 
                    local inputType, keyCode 
                    
                    -- if the input is a string (ex 'MouseButton1', 'RightShift') convert it into an enum
                    if ( typeof(newKey) == 'string' ) then
                        -- this is so fucking cringe
                        for _, kc in ipairs( Enum.KeyCode:GetEnumItems() ) do 
                            if ( newKey == kc.Name ) then
                                keyCode = kc
                                break
                            end
                        end
                        
                        if ( keyCode ) then
                            inputType = Enum.UserInputType.Keyboard
                        else 
                            for _, it in ipairs( Enum.UserInputType:GetEnumItems() ) do 
                                if ( newKey == it.Name ) then
                                    inputType = it
                                    break
                                end
                            end
                        end
                    else
                        if ( typeof(newKey) == 'EnumItem' ) then
                            if ( newKey.EnumType == Enum.KeyCode ) then
                                keyCode = newKey
                                inputType = Enum.UserInputType.Keyboard
                            elseif ( newKey.EnumType == Enum.UserInputType ) then
                                inputType = newKey
                            end
                        end
                    end
                    
                    keyCode = keyCode or Enum.KeyCode.Unknown
                    inputType = inputType or Enum.UserInputType.None
                                
                    -- and call SetHotkeyInternal to save extra space
                    return self:SetHotkeyInternal( keyCode, inputType )
                end
                
                function RLSettingHotkey:GetHotkey() 
                    local hotkeyInfo = self.CurrentHotkey 
                    
                    return hotkeyInfo.key or hotkeyInfo.input
                end
                
                function RLSettingHotkey:MakeLink( Module: RLModule, Func: string ) 
                    self.LinkedInstance = Module
                    self.LinkedFunction = Module[Func]
                    
                    return self 
                end
                
                function RLSettingHotkey:RemoveLink() 
                    self.LinkedInstance = nil
                    self.LinkedFunction = nil
                    
                    return self 
                end
                
                function RLSettingHotkey:MatchesInput( input: InputObject ) 
                    local hotkey = self.CurrentHotkey
                    if ( hotkey ) then
                        if ( hotkey.input == input.UserInputType ) then
                            return true
                            
                        elseif ( hotkey.key == input.KeyCode ) then
                            return true
                        end 
                        
                    else
                        return false 
                    end
                    
                    return false 
                end
                
                function RLSettingHotkey:IsInputPressed()
                    local hotkey = self.CurrentHotkey 
                    if ( hotkey ) then
                        if ( hotkey.key ) then
                            return inputService:IsKeyDown( hotkey.key ) 
                            
                        elseif ( hotkey.input ) then
                            return inputService:IsMouseButtonPressed( hotkey.input ) 
                        end
                    else
                        return false
                    end
                    
                    return false 
                end
                
                
                function RLSettingHotkey:OpenUnbindPrompt() 
                    if ( self.PromptStatus == true ) then
                        return self
                    end
                    
                    self.PromptStatus = true 
                    
                    local objects = self.objects 
                    local dimmer = objects.Dimmer 
                    local prompt = objects.ResetPrompt 
                    
                    prompt.MaxVisibleGraphemes = 0
                    Tween.Quick(prompt, {
                        MaxVisibleGraphemes = #prompt.Text
                    })
                    
                    dimmer.Position = UDim2.fromScale(0, -1)
                    dimmer.Visible = true
                    Tween.Quick(dimmer, {
                        Position = UDim2.fromScale()
                    })
                    
                    return self
                end
                
                function RLSettingHotkey:CloseUnbindPrompt() 
                    if ( self.PromptStatus == false ) then
                        return self
                    end
                    
                    self.PromptStatus = false 
                    
                    local objects = self.objects 
                    local dimmer = objects.Dimmer 
                    local prompt = objects.ResetPrompt 
                    
                    Tween.Quick(prompt, {
                        MaxVisibleGraphemes = 0
                    })
                    
                    dimmer.Position = UDim2.fromScale()
                    dimmer.Visible = true
                    
                    task.spawn(function()
                        Tween.Quick(dimmer, {
                            Position = UDim2.fromScale(0, -1)
                        }).Completed:Wait()
                        
                        dimmer.Visible = false
                    end)
                    
                    return self
                end
                
                RLSettingHotkey.GetValue = RLSettingHotkey.GetHotkey
                RLSettingHotkey.GetBind = RLSettingHotkey.GetHotkey
                RLSettingHotkey.SetValue = RLSettingHotkey.SetHotkey 
                
                RLSettingHotkey.ValidateInput = RLSettingHotkey.MatchesInput
                RLSettingHotkey.CheckInput = RLSettingHotkey.MatchesInput
                
                RLSettingHotkey.IsInputDown = RLSettingHotkey.IsInputPressed
                
                --- Constructor
                function RLSettingHotkey.new( Parent: table, SettingName: string, ZIndex: number ) 
                    --- Setup
                    local this = RLBaseSetting.new( Parent, SettingName, ZIndex )
                    setmetatable( this, RLSettingHotkey )
                    -- Properties
                    this.connections = {}
                    
                    this.PromptStatus = false 
                    
                    --- Objects
                    local objects = this.objects
                    do 
                        objects.Main.ClipsDescendants = true 
                        
                        -- objects.Hotkey
                        do 
                            local Hotkey = Instance.new('TextLabel')
                            Hotkey.AnchorPoint = Vector2.new(1, 0)
                            Hotkey.AutomaticSize = 'X'
                            Hotkey.BackgroundColor3 = InterfaceTheme.Shade1
                            Hotkey.BorderColor3 = InterfaceTheme.Outline
                            Hotkey.BorderSizePixel = 1
                            Hotkey.Font = InterfaceTheme.Font
                            Hotkey.Position = UDim2.new(1, -5, 0, 5) 
                            Hotkey.Size = UDim2.fromOffset(30, 14)
                            Hotkey.Text = ' None '
                            Hotkey.TextColor3 = InterfaceTheme.Text_Shade3
                            Hotkey.TextSize = InterfaceTheme.TextSize - 2 
                            Hotkey.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Hotkey.TextStrokeTransparency = 0.5
                            Hotkey.TextXAlignment = 'Center'
                            Hotkey.TextYAlignment = 'Center'
                            Hotkey.Visible = true
                            Hotkey.ZIndex = ZIndex
                            
                            Hotkey.Parent = objects.Main
                            objects.Hotkey = Hotkey
                        end
                        
                        -- objects.Dimmer
                        do 
                            local Dimmer = Instance.new('Frame')
                            Dimmer.BackgroundColor3 = InterfaceTheme.Shade3
                            Dimmer.BackgroundTransparency = 0.3 
                            Dimmer.BorderSizePixel = 0
                            Dimmer.Position = UDim2.fromScale(0, 0)
                            Dimmer.Size = UDim2.fromScale(1, 1)
                            Dimmer.Visible = false 
                            Dimmer.ZIndex = ZIndex + 1
                            
                            Dimmer.Parent = objects.Main
                            objects.Dimmer = Dimmer 
                        end
                        
                        -- objects.ToggleSound
                        do 
                            local ToggleSound = Instance.new('Sound')
                            ToggleSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            ToggleSound.SoundId = CustomAssets['Sounds/guiCtrl_Toggle.mp3']
                            
                            ToggleSound.Parent = objects.Dimmer -- epically reuse the same toggle sound 😎
                            objects.ToggleSound = ToggleSound 
                        end
                        
                        -- objects.OpenSound
                        do 
                            local OpenSound = Instance.new('Sound')
                            OpenSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                            OpenSound.PlaybackSpeed = 1.5
                            OpenSound.SoundId = CustomAssets['Sounds/guiCtrl_Menu.mp3']
                            
                            OpenSound.Parent = objects.Dimmer
                            objects.OpenSound = OpenSound 
                        end
                        
                        -- objects.ResetPrompt
                        do 
                            local ResetPrompt = Instance.new('TextLabel')
                            ResetPrompt.BackgroundTransparency = 1
                            ResetPrompt.Font = InterfaceTheme.Font
                            ResetPrompt.Position = UDim2.fromOffset(8, 0)
                            ResetPrompt.Size = UDim2.fromOffset(60, 24)
                            ResetPrompt.Text = 'Reset this bind?'
                            ResetPrompt.TextColor3 = InterfaceTheme.Text_Shade3
                            ResetPrompt.TextSize = InterfaceTheme.TextSize - 2 
                            ResetPrompt.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            ResetPrompt.TextStrokeTransparency = 0.5
                            ResetPrompt.TextXAlignment = 'Left'
                            ResetPrompt.TextYAlignment = 'Center'
                            ResetPrompt.Visible = true 
                            ResetPrompt.ZIndex = ZIndex + 1 
                            
                            ResetPrompt.Parent = objects.Dimmer
                            objects.ResetPrompt = ResetPrompt
                        end      
                             
                        -- objects.ResetButton 
                        do 
                            local ResetButton = Instance.new('TextButton')
                            ResetButton.AnchorPoint = Vector2.new(1, 0)
                            ResetButton.AutoButtonColor = false 
                            ResetButton.BackgroundColor3 = InterfaceTheme.Shade1
                            ResetButton.BorderColor3 = InterfaceTheme.Outline
                            ResetButton.BorderSizePixel = 1
                            ResetButton.Font = InterfaceTheme.Font
                            ResetButton.Position = UDim2.new(1, -50, 0, 5) 
                            ResetButton.Size = UDim2.fromOffset(40, 14)
                            ResetButton.Text = 'Yes'
                            ResetButton.TextColor3 = InterfaceTheme.Text_Shade3
                            ResetButton.TextSize = InterfaceTheme.TextSize - 2 
                            ResetButton.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            ResetButton.TextStrokeTransparency = 0.5
                            ResetButton.TextXAlignment = 'Center'
                            ResetButton.TextYAlignment = 'Center'
                            ResetButton.Visible = true
                            ResetButton.ZIndex = ZIndex + 1 
                            
                            ResetButton.Parent = objects.Dimmer
                            objects.ResetButton = ResetButton
                        end
                        
                        -- objects.ResetButtonHover
                        do 
                            local Hover = Instance.new('Frame')
                            Hover.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            Hover.BackgroundTransparency = 1
                            Hover.BorderSizePixel = 0
                            Hover.Size = UDim2.fromScale(1, 1)
                            Hover.ZIndex = ZIndex + 1  
                            
                            Hover.Parent = objects.ResetButton
                            objects.ResetButtonHover = Hover
                        end
                        
                        -- objects.CancelButton 
                        do 
                            local CancelButton = Instance.new('TextButton')
                            CancelButton.AnchorPoint = Vector2.new(1, 0)
                            CancelButton.AutoButtonColor = false 
                            CancelButton.BackgroundColor3 = InterfaceTheme.Shade1
                            CancelButton.BorderColor3 = InterfaceTheme.Outline
                            CancelButton.BorderSizePixel = 1
                            CancelButton.Font = InterfaceTheme.Font
                            CancelButton.Position = UDim2.new(1, -5, 0, 5) 
                            CancelButton.Size = UDim2.fromOffset(40, 14)
                            CancelButton.Text = 'No'
                            CancelButton.TextColor3 = InterfaceTheme.Text_Shade3
                            CancelButton.TextSize = InterfaceTheme.TextSize - 2 
                            CancelButton.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            CancelButton.TextStrokeTransparency = 0.5
                            CancelButton.TextXAlignment = 'Center'
                            CancelButton.TextYAlignment = 'Center'
                            CancelButton.Visible = true
                            CancelButton.ZIndex = ZIndex + 1 
                            
                            CancelButton.Parent = objects.Dimmer
                            objects.CancelButton = CancelButton
                        end
                        
                        -- objects.CancelButtonHover
                        do 
                            local Hover = Instance.new('Frame')
                            Hover.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            Hover.BackgroundTransparency = 1
                            Hover.BorderSizePixel = 0
                            Hover.Size = UDim2.fromScale(1, 1)
                            Hover.ZIndex = ZIndex + 1  
                            
                            Hover.Parent = objects.CancelButton
                            objects.CancelButtonHover = Hover
                        end
                    end
                    
                    --- Events
                    do 
                        objects.ClickSensor.MouseButton1Click:Connect(function() 
                            if ( this.PromptStatus ) then 
                                return
                            end 
                            
                            this:Focus()
                        end)
                        
                        objects.ClickSensor.MouseButton2Click:Connect(function() 
                            objects.OpenSound:Play()
                            
                            this:OpenUnbindPrompt()
                        end)
                        
                        objects.CancelButton.MouseEnter:Connect(function() 
                            Tween.Quick(objects.CancelButtonHover, {
                                BackgroundTransparency = 0.985
                            })
                        end)
                        
                        objects.CancelButton.MouseLeave:Connect(function() 
                            Tween.Quick(objects.CancelButtonHover, {
                                BackgroundTransparency = 1
                            })
                        end)
                        
                        objects.ResetButton.MouseButton1Click:Connect(function() 
                            objects.ToggleSound:Play()
                            
                            this:SetHotkey(nil)
                            this:CloseUnbindPrompt()
                        end)
                        
                        objects.CancelButton.MouseButton1Click:Connect(function() 
                            objects.ToggleSound:Play()
                            
                            this:CloseUnbindPrompt()
                        end)
                        
                        objects.ResetButton.MouseEnter:Connect(function() 
                            Tween.Quick(objects.ResetButtonHover, {
                                BackgroundTransparency = 0.985
                            })
                        end)
                        
                        objects.ResetButton.MouseLeave:Connect(function() 
                            Tween.Quick(objects.ResetButtonHover, {
                                BackgroundTransparency = 1
                            })
                        end)
                    end
                    
                    --- Finalization 
                    return this 
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLSettingHotkey
        end)()
        UiClasses.RLSettingHotkey = RLSettingHotkey
        
        --- RLSettingCarousel : RLBaseSetting
        -- A "wheel" / "carousel" that you can rotate to choose an option. Kinda like a dropdown, but more compact
        local RLSettingCarousel: RLBaseSetting = (function() -- src/UiClasses/Settings/RLSettingCarousel.lua
            --- RLSettingCarousel : RLBaseSetting
            -- A "wheel" / "carousel" that you can rotate to choose an option. Kinda like a dropdown, but more compact
            local RLSettingCarousel: RLBaseSetting = {} do 
                --- Setup
                RLSettingCarousel.__index = RLSettingCarousel
                RLSettingCarousel.class = 'RLSettingCarousel'
                setmetatable(RLSettingCarousel, RLBaseSetting)
                
                --- Interaction
                function RLSettingCarousel:RotateLeft() 
                    local children = self.children
                    local curIndex = self.ItemIndex -- get currently selected index 
                    local newIndex = curIndex - 1 -- subtract 1; this shifts it to the left 
                    
                    if ( newIndex < 1 ) then -- check if the index is 0, and wrap it around 
                        newIndex = #children
                    end
                    
                    children[curIndex]:Deselect() -- deselect the previous child 
                    
                    self.ItemIndex = newIndex -- set index 
                    
                    children[newIndex]:Select() -- select the new child
                end
                
                function RLSettingCarousel:RotateRight() 
                    local children = self.children
                    local curIndex = self.ItemIndex
                    local newIndex = curIndex + 1
                    
                    children[curIndex]:Deselect()
                    
                    if ( newIndex > #children ) then
                        newIndex = 1
                    end
                    
                    self.ItemIndex = newIndex
                    
                    children[newIndex]:Select()
                end
                
                function RLSettingCarousel:SelectOption( optionName: string ) 
                    local children = self.children
                    
                    -- get the index of the new option 
                    local index
                    for idx, c in ipairs( children ) do 
                        if ( c.name == optionName ) then
                            index = idx 
                            break 
                        end
                    end
                    
                    -- if it couldnt be found, cancel selection 
                    if ( not index ) then
                        return
                    end
                    
                    -- get current selection, disable it if it's active
                    local currentChild = children[self.ItemIndex]
                    if ( currentChild:IsSelected() ) then 
                        currentChild:Deselect()
                    end
                    
                    self.ItemIndex = index
                    
                    -- select the new option 
                    children[index]:Select()
                end
                
                function RLSettingCarousel:Reposition() -- repositions all carousel items  
                    local newIndex = self.ItemIndex
                    local children = self.children
                    local childCount = #children
                    
                    for idx, c in ipairs( children ) do 
                        local label = c.objects.Label 
                        
                        local delta = idx - newIndex
                        
                        -- i love math!!!!
                        -- ((delta + (childCount / 2)) % childCount - (childCount / 2))
                        -- 2, 6: (5 % 3)
                        -- (delta % childCount) - math.floor(childCount / 2)
                        -- 2, 6: (2 % 6) - 3
                        local dest = ((delta + (childCount / 2)) % childCount - (childCount / 2))
                        
                        if ( math.abs(dest) > 1 or ( c.posIndex < -1 )) then
                            Tween.Linear(label, { -- as retarded as this is its needed to stop the currently playing tween
                                Position = UDim2.fromScale(dest, 0)
                            }, 0)
                        else
                            Tween.Quick(label, {
                                Position = UDim2.fromScale(dest, 0)
                            })
                        end
                        
                        c.posIndex = dest 
                    end
                end
                
                RLSettingCarousel.GetValue = UiClasses.RLSettingDropdown.GetValue
                RLSettingCarousel.GetSelection = UiClasses.RLSettingDropdown.GetValue 
                RLSettingCarousel.GetOption = UiClasses.RLSettingDropdown.GetOption
                
                --- Element
                function RLSettingCarousel:AddOption( OptionName: string ) 
                    local this = UiClasses.RLCarouselItem.new( self, OptionName, self.zindex + 1 )
                    
                    local childCount = #self.children
                    this.index = childCount
                    
                    local dest = (((childCount - 1) + (childCount / 2)) % childCount - (childCount / 2))
                    this.posIndex = dest 
                    local main = this.objects.Label
                    main.Position = UDim2.fromScale( dest )
                    main.Parent = self.objects.Container 
                    
                    return this
                end
                
                --- Constructor
                function RLSettingCarousel.new( Parent: table, SettingName: string, ZIndex: number ) 
                    --- Setup
                    local this = RLBaseSetting.new( Parent, SettingName, ZIndex )
                    setmetatable( this, RLSettingCarousel )
                    -- states 
                    this.HoverState = false 
                    -- properties
                    this.ItemIndex = 1
                    
                    --- Objects
                    local objects = this.objects
                    do 
                        objects.Label.ZIndex = ZIndex + 2 
                        objects.ClickSensor.ZIndex = ZIndex 
                        
                        -- objects.Container 
                        do 
                            local Container = Instance.new('Frame')
                            Container.Size = UDim2.new(1, 0, 0, 24)
                            Container.BackgroundTransparency = 1 
                            
                            Container.Parent = objects.Main 
                            objects.Container = Container 
                        end
                        
                        -- objects.Dimmer
                        do 
                            local Dimmer = Instance.new('Frame')
                            Dimmer.BackgroundColor3 = InterfaceTheme.Shade3
                            Dimmer.BackgroundTransparency = 0.3 
                            Dimmer.BorderSizePixel = 0
                            Dimmer.Size = UDim2.new(1, 0, 0, 24)
                            Dimmer.Visible = true 
                            Dimmer.ZIndex = ZIndex + 1
                            
                            Dimmer.Parent = objects.Main
                            objects.Dimmer = Dimmer 
                        end
                        
                        -- objects.LeftSensor
                        do 
                            local LeftSensor = Instance.new('TextButton')
                            LeftSensor.AutoButtonColor = false 
                            LeftSensor.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            LeftSensor.BackgroundTransparency = 1
                            LeftSensor.BorderSizePixel = 0
                            LeftSensor.Size = UDim2.new(0.5, 0, 0, 24)
                            LeftSensor.Text = '' 
                            LeftSensor.TextTransparency = 1 
                            LeftSensor.ZIndex = ZIndex
                            
                            LeftSensor.Parent = objects.Main
                            objects.LeftSensor = LeftSensor
                        end
                        
                        -- objects.RightSensor
                        do 
                            local RightSensor = Instance.new('TextButton')
                            RightSensor.AutoButtonColor = false 
                            RightSensor.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                            RightSensor.BackgroundTransparency = 1
                            RightSensor.BorderSizePixel = 0
                            RightSensor.Position = UDim2.fromScale(0.5, 0)
                            RightSensor.Size = UDim2.new(0.5, 0, 0, 24)
                            RightSensor.Text = '' 
                            RightSensor.TextTransparency = 1 
                            RightSensor.ZIndex = ZIndex
                            
                            RightSensor.Parent = objects.Main
                            objects.RightSensor = RightSensor
                        end
                        
                        -- objects.LeftArrow
                        do 
                            local LeftArrow = Instance.new('ImageLabel')
                            LeftArrow.AnchorPoint = Vector2.new(0, 0)
                            LeftArrow.BackgroundTransparency = 1
                            LeftArrow.Image = 'rbxassetid://10771256737'
                            LeftArrow.ImageColor3 = Color3.fromRGB(250, 250, 255)
                            LeftArrow.ImageTransparency = 0.5
                            LeftArrow.Position = UDim2.fromOffset(10, 5)
                            LeftArrow.ResampleMode = 'Pixelated'
                            LeftArrow.Rotation = 90
                            LeftArrow.Size = UDim2.fromOffset(14, 14)
                            LeftArrow.ZIndex = ZIndex 
                            
                            LeftArrow.Parent = objects.LeftSensor 
                            objects.LeftArrow = LeftArrow
                        end
                        
                        -- objects.RightArrow
                        do 
                            local RightArrow = Instance.new('ImageLabel')
                            RightArrow.AnchorPoint = Vector2.new(1, 0)
                            RightArrow.BackgroundTransparency = 1
                            RightArrow.Image = 'rbxassetid://10771256737'
                            RightArrow.ImageColor3 = Color3.fromRGB(250, 250, 255)
                            RightArrow.ImageTransparency = 0.5
                            RightArrow.Position = UDim2.new(1, -10, 0, 5)
                            RightArrow.ResampleMode = 'Pixelated'
                            RightArrow.Rotation = -90
                            RightArrow.Size = UDim2.fromOffset(14, 14)
                            RightArrow.ZIndex = ZIndex 
                            
                            RightArrow.Parent = objects.RightSensor 
                            objects.RightArrow = RightArrow
                        end
                    end
                    
                    --- Events
                    do 
                        objects.ClickSensor.MouseEnter:Connect(function() 
                            this.HoverState = true
                            
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 0.985
                            })
                            Tween.Quick(objects.Dimmer, {
                                BackgroundTransparency = 1
                            })
                            
                            Tween.Quick(objects.Label, {
                                TextTransparency = 1,
                                TextStrokeTransparency = 1,
                                Position = UDim2.fromOffset(10, 0),
                                Size = UDim2.new(1, -10, 1, 0)
                            })
                            
                            if ( this.tooltip ) then 
                                instances.Tooltip:Show(this)
                            end
                        end)
                        
                        objects.ClickSensor.MouseLeave:Connect(function() 
                            this.HoverState = false
                            
                            Tween.Quick(objects.ClickSensor, {
                                BackgroundTransparency = 1
                            })
                            Tween.Quick(objects.Dimmer, {
                                BackgroundTransparency = 0.3
                            })
                            
                            Tween.Quick(objects.Label, {
                                TextTransparency = 0,
                                TextStrokeTransparency = 0.5,
                                Position = UDim2.fromOffset(8, 0),
                                Size = UDim2.new(1, -8, 1, 0)
                            })
                            
                            if ( this.tooltip ) then 
                                instances.Tooltip:Hide(this)
                            end
                        end)
                        
                        objects.LeftSensor.MouseEnter:Connect(function() 
                            Tween.Quick(objects.LeftArrow, {
                                ImageTransparency = 0
                            })
                        end)
                        
                        objects.RightSensor.MouseEnter:Connect(function() 
                            Tween.Quick(objects.RightArrow, {
                                ImageTransparency = 0
                            })
                        end)
                        
                        objects.LeftSensor.MouseLeave:Connect(function() 
                            Tween.Quick(objects.LeftArrow, {
                                ImageTransparency = 0.5
                            })
                        end)
                        
                        objects.RightSensor.MouseLeave:Connect(function() 
                            Tween.Quick(objects.RightArrow, {
                                ImageTransparency = 0.5
                            })
                        end)
                        
                        objects.LeftSensor.MouseButton1Click:Connect(function() 
                            this:RotateLeft() 
                        end)
                        objects.RightSensor.MouseButton1Click:Connect(function() 
                            this:RotateRight() 
                        end)
                    end
                    
                    --- Finalization 
                    return this 
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLSettingCarousel
        end)()
        UiClasses.RLSettingCarousel = RLSettingCarousel
        
        --- RLCarouselItem : RLBase
        -- The item class for carousel menus 
        local RLCarouselItem: RLBase = (function() -- src/UiClasses/Settings/RLCarouselItem.lua
            --- RLCarouselItem : RLBase
            -- The item class for carousel menus 
            local RLCarouselItem: RLBase = {} do 
                --- Setup
                RLCarouselItem.__index = RLCarouselItem
                RLCarouselItem.class = 'RLCarouselItem'
                setmetatable(RLCarouselItem, RLBase)
                
                --- Interaction
                function RLCarouselItem:GetValue() 
                    return self.SelectState
                end
                
                function RLCarouselItem:Select( NoSound: boolean ) 
                    self.SelectState = true
                    
                    local parent = self.parent
                    
                    parent.ItemIndex = self.index 
                    parent.selection = self.name
                    parent:Fire('OnSelection', self.name)
                    parent:Reposition()
                    
                    for _, obj in ipairs( self.LinkedObjs ) do 
                        local main = obj.objects.Main 
                        
                        main.Visible = true
                    end
                    
                    return self
                end
                
                function RLCarouselItem:Deselect( NoSound: boolean ) 
                    self.SelectState = false
                    
                    self.parent:Fire('OnDeselection', self.name)
                    for _, obj in ipairs( self.LinkedObjs ) do 
                        local main = obj.objects.Main 
                        
                        main.Visible = false 
                        for _, option in ipairs( obj.LinkedOptions ) do 
                            if ( option:GetState() == true ) then
                                main.Visible = true
                                break  
                            end
                        end
                    end
                    
                    return self
                end
                
                RLCarouselItem.Enable = RLCarouselItem.Select
                RLCarouselItem.Disable = RLCarouselItem.Deselect
                
                RLCarouselItem.GetState = RLCarouselItem.GetValue
                RLCarouselItem.IsSelected = RLCarouselItem.GetValue 
                
                RLCarouselItem.SetTooltip = UiClasses.RLModule.SetTooltip
                
                --- Constructor 
                function RLCarouselItem.new( Parent: table, SettingName: string, ZIndex: number )
                    --- Setup
                    local this = RLBase.new()
                    setmetatable(this, RLCarouselItem)
                    table.insert(Parent.children, this)
                    -- properties
                    this.LinkedObjs = {}
                    this.name = SettingName 
                    this.parent = Parent
                    this.zindex = ZIndex 
                    
                    -- states 
                    this.SelectState = false 
                    
                    --- Objects
                    local objects = {}
                    do 
                        
                        -- objects.Label
                        do 
                            local Label = Instance.new('TextLabel')
                            Label.BackgroundTransparency = 1
                            Label.Font = InterfaceTheme.Font
                            Label.Size = UDim2.fromScale(1, 1)
                            Label.Text = SettingName 
                            Label.TextColor3 = InterfaceTheme.Text_Shade3
                            Label.TextSize = InterfaceTheme.TextSize - 2 
                            Label.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                            Label.TextStrokeTransparency = 0.5
                            Label.TextXAlignment = 'Center'
                            Label.TextYAlignment = 'Center'
                            Label.ZIndex = ZIndex
                            
                            Label.Parent = objects.Main
                            objects.Label = Label
                        end
                    end
                    
                    --- Finalization
                    this.objects = objects 
                    return this
                end
                
                --- Destructor
                -- Inherited from RLBase
            end
            
            return RLCarouselItem
        end)()
        UiClasses.RLCarouselItem = RLCarouselItem
        
        --- RLSettingTextbox
        -- A simple input box
        
        --- RLSettingGraph
        -- A 2 dimensional "slider" that outputs an X and Y
        
        --- RLSettingPicker
        -- A standard color picker that supports chroma cycling
        
        
        --- RLSettingOptionslider
        -- Come up with a better name
        -- Dropdown + slider combination, look at apple photos year/month/day slider for an example.
        -- A slider, but divided into several dropdown options.
        
        ---- Experimental settings
        
        --- RLSettingRange: RLBaseSetting 
        -- A one dimension slider that lets you choose a range of numbers clamped from A to B
        -- Idea from v3rm thread 1185256
            
        --- RLSettingMultiDropdown?
        -- A dropdown menu letting you select multiple items from the list 
        
        --- RLSettingRangeGraph? 
        -- RLSettingRange but 2 dimensional
        
        --- RLInterface: RLBase
        -- Main ui class; provides an abstract interface for creating stuff like tabs, modules, etc.
        local RLInterface: RLBase = {} do 
            --- Setup
            RLInterface.__index = RLInterface
            RLInterface.class = 'RLInterface'
            setmetatable(RLInterface, RLBase)
            
            --- Interaction (functions that interact with this class)
            
            --- Element (functions that create / work with elements that are based off of this class) 
            
            --- Constructor 
            function RLInterface.new() 
                --- Setup
                local this = RLBase.new()
                setmetatable(this, RLInterface)
            
                --- Objects
            
                --- Events
                
                --- Finalization
                return this
            end
        end
        UiClasses.RLInterface = RLInterface 
    end
    
    --- Initial building
    do
        -- instances.ScreenGui
        do 
            local ScreenGui = Instance.new('ScreenGui')
            ScreenGui.Name = RLGlobals.Identifier:rep(2)
            ScreenGui.ZIndexBehavior = 'Global'
            ScreenGui.IgnoreGuiInset = true 
            ScreenGui.DisplayOrder = 9e6 + 1
            
            ScreenGui.Parent = game.CoreGui 
            instances.ScreenGui = ScreenGui
        end
    
        -- instances.Clip
        do 
            local Clip = Instance.new('Frame')
            Clip.ClipsDescendants = true
            Clip.Size = UDim2.fromScale(1, 0)
            Clip.BackgroundTransparency = 1
            Clip.Name = 'Clip'
            Clip.ZIndex = 0
            
            Clip.Parent = instances.ScreenGui
            instances.Clip = Clip
        end
    
        -- instances.Main
        do 
            local Main = Instance.new('Frame')
            Main.Size = UDim2.fromOffset(RLGlobals.Resolution.X, RLGlobals.Resolution.Y)
            Main.BackgroundTransparency = 0.3
            Main.BackgroundColor3 = InterfaceTheme.Window
            Main.ZIndex = 1 
            
            Main.Parent = instances.Clip
            instances.Main = Main 
        end
    
        -- instances.TabContainer
        do 
            local TabContainer = Instance.new('Frame')
            TabContainer.AnchorPoint = Vector2.new(0.5, 0)
            TabContainer.AutomaticSize = 'X'
            TabContainer.BackgroundColor3 = InterfaceTheme.Shade1
            TabContainer.BorderSizePixel = 0
            TabContainer.Position = UDim2.new(0.5, 0, 0, -36)
            TabContainer.Size = UDim2.new(0.1, 0, 0, 36)
            TabContainer.ZIndex = 300
            
            if ( ActiveConfig.Interface.TabbarStyle == 'Long' ) then
                TabContainer.AutomaticSize = 'None'
                TabContainer.Size = UDim2.new(1, 0, 0, 36)
            end
            
            
            local Layout = Instance.new('UIListLayout')
            Layout.FillDirection = 'Horizontal'
            Layout.HorizontalAlignment = 'Center'
            Layout.VerticalAlignment = 'Top'
            Layout.Parent = TabContainer
            
            local Stroke = Instance.new('UIStroke')
            Stroke.Color = InterfaceTheme.Outline
            Stroke.Thickness = 1
            Stroke.Parent = TabContainer
            
            TabContainer.Parent = instances.Main
            instances.TabContainer = TabContainer
        end
    
        -- instances.Emblem
        do 
            local Emblem = Instance.new('Frame')
            Emblem.BackgroundTransparency = 1
            Emblem.Position = UDim2.new(0, 20, -0.1, 0)
            Emblem.Size = UDim2.fromScale(0.1, 0.07)
            Emblem.ZIndex = 2
                    
            local Ratio = Instance.new('UIAspectRatioConstraint')
            Ratio.AspectRatio = 3
            Ratio.AspectType = 'FitWithinMaxSize'
            Ratio.DominantAxis = 'Width'
            Ratio.Parent = Emblem
            
            local Prism = Instance.new('ImageLabel')
            Prism.BackgroundTransparency = 1
            Prism.Image = CustomAssets['Images/emblem_Prism.png']
            Prism.ScaleType = 'Fit'
            Prism.Size = UDim2.fromScale(0.33, 0.33)
            Prism.SizeConstraint = 'RelativeXX'
            Prism.ZIndex = 2
            Prism.Parent = Emblem
            
            local Text = Instance.new('ImageLabel')
            Text.BackgroundTransparency = 1
            Text.Image = CustomAssets['Images/emblem_Text.png']
            Text.Position = UDim2.fromScale(0.33, 0)
            Text.ScaleType = 'Fit'
            Text.Size = UDim2.fromScale(0.66, 0.33)
            Text.SizeConstraint = 'RelativeXX'
            Text.ZIndex = 2
            Text.Parent = Emblem
            
            local PrismGradient = Instance.new('UIGradient')
            PrismGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, InterfaceTheme.Primary),
                ColorSequenceKeypoint.new(1, InterfaceTheme.Secondary)
            })
            PrismGradient.Parent = Prism
            
            local TextGradient = Instance.new('UIGradient')
            TextGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1.0, 1.0, 1.0)),
                ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 0.7))
            })
            TextGradient.Parent = Text
            
            Emblem.Parent = instances.Main
            instances.Emblem = Emblem 
        end
        
        -- instances.Shutdown
        do 
            local Shutdown = Instance.new('Sound')
            Shutdown.Volume = 1 -- not an "extra" sound
            Shutdown.SoundId = CustomAssets['Sounds/main_Shutdown.mp3']
            
            Shutdown.Parent = instances.ScreenGui
            instances.Shutdown = Shutdown 
        end
        
        -- instances.Slide
        do 
            local Slide = Instance.new('Sound')
            Slide.Volume = ActiveConfig.Interface.FeedbackSounds and 4 or 0
            Slide.SoundId = CustomAssets['Sounds/main_Open.mp3']
            
            Slide.Parent = instances.ScreenGui
            instances.Slide = Slide 
        end
        
        -- instances.Tooltip 
        do 
            instances.Tooltip = UiClasses.RLTooltip.new()
        end
    end
    
    --- UI 
    ui = UiClasses.RLBase.new() do 
        --- Properties
        -- Class properties
        ui.class = 'ui'
        ui.name = 'ui'
        
        -- Ui properties 
        ui.windowOpen = false
        ui.connections = {}
        
        --- Connections
        -- Hotkey handling
        do
            ui.connections.Hotkey = inputService.InputBegan:Connect(function(inputObject, gpe) 
                if ( gpe == false and #hotkeys > 0 ) then
                    local keycode = inputObject.KeyCode
                    local inputType = inputObject.UserInputType
                    
                    local now = time() 
                    
                    for idx, hotkey in ipairs( hotkeys ) do 
                        if ( hotkey.set ~= now and ( hotkey.input == inputType or hotkey.key == keycode )) then
                            hotkey.callback(hotkey.parent) 
                        end
                    end
                end
            end)
        end
        
        -- RGB handling
        do
            local rgbTime = 0
            
            local function rgbLoop(deltaTime) 
                local deltaSpeed = ( ( deltaTime / 10 ) * ActiveConfig.Interface.RGBSpeed ) 
                
                rgbTime += deltaSpeed
                if ( rgbTime > 1 ) then
                    rgbTime -= 1
                end  
                
                local color = Color3.fromHSV(rgbTime, 0.8, 1)
                RLGlobals.ActiveColor = color
                
                if ( #rgbInstances > 0 ) then 
                    for _, v in ipairs( rgbInstances ) do
                        -- v[1] is the instance itself
                        -- v[2] is the property being changed
                        -- ex. {Frame, 'BackgroundColor3'}, {UIStroke, 'Color'}
                        v[1][ v[2] ] = color
                    end
                end
            end
            
            ui.connections.ChromaLoop = runService.Heartbeat:Connect(rgbLoop)
            
            ui.connections.ChromaEnable = inputService.WindowFocused:Connect(function() 
                local loop = ui.connections.ChromaLoop
                if ( loop and loop.Connected ) then
                    loop:Disconnect()
                end
                
                ui.connections.ChromaLoop = runService.Heartbeat:Connect(rgbLoop)
            end)
            
            ui.connections.ChromaDisable = inputService.WindowFocusReleased:Connect(function() 
                local loop = ui.connections.ChromaLoop
                if ( loop and loop.Connected ) then
                    loop:Disconnect()
                end
            end)
        end
            
        -- Resize handling
        do 
            -- camera.ViewportSize is trash and doesnt reliably update on resize + 
            -- the game could set CurrentCamera to nil or do some stupid shit and completely break the ui 
            -- so the resolution is gotten from GetScreenResolution per frame instead
            
            local screenInset = guiService:GetGuiInset()
            
            ui.connections.Resize = runService.Heartbeat:Connect(function() 
                ScreenRes = guiService:GetScreenResolution() + screenInset
                if ( ScreenRes ~= RLGlobals.Resolution ) then
                    local x, y = ScreenRes.X, ScreenRes.Y
                    
                    instances.Main.Size = UDim2.fromOffset(x, y)
                    
                    local rowMax = math.floor( (x - 200) / 250 )
                    for _, module in ipairs( moduleMenus ) do 
                        local main = module.objects.Main
                        local index = module.index
                        
                        local position = main.AbsolutePosition.X + 250 
                        
                        if ( module.MovedState and position < x ) then 
                            continue
                        else
                            local row = ( index % rowMax )
                            local column = math.floor(index / rowMax)
                            local xPosition = ( (300 * row) + 100 )
                            local yPosition = ( (200 * column) + 200 )
                            
                            Tween.Quick(main, {
                                Position = UDim2.fromOffset(xPosition, yPosition)
                            })
                            module.MovedState = false
                        end
                    end
                end
                
                RLGlobals.Resolution = ScreenRes
            end)
        end
        
        --- Functions
        -- Element
        do 
            local notifs = {}
                    
            local function CleanUp( this: RLNotif ) 
                local index = table.find(notifs, this)
                if ( index ) then 
                    table.remove(notifs, index)
                    
                    for i = index, #notifs do 
                        local notif = notifs[i]
                        local positionY = -( 15 + ( i - 1 ) * 105 )
                        
                        Tween.Quick(notif.objects.Main, {
                            Position = UDim2.new(1, -15, 1, positionY),
                            AnchorPoint = Vector2.new(1, 1)
                        })
                    end
                    
                    Tween.Quick(this.objects.Main, {
                        Position = UDim2.new(1, -15, 1, 110)
                    }).Completed:Wait()
                    this:Destroy() 
                else
                    warn('[RLNotif:CleanUp] Missing index in notifs table!') 
                end
            end
            
            function ui:Notify( Settings: table ) 
                --- Settings 
                Settings.Title = Settings.Title or 'Title'
                Settings.Message = Settings.Message or 'Message'
                Settings.Duration = Settings.Duration or 3
                Settings.Type = Settings.Type or 'Generic'
                
                --- Preparation
                local this = UiClasses.RLNotif.new()
                
                this:SetType( Settings.Type )
                this:SetTitle( Settings.Title )
                this:SetDesc( Settings.Message ) 
                
                notifs[ #notifs + 1 ] = this -- as much as i hate doing t[#t+1], its faster than table.insert :(
                
                -- localized vars
                local objects = this.objects
                local Main = objects.Main
                
                --- Actual logic + handling
                -- positioning
                local positionY = -( 15 + ( #notifs - 1 ) * 105 )
                Main.AnchorPoint = Vector2.new(0, 1)
                Main.Position = UDim2.new(1, 15, 1, positionY)
                Main.Visible = true 
                
                -- notif "pushing" 
                Tween.Quick(Main, {
                    Position = UDim2.new(1, -15, 1, positionY),
                    AnchorPoint = Vector2.new(1, 1)
                })
                
                -- sound fx
                objects.Sound:Play()
                
                task.delay(Settings.Duration, CleanUp, this) -- save perf by reusing the same cleanup function 🤑🤑
                
                return self 
            end
        end 
        
        function ui:AddTab( TabName: string ) 
            local this = UiClasses.RLTab.new( self, TabName ) 
            return this
        end
        
        -- Interaction
        function ui:Destroy() 
            -- Fire destruction event
            ui:Fire('OnDestroy') 
            
            ctxService:UnbindAction( RLGlobals.Identifier .. 'T' )
            ctxService:UnbindAction( RLGlobals.Identifier .. 'C' )
            
            instances.Shutdown:Play()
            
            if ( windowOpen ) then
                ui:Close()
            end
            
            for _, menu in ipairs( moduleMenus ) do 
                local children = menu:GetChildren()
                for _, v in ipairs( children ) do 
                    if ( v.class == 'RLModule' and v:GetState() ) then
                        v:Disable( true )
                    end
                end
            end
            
            task.wait(2.5)
            ui:Fire('OnDestroyFinish')
            
            
            for _, cn in pairs( ui.connections ) do 
                cn:Disconnect()
            end
            
            for _, tab in ipairs( windowTabs ) do 
                tab:Destroy()
            end
            
            for k in pairs( UiClasses ) do 
                UiClasses[k] = nil
            end
            
            windowTabs = nil
            moduleMenus = nil
            rgbInstances = nil 
            UiClasses = nil
            
            instances.ScreenGui:Destroy()
            shared.REDLINE = nil 
            ui = nil
        end
        
        function ui:Open() 
            windowOpen = true 
            instances.Slide:Play()
            
            Tween.Quick(instances.Clip, {
                Size = UDim2.fromScale(1, 1)
            })
            Tween.Quick(instances.Emblem, {
                Position = UDim2.fromOffset(20, 20)
            })
            Tween.Quick(instances.TabContainer , {
                Position = UDim2.fromScale(0.5, 0)
            })
        end
        
        function ui:Close() 
            windowOpen = false 
            instances.Slide:Play()
            
            Tween.Quick(instances.Clip, {
                Size = UDim2.fromScale(1, 0)
            })
            Tween.Quick(instances.Emblem, {
                Position = UDim2.new(0, 20, -0.1, 0)
            })
            Tween.Quick(instances.TabContainer , {
                Position = UDim2.new(0.5, 0, 0, -36)
            })
        end
        
        function ui:Toggle() 
            windowOpen = not windowOpen
            if ( windowOpen ) then
                ui:Open()
            else
                ui:Close()
            end
        end
    end
    
    local function closeUi(_, input) 
        if ( input.Name == 'Begin' ) then
            ui:Destroy()
        end
    end
    
    local function toggleUi(_, input) 
        if ( input.Name == 'Begin' ) then
            ui:Toggle()
        end
    end
    
    local toggleKey = Enum.KeyCode[ ActiveConfig.Interface.Toggle or 'RightShift' ]
    local destroyKey = Enum.KeyCode[ ActiveConfig.Interface.Destroy or 'End' ]
    
    ctxService:BindActionAtPriority(RLGlobals.Identifier..'T', toggleUi, false, 9e6, toggleKey)
    ctxService:BindActionAtPriority(RLGlobals.Identifier..'C', closeUi, false, 9e6, destroyKey)
    
    function ui.CleanImport() 
        ui:Destroy() 
    end
    
    return ui 
    
    
    --[[
    - make color pickers
    - make notifications
    - make setting menus (inheirt basemenu)    
    
    
    
    ]]--
end)()

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
            Modules.AirJump = (function() -- src/Modules/Movement/AirJump.lua
                --- REDLINE MODULE
                -- Module: Air jump
                -- Category: Movement
                -- Description: Lets you infinitely jump, even if you aren't touching the ground
                -- Version: v1.0.0
                
                local Module = Movement:AddModule('Air jump')
                    :SetTooltip('Lets you infinitely jump mid-air. Depending on your settings, this can bypass jump restrictions that may be in place.')
                    --:SetHotkey(ModuleBinds.AirJump)
                
                do 
                    local Settings = {}
                    Settings.Mode = Module:AddDropdown('Mode')
                        :MakePrimary()
                        :SetTooltip('The method used for jumps / boosts. Each one may have varying performance depending on the game')
                    
                    do
                        Settings.Mode:AddOption('Bypass')
                            :SetTooltip('Avoids jumping entirely by directly modifying your velocity. Oftentimes this will bypass jump restrictions')
                            :Select(true)
                        Settings.Mode:AddOption('Jump')
                            :SetTooltip('Forces a jump by changing your state. If the game does something to prevent you from jumping (like disabling the Jumping state), this won\'t work' )
                    end
                    
                    Settings.Velocity = Module:AddSlider( 'Velocity amount' )
                        :SetSettings({
                            Min = -100,
                            Max = 300,
                            Val = 50,
                            Step = 1
                        })
                        :SetTooltip('What your velocity gets set to when you jump. This setting only affects the "Bypass" mode')
                        :LinkToOption( Settings.Mode:GetOption('Bypass') ) 
                    Settings.Keybind = Module:AddHotkey('Jump key')
                        :SetHotkey( Enum.KeyCode.Space )
                        :SetTooltip('The key that causes you to jump. Defaults to space')         
                    
                    
                    local function jump() 
                        if ( Settings.Mode:GetSelection() == 'Jump' ) then
                            localHumanoid:ChangeState('Jumping')
                        else
                            localRoot.Velocity = Vector3.new(0, Settings.Velocity:GetValue(), 0)
                        end
                    end
                    
                    local jumpCn
                    Module:Connect('OnEnable', function() 
                        jumpCn = inputService.InputBegan:Connect(function( input, gpe ) 
                            if ( gpe == false and Settings.Keybind:CheckInput( input ) ) then
                                jump()
                            end
                        end)
                    end)
                
                    Module:Connect('OnDisable', function() 
                        if ( jumpCn and jumpCn.Connected ) then 
                            jumpCn:Disconnect()
                        end
                    end)
                    
                    Settings.Mode:Connect('OnSelection', function() 
                        Module:Reset()
                    end)
                end
                
                return Module
            end)()
            Modules.ClickTP = (function() -- src/Modules/Movement/ClickTP.lua
                --- REDLINE MODULE
                -- Module: Click TP
                -- Category: Movement
                -- Description: Lets you teleport to your mouse whenever you press ctrl + click
                -- Version: v1.0.0
                
                local Module = Movement:AddModule('Click TP')
                    :SetTooltip('Simply teleports you to your mouse whenever you press a specified key combination')
                    --:SetHotkey(ModuleBinds.ClickTP)
                
                do 
                    local Settings = {}
                    Settings.Mode = Module:AddDropdown('Mode')
                        :MakePrimary()
                        :SetTooltip('The method used for teleporting')
                    do
                        Settings.Mode:AddOption('Instant')
                            :SetTooltip('The normal method that instantly teleports you to your mouse')
                            :Select( true )
                        Settings.Mode:AddOption('Tween')
                            :SetTooltip('Smoothly moves you towards your mouse with an optional speed. May bypass shitty anticheats')
                    end
                    
                    Settings.TweenSpeed = Module:AddSlider('Tween speed')
                        :SetSettings({
                            Min = 0,
                            Max = 100,
                            Val = 50,
                            Step = 1
                        })
                        :SetTooltip('How fast the tween teleports are')
                        :LinkToOption( Settings.Mode:GetOption('Tween'))         
                    
                    Settings.OffsetY = Module:AddSlider('Y Offset')
                        :SetSettings({
                            Min = 0,
                            Max = 10, 
                            Val = 3,
                            Step = 0.1 
                        })
                        :SetTooltip('An offset that gets added to where you teleport. Anything below 3 will shove you inside the ground!')
                        
                    Settings.KeyOne = Module:AddHotkey('Primary key')
                        :SetHotkey( Enum.UserInputType.MouseButton1 )
                        :SetTooltip( 'The primary key that needs to be held down in order to teleport' )
                        
                    Settings.KeyTwo = Module:AddHotkey('Secondary key')
                        :SetHotkey( Enum.KeyCode.LeftControl )
                        :SetTooltip( 'The secondary key that triggers the teleportation. If this isn\'t set, then a secondary key press won\'t be required' ) 
                    
                    --// end settings // --
                    
                    local playerMouse = localPlayer:GetMouse()  
                    local inputCn
                    
                    local function teleport() 
                        if ( not localRoot ) then
                            return
                        end
                        
                        local offset = Vector3.new(0, Settings.OffsetY:GetValue(), 0)
                        local destPosition = playerMouse.Hit.Position + offset
                        local destCFrame = CFrame.new(destPosition, destPosition + localRoot.CFrame.LookVector)
                        
                        if ( Settings.Mode:GetSelection() == 'Instant' ) then
                            localRoot.CFrame = destCFrame 
                            
                        else
                            local distance = ( localRoot.Position - destPosition ).Magnitude
                            local speed = Settings.TweenSpeed:GetValue() * 5
                            
                            Tween.Linear( localRoot, { CFrame = destCFrame }, ( distance / speed ) )
                        end
                    end
                
                    Module:Connect('OnEnable', function() 
                        inputCn = inputService.InputBegan:Connect(function( input, gpe ) 
                            if ( gpe == false and Settings.KeyOne:CheckInput(input)  ) then
                                if ( Settings.KeyTwo:IsInputDown() ) then
                                    teleport() 
                                end
                            end
                        end)
                    end)
                
                    Module:Connect('OnDisable', function() 
                        if ( inputCn and inputCn.Connected ) then 
                            inputCn:Disconnect()
                        end
                    end)
                end
                
                return Module
            end)()
            Modules.Speed = (function() -- src/Modules/Movement/Speed.lua
                --- REDLINE MODULE
                -- Module: Speed
                -- Category: Movement
                -- Description: Standard speedhacks with several modes
                -- Version: v1.0.0
                
                local Module = Movement:AddModule('Speed')
                    :SetTooltip('Standard speedhacks with several modes')
                    --:SetHotkey( ModuleBinds.Speed )
                
                do 
                    local Settings = {}
                    Settings.Mode = Module:AddDropdown('Mode')
                        :MakePrimary()
                        :SetTooltip('The method used for speed')
                    
                    do
                        Settings.Mode:AddOption('CFrame')
                            :SetTooltip('Adds the direction of your movement to your CFrame, increasing how fast you move')
                            :Select( true )
                        
                        Settings.Mode:AddOption('Velocity')
                            :SetTooltip('Kinda like CFrame, but it adds the direction to your velocity instead. Enable Frictionless for better performance')
                            -- add toggle called Frictionless that changes your customphysics and maybe sets massless too
                        Settings.Mode:AddOption('Bhop')
                            :SetTooltip('Velocity, but it spam jumps. Although Bhop is primarily used for going insanely fast, it can legit in certain games with bhop mechanics')
                        
                        Settings.Mode:AddOption('Part')
                            :SetTooltip('Creates a clientside part and pushes you with it. Pretty janky, but can be OP depending on the situation')
                        
                        Settings.Mode:AddOption('Walkspeed')
                            :SetTooltip('This method is highly discouraged from being used, and does not have any protection from anticheats! Use one of the other modes, like CFrame!')
                    end      
                    
                    Settings.Frictionless = Module:AddToggle('Frictionless')
                        :SetTooltip('Reduces friction, improving the performance of Bhop and Velocity')
                        :LinkToOption( Settings.Mode:GetOption('Velocity') )
                        :LinkToOption( Settings.Mode:GetOption('Bhop') )
                    
                    Settings.DefaultSpeed = Module:AddSlider('Speed')
                        :SetSettings({
                            Min = 0,
                            Max = 400,
                            Val = 50,
                            Step = 0.1
                        })
                        :SetTooltip('The speed amount used for every speedhack mode')
                    
                    -- // end settings // -- 
                    
                    local SpeedValue = Settings.DefaultSpeed:GetValue()
                    Settings.DefaultSpeed:Connect('OnUpdate', function( NewValue ) 
                        SpeedValue = NewValue
                    end)
                    
                    local SpeedFuncs = {
                        ['CFrame'] = function( DeltaTime ) 
                            if ( not localRoot ) then
                                return  
                            end
                            
                            localRoot.CFrame += localHumanoid.MoveDirection * ( SpeedValue * 5 * DeltaTime )
                        end,
                        ['Velocity'] = function( DeltaTime ) 
                            if ( not localRoot ) then
                                return  
                            end
                            
                            localRoot.Velocity += localHumanoid.MoveDirection * ( SpeedValue * 5 * DeltaTime )
                        end
                    }
                    
                    local SpeedCn
                    Module:Connect('OnEnable', function() 
                        local Mode = Settings.Mode:GetSelection() 
                        
                        if ( not SpeedFuncs[Mode] ) then
                            return ui:Notify({
                                Title = 'Whoops',
                                Message = 'This mode is still being developed',
                                Duration = 3,
                                Type = 'Warning'
                            }) 
                        end
                        
                        SpeedCn = runService.Heartbeat:Connect(SpeedFuncs[Mode])
                    end)
                
                    Module:Connect('OnDisable', function() 
                        if ( SpeedCn and SpeedCn.Connected ) then 
                            SpeedCn:Disconnect()
                        end
                    end)
                    
                    Settings.Mode:Connect('OnSelection', function() 
                        Module:Reset()
                    end)
                end
                
                return Module
                
                --[[local m_speed     = m_movement:addMod('Speed')
                -- Speed
                do 
                    local mode = m_speed:addDropdown('Mode',true)
                    mode:addOption('Standard'):setTooltip('Standard CFrame speed. <b>Mostly</b> undetectable, unlike other scripts such as Inf Yield. Also known as TPWalk'):Select()
                    mode:addOption('Velocity'):setTooltip('Changes your velocity, doesn\'t use any bodymovers. Because of friction, Velocity typically won\'t increase your speed unless it\'s set high or you jump.')
                    mode:addOption('Bhop'):setTooltip('The exact same as Velocity, but it spam jumps. Useful for looking legit in games with bhop mechanics, like Arsenal')
                    mode:addOption('Part'):setTooltip('Pushes you physically with a clientside part. Can also affect vehicles in certain games, such as Jailbreak')
                    mode:addOption('WalkSpeed'):setTooltip('<font color="rgb(255,64,64)"><b>Insanely easy to detect. Use Standard instead.</b></font>')
                    
                    local speedslider = m_speed:addSlider('Speed',{min=0,max=250,cur=30,step=0.01})
                    local speed = 30
                    speedslider:Connect('Changed',function(v)speed=v;end)
                    local part
                    local scon
                            
                    m_speed:Connect('Enabled',function() 
                        local mode = mode:GetSelection()
                        
                        dnec(clientHumanoid.Changed, 'hum_changed')
                        dnec(clientHumanoid:GetPropertyChangedSignal('Jump'), 'hum_jump')
                        dnec(clientRoot.Changed, 'rp_changed')
                        dnec(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                        dnec(clientRoot:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                        
                        if (scon) then scon:Disconnect() scon = nil end
                        
                        if (mode == 'Standard') then
                            scon = servRun.Heartbeat:Connect(function(dt) 
                                clientRoot.CFrame += clientHumanoid.MoveDirection * (5 * dt * speed)
                            end)
                        elseif (mode == 'Velocity') then
                            scon = servRun.Heartbeat:Connect(function(dt) 
                                clientRoot.Velocity += clientHumanoid.MoveDirection * (5 * dt * speed)
                            end)
                        elseif (mode == 'Bhop') then
                            scon = servRun.RenderStepped:Connect(function(dt) 
                                local md = clientHumanoid.MoveDirection
                                
                                clientRoot.Velocity += md * (5 * dt * speed)
                                clientHumanoid.Jump = not (md.Magnitude < 0.01 and true or false)
                            end)
                        elseif (mode == 'Part') then
                            part = instNew('Part')
                            part.Transparency = 0.8
                            part.Size = vec3(4,4,1)
                            part.CanTouch = false
                            part.CanCollide = true
                            part.Anchored = false
                            part.Name = getnext()
                            part.Parent = workspace
                            scon = ev:Connect(function(dt) 
                                local md = clientHumanoid.MoveDirection
                                local p = clientRoot.Position
                                
                                part.CFrame = cfrNew(p-(md), p)
                                part.Velocity = md * (dt * speed * 1200)
                                
                                clientHumanoid:ChangeState(8)
                            end)
                        elseif (mode == 'WalkSpeed') then
                            dnec(clientHumanoid:GetPropertyChangedSignal('WalkSpeed'), 'hum_walk')
                            
                            scon = servRun.Heartbeat:Connect(function() 
                                clientHumanoid.WalkSpeed = speed
                            end)
                        end
                    end)
                    
                    m_speed:Connect('Disabled',function() 
                        if (scon) then scon:Disconnect() scon = nil end
                        if (part) then part:Destroy() end
                        
                        enec('hum_changed')
                        enec('hum_jump')
                        
                        enec('hum_walk')
                        
                        enec('rp_changed')
                        enec('rp_cframe')
                        enec('rp_velocity')
                        
                        
                    end)
                    
                    mode:Connect('Changed',function() 
                        m_speed:Reset()
                    end)
                    
                    mode:setTooltip('Method used for the speedhack')
                    speedslider:setTooltip('Amount of speed')
                end
                m_speed:setTooltip('Speedhacks with various bypasses and settings')]]
            end)()
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
            Modules.Crosshair = (function() -- src/Modules/Render/Crosshair.lua
                --- REDLINE MODULE
                -- Module: Crosshair
                -- Category: Render
                -- Description: Crosshair display using Drawing 
                -- Version: v1.0.0
                
                
                local Module = Render:AddModule('Crosshair')
                    :SetTooltip('A smooth crosshair overlay, made with Drawing. Meant to be a cool display, and not actually useful')
                    
                do 
                    local Settings = {}
                    do
                        Settings.Style = Module:AddDropdown('Style')
                            :SetTooltip('What the crosshair looks like')
                            
                        Settings.Style:AddOption('Style 1')
                            :SetTooltip('Standard 4 armed crosshair')
                            :Select()
                            
                        Settings.Animation = Module:AddDropdown('Animation')
                            :SetTooltip('A "procedural" animation that gets applied to the crosshair')
                        
                        Settings.Animation:AddOption('Breathe')
                            :SetTooltip('Slowly oscillates the crosshair\'s size')
                            :Select()
                        
                        Settings.Animation:AddOption('Spin')
                            :SetTooltip('Spins the crosshair at a steady rate')
                        
                        Settings.Animation:AddOption('Swing')
                            :SetTooltip('Swings the crosshair back and forth')
                            
                        Settings.Animation:AddOption('3d')
                            :SetTooltip('Tilts and rotates the crosshair in a pseudo 3d manner, kinda funky')
                            
                        Settings.Animation:AddOption('None')
                            :SetTooltip('No animation')
                        
                        Settings.AnimSpeed = Module:AddSlider('Animation speed')
                            :SetSettings({
                                Min = 0,
                                Max = 5,
                                Val = 1,
                                Step = 0.1 
                            })
                            :SetTooltip('How fast the animation plays - 1 is at the normal speed, 2 is twice as fast, etc.')
                        
                        Settings.Smoothness = Module:AddSlider('Smoothness')
                            :SetTooltip('How smooth the crosshair moves')
                            :SetSettings({
                                Min = 1,
                                Max = 20,
                                Val = 10,
                                Step = 0.1 
                            })
                            
                        Settings.Size = Module:AddSlider('Size')
                            :SetSettings({
                                Min = 0,
                                Max = 15,
                                Val = 3,
                                Step = 0.1 
                            })
                            :SetTooltip('The overall scale of the crosshair')
                        
                        Settings.ArmDist = Module:AddSlider('Arm distance')
                            :SetSettings({
                                Min = 0,
                                Max = 10,
                                Val = 3,
                                Step = 0.1
                            })
                            :SetTooltip('How far away the crosshair arms are - only applies to certain styles')
                            
                        Settings.CenterDot = Module:AddToggle('Center dot')
                            :SetTooltip('Displays a small center dot')
                            
                        Settings.Outline = Module:AddToggle('Outline')
                            :SetTooltip('Enables outlines around each crosshair line')
                            :Enable()
                            
                        Settings.Invert = Module:AddToggle('Invert colors')
                            :SetTooltip('Reverses the color "palette" of the crosshair - outlines become RGB, inlines (?) become black')
                            
                        Settings.MouseCursor = Module:AddToggle('Cursorize')
                            :SetTooltip('Hides the roblox cursor and moves the crosshair to your cursor, acting as a new mouse. This will get overwrited by other modules, like Aimbot and Triggerbot!')
                    end
                    
                    -- // end settings // -- 
                    
                    local AnimSpeed = Settings.AnimSpeed:GetValue()
                    local Animation = Settings.Animation:GetSelection() 
                    local ArmDist = Settings.ArmDist:GetValue()
                    local DotEnabled = Settings.CenterDot:GetValue()
                    local OutlineEnabled = Settings.Outline:GetValue()
                    local Size = Settings.Size:GetValue()
                    local Smoothness = Settings.Smoothness:GetValue()
                    local PaletteInvert = Settings.Invert:GetValue() 
                    
                    Settings.Smoothness:Connect('OnUpdate', function( newV ) -- godly var names 🔥
                        Smoothness = newV
                    end)
                    
                    Settings.Size:Connect('OnUpdate', function( newV ) 
                        Size = newV
                    end)
                    
                    Settings.Animation:Connect('OnSelection', function( selection ) 
                        Animation = selection
                    end)
                    
                    Settings.CenterDot:Connect('OnToggle', function( dot ) 
                        DotEnabled = dot 
                    end)
                    
                    Settings.Outline:Connect('OnToggle', function( outline ) 
                        OutlineEnabled = outline 
                    end)
                    
                    Settings.Invert:Connect('OnToggle', function( invert ) 
                        PaletteInvert = invert 
                    end)
                    
                    Settings.AnimSpeed:Connect('OnUpdate', function( newV )  
                        AnimSpeed = newV  
                    end)
                    
                    Settings.ArmDist:Connect('OnUpdate', function( newV )  
                        ArmDist = newV  
                    end)
                    
                    local CursorPrev = false -- if MouseIconEnabled was false before potentially modifying it 
                    local Styles = {}
                    Styles['Style 1'] = (function() -- src/Resources/Crosshair/Style1.lua
                        --- REDLINE Resource
                        -- Description: Style #1 for the Crosshair module 
                        -- Version: v1.0.0
                        
                        local Style = {} 
                        local Loaded = false
                        
                        local HALFPI1 = math.pi / 2
                        local HALFPI2 = HALFPI1 * 2
                        local HALFPI3 = HALFPI1 * 3
                        
                        local BLACK = Color3.new(0, 0, 0)
                        
                        do
                            local Objects = {} 
                            local Delta
                        
                            function Style.Init() 
                                Loaded = true 
                                Delta = 0 
                                
                                -- Objects.Arm1
                                do
                                    local Obj_Arm1 = Drawing.new('Line')
                                    Obj_Arm1.Thickness = 1
                                    Obj_Arm1.Visible = true
                                    Obj_Arm1.ZIndex = 500
                                    
                                    Objects.Arm1 = Obj_Arm1
                                end
                                
                                -- Objects.Arm2
                                do
                                    local Obj_Arm2 = Drawing.new('Line')
                                    Obj_Arm2.Thickness = 1
                                    Obj_Arm2.Visible = true
                                    Obj_Arm2.ZIndex = 500
                                    
                                    Objects.Arm2 = Obj_Arm2
                                end
                                
                                -- Objects.Arm3
                                do
                                    local Obj_Arm3 = Drawing.new('Line')
                                    Obj_Arm3.Thickness = 1
                                    Obj_Arm3.Visible = true
                                    Obj_Arm3.ZIndex = 500
                                    
                                    Objects.Arm3 = Obj_Arm3
                                end
                                
                                -- Objects.Arm4
                                do
                                    local Obj_Arm4 = Drawing.new('Line')
                                    Obj_Arm4.Thickness = 1
                                    Obj_Arm4.Visible = true
                                    Obj_Arm4.ZIndex = 500
                                    
                                    Objects.Arm4 = Obj_Arm4
                                end
                                
                                -- Objects.Arm1Outline
                                do
                                    local Obj_Arm1 = Drawing.new('Line')
                                    Obj_Arm1.Color = Color3.new(0, 0, 0)
                                    Obj_Arm1.Thickness = 3
                                    Obj_Arm1.Visible = false
                                    Obj_Arm1.ZIndex = 499
                                    
                                    Objects.Arm1Outline = Obj_Arm1
                                end
                                
                                -- Objects.Arm2Outline
                                do
                                    local Obj_Arm2 = Drawing.new('Line')
                                    Obj_Arm2.Color = Color3.new(0, 0, 0)
                                    Obj_Arm2.Thickness = 3
                                    Obj_Arm2.Visible = false
                                    Obj_Arm2.ZIndex = 499
                                    
                                    Objects.Arm2Outline = Obj_Arm2
                                end
                                
                                -- Objects.Arm3Outline
                                do
                                    local Obj_Arm3 = Drawing.new('Line')
                                    Obj_Arm3.Color = Color3.new(0, 0, 0)
                                    Obj_Arm3.Thickness = 3
                                    Obj_Arm3.Visible = false
                                    Obj_Arm3.ZIndex = 499
                                    
                                    Objects.Arm3Outline = Obj_Arm3
                                end
                                
                                -- Objects.Arm4Outline
                                do
                                    local Obj_Arm4 = Drawing.new('Line')
                                    Obj_Arm4.Color = Color3.new(0, 0, 0)
                                    Obj_Arm4.Thickness = 3
                                    Obj_Arm4.Visible = false
                                    Obj_Arm4.ZIndex = 499
                                    
                                    Objects.Arm4Outline = Obj_Arm4
                                end
                                
                                -- Objects.Dot
                                do
                                    local Obj_Dot = Drawing.new('Square')
                                    Obj_Dot.Filled = true 
                                    Obj_Dot.Size = Vector2.new(0.5, 0.5)
                                    Obj_Dot.Thickness = 1
                                    Obj_Dot.Visible = false
                                    Obj_Dot.ZIndex = 500 
                                    
                                    Objects.Dot = Obj_Dot
                                end
                                
                                -- Objects.DotOutline
                                do
                                    local Obj_Dot = Drawing.new('Square')
                                    Obj_Dot.Color = Color3.new(0, 0, 0)
                                    Obj_Dot.Filled = true 
                                    Obj_Dot.Size = Vector2.new(0.5, 0.5)
                                    Obj_Dot.Thickness = 3
                                    Obj_Dot.Visible = false
                                    Obj_Dot.ZIndex = 499 
                                    
                                    Objects.DotOutline = Obj_Dot
                                end
                            end
                        
                            function Style.Update( DeltaTime: number ) 
                                Delta += ( DeltaTime * AnimSpeed )
                                
                                -- Constant vals 
                                local Arm1, Arm2, Arm3, Arm4, Dot = Objects.Arm1, Objects.Arm2, Objects.Arm3, Objects.Arm4, Objects.Dot 
                                local Arm1Ol = Objects.Arm1Outline
                                local Arm2Ol = Objects.Arm2Outline
                                local Arm3Ol = Objects.Arm3Outline
                                local Arm4Ol = Objects.Arm4Outline
                                local DotOl  = Objects.DotOutline
                                local CrossPos = ScreenRes / 2 
                                
                                -- "Proxy" vals - these are what will be modified 
                                local PosProxy = CrossPos
                                local ScaleProxy = Size 
                                local Angle = 0
                                
                                local AngleOffset1 = 0
                                local AngleOffset2 = 0
                                
                                -- Pre modification - generic stuff that won't be animated is set here
                                local ActiveColor = PaletteInvert and BLACK or RLGlobals.ActiveColor
                                local OutlineColor = PaletteInvert and RLGlobals.ActiveColor or BLACK
                                Arm1.Color = ActiveColor
                                Arm2.Color = ActiveColor
                                Arm3.Color = ActiveColor
                                Arm4.Color = ActiveColor
                                Dot.Color = ActiveColor
                                
                                Dot.Visible = DotEnabled
                                
                                Arm1Ol.Visible = OutlineEnabled
                                Arm2Ol.Visible = OutlineEnabled
                                Arm3Ol.Visible = OutlineEnabled
                                Arm4Ol.Visible = OutlineEnabled
                                DotOl.Visible = DotEnabled and OutlineEnabled
                                
                                
                                -- Animation handling 
                                -- giant elif chains are bad but what else can i do 
                                if ( Animation == 'Breathe' ) then
                                    ScaleProxy += math.sin( Delta ) 
                                    
                                elseif ( Animation == 'Spin' ) then 
                                    Angle = Delta % 360 -- modulo isnt required, might as well do it
                                    
                                elseif ( Animation == 'Swing' ) then
                                    Angle = math.sin ( Delta ) * 4
                                    
                                elseif ( Animation == '3d' ) then 
                                    local scaledDelta = math.cos(Delta) * 5 
                                    --math.cos(Delta * 2) + 1.5 * math.sin(Delta * 2) ^ 5
                                    --math.cos(Delta) * (math.sin(Delta)^6) * 7
                                    
                                    AngleOffset1 = scaledDelta
                                    AngleOffset2 = -scaledDelta
                                     
                                end
                                
                                local Angle1 = ScaleProxy * Vector2.new(math.sin(Angle           + AngleOffset1), math.cos(Angle           + AngleOffset2))
                                local Angle2 = ScaleProxy * Vector2.new(math.sin(Angle + HALFPI1 + AngleOffset1), math.cos(Angle + HALFPI1 + AngleOffset2))
                                local Angle3 = ScaleProxy * Vector2.new(math.sin(Angle + HALFPI2 + AngleOffset1), math.cos(Angle + HALFPI2 + AngleOffset2))
                                local Angle4 = ScaleProxy * Vector2.new(math.sin(Angle + HALFPI3 + AngleOffset1), math.cos(Angle + HALFPI3 + AngleOffset2))
                                
                                local ArmDistOffs = ( 2 + ArmDist ) -- armdist + some extra offset
                                
                                if ( Settings.MouseCursor:GetState() ) then 
                                    local position = inputService:GetMouseLocation()
                                    inputService.MouseIconEnabled = false 
                                    
                                    PosProxy = position
                                else
                                    inputService.MouseIconEnabled = CursorPrev 
                                end
                                
                                Arm1.From = PosProxy - ( Angle1 * ArmDistOffs )
                                Arm1.To   = PosProxy - ( Angle1 * ArmDist )
                                Arm2.From = PosProxy - ( Angle2 * ArmDistOffs )
                                Arm2.To   = PosProxy - ( Angle2 * ArmDist )
                                Arm3.From = PosProxy - ( Angle3 * ArmDistOffs )
                                Arm3.To   = PosProxy - ( Angle3 * ArmDist )
                                Arm4.From = PosProxy - ( Angle4 * ArmDistOffs )
                                Arm4.To   = PosProxy - ( Angle4 * ArmDist )
                                Dot.Position = PosProxy
                                
                                if ( OutlineEnabled ) then 
                                    
                                    Arm1Ol.From = Arm1.From
                                    Arm1Ol.To   = Arm1.To
                                    Arm2Ol.From = Arm2.From
                                    Arm2Ol.To   = Arm2.To
                                    Arm3Ol.From = Arm3.From
                                    Arm3Ol.To   = Arm3.To
                                    Arm4Ol.From = Arm4.From
                                    Arm4Ol.To   = Arm4.To
                                    
                                    DotOl.Position = PosProxy 
                                    
                                    Arm1Ol.Color = OutlineColor
                                    Arm2Ol.Color = OutlineColor
                                    Arm3Ol.Color = OutlineColor
                                    Arm4Ol.Color = OutlineColor
                                    DotOl.Color = OutlineColor
                                end
                            end
                        
                            function Style.Unload() 
                                if ( Loaded == false ) then
                                    return
                                end
                                        
                                for _, obj in pairs( Objects ) do 
                                    obj:Remove()
                                end
                                
                                Loaded = false 
                            end
                        end
                        
                        return Style 
                    end)()
                    
                    local Style
                    Settings.Style:Connect('OnSelection', function() 
                        if ( Style ) then 
                            Style.Unload() 
                        end
                        
                        Module:Reset()
                    end)
                    
                    local UpdateCon
                    Module:Connect('OnEnable', function() 
                        Style = Styles[ Settings.Style:GetSelection() ]
                        
                        if ( not Style ) then
                            return ui:Notify({
                                Title = 'Oops',
                                Message = 'Nonexistant crosshair style',
                                Type = 'Warning',
                                Duration = 3
                            }) 
                        end
                        
                        ui:Notify({
                            Title = 'Style',
                            Message = Settings.Style:GetSelection(),
                            Type = 'Generic',
                            Duration = 3
                        }) 
                        
                        CursorPrev = inputService.MouseIconEnabled 
                        
                        Style.Init() -- init function that creates the stuff and does some other stuff
                        UpdateCon = runService.Heartbeat:Connect(Style.Update) -- update function that handles the animations 
                        
                    end)
                    
                    Module:Connect('OnDisable', function() 
                        if ( UpdateCon and UpdateCon.Connected ) then
                            UpdateCon:Disconnect()
                        end
                        
                        if ( Style ) then 
                            Style.Unload() 
                        end
                        
                        if ( CursorPrev == true ) then 
                            inputService.MouseIconEnabled = true
                        end
                    end)
                end
                
                
                return Module 
            end)()
            
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

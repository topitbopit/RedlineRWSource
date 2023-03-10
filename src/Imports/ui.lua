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
    local RLBase = import('src/UiClasses/RLBase.lua')
    UiClasses.RLBase = RLBase
    
    --- RLTab : RLBase
    -- Class for window tabs
    local RLTab: RLBase = import('src/UiClasses/RLTab.lua')
    UiClasses.RLTab = RLTab 
    
    --- RLBaseMenu : RLBase
    -- Base class for certain menu elements, like ModuleMenus
    local RLBaseMenu: RLBase = import('src/UiClasses/RLBaseMenu.lua')
    UiClasses.RLBaseMenu = RLBaseMenu 
    
    --- RLModuleMenu : RLBaseMenu
    -- Container for modules
    local RLModuleMenu: RLBaseMenu = import('src/UiClasses/RLModuleMenu.lua')
    UiClasses.RLModuleMenu = RLModuleMenu

    --- RLModule : RLBase
    -- Class for modules
    local RLModule: RLBase = import('src/UiClasses/RLModule.lua')
    UiClasses.RLModule = RLModule
    
    --- RLTooltip : RLBase
    -- Class for tooltips
    local RLTooltip: RLBase = import('src/UiClasses/RLTooltip.lua')
    UiClasses.RLTooltip = RLTooltip
    
    --- RLNotif : RLBase
    -- Class for notifs 
    local RLNotif: RLBase = import('src/UiClasses/RLNotif.lua')
    UiClasses.RLNotif = RLNotif
    
    --- RLBaseSetting : RLBase 
    -- Base class used for certain settings, like toggles, sliders etc.
    local RLBaseSetting: RLBase = import('src/UiClasses/Settings/RLBaseSetting.lua')
    UiClasses.RLBaseSetting = RLBaseSetting
    
    --- RLSettingSlider : RLBaseSetting 
    -- A one dimensional slider that lets you choose a single number from a min to max 
    local RLSettingSlider: RLBaseSetting = import('src/UiClasses/Settings/RLSettingSlider.lua')
    UiClasses.RLSettingSlider = RLSettingSlider
    
    --- RLSettingToggle : RLBaseSetting
    -- A single boolean toggle. *May* support implicit hotkey binding
    local RLSettingToggle: RLBaseSetting = import('src/UiClasses/Settings/RLSettingToggle.lua')
    UiClasses.RLSettingToggle = RLSettingToggle
    
    --- RLSettingButton : RLBaseSetting
    -- A simple clickable button
    local RLSettingButton: RLSettingButton = import('src/UiClasses/Settings/RLSettingButton.lua')
    UiClasses.RLSettingButton = RLSettingButton
    
    --- RLSettingDropdown : RLBaseSetting
    -- A dropdown menu letting you select a single item from a list of options 
    local RLSettingDropdown: RLBaseSetting = import('src/UiClasses/Settings/RLSettingDropdown.lua')
    UiClasses.RLSettingDropdown = RLSettingDropdown
    
    --- RLDropdownItem : RLBase
    -- The item class for dropdown menus 
    local RLDropdownItem: RLBase = import('src/UiClasses/Settings/RLDropdownitem.lua')
    UiClasses.RLDropdownItem = RLDropdownItem
    
    --- RLSettingHotkey : RLBaseSetting
    -- A simple keybind selector. Now supports mouse buttons - unbinding is done via the right-click unbind menu
    local RLSettingHotkey: RLBaseSetting = import('src/UiClasses/Settings/RLSettingHotkey.lua')
    UiClasses.RLSettingHotkey = RLSettingHotkey
    
    --- RLSettingCarousel : RLBaseSetting
    -- A "wheel" / "carousel" that you can rotate to choose an option. Kinda like a dropdown, but more compact
    local RLSettingCarousel: RLBaseSetting = import('src/UiClasses/Settings/RLSettingCarousel.lua')
    UiClasses.RLSettingCarousel = RLSettingCarousel
    
    --- RLCarouselItem : RLBase
    -- The item class for carousel menus 
    local RLCarouselItem: RLBase = import('src/UiClasses/Settings/RLCarouselItem.lua')
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
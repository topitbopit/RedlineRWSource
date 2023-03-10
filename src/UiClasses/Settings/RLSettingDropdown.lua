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
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
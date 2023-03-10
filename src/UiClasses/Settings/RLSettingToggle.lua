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
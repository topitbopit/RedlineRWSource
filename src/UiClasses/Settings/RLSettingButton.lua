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
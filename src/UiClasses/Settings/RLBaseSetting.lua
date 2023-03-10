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
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
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
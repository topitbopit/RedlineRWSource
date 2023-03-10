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
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
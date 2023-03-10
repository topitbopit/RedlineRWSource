--- RLBaseMenu : RLBase
-- Base class for certain menu elements, like ModuleMenus
local RLBaseMenu: RLBase = {} do 
    --- Setup
    RLBaseMenu.__index = RLBaseMenu
    RLBaseMenu.class = 'RLBaseMenu' 
    setmetatable(RLBaseMenu, RLBase)
    
    --- Interaction
    function RLBaseMenu:IsOpen() 
        return self.MenuState 
    end
    
    --- Constructor
    function RLBaseMenu.new( Parent: table, MenuName: string, IconId: string, ZIndex: number )
        ZIndex = ZIndex or 100
        
        --- Setup 
        local this = RLBase.new()
        setmetatable(this, RLBaseMenu)
        table.insert(Parent.children, this)
        this.DragState = false
        this.MenuState = true 
        this.MovedState = false
        this.connections = {}
        this.name = MenuName 
        this.parent = Parent
        this.zindex = ZIndex 
        
        --- Objects
        local objects = {}
        do
            -- objects.Main
            do 
                local Main = Instance.new('Frame')
                Main.AutomaticSize = 'Y'
                Main.BackgroundColor3 = InterfaceTheme.Shade2
                Main.BorderSizePixel = 0
                Main.Size = UDim2.fromOffset(250, 30) --UDim2.new(0.15, 0, 0, 30)
                Main.ZIndex = ZIndex
                --[[
                local Constraint = Instance.new('UISizeConstraint')
                Constraint.MaxSize = Vector2.new(250, 9e5)
                Constraint.MinSize = Vector2.new(150, 0)
                Constraint.Parent = Main]]
                
                objects.Main = Main
            end
            
            -- objects.MainOutline
            do 
                local MainOutline = Instance.new('UIStroke')
                MainOutline.Color = Color3.new(1, 1, 1)
                MainOutline.Thickness = 1
                
                MainOutline.Parent = objects.Main
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
            
            -- objects.Container
            do 
                local Container = Instance.new('ScrollingFrame')
                Container.AutomaticSize = 'Y'
                Container.BackgroundTransparency = 1 
                Container.BorderColor3 = InterfaceTheme.Outline
                Container.BorderSizePixel = 1
                Container.BottomImage = 'rbxassetid://9416839567'
                Container.ClipsDescendants = true --ASFDASFASF
                Container.MidImage = 'rbxassetid://9416839567'
                Container.Position = UDim2.fromOffset(0, 31)
                Container.ScrollBarImageTransparency = 0.4
                Container.ScrollBarThickness = 0 -- 3 when scrolling 
                Container.ScrollingEnabled = false -- true when scrolling 
                Container.Size = UDim2.new(1, 0, 0, -31)
                Container.TopImage = 'rbxassetid://9416839567'
                Container.Visible = true
                Container.ZIndex = ZIndex -- - 1 maybe?
                
                local Layout = Instance.new('UIListLayout')
                Layout.VerticalAlignment = 'Top'
                Layout.HorizontalAlignment = 'Left'
                Layout.FillDirection = 'Vertical'
                Layout.Parent = Container
                
                Container.Parent = objects.Main
                objects.Container = Container 
            end
            
            -- objects.Header
            do 
                local Header = Instance.new('Frame')
                Header.BackgroundColor3 = InterfaceTheme.Shade1
                Header.BorderSizePixel = 0
                Header.Size = UDim2.new(1, 0, 0, 30)
                Header.ZIndex = ZIndex + 1 
                
                Header.Parent = objects.Main
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
                
                ClickSensor.Parent = objects.Header
                objects.ClickSensor = ClickSensor
            end
            
            -- objects.HeaderIcon
            do 
                local HeaderIcon = Instance.new('ImageLabel')
                HeaderIcon.BackgroundTransparency = 1
                HeaderIcon.Image = IconId
                HeaderIcon.ImageColor3 = Color3.fromRGB(250, 250, 255)
                HeaderIcon.Position = UDim2.fromOffset(7, 7) -- offset = (Header height - icon height) / 2
                HeaderIcon.Size = UDim2.fromOffset(16, 16)
                HeaderIcon.ZIndex = ZIndex + 1
                
                HeaderIcon.Parent = objects.Header 
                objects.HeaderIcon = HeaderIcon
            end
            
            -- objects.HeaderLabel
            do 
                local HeaderLabel = Instance.new('TextLabel')
                HeaderLabel.BackgroundTransparency = 1
                HeaderLabel.Font = InterfaceTheme.Font
                HeaderLabel.Size = UDim2.fromScale(1, 1)
                HeaderLabel.Text = MenuName
                HeaderLabel.TextColor3 = InterfaceTheme.Text_Shade1
                HeaderLabel.TextSize = InterfaceTheme.TextSize
                HeaderLabel.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                HeaderLabel.TextStrokeTransparency = 0.5
                HeaderLabel.TextXAlignment = 'Center'
                HeaderLabel.TextYAlignment = 'Center'
                HeaderLabel.ZIndex = ZIndex + 1 
                
                if ( ActiveConfig.Interface.MenuTitleStyle == 'Bold' ) then
                    HeaderLabel.RichText = true 
                    HeaderLabel.Text = string.format('<b>%s</b>', MenuName:upper())
                end
                
                HeaderLabel.Parent = objects.Header
                objects.HeaderLabel = HeaderLabel
            end
        end
        
        --- Events
        do
            objects.ClickSensor.MouseEnter:Connect(function() 
                Tween.Quick(objects.ClickSensor, {
                    BackgroundTransparency = 0.985
                })
            end)
            
            objects.ClickSensor.MouseLeave:Connect(function() 
                Tween.Quick(objects.ClickSensor, {
                    BackgroundTransparency = 1
                })
            end)
            
            objects.ClickSensor.MouseButton1Down:Connect(function() 
                if ( this.DragState ) then
                    local dragCon = this.connections.dragCon 
                    local dragEnd = this.connections.dragEnd
                    
                    if ( dragCon ) then 
                        dragCon:Disconnect()
                    end
                    if ( dragEnd ) then
                        dragEnd:Disconnect() 
                    end
                end
                
                this.MovedState = true
                this.DragState = true
                
                local startRoot = objects.Main.AbsolutePosition + guiService:GetGuiInset()
                local startMouse = inputService:GetMouseLocation()
                
                this.connections.dragCon = inputService.InputChanged:Connect(function() 
                    local newMouse  = inputService:GetMouseLocation()
                    local finalVec2 = ( startRoot + (newMouse - startMouse) )
                    local finalUDim2 = UDim2.fromOffset(finalVec2.X, finalVec2.Y)
                    
                    Tween.Quick(objects.Main, {
                        Position = finalUDim2
                    })
                end)
                
                this.connections.dragEnd = inputService.InputEnded:Connect(function(input) 
                    if ( input.UserInputType.Name == 'MouseButton1' ) then
                        this.DragState = false 
                
                        local dragCon = this.connections.dragCon 
                        local dragEnd = this.connections.dragEnd
                        
                        if ( dragCon ) then 
                            dragCon:Disconnect()
                        end
                        if ( dragEnd ) then
                            dragEnd:Disconnect() 
                        end
                    end
                end)
            end)
        end
        
        --- Finalize
        this.objects = objects
        return this 
    end
    
    --- Destructor
    -- Inherited from RLBase
end

return RLBaseMenu 
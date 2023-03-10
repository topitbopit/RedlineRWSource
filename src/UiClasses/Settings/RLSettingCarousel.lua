--- RLSettingCarousel : RLBaseSetting
-- A "wheel" / "carousel" that you can rotate to choose an option. Kinda like a dropdown, but more compact
local RLSettingCarousel: RLBaseSetting = {} do 
    --- Setup
    RLSettingCarousel.__index = RLSettingCarousel
    RLSettingCarousel.class = 'RLSettingCarousel'
    setmetatable(RLSettingCarousel, RLBaseSetting)
    
    --- Interaction
    function RLSettingCarousel:RotateLeft() 
        local children = self.children
        local curIndex = self.ItemIndex -- get currently selected index 
        local newIndex = curIndex - 1 -- subtract 1; this shifts it to the left 
        
        if ( newIndex < 1 ) then -- check if the index is 0, and wrap it around 
            newIndex = #children
        end
        
        children[curIndex]:Deselect() -- deselect the previous child 
        
        self.ItemIndex = newIndex -- set index 
        
        children[newIndex]:Select() -- select the new child
    end
    
    function RLSettingCarousel:RotateRight() 
        local children = self.children
        local curIndex = self.ItemIndex
        local newIndex = curIndex + 1
        
        children[curIndex]:Deselect()
        
        if ( newIndex > #children ) then
            newIndex = 1
        end
        
        self.ItemIndex = newIndex
        
        children[newIndex]:Select()
    end
    
    function RLSettingCarousel:SelectOption( optionName: string ) 
        local children = self.children
        
        -- get the index of the new option 
        local index
        for idx, c in ipairs( children ) do 
            if ( c.name == optionName ) then
                index = idx 
                break 
            end
        end
        
        -- if it couldnt be found, cancel selection 
        if ( not index ) then
            return
        end
        
        -- get current selection, disable it if it's active
        local currentChild = children[self.ItemIndex]
        if ( currentChild:IsSelected() ) then 
            currentChild:Deselect()
        end
        
        self.ItemIndex = index
        
        -- select the new option 
        children[index]:Select()
    end
    
    function RLSettingCarousel:Reposition() -- repositions all carousel items  
        local newIndex = self.ItemIndex
        local children = self.children
        local childCount = #children
        
        for idx, c in ipairs( children ) do 
            local label = c.objects.Label 
            
            local delta = idx - newIndex
            
            -- i love math!!!!
            -- ((delta + (childCount / 2)) % childCount - (childCount / 2))
            -- 2, 6: (5 % 3)
            -- (delta % childCount) - math.floor(childCount / 2)
            -- 2, 6: (2 % 6) - 3
            local dest = ((delta + (childCount / 2)) % childCount - (childCount / 2))
            
            if ( math.abs(dest) > 1 or ( c.posIndex < -1 )) then
                Tween.Linear(label, { -- as retarded as this is its needed to stop the currently playing tween
                    Position = UDim2.fromScale(dest, 0)
                }, 0)
            else
                Tween.Quick(label, {
                    Position = UDim2.fromScale(dest, 0)
                })
            end
            
            c.posIndex = dest 
        end
    end
    
    RLSettingCarousel.GetValue = UiClasses.RLSettingDropdown.GetValue
    RLSettingCarousel.GetSelection = UiClasses.RLSettingDropdown.GetValue 
    RLSettingCarousel.GetOption = UiClasses.RLSettingDropdown.GetOption
    
    --- Element
    function RLSettingCarousel:AddOption( OptionName: string ) 
        local this = UiClasses.RLCarouselItem.new( self, OptionName, self.zindex + 1 )
        
        local childCount = #self.children
        this.index = childCount
        
        local dest = (((childCount - 1) + (childCount / 2)) % childCount - (childCount / 2))
        this.posIndex = dest 
        local main = this.objects.Label
        main.Position = UDim2.fromScale( dest )
        main.Parent = self.objects.Container 
        
        return this
    end
    
    --- Constructor
    function RLSettingCarousel.new( Parent: table, SettingName: string, ZIndex: number ) 
        --- Setup
        local this = RLBaseSetting.new( Parent, SettingName, ZIndex )
        setmetatable( this, RLSettingCarousel )
        -- states 
        this.HoverState = false 
        -- properties
        this.ItemIndex = 1
        
        --- Objects
        local objects = this.objects
        do 
            objects.Label.ZIndex = ZIndex + 2 
            objects.ClickSensor.ZIndex = ZIndex 
            
            -- objects.Container 
            do 
                local Container = Instance.new('Frame')
                Container.Size = UDim2.new(1, 0, 0, 24)
                Container.BackgroundTransparency = 1 
                
                Container.Parent = objects.Main 
                objects.Container = Container 
            end
            
            -- objects.Dimmer
            do 
                local Dimmer = Instance.new('Frame')
                Dimmer.BackgroundColor3 = InterfaceTheme.Shade3
                Dimmer.BackgroundTransparency = 0.3 
                Dimmer.BorderSizePixel = 0
                Dimmer.Size = UDim2.new(1, 0, 0, 24)
                Dimmer.Visible = true 
                Dimmer.ZIndex = ZIndex + 1
                
                Dimmer.Parent = objects.Main
                objects.Dimmer = Dimmer 
            end
            
            -- objects.LeftSensor
            do 
                local LeftSensor = Instance.new('TextButton')
                LeftSensor.AutoButtonColor = false 
                LeftSensor.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                LeftSensor.BackgroundTransparency = 1
                LeftSensor.BorderSizePixel = 0
                LeftSensor.Size = UDim2.new(0.5, 0, 0, 24)
                LeftSensor.Text = '' 
                LeftSensor.TextTransparency = 1 
                LeftSensor.ZIndex = ZIndex
                
                LeftSensor.Parent = objects.Main
                objects.LeftSensor = LeftSensor
            end
            
            -- objects.RightSensor
            do 
                local RightSensor = Instance.new('TextButton')
                RightSensor.AutoButtonColor = false 
                RightSensor.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                RightSensor.BackgroundTransparency = 1
                RightSensor.BorderSizePixel = 0
                RightSensor.Position = UDim2.fromScale(0.5, 0)
                RightSensor.Size = UDim2.new(0.5, 0, 0, 24)
                RightSensor.Text = '' 
                RightSensor.TextTransparency = 1 
                RightSensor.ZIndex = ZIndex
                
                RightSensor.Parent = objects.Main
                objects.RightSensor = RightSensor
            end
            
            -- objects.LeftArrow
            do 
                local LeftArrow = Instance.new('ImageLabel')
                LeftArrow.AnchorPoint = Vector2.new(0, 0)
                LeftArrow.BackgroundTransparency = 1
                LeftArrow.Image = 'rbxassetid://10771256737'
                LeftArrow.ImageColor3 = Color3.fromRGB(250, 250, 255)
                LeftArrow.ImageTransparency = 0.5
                LeftArrow.Position = UDim2.fromOffset(10, 5)
                LeftArrow.ResampleMode = 'Pixelated'
                LeftArrow.Rotation = 90
                LeftArrow.Size = UDim2.fromOffset(14, 14)
                LeftArrow.ZIndex = ZIndex 
                
                LeftArrow.Parent = objects.LeftSensor 
                objects.LeftArrow = LeftArrow
            end
            
            -- objects.RightArrow
            do 
                local RightArrow = Instance.new('ImageLabel')
                RightArrow.AnchorPoint = Vector2.new(1, 0)
                RightArrow.BackgroundTransparency = 1
                RightArrow.Image = 'rbxassetid://10771256737'
                RightArrow.ImageColor3 = Color3.fromRGB(250, 250, 255)
                RightArrow.ImageTransparency = 0.5
                RightArrow.Position = UDim2.new(1, -10, 0, 5)
                RightArrow.ResampleMode = 'Pixelated'
                RightArrow.Rotation = -90
                RightArrow.Size = UDim2.fromOffset(14, 14)
                RightArrow.ZIndex = ZIndex 
                
                RightArrow.Parent = objects.RightSensor 
                objects.RightArrow = RightArrow
            end
        end
        
        --- Events
        do 
            objects.ClickSensor.MouseEnter:Connect(function() 
                this.HoverState = true
                
                Tween.Quick(objects.ClickSensor, {
                    BackgroundTransparency = 0.985
                })
                Tween.Quick(objects.Dimmer, {
                    BackgroundTransparency = 1
                })
                
                Tween.Quick(objects.Label, {
                    TextTransparency = 1,
                    TextStrokeTransparency = 1,
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
                Tween.Quick(objects.Dimmer, {
                    BackgroundTransparency = 0.3
                })
                
                Tween.Quick(objects.Label, {
                    TextTransparency = 0,
                    TextStrokeTransparency = 0.5,
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.new(1, -8, 1, 0)
                })
                
                if ( this.tooltip ) then 
                    instances.Tooltip:Hide(this)
                end
            end)
            
            objects.LeftSensor.MouseEnter:Connect(function() 
                Tween.Quick(objects.LeftArrow, {
                    ImageTransparency = 0
                })
            end)
            
            objects.RightSensor.MouseEnter:Connect(function() 
                Tween.Quick(objects.RightArrow, {
                    ImageTransparency = 0
                })
            end)
            
            objects.LeftSensor.MouseLeave:Connect(function() 
                Tween.Quick(objects.LeftArrow, {
                    ImageTransparency = 0.5
                })
            end)
            
            objects.RightSensor.MouseLeave:Connect(function() 
                Tween.Quick(objects.RightArrow, {
                    ImageTransparency = 0.5
                })
            end)
            
            objects.LeftSensor.MouseButton1Click:Connect(function() 
                this:RotateLeft() 
            end)
            objects.RightSensor.MouseButton1Click:Connect(function() 
                this:RotateRight() 
            end)
        end
        
        --- Finalization 
        return this 
    end
    
    --- Destructor
    -- Inherited from RLBase
end

return RLSettingCarousel
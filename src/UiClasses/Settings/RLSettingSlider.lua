--- RLSettingSlider : RLBaseSetting 
-- A one dimensional slider that lets you choose a single number from a min to max 
local RLSettingSlider: RLBaseSetting = {} do 
    --- Setup
    RLSettingSlider.__index = RLSettingSlider
    RLSettingSlider.class = 'RLSettingSlider'
    setmetatable(RLSettingSlider, RLBaseSetting)
    
    --- Interaction
    function RLSettingSlider:GetValue( newValue: number ) 
        return self.sVal 
    end
    
    -- Takes in a new value, processes it, and sets the slider's value to the processed value
    function RLSettingSlider:SetValue( newValue: number ) 
        newValue = round( math.clamp( newValue, self.sMin, self.sMax ), self.sStep )
        
        if ( self.sVal == newValue ) then
            return self
        end 
        
        self.sVal = newValue 
        self:Fire( 'OnUpdate', newValue )
        
        if ( self:IsPrimary() ) then
            self.parent:Fire( 'OnPrimaryChange', newValue ) 
        end
        
        local objects = self.objects 
        Tween.Quick(objects.Fill, {
            Size = UDim2.fromScale( ( newValue - self.sMin ) / ( self.sMax - self.sMin ), 1 )
        })
        objects.Value.Text = self.sFormat:format( newValue )
        
        return self
    end
    
    -- Sets a slider's value to an already processed value
    function RLSettingSlider:SetFinishedValue( newValue: number ) 
        if ( self.sVal == newValue ) then
            return self
        end 
        
        self.sVal = newValue 
        self:Fire( 'OnUpdate', newValue )
        
        if ( self:IsPrimary() ) then
            self.parent:Fire( 'OnPrimaryChange', newValue ) 
        end
        
        local objects = self.objects 
        Tween.Quick(objects.Fill, {
            Size = UDim2.fromScale( ( newValue - self.sMin ) / ( self.sMax - self.sMin ), 1 )
        })
        objects.Value.Text = self.sFormat:format( newValue )
        
        return self
    end
    
    -- Set a slider's minimum, maximum, step, and value
    function RLSettingSlider:SetSettings( newValues: table ) 
        local newMin = newValues.Min or 0
        local newMax = newValues.Max or 100
        local newStep = newValues.Step or 1 
        local newVal = newValues.Val or 0 
        
        local newFormat
        do 
            local stepStr = tostring(newStep)
            
            local pattern = '%d'
            if ( pattern:format(newStep) == stepStr ) then
                newFormat = pattern
            else
                for i = 1, 10 do 
                    pattern = '%.' .. i .. 'f'
                    if ( pattern:format(newStep) == stepStr ) then
                        newFormat = pattern
                        break
                    end
                end
            end
        end
        newFormat = newFormat or '%.3f'
        
        self.sMin = newMin 
        self.sMax = newMax
        self.sStep = newStep  
        self.sFormat = newFormat
        
        return self:SetValue(newVal)
    end
    
    -- Set's a slider's step to newStep. Use only when there is no alternative, as SetSettings is heavily preferred
    function RLSettingSlider:SetStep( newStep: number ) 
        local newFormat
        do 
            local stepStr = tostring(newStep)
            
            local pattern = '%d'
            if ( pattern:format(newStep) == stepStr ) then
                newFormat = pattern
            else
                for i = 1, 10 do 
                    pattern = '%.' .. i .. 'f'
                    if ( pattern:format(newStep) == stepStr ) then
                        newFormat = pattern
                        break
                    end
                end
            end
        end
        
        self.sStep = newStep 
        self.sFormat = newFormat or '%.3f'
                    
        return self:SetValue( self.sVal )
    end
    
    -- Set's a slider's minimum to newMin. Use only when there is no alternative, as SetSettings is heavily preferred
    function RLSettingSlider:SetMinimum( newMin: number ) 
        self.sMin = newMin 
        
        return self:SetValue( self.sVal )
    end
    
    -- Set's a slider's maximum to newMax. Use only when there is no alternative, as SetSettings is heavily preferred
    function RLSettingSlider:SetMaximum( newMax: number ) 
        self.sMin = newMax 
        
        return self:SetValue( self.sVal )
    end
    
    --- Constructor
    function RLSettingSlider.new( Parent: table, SettingName: string, ZIndex: number ) 
        --- Setup
        local this = RLBaseSetting.new( Parent, SettingName, ZIndex, 2 )
        setmetatable( this, RLSettingSlider )
        this.sMin = 0
        this.sMax = 100 
        this.sStep = 1
        this.sVal = 0
        this.sFormat = '%d'
        
        this.connections = {} 
        this.SlideState = false
        
        --- Objects
        local objects = {}
        do 
            -- objects.Main
            do
                local Main = Instance.new('Frame')
                Main.BackgroundColor3 = InterfaceTheme.Shade3
                Main.BorderSizePixel = 0 
                Main.ClipsDescendants = true 
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
            
            -- objects.Input
            do 
                local Input = Instance.new('TextBox')
                Input.Active = true 
                Input.BackgroundColor3 = InterfaceTheme.Shade3
                Input.BackgroundTransparency = 0.2
                Input.BorderSizePixel = 0
                Input.BorderSizePixel = Color3.new(1, 1, 1) 
                Input.ClearTextOnFocus = true
                Input.Font = InterfaceTheme.Font
                Input.PlaceholderText = 'Enter a new value' 
                Input.Size = UDim2.fromScale(1, 1)
                Input.Text = Input.PlaceholderText
                Input.TextColor3 = InterfaceTheme.Text_Shade3
                Input.TextSize = InterfaceTheme.TextSize - 2 
                Input.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                Input.TextStrokeTransparency = 0.5
                Input.TextXAlignment = 'Center'
                Input.TextYAlignment = 'Center'
                Input.Visible = false 
                Input.ZIndex = ZIndex + 2
                
                Input.Parent = objects.Main
                objects.Input = Input
            end
            
            
            -- objects.PromptSound
            do 
                local PromptSound = Instance.new('Sound')
                PromptSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                PromptSound.PlaybackSpeed = 1.5
                PromptSound.SoundId = CustomAssets['Sounds/guiCtrl_Menu.mp3']
                
                PromptSound.Parent = objects.Input
                objects.PromptSound = PromptSound 
            end
            
            -- objects.CloseSound
            do 
                local CloseSound = Instance.new('Sound')
                CloseSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                CloseSound.SoundId = CustomAssets['Sounds/guiCtrl_Toggle.mp3']
                
                CloseSound.Parent = objects.Input
                objects.CloseSound = CloseSound 
            end
            
            -- objects.Slider
            do 
                local Slider = Instance.new('Frame')
                Slider.BackgroundColor3 = InterfaceTheme.Shade1
                Slider.BorderColor3 = InterfaceTheme.Outline
                Slider.BorderSizePixel = 1
                Slider.ClipsDescendants = true 
                Slider.Position = UDim2.fromOffset(5, 6)
                Slider.Size = UDim2.new(1, -10, 0, 12)
                Slider.Visible = true
                Slider.ZIndex = ZIndex + 1
                
                Slider.Parent = objects.Main
                objects.Slider = Slider
            end
            
            -- objects.Fill
            do 
                local Fill = Instance.new('Frame')
                Fill.BackgroundColor3 = InterfaceTheme.Enabled
                Fill.BackgroundTransparency = 0
                Fill.BorderSizePixel = 0
                Fill.Position = UDim2.fromOffset(0, 0)
                Fill.Size = UDim2.fromScale(0, 1)
                Fill.ZIndex = ZIndex + 1 
                
                local Gradient = Instance.new('UIGradient')
                Gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1.0, 1.0, 1.0)),
                    ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 0.7))
                })
                Gradient.Rotation = 90
                Gradient.Parent = Fill
                
                Fill.Parent = objects.Slider
                objects.Fill = Fill 
            end
            
            -- objects.Dimmer
            do 
                local Dimmer = Instance.new('Frame')
                Dimmer.BackgroundColor3 = InterfaceTheme.Shade3
                Dimmer.BackgroundTransparency = 0.3 
                Dimmer.BorderSizePixel = 0
                Dimmer.Size = UDim2.fromScale(1, 1)
                Dimmer.ZIndex = ZIndex + 1
                
                Dimmer.Parent = objects.Main
                objects.Dimmer = Dimmer 
            end
            
            -- objects.Label
            do 
                local Label = Instance.new('TextLabel')
                Label.BackgroundTransparency = 1
                Label.Font = InterfaceTheme.Font
                Label.Position = UDim2.fromOffset(8, 0)
                Label.Size = UDim2.new(0.6, -8, 1, 0)
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
            
            -- objects.Value
            do 
                local Value = Instance.new('TextLabel')
                Value.AnchorPoint = Vector2.new(1, 0)
                Value.BackgroundTransparency = 1
                Value.Font = InterfaceTheme.Font
                Value.Position = UDim2.new(1, -5, 0, 0)
                Value.Size = UDim2.new(0, 20, 1, 0)
                Value.Text = '0'  
                Value.TextColor3 = InterfaceTheme.Text_Shade3
                Value.TextSize = InterfaceTheme.TextSize - 2 
                Value.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                Value.TextStrokeTransparency = 0.5
                Value.TextXAlignment = 'Right'
                Value.TextYAlignment = 'Center'
                Value.ZIndex = ZIndex + 1
                
                Value.Parent = objects.Main
                objects.Value = Value
            end
        end
        
        --- Events
        do 
            objects.Slider.InputBegan:Connect(function( input )
                if ( input.UserInputType.Name ~= 'MouseButton1' ) then
                    return
                end
                
                if ( this.SlideState ) then
                    local slideCon = this.connections.slideCon 
                    local slideEnd = this.connections.slideEnd
                    
                    if ( slideCon ) then 
                        slideCon:Disconnect()
                    end
                    if ( slideEnd ) then
                        slideEnd:Disconnect() 
                    end
                end
                
                this.SlideState = true
                
                local sliderStart = objects.ClickSensor.AbsolutePosition + guiService:GetGuiInset()
                local sliderWidth = objects.Slider.AbsoluteSize.X
                
                this.connections.slideCon = inputService.InputChanged:Connect(function() 
                    local mouseCur = inputService:GetMouseLocation().X - 4 -- for some reason the mouse position is offset from the slider, subtracting 4 fixes it
                    
                    -- get mouse position relative to the slider position
                    local mouseRelative = mouseCur - sliderStart.X
                    -- divide by the slider width to get a value from 0 to 1, and clamp it
                    local rangeValue = math.clamp(mouseRelative / sliderWidth, 0, 1)
                    -- scale value from min to max, accounting for the min value
                    local scaledValue = rangeValue * ( this.sMax - this.sMin ) + this.sMin
                    -- round the value to the step 
                    local roundedValue = round(scaledValue, this.sStep)
                    
                    this:SetFinishedValue(roundedValue)
                end)
                
                this.connections.slideEnd = inputService.InputEnded:Connect(function(input) 
                    if ( input.UserInputType.Name == 'MouseButton1' ) then
                        this.SlideState = false 
                
                        local slideCon = this.connections.slideCon 
                        local slideEnd = this.connections.slideEnd
                        
                        if ( slideCon ) then 
                            slideCon:Disconnect()
                        end
                        if ( slideEnd ) then
                            slideEnd:Disconnect() 
                        end
                    end
                end)
                
                do 
                    local mouseCur = inputService:GetMouseLocation().X - 4 
                    -- get mouse position relative to the slider position
                    local mouseRelative = mouseCur - sliderStart.X
                    -- divide by the slider width to get a value from 0 to 1, and clamp it
                    local rangeValue = math.clamp(mouseRelative / sliderWidth, 0, 1)
                    -- scale value from min to max, accounting for the min value
                    local scaledValue = rangeValue * ( this.sMax - this.sMin ) + this.sMin
                    -- round the value to the step 
                    local roundedValue = round(scaledValue, this.sStep)
                    
                    this:SetFinishedValue(roundedValue)
                end
            end)
            
            objects.ClickSensor.MouseButton2Click:Connect(function() 
                local input = objects.Input
                input.Position = UDim2.fromScale(0, -1)
                input.Visible = true
                
                objects.PromptSound:Play()
                
                input.MaxVisibleGraphemes = 0
                Tween.Quick(input, {
                    MaxVisibleGraphemes = #input.Text
                })
                
                Tween.Quick(input, {
                    Position = UDim2.fromScale(0, 0)
                })
                
                input:CaptureFocus()
            end)
            
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
                Tween.Quick(objects.Value, {
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, 0)
                })
                objects.Value.TextXAlignment = 'Center'
                
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
                Tween.Quick(objects.Value, {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -5, 0, 0)
                })
                objects.Value.TextXAlignment = 'Right'
                
                if ( this.tooltip ) then 
                    instances.Tooltip:Hide(this)
                end
            end)
            
            do
                --local lastScroll = tick()
                --local raw = this:GetValue()
                
                objects.ClickSensor.InputChanged:Connect(function( input ) 
                    if ( input.UserInputType.Name == 'MouseWheel' ) then
                        local scrollAmnt = input.Position.Z * math.max( this.sStep, 1 )
                        
                        this:SetValue( this.sVal + scrollAmnt )
                        
                        --[[local nowScroll = tick()
                        
                        if ( nowScroll - lastScroll > 0.3 ) then
                            -- new scroll
                            raw = this:GetValue()
                        end
                        
                        lastScroll = nowScroll
                                                    
                        local scroll = input.Position.Z * this.sStep 
                        raw += scroll
                        
                        this:SetValue( raw )]]
                    end
                end)
                
            end
            
            objects.Input.FocusLost:Connect(function( enter ) 
                if ( not enter ) then
                    return 
                end 
                
                local input = objects.Input
                local text = input.Text:match('^%s*(.-)%s*$') -- trim whitespace at each edge
                local num = tonumber(text)
                
                if ( num ) then                     
                    this:SetValue(num)
                    
                elseif ( text ~= '' ) then 
                    input.Text = 'Invalid input'
                    task.wait(1)
                end
                
                objects.CloseSound:Play()
                
                Tween.Quick(input, {
                    MaxVisibleGraphemes = 0
                })
                
                Tween.Quick(input, {
                    Position = UDim2.fromScale(0, -1)
                }).Completed:Wait()
                
                input.Text = 'Enter a new value'
                input.Visible = false
            end)
        end
        
        --- Finalization 
        this.objects = objects 
        return this 
    end
    
    --- Destructor
    -- Inherited from RLBase
end

return RLSettingSlider
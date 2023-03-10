--- RLSettingHotkey : RLBaseSetting
-- A simple keybind selector. Now supports mouse buttons - unbinding is done via the right-click unbind menu
local RLSettingHotkey: RLBaseSetting = {} do 
    --- Setup
    RLSettingHotkey.__index = RLSettingHotkey
    RLSettingHotkey.class = 'RLSettingHotkey'
    setmetatable(RLSettingHotkey, RLBaseSetting)
    
    --- Interaction
    function RLSettingHotkey:Focus() 
        local time = 0
        local dots = 0
        
        local hotkeyLabel = self.objects.Hotkey
        local connections = self.connections
        
        Tween.Quick(hotkeyLabel, {
            TextColor3 = InterfaceTheme.Enabled
        })
        
        hotkeyLabel.Text = ' Press any key '
        
        --[[connections.idleAnim = runService.Heartbeat:Connect(function(deltaTime) 
            time += deltaTime 
            
            if ( time > 0 ) then
                time -= 0.2
                dots += 1
                
                local dotCount = (dots % 3) + 1
                hotkeyLabel.Text = string.format(' Press any key ', string.rep( '.', dotCount ))
            end
        end)]]
        
        connections.keyRead = inputService.InputBegan:Connect(function(input) 
            
            Tween.Quick(hotkeyLabel, {
                TextColor3 = InterfaceTheme.Text_Shade3
            })
            
            self:SetHotkeyInternal( input.KeyCode, input.UserInputType )
            
            --connections.keyRead:Disconnect()
        end)
    end
    
    function RLSettingHotkey:SetHotkeyInternal( keyCode: KeyCode, inputType: UserInputType ) 
        -- disconnect the input getter connection
        local keyRead = self.connections.keyRead
        if ( keyRead and keyRead.Connected ) then
            keyRead:Disconnect()    
        end
        
        -- localize hotkey label since it'll be modified frequently
        local hotkeyLabel = self.objects.Hotkey
        
        -- check for an existing bind, unbind it if one exists
        if ( self.CurrentHotkey ) then
            local index = table.find(hotkeys, self.CurrentHotkey)
            
            if ( index ) then
                table.remove(hotkeys, index)
            end
        end
        
        local newHotkey = {} -- the hotkey object storing info about the hotkey
        local finalBindValue -- the final value that'll be displayed
        
        -- check the input type 
        if ( inputType.Name == 'Keyboard' ) then
            -- a key is being bound, make sure that it's valid 
            if ( keyCode.Name ~= 'Unknown' and keyCode.Name ~= 'Escape' ) then 
                -- if it is then set the bind to this key 
                newHotkey.key = keyCode
                finalBindValue = keyCode.Name 
            end
        else
            -- if its not a keyboard input its likely some type of mouse input, make sure that it's valid
            if ( inputType.Name ~= 'None' ) then 
                newHotkey.input = inputType
                finalBindValue = inputType.Name 
            end
        end
         
        if ( finalBindValue ) then 
            -- since hotkeys can both be bound to modules or be standalone just for getting an input
            -- to support both, check for an existing linked control
            if ( self.LinkedInstance ) then 
                -- if there is one, set parameters for it and insert it into the hotkeys list 
                -- .callback and .parent let a pseudo namecall thing be done instead of making a new function every time like beta redline
                newHotkey.callback = self.LinkedFunction 
                newHotkey.parent = self.LinkedInstance
                newHotkey.set = time() -- time is more precise than os.time(), but less precise than tick() (which is needed for this to even work)
                
                table.insert(hotkeys, newHotkey)
                self.CurrentHotkey = newHotkey
            else
                -- since this is a standalone hotkey nothing has to be done 
            end
            
            -- set the label text
            hotkeyLabel.Text = string.format(' %s ', finalBindValue) 
            -- set the current hotkey 
            self.CurrentHotkey = newHotkey
            
            self:Fire('OnBind', newHotkey.key or newHotkey.input, finalBindValue)
        else
            -- there is no bind, set text to none and remove the hotkey 
            hotkeyLabel.Text = ' None '
            
            self:Fire('OnBind', nil)
            self.CurrentHotkey = nil
        end
    
        return self
    end
    
    function RLSettingHotkey:SetHotkey( newKey: any ) 
        local inputType, keyCode 
        
        -- if the input is a string (ex 'MouseButton1', 'RightShift') convert it into an enum
        if ( typeof(newKey) == 'string' ) then
            -- this is so fucking cringe
            for _, kc in ipairs( Enum.KeyCode:GetEnumItems() ) do 
                if ( newKey == kc.Name ) then
                    keyCode = kc
                    break
                end
            end
            
            if ( keyCode ) then
                inputType = Enum.UserInputType.Keyboard
            else 
                for _, it in ipairs( Enum.UserInputType:GetEnumItems() ) do 
                    if ( newKey == it.Name ) then
                        inputType = it
                        break
                    end
                end
            end
        else
            if ( typeof(newKey) == 'EnumItem' ) then
                if ( newKey.EnumType == Enum.KeyCode ) then
                    keyCode = newKey
                    inputType = Enum.UserInputType.Keyboard
                elseif ( newKey.EnumType == Enum.UserInputType ) then
                    inputType = newKey
                end
            end
        end
        
        keyCode = keyCode or Enum.KeyCode.Unknown
        inputType = inputType or Enum.UserInputType.None
                    
        -- and call SetHotkeyInternal to save extra space
        return self:SetHotkeyInternal( keyCode, inputType )
    end
    
    function RLSettingHotkey:GetHotkey() 
        local hotkeyInfo = self.CurrentHotkey 
        
        return hotkeyInfo.key or hotkeyInfo.input
    end
    
    function RLSettingHotkey:MakeLink( Module: RLModule, Func: string ) 
        self.LinkedInstance = Module
        self.LinkedFunction = Module[Func]
        
        return self 
    end
    
    function RLSettingHotkey:RemoveLink() 
        self.LinkedInstance = nil
        self.LinkedFunction = nil
        
        return self 
    end
    
    function RLSettingHotkey:MatchesInput( input: InputObject ) 
        local hotkey = self.CurrentHotkey
        if ( hotkey ) then
            if ( hotkey.input == input.UserInputType ) then
                return true
                
            elseif ( hotkey.key == input.KeyCode ) then
                return true
            end 
            
        else
            return false 
        end
        
        return false 
    end
    
    function RLSettingHotkey:IsInputPressed()
        local hotkey = self.CurrentHotkey 
        if ( hotkey ) then
            if ( hotkey.key ) then
                return inputService:IsKeyDown( hotkey.key ) 
                
            elseif ( hotkey.input ) then
                return inputService:IsMouseButtonPressed( hotkey.input ) 
            end
        else
            return false
        end
        
        return false 
    end
    
    
    function RLSettingHotkey:OpenUnbindPrompt() 
        if ( self.PromptStatus == true ) then
            return self
        end
        
        self.PromptStatus = true 
        
        local objects = self.objects 
        local dimmer = objects.Dimmer 
        local prompt = objects.ResetPrompt 
        
        prompt.MaxVisibleGraphemes = 0
        Tween.Quick(prompt, {
            MaxVisibleGraphemes = #prompt.Text
        })
        
        dimmer.Position = UDim2.fromScale(0, -1)
        dimmer.Visible = true
        Tween.Quick(dimmer, {
            Position = UDim2.fromScale()
        })
        
        return self
    end
    
    function RLSettingHotkey:CloseUnbindPrompt() 
        if ( self.PromptStatus == false ) then
            return self
        end
        
        self.PromptStatus = false 
        
        local objects = self.objects 
        local dimmer = objects.Dimmer 
        local prompt = objects.ResetPrompt 
        
        Tween.Quick(prompt, {
            MaxVisibleGraphemes = 0
        })
        
        dimmer.Position = UDim2.fromScale()
        dimmer.Visible = true
        
        task.spawn(function()
            Tween.Quick(dimmer, {
                Position = UDim2.fromScale(0, -1)
            }).Completed:Wait()
            
            dimmer.Visible = false
        end)
        
        return self
    end
    
    RLSettingHotkey.GetValue = RLSettingHotkey.GetHotkey
    RLSettingHotkey.GetBind = RLSettingHotkey.GetHotkey
    RLSettingHotkey.SetValue = RLSettingHotkey.SetHotkey 
    
    RLSettingHotkey.ValidateInput = RLSettingHotkey.MatchesInput
    RLSettingHotkey.CheckInput = RLSettingHotkey.MatchesInput
    
    RLSettingHotkey.IsInputDown = RLSettingHotkey.IsInputPressed
    
    --- Constructor
    function RLSettingHotkey.new( Parent: table, SettingName: string, ZIndex: number ) 
        --- Setup
        local this = RLBaseSetting.new( Parent, SettingName, ZIndex )
        setmetatable( this, RLSettingHotkey )
        -- Properties
        this.connections = {}
        
        this.PromptStatus = false 
        
        --- Objects
        local objects = this.objects
        do 
            objects.Main.ClipsDescendants = true 
            
            -- objects.Hotkey
            do 
                local Hotkey = Instance.new('TextLabel')
                Hotkey.AnchorPoint = Vector2.new(1, 0)
                Hotkey.AutomaticSize = 'X'
                Hotkey.BackgroundColor3 = InterfaceTheme.Shade1
                Hotkey.BorderColor3 = InterfaceTheme.Outline
                Hotkey.BorderSizePixel = 1
                Hotkey.Font = InterfaceTheme.Font
                Hotkey.Position = UDim2.new(1, -5, 0, 5) 
                Hotkey.Size = UDim2.fromOffset(30, 14)
                Hotkey.Text = ' None '
                Hotkey.TextColor3 = InterfaceTheme.Text_Shade3
                Hotkey.TextSize = InterfaceTheme.TextSize - 2 
                Hotkey.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                Hotkey.TextStrokeTransparency = 0.5
                Hotkey.TextXAlignment = 'Center'
                Hotkey.TextYAlignment = 'Center'
                Hotkey.Visible = true
                Hotkey.ZIndex = ZIndex
                
                Hotkey.Parent = objects.Main
                objects.Hotkey = Hotkey
            end
            
            -- objects.Dimmer
            do 
                local Dimmer = Instance.new('Frame')
                Dimmer.BackgroundColor3 = InterfaceTheme.Shade3
                Dimmer.BackgroundTransparency = 0.3 
                Dimmer.BorderSizePixel = 0
                Dimmer.Position = UDim2.fromScale(0, 0)
                Dimmer.Size = UDim2.fromScale(1, 1)
                Dimmer.Visible = false 
                Dimmer.ZIndex = ZIndex + 1
                
                Dimmer.Parent = objects.Main
                objects.Dimmer = Dimmer 
            end
            
            -- objects.ToggleSound
            do 
                local ToggleSound = Instance.new('Sound')
                ToggleSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                ToggleSound.SoundId = CustomAssets['Sounds/guiCtrl_Toggle.mp3']
                
                ToggleSound.Parent = objects.Dimmer -- epically reuse the same toggle sound 😎
                objects.ToggleSound = ToggleSound 
            end
            
            -- objects.OpenSound
            do 
                local OpenSound = Instance.new('Sound')
                OpenSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                OpenSound.PlaybackSpeed = 1.5
                OpenSound.SoundId = CustomAssets['Sounds/guiCtrl_Menu.mp3']
                
                OpenSound.Parent = objects.Dimmer
                objects.OpenSound = OpenSound 
            end
            
            -- objects.ResetPrompt
            do 
                local ResetPrompt = Instance.new('TextLabel')
                ResetPrompt.BackgroundTransparency = 1
                ResetPrompt.Font = InterfaceTheme.Font
                ResetPrompt.Position = UDim2.fromOffset(8, 0)
                ResetPrompt.Size = UDim2.fromOffset(60, 24)
                ResetPrompt.Text = 'Reset this bind?'
                ResetPrompt.TextColor3 = InterfaceTheme.Text_Shade3
                ResetPrompt.TextSize = InterfaceTheme.TextSize - 2 
                ResetPrompt.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                ResetPrompt.TextStrokeTransparency = 0.5
                ResetPrompt.TextXAlignment = 'Left'
                ResetPrompt.TextYAlignment = 'Center'
                ResetPrompt.Visible = true 
                ResetPrompt.ZIndex = ZIndex + 1 
                
                ResetPrompt.Parent = objects.Dimmer
                objects.ResetPrompt = ResetPrompt
            end      
                 
            -- objects.ResetButton 
            do 
                local ResetButton = Instance.new('TextButton')
                ResetButton.AnchorPoint = Vector2.new(1, 0)
                ResetButton.AutoButtonColor = false 
                ResetButton.BackgroundColor3 = InterfaceTheme.Shade1
                ResetButton.BorderColor3 = InterfaceTheme.Outline
                ResetButton.BorderSizePixel = 1
                ResetButton.Font = InterfaceTheme.Font
                ResetButton.Position = UDim2.new(1, -50, 0, 5) 
                ResetButton.Size = UDim2.fromOffset(40, 14)
                ResetButton.Text = 'Yes'
                ResetButton.TextColor3 = InterfaceTheme.Text_Shade3
                ResetButton.TextSize = InterfaceTheme.TextSize - 2 
                ResetButton.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                ResetButton.TextStrokeTransparency = 0.5
                ResetButton.TextXAlignment = 'Center'
                ResetButton.TextYAlignment = 'Center'
                ResetButton.Visible = true
                ResetButton.ZIndex = ZIndex + 1 
                
                ResetButton.Parent = objects.Dimmer
                objects.ResetButton = ResetButton
            end
            
            -- objects.ResetButtonHover
            do 
                local Hover = Instance.new('Frame')
                Hover.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                Hover.BackgroundTransparency = 1
                Hover.BorderSizePixel = 0
                Hover.Size = UDim2.fromScale(1, 1)
                Hover.ZIndex = ZIndex + 1  
                
                Hover.Parent = objects.ResetButton
                objects.ResetButtonHover = Hover
            end
            
            -- objects.CancelButton 
            do 
                local CancelButton = Instance.new('TextButton')
                CancelButton.AnchorPoint = Vector2.new(1, 0)
                CancelButton.AutoButtonColor = false 
                CancelButton.BackgroundColor3 = InterfaceTheme.Shade1
                CancelButton.BorderColor3 = InterfaceTheme.Outline
                CancelButton.BorderSizePixel = 1
                CancelButton.Font = InterfaceTheme.Font
                CancelButton.Position = UDim2.new(1, -5, 0, 5) 
                CancelButton.Size = UDim2.fromOffset(40, 14)
                CancelButton.Text = 'No'
                CancelButton.TextColor3 = InterfaceTheme.Text_Shade3
                CancelButton.TextSize = InterfaceTheme.TextSize - 2 
                CancelButton.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                CancelButton.TextStrokeTransparency = 0.5
                CancelButton.TextXAlignment = 'Center'
                CancelButton.TextYAlignment = 'Center'
                CancelButton.Visible = true
                CancelButton.ZIndex = ZIndex + 1 
                
                CancelButton.Parent = objects.Dimmer
                objects.CancelButton = CancelButton
            end
            
            -- objects.CancelButtonHover
            do 
                local Hover = Instance.new('Frame')
                Hover.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
                Hover.BackgroundTransparency = 1
                Hover.BorderSizePixel = 0
                Hover.Size = UDim2.fromScale(1, 1)
                Hover.ZIndex = ZIndex + 1  
                
                Hover.Parent = objects.CancelButton
                objects.CancelButtonHover = Hover
            end
        end
        
        --- Events
        do 
            objects.ClickSensor.MouseButton1Click:Connect(function() 
                if ( this.PromptStatus ) then 
                    return
                end 
                
                this:Focus()
            end)
            
            objects.ClickSensor.MouseButton2Click:Connect(function() 
                objects.OpenSound:Play()
                
                this:OpenUnbindPrompt()
            end)
            
            objects.CancelButton.MouseEnter:Connect(function() 
                Tween.Quick(objects.CancelButtonHover, {
                    BackgroundTransparency = 0.985
                })
            end)
            
            objects.CancelButton.MouseLeave:Connect(function() 
                Tween.Quick(objects.CancelButtonHover, {
                    BackgroundTransparency = 1
                })
            end)
            
            objects.ResetButton.MouseButton1Click:Connect(function() 
                objects.ToggleSound:Play()
                
                this:SetHotkey(nil)
                this:CloseUnbindPrompt()
            end)
            
            objects.CancelButton.MouseButton1Click:Connect(function() 
                objects.ToggleSound:Play()
                
                this:CloseUnbindPrompt()
            end)
            
            objects.ResetButton.MouseEnter:Connect(function() 
                Tween.Quick(objects.ResetButtonHover, {
                    BackgroundTransparency = 0.985
                })
            end)
            
            objects.ResetButton.MouseLeave:Connect(function() 
                Tween.Quick(objects.ResetButtonHover, {
                    BackgroundTransparency = 1
                })
            end)
        end
        
        --- Finalization 
        return this 
    end
    
    --- Destructor
    -- Inherited from RLBase
end

return RLSettingHotkey
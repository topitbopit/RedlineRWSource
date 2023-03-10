--- RLNotif : RLBase
-- Class for notifs 
local RLNotif: RLBase = {} do 
    --- Setup
    RLNotif.__index = RLNotif
    RLNotif.class = 'RLNotif'
    setmetatable(RLNotif, RLBase)
    
    --- Interaction 
    do 
        local soundSwitch = {
            Error = 'Sounds/notif_Error.mp3';
            Friend = 'Sounds/notif_Friend.mp3';
            Generic = 'Sounds/notif_Generic.mp3';
            Success = 'Sounds/notif_Success.mp3';
            Warning = 'Sounds/notif_Warning.mp3';
        } 
        local iconSwitch = {
            Generic = 'rbxassetid://11140658143';
            Friend = 'rbxassetid://11140661564';
            Warning = 'rbxassetid://11140659388';
            
            Error = 'rbxassetid://11140659388';
            Success = 'rbxassetid://11140658143';
        }
        
        function RLNotif:SetType( newType: string ) 
            local objects = self.objects
            
            objects.Sound.SoundId = CustomAssets[ soundSwitch[ newType ] ]
            objects.Icon.Image = iconSwitch[ newType ]
            
            return self 
        end
        
        function RLNotif:SetTitle( TitleText: string ) 
            local addedSize = UDim2.fromOffset(5, 0)
            
            local objects = self.objects
            local Main = objects.Main
            local Title = objects.Title
            
            Title.Text = TitleText 
            
            for i = 1, 20 do 
                if ( Title.TextFits ) then
                    break 
                end
                
                Main.Size += addedSize
            end
            
            Main.Size += addedSize
            
            Title.MaxVisibleGraphemes = 0
            Tween.Quick(Title, {
                MaxVisibleGraphemes = #TitleText
            })
            
            return self 
        end
        
        function RLNotif:SetDesc( DescText: string )
            local addedSize = UDim2.fromOffset(5, 0)
            
            local objects = self.objects
            local Main = objects.Main
            local Description = objects.Description
            
            Description.Text = DescText 
            
            for i = 1, 20 do 
                if ( Description.TextFits ) then
                    break 
                end
                
                Main.Size += addedSize
            end
            
            Main.Size += addedSize 
            
            Description.MaxVisibleGraphemes = 0
            Tween.Quick(Description, {
                MaxVisibleGraphemes = #DescText
            })
            
            return self 
        end
    end
    --- Constructor
    function RLNotif.new() 
        --- Setup
        local this = RLBase.new()
        setmetatable(this, RLNotif)
        
        --- Objects
        local objects = {}
        do 
            -- objects.Main
            do 
                local Main = Instance.new('Frame')
                Main.AnchorPoint = Vector2.new(1, 1)
                Main.BackgroundColor3 = InterfaceTheme.Shade2
                Main.BackgroundTransparency = 0.2
                Main.BorderSizePixel = 0
                Main.Size = UDim2.fromOffset(200, 100)
                Main.Visible = false
                Main.ZIndex = 7000
                
                Main.Parent = instances.ScreenGui 
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
            
            -- objects.Header
            do
                local Header = Instance.new('Frame')
                Header.BackgroundColor3 = InterfaceTheme.Shade1
                Header.BackgroundTransparency = 0.25
                Header.BorderSizePixel = 0
                Header.Size = UDim2.new(1, 0, 0, 26)
                Header.Visible = true
                Header.ZIndex = 7001
                
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
            
            -- objects.Icon
            do 
                local Icon = Instance.new('ImageLabel')
                Icon.BackgroundTransparency = 1
                Icon.Image = 'rbxassetid://11140658143' -- Generic: 11140658143 Warning: 11140659388 Person: 11140661564
                Icon.ImageColor3 = InterfaceTheme.Enabled 
                Icon.Position = UDim2.fromOffset(3, 3)
                Icon.Size = UDim2.fromOffset(20, 20)
                Icon.ZIndex = 7001 
                
                local Gradient = Instance.new('UIGradient')
                Gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1.0, 1.0, 1.0)),
                    ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 0.7))
                })
                Gradient.Rotation = 90
                Gradient.Parent = Icon
                
                Icon.Parent = objects.Header
                objects.Icon = Icon
            end
            
            -- objects.Title 
            do 
                local Title = Instance.new('TextLabel')
                Title.BackgroundTransparency = 1
                Title.Font = InterfaceTheme.Font
                Title.Position = UDim2.fromOffset(26, 0)
                Title.Size = UDim2.new(1, -26, 1, 0)
                Title.Text = 'Placeholder text'  
                Title.TextColor3 = InterfaceTheme.Text_Shade1
                Title.TextSize = InterfaceTheme.TextSize
                Title.TextStrokeColor3 = InterfaceTheme.Text_Stroke
                Title.TextStrokeTransparency = 0.5
                Title.TextXAlignment = 'Left'
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
                
                Description.Parent = objects.Main
                objects.Description = Description
            end
            -- objects.Sound
            do 
                local Sound = Instance.new('Sound')
                Sound.Volume = ActiveConfig.Interface.NotifSounds and 1 or 0 
                Sound.SoundId = CustomAssets['Sounds/notif_Generic.mp3']
                
                Sound.Parent = objects.Main
                objects.Sound = Sound 
            end
            
        end
        
        --- Finalization 
        this.objects = objects
        return this 
    end
    
    --- Destructor
    -- Inherited from RLBase
end

return RLNotif
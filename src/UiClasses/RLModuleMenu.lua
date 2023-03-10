--- RLModuleMenu : RLBaseMenu
-- Container for modules
local RLModuleMenu: RLBaseMenu = {} do 
    --- Setup 
    RLModuleMenu.__index = RLModuleMenu
    RLModuleMenu.class = 'RLModuleMenu'
    setmetatable(RLModuleMenu, RLBaseMenu)
    
    --- Interaction
    function RLModuleMenu:ToggleMenu() 
        self.MenuState = not self.MenuState
        
        local objects = self.objects 
        local container = objects.Container
                  
        if ( self.MenuState ) then
            Tween.Quick(objects.Arrow, {
                Rotation = 180
            })
            
            objects.Container.Visible = true
            objects.Main.AutomaticSize = 'Y'
            
            objects.OpenSound:Play()
        else
            Tween.Quick(objects.Arrow, {
                Rotation = 0
            })
            
            objects.Container.Visible = false
            objects.Main.AutomaticSize = 'None'
            
            objects.OpenSound:Play()
        end
    end
    
    --- Element
    function RLModuleMenu:AddModule(ModuleName: string, DisableHotkey: boolean) 
        local this = UiClasses.RLModule.new(self, ModuleName, self.zindex)
        
        if ( DisableHotkey ~= true ) then
            local hotkey = this:AddHotkey('Hotkey')
            hotkey:SetTooltip(string.format('Toggles %s when this key is pressed', ModuleName))
            hotkey:MakeLink(this, 'Toggle')
            this.LinkedHotkey = hotkey
        end
        
        this.objects.Main.Parent = self.objects.Container 
        
        return this
    end
    
    --- Constructor
    function RLModuleMenu.new( Parent: table, MenuName: string, IconId: string, ZIndex: number ) 
        IconId = IconId or ''
        
        --- Setup
        local this = RLBaseMenu.new(Parent, MenuName, IconId, ZIndex)
        setmetatable(this, RLModuleMenu)           
        this.index = #Parent.children - 1
        
        --- Objects
        local objects = this.objects 
        do 
            -- objects.Arrow
            do 
                local Arrow = Instance.new('ImageLabel')
                Arrow.AnchorPoint = Vector2.new(1, 0)
                Arrow.BackgroundTransparency = 1
                Arrow.Image = 'rbxassetid://10667805858'
                Arrow.ImageColor3 = Color3.fromRGB(250, 250, 255)
                Arrow.Position = UDim2.new(1, -8, 0, 8)
                Arrow.ResampleMode = 'Pixelated' -- not sure if this is needed
                Arrow.Rotation = 180 
                Arrow.Size = UDim2.fromOffset(14, 14)
                Arrow.ZIndex = ZIndex + 1
                
                Arrow.Parent = objects.Header 
                objects.Arrow = Arrow
            end
            
            -- objects.OpenSound
            do 
                local OpenSound = Instance.new('Sound')
                OpenSound.Volume = ActiveConfig.Interface.FeedbackSounds and 0.7 or 0
                OpenSound.PlaybackSpeed = 1.5
                OpenSound.SoundId = CustomAssets['Sounds/guiCtrl_Menu.mp3']
                
                OpenSound.Parent = objects.Main
                objects.OpenSound = OpenSound 
            end
        end
        
        --- Events 
        do
            objects.ClickSensor.MouseButton2Click:Connect(function() 
                this:ToggleMenu()
            end)
        end
        
        --- Finalization 
        return this 
    end
    
    --- Destructor
    -- Inherited from RLBase
end

return RLModuleMenu
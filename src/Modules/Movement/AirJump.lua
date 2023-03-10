--- REDLINE MODULE
-- Module: Air jump
-- Category: Movement
-- Description: Lets you infinitely jump, even if you aren't touching the ground
-- Version: v1.0.0

local Module = Movement:AddModule('Air jump')
    :SetTooltip('Lets you infinitely jump mid-air. Depending on your settings, this can bypass jump restrictions that may be in place.')
    --:SetHotkey(ModuleBinds.AirJump)

do 
    local Settings = {}
    Settings.Mode = Module:AddDropdown('Mode')
        :MakePrimary()
        :SetTooltip('The method used for jumps / boosts. Each one may have varying performance depending on the game')
    
    do
        Settings.Mode:AddOption('Bypass')
            :SetTooltip('Avoids jumping entirely by directly modifying your velocity. Oftentimes this will bypass jump restrictions')
            :Select(true)
        Settings.Mode:AddOption('Jump')
            :SetTooltip('Forces a jump by changing your state. If the game does something to prevent you from jumping (like disabling the Jumping state), this won\'t work' )
    end
    
    Settings.Velocity = Module:AddSlider( 'Velocity amount' )
        :SetSettings({
            Min = -100,
            Max = 300,
            Val = 50,
            Step = 1
        })
        :SetTooltip('What your velocity gets set to when you jump. This setting only affects the "Bypass" mode')
        :LinkToOption( Settings.Mode:GetOption('Bypass') ) 
    Settings.Keybind = Module:AddHotkey('Jump key')
        :SetHotkey( Enum.KeyCode.Space )
        :SetTooltip('The key that causes you to jump. Defaults to space')         
    
    
    local function jump() 
        if ( Settings.Mode:GetSelection() == 'Jump' ) then
            localHumanoid:ChangeState('Jumping')
        else
            localRoot.Velocity = Vector3.new(0, Settings.Velocity:GetValue(), 0)
        end
    end
    
    local jumpCn
    Module:Connect('OnEnable', function() 
        jumpCn = inputService.InputBegan:Connect(function( input, gpe ) 
            if ( gpe == false and Settings.Keybind:CheckInput( input ) ) then
                jump()
            end
        end)
    end)

    Module:Connect('OnDisable', function() 
        if ( jumpCn and jumpCn.Connected ) then 
            jumpCn:Disconnect()
        end
    end)
    
    Settings.Mode:Connect('OnSelection', function() 
        Module:Reset()
    end)
end

return Module
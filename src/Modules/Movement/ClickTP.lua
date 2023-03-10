--- REDLINE MODULE
-- Module: Click TP
-- Category: Movement
-- Description: Lets you teleport to your mouse whenever you press ctrl + click
-- Version: v1.0.0

local Module = Movement:AddModule('Click TP')
    :SetTooltip('Simply teleports you to your mouse whenever you press a specified key combination')
    --:SetHotkey(ModuleBinds.ClickTP)

do 
    local Settings = {}
    Settings.Mode = Module:AddDropdown('Mode')
        :MakePrimary()
        :SetTooltip('The method used for teleporting')
    do
        Settings.Mode:AddOption('Instant')
            :SetTooltip('The normal method that instantly teleports you to your mouse')
            :Select( true )
        Settings.Mode:AddOption('Tween')
            :SetTooltip('Smoothly moves you towards your mouse with an optional speed. May bypass shitty anticheats')
    end
    
    Settings.TweenSpeed = Module:AddSlider('Tween speed')
        :SetSettings({
            Min = 0,
            Max = 100,
            Val = 50,
            Step = 1
        })
        :SetTooltip('How fast the tween teleports are')
        :LinkToOption( Settings.Mode:GetOption('Tween'))         
    
    Settings.OffsetY = Module:AddSlider('Y Offset')
        :SetSettings({
            Min = 0,
            Max = 10, 
            Val = 3,
            Step = 0.1 
        })
        :SetTooltip('An offset that gets added to where you teleport. Anything below 3 will shove you inside the ground!')
        
    Settings.KeyOne = Module:AddHotkey('Primary key')
        :SetHotkey( Enum.UserInputType.MouseButton1 )
        :SetTooltip( 'The primary key that needs to be held down in order to teleport' )
        
    Settings.KeyTwo = Module:AddHotkey('Secondary key')
        :SetHotkey( Enum.KeyCode.LeftControl )
        :SetTooltip( 'The secondary key that triggers the teleportation. If this isn\'t set, then a secondary key press won\'t be required' ) 
    
    --// end settings // --
    
    local playerMouse = localPlayer:GetMouse()  
    local inputCn
    
    local function teleport() 
        if ( not localRoot ) then
            return
        end
        
        local offset = Vector3.new(0, Settings.OffsetY:GetValue(), 0)
        local destPosition = playerMouse.Hit.Position + offset
        local destCFrame = CFrame.new(destPosition, destPosition + localRoot.CFrame.LookVector)
        
        if ( Settings.Mode:GetSelection() == 'Instant' ) then
            localRoot.CFrame = destCFrame 
            
        else
            local distance = ( localRoot.Position - destPosition ).Magnitude
            local speed = Settings.TweenSpeed:GetValue() * 5
            
            Tween.Linear( localRoot, { CFrame = destCFrame }, ( distance / speed ) )
        end
    end

    Module:Connect('OnEnable', function() 
        inputCn = inputService.InputBegan:Connect(function( input, gpe ) 
            if ( gpe == false and Settings.KeyOne:CheckInput(input)  ) then
                if ( Settings.KeyTwo:IsInputDown() ) then
                    teleport() 
                end
            end
        end)
    end)

    Module:Connect('OnDisable', function() 
        if ( inputCn and inputCn.Connected ) then 
            inputCn:Disconnect()
        end
    end)
end

return Module
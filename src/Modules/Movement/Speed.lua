--- REDLINE MODULE
-- Module: Speed
-- Category: Movement
-- Description: Standard speedhacks with several modes
-- Version: v1.0.0

local Module = Movement:AddModule('Speed')
    :SetTooltip('Standard speedhacks with several modes')
    --:SetHotkey( ModuleBinds.Speed )

do 
    local Settings = {}
    Settings.Mode = Module:AddDropdown('Mode')
        :MakePrimary()
        :SetTooltip('The method used for speed')
    
    do
        Settings.Mode:AddOption('CFrame')
            :SetTooltip('Adds the direction of your movement to your CFrame, increasing how fast you move')
            :Select( true )
        
        Settings.Mode:AddOption('Velocity')
            :SetTooltip('Kinda like CFrame, but it adds the direction to your velocity instead. Enable Frictionless for better performance')
            -- add toggle called Frictionless that changes your customphysics and maybe sets massless too
        Settings.Mode:AddOption('Bhop')
            :SetTooltip('Velocity, but it spam jumps. Although Bhop is primarily used for going insanely fast, it can legit in certain games with bhop mechanics')
        
        Settings.Mode:AddOption('Part')
            :SetTooltip('Creates a clientside part and pushes you with it. Pretty janky, but can be OP depending on the situation')
        
        Settings.Mode:AddOption('Walkspeed')
            :SetTooltip('This method is highly discouraged from being used, and does not have any protection from anticheats! Use one of the other modes, like CFrame!')
    end      
    
    Settings.Frictionless = Module:AddToggle('Frictionless')
        :SetTooltip('Reduces friction, improving the performance of Bhop and Velocity')
        :LinkToOption( Settings.Mode:GetOption('Velocity') )
        :LinkToOption( Settings.Mode:GetOption('Bhop') )
    
    Settings.DefaultSpeed = Module:AddSlider('Speed')
        :SetSettings({
            Min = 0,
            Max = 400,
            Val = 50,
            Step = 0.1
        })
        :SetTooltip('The speed amount used for every speedhack mode')
    
    -- // end settings // -- 
    
    local SpeedValue = Settings.DefaultSpeed:GetValue()
    Settings.DefaultSpeed:Connect('OnUpdate', function( NewValue ) 
        SpeedValue = NewValue
    end)
    
    local SpeedFuncs = {
        ['CFrame'] = function( DeltaTime ) 
            if ( not localRoot ) then
                return  
            end
            
            localRoot.CFrame += localHumanoid.MoveDirection * ( SpeedValue * 5 * DeltaTime )
        end,
        ['Velocity'] = function( DeltaTime ) 
            if ( not localRoot ) then
                return  
            end
            
            localRoot.Velocity += localHumanoid.MoveDirection * ( SpeedValue * 5 * DeltaTime )
        end
    }
    
    local SpeedCn
    Module:Connect('OnEnable', function() 
        local Mode = Settings.Mode:GetSelection() 
        
        if ( not SpeedFuncs[Mode] ) then
            return ui:Notify({
                Title = 'Whoops',
                Message = 'This mode is still being developed',
                Duration = 3,
                Type = 'Warning'
            }) 
        end
        
        SpeedCn = runService.Heartbeat:Connect(SpeedFuncs[Mode])
    end)

    Module:Connect('OnDisable', function() 
        if ( SpeedCn and SpeedCn.Connected ) then 
            SpeedCn:Disconnect()
        end
    end)
    
    Settings.Mode:Connect('OnSelection', function() 
        Module:Reset()
    end)
end

return Module

--[[local m_speed     = m_movement:addMod('Speed')
-- Speed
do 
    local mode = m_speed:addDropdown('Mode',true)
    mode:addOption('Standard'):setTooltip('Standard CFrame speed. <b>Mostly</b> undetectable, unlike other scripts such as Inf Yield. Also known as TPWalk'):Select()
    mode:addOption('Velocity'):setTooltip('Changes your velocity, doesn\'t use any bodymovers. Because of friction, Velocity typically won\'t increase your speed unless it\'s set high or you jump.')
    mode:addOption('Bhop'):setTooltip('The exact same as Velocity, but it spam jumps. Useful for looking legit in games with bhop mechanics, like Arsenal')
    mode:addOption('Part'):setTooltip('Pushes you physically with a clientside part. Can also affect vehicles in certain games, such as Jailbreak')
    mode:addOption('WalkSpeed'):setTooltip('<font color="rgb(255,64,64)"><b>Insanely easy to detect. Use Standard instead.</b></font>')
    
    local speedslider = m_speed:addSlider('Speed',{min=0,max=250,cur=30,step=0.01})
    local speed = 30
    speedslider:Connect('Changed',function(v)speed=v;end)
    local part
    local scon
            
    m_speed:Connect('Enabled',function() 
        local mode = mode:GetSelection()
        
        dnec(clientHumanoid.Changed, 'hum_changed')
        dnec(clientHumanoid:GetPropertyChangedSignal('Jump'), 'hum_jump')
        dnec(clientRoot.Changed, 'rp_changed')
        dnec(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
        dnec(clientRoot:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
        
        if (scon) then scon:Disconnect() scon = nil end
        
        if (mode == 'Standard') then
            scon = servRun.Heartbeat:Connect(function(dt) 
                clientRoot.CFrame += clientHumanoid.MoveDirection * (5 * dt * speed)
            end)
        elseif (mode == 'Velocity') then
            scon = servRun.Heartbeat:Connect(function(dt) 
                clientRoot.Velocity += clientHumanoid.MoveDirection * (5 * dt * speed)
            end)
        elseif (mode == 'Bhop') then
            scon = servRun.RenderStepped:Connect(function(dt) 
                local md = clientHumanoid.MoveDirection
                
                clientRoot.Velocity += md * (5 * dt * speed)
                clientHumanoid.Jump = not (md.Magnitude < 0.01 and true or false)
            end)
        elseif (mode == 'Part') then
            part = instNew('Part')
            part.Transparency = 0.8
            part.Size = vec3(4,4,1)
            part.CanTouch = false
            part.CanCollide = true
            part.Anchored = false
            part.Name = getnext()
            part.Parent = workspace
            scon = ev:Connect(function(dt) 
                local md = clientHumanoid.MoveDirection
                local p = clientRoot.Position
                
                part.CFrame = cfrNew(p-(md), p)
                part.Velocity = md * (dt * speed * 1200)
                
                clientHumanoid:ChangeState(8)
            end)
        elseif (mode == 'WalkSpeed') then
            dnec(clientHumanoid:GetPropertyChangedSignal('WalkSpeed'), 'hum_walk')
            
            scon = servRun.Heartbeat:Connect(function() 
                clientHumanoid.WalkSpeed = speed
            end)
        end
    end)
    
    m_speed:Connect('Disabled',function() 
        if (scon) then scon:Disconnect() scon = nil end
        if (part) then part:Destroy() end
        
        enec('hum_changed')
        enec('hum_jump')
        
        enec('hum_walk')
        
        enec('rp_changed')
        enec('rp_cframe')
        enec('rp_velocity')
        
        
    end)
    
    mode:Connect('Changed',function() 
        m_speed:Reset()
    end)
    
    mode:setTooltip('Method used for the speedhack')
    speedslider:setTooltip('Amount of speed')
end
m_speed:setTooltip('Speedhacks with various bypasses and settings')]]
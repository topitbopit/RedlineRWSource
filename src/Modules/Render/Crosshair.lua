--- REDLINE MODULE
-- Module: Crosshair
-- Category: Render
-- Description: Crosshair display using Drawing 
-- Version: v1.0.0


local Module = Render:AddModule('Crosshair')
    :SetTooltip('A smooth crosshair overlay, made with Drawing. Meant to be a cool display, and not actually useful')
    
do 
    local Settings = {}
    do
        Settings.Style = Module:AddDropdown('Style')
            :SetTooltip('What the crosshair looks like')
            
        Settings.Style:AddOption('Style 1')
            :SetTooltip('Standard 4 armed crosshair')
            :Select()
            
        Settings.Animation = Module:AddDropdown('Animation')
            :SetTooltip('A "procedural" animation that gets applied to the crosshair')
        
        Settings.Animation:AddOption('Breathe')
            :SetTooltip('Slowly oscillates the crosshair\'s size')
            :Select()
        
        Settings.Animation:AddOption('Spin')
            :SetTooltip('Spins the crosshair at a steady rate')
        
        Settings.Animation:AddOption('Swing')
            :SetTooltip('Swings the crosshair back and forth')
            
        Settings.Animation:AddOption('3d')
            :SetTooltip('Tilts and rotates the crosshair in a pseudo 3d manner, kinda funky')
            
        Settings.Animation:AddOption('None')
            :SetTooltip('No animation')
        
        Settings.AnimSpeed = Module:AddSlider('Animation speed')
            :SetSettings({
                Min = 0,
                Max = 5,
                Val = 1,
                Step = 0.1 
            })
            :SetTooltip('How fast the animation plays - 1 is at the normal speed, 2 is twice as fast, etc.')
        
        --[[Settings.Smoothness = Module:AddSlider('Smoothness')
            :SetTooltip('How smooth the crosshair moves')
            :SetSettings({
                Min = 1,
                Max = 20,
                Val = 10,
                Step = 0.1 
            })]]
            
        Settings.Size = Module:AddSlider('Size')
            :SetSettings({
                Min = 0,
                Max = 15,
                Val = 3,
                Step = 0.1 
            })
            :SetTooltip('The overall scale of the crosshair')
        
        Settings.ArmDist = Module:AddSlider('Arm distance')
            :SetSettings({
                Min = 0,
                Max = 10,
                Val = 3,
                Step = 0.1
            })
            :SetTooltip('How far away the crosshair arms are - only applies to certain styles')
            
        Settings.CenterDot = Module:AddToggle('Center dot')
            :SetTooltip('Displays a small center dot. This is meant to work for synapse v3, and will not show up on other exploits.')
            
        Settings.Outline = Module:AddToggle('Outline')
            :SetTooltip('Enables outlines around each crosshair line')
            :Enable()
            
        Settings.Invert = Module:AddToggle('Invert colors')
            :SetTooltip('Reverses the color "palette" of the crosshair - outlines become RGB, inlines (?) become black')
            
        Settings.MouseCursor = Module:AddToggle('Cursorize')
            :SetTooltip('Hides the roblox cursor and moves the crosshair to your cursor, acting as a new mouse. This will get overwrited by other modules, like Aimbot and Triggerbot!')
    end
    
    -- // end settings // -- 
    
    local AnimSpeed = Settings.AnimSpeed:GetValue()
    local Animation = Settings.Animation:GetSelection() 
    local ArmDist = Settings.ArmDist:GetValue()
    local DotEnabled = Settings.CenterDot:GetValue()
    local OutlineEnabled = Settings.Outline:GetValue()
    local Size = Settings.Size:GetValue()
    local Smoothness = Settings.Smoothness:GetValue()
    local PaletteInvert = Settings.Invert:GetValue() 
    
    Settings.Smoothness:Connect('OnUpdate', function( newV ) -- godly var names 🔥
        Smoothness = newV
    end)
    
    Settings.Size:Connect('OnUpdate', function( newV ) 
        Size = newV
    end)
    
    Settings.Animation:Connect('OnSelection', function( selection ) 
        Animation = selection
    end)
    
    Settings.CenterDot:Connect('OnToggle', function( dot ) 
        DotEnabled = dot 
    end)
    
    Settings.Outline:Connect('OnToggle', function( outline ) 
        OutlineEnabled = outline 
    end)
    
    Settings.Invert:Connect('OnToggle', function( invert ) 
        PaletteInvert = invert 
    end)
    
    Settings.AnimSpeed:Connect('OnUpdate', function( newV )  
        AnimSpeed = newV  
    end)
    
    Settings.ArmDist:Connect('OnUpdate', function( newV )  
        ArmDist = newV  
    end)
    
    local CursorPrev = false -- if MouseIconEnabled was false before potentially modifying it 
    local Styles = {}
    Styles['Style 1'] = import('src/Resources/Crosshair/Style1.lua')
    
    local Style
    Settings.Style:Connect('OnSelection', function() 
        if ( Style ) then 
            Style.Unload() 
        end
        
        Module:Reset()
    end)
    
    local UpdateCon
    Module:Connect('OnEnable', function() 
        Style = Styles[ Settings.Style:GetSelection() ]
        
        if ( not Style ) then
            return ui:Notify({
                Title = 'Oops',
                Message = 'Nonexistant crosshair style',
                Type = 'Warning',
                Duration = 3
            }) 
        end
        
        ui:Notify({
            Title = 'Style',
            Message = Settings.Style:GetSelection(),
            Type = 'Generic',
            Duration = 3
        }) 
        
        CursorPrev = inputService.MouseIconEnabled 
        
        Style.Init() -- init function that creates the stuff and does some other stuff
        UpdateCon = runService.Heartbeat:Connect(Style.Update) -- update function that handles the animations 
        
    end)
    
    Module:Connect('OnDisable', function() 
        if ( UpdateCon and UpdateCon.Connected ) then
            UpdateCon:Disconnect()
        end
        
        if ( Style ) then 
            Style.Unload() 
        end
        
        if ( CursorPrev == true ) then 
            inputService.MouseIconEnabled = true
        end
    end)
end


return Module 
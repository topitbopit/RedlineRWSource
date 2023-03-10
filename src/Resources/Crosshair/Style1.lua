--- REDLINE Resource
-- Description: Style #1 for the Crosshair module 
-- Version: v1.0.0

local Style = {} 
local Loaded = false

local HALFPI1 = math.pi / 2
local HALFPI2 = HALFPI1 * 2
local HALFPI3 = HALFPI1 * 3

local BLACK = Color3.new(0, 0, 0)

do
    local Objects = {} 
    local Delta

    function Style.Init() 
        Loaded = true 
        Delta = 0 
        
        -- Objects.Arm1
        do
            local Obj_Arm1 = Drawing.new('Line')
            Obj_Arm1.Thickness = 1
            Obj_Arm1.Visible = true
            Obj_Arm1.ZIndex = 500
            
            Objects.Arm1 = Obj_Arm1
        end
        
        -- Objects.Arm2
        do
            local Obj_Arm2 = Drawing.new('Line')
            Obj_Arm2.Thickness = 1
            Obj_Arm2.Visible = true
            Obj_Arm2.ZIndex = 500
            
            Objects.Arm2 = Obj_Arm2
        end
        
        -- Objects.Arm3
        do
            local Obj_Arm3 = Drawing.new('Line')
            Obj_Arm3.Thickness = 1
            Obj_Arm3.Visible = true
            Obj_Arm3.ZIndex = 500
            
            Objects.Arm3 = Obj_Arm3
        end
        
        -- Objects.Arm4
        do
            local Obj_Arm4 = Drawing.new('Line')
            Obj_Arm4.Thickness = 1
            Obj_Arm4.Visible = true
            Obj_Arm4.ZIndex = 500
            
            Objects.Arm4 = Obj_Arm4
        end
        
        -- Objects.Arm1Outline
        do
            local Obj_Arm1 = Drawing.new('Line')
            Obj_Arm1.Color = Color3.new(0, 0, 0)
            Obj_Arm1.Thickness = 3
            Obj_Arm1.Visible = false
            Obj_Arm1.ZIndex = 499
            
            Objects.Arm1Outline = Obj_Arm1
        end
        
        -- Objects.Arm2Outline
        do
            local Obj_Arm2 = Drawing.new('Line')
            Obj_Arm2.Color = Color3.new(0, 0, 0)
            Obj_Arm2.Thickness = 3
            Obj_Arm2.Visible = false
            Obj_Arm2.ZIndex = 499
            
            Objects.Arm2Outline = Obj_Arm2
        end
        
        -- Objects.Arm3Outline
        do
            local Obj_Arm3 = Drawing.new('Line')
            Obj_Arm3.Color = Color3.new(0, 0, 0)
            Obj_Arm3.Thickness = 3
            Obj_Arm3.Visible = false
            Obj_Arm3.ZIndex = 499
            
            Objects.Arm3Outline = Obj_Arm3
        end
        
        -- Objects.Arm4Outline
        do
            local Obj_Arm4 = Drawing.new('Line')
            Obj_Arm4.Color = Color3.new(0, 0, 0)
            Obj_Arm4.Thickness = 3
            Obj_Arm4.Visible = false
            Obj_Arm4.ZIndex = 499
            
            Objects.Arm4Outline = Obj_Arm4
        end
        
        -- Objects.Dot
        do
            local Obj_Dot = Drawing.new('Square')
            Obj_Dot.Filled = true 
            Obj_Dot.Size = Vector2.new(0.5, 0.5)
            Obj_Dot.Thickness = 1
            Obj_Dot.Visible = false
            Obj_Dot.ZIndex = 500 
            
            Objects.Dot = Obj_Dot
        end
        
        -- Objects.DotOutline
        do
            local Obj_Dot = Drawing.new('Square')
            Obj_Dot.Color = Color3.new(0, 0, 0)
            Obj_Dot.Filled = true 
            Obj_Dot.Size = Vector2.new(0.5, 0.5)
            Obj_Dot.Thickness = 3
            Obj_Dot.Visible = false
            Obj_Dot.ZIndex = 499 
            
            Objects.DotOutline = Obj_Dot
        end
    end

    function Style.Update( DeltaTime: number ) 
        Delta += ( DeltaTime * AnimSpeed )
        
        -- Constant vals 
        local Arm1, Arm2, Arm3, Arm4, Dot = Objects.Arm1, Objects.Arm2, Objects.Arm3, Objects.Arm4, Objects.Dot 
        local Arm1Ol = Objects.Arm1Outline
        local Arm2Ol = Objects.Arm2Outline
        local Arm3Ol = Objects.Arm3Outline
        local Arm4Ol = Objects.Arm4Outline
        local DotOl  = Objects.DotOutline
        local CrossPos = ScreenRes / 2 
        
        -- "Proxy" vals - these are what will be modified 
        local PosProxy = CrossPos
        local ScaleProxy = Size 
        local Angle = 0
        
        local AngleOffset1 = 0
        local AngleOffset2 = 0
        
        -- Pre modification - generic stuff that won't be animated is set here
        local ActiveColor = PaletteInvert and BLACK or RLGlobals.ActiveColor
        local OutlineColor = PaletteInvert and RLGlobals.ActiveColor or BLACK
        Arm1.Color = ActiveColor
        Arm2.Color = ActiveColor
        Arm3.Color = ActiveColor
        Arm4.Color = ActiveColor
        Dot.Color = ActiveColor
        
        Dot.Visible = DotEnabled
        
        Arm1Ol.Visible = OutlineEnabled
        Arm2Ol.Visible = OutlineEnabled
        Arm3Ol.Visible = OutlineEnabled
        Arm4Ol.Visible = OutlineEnabled
        DotOl.Visible = DotEnabled and OutlineEnabled
        
        
        -- Animation handling 
        -- giant elif chains are bad but what else can i do 
        if ( Animation == 'Breathe' ) then
            ScaleProxy += math.sin( Delta ) 
            
        elseif ( Animation == 'Spin' ) then 
            Angle = Delta % 360 -- modulo isnt required, might as well do it
            
        elseif ( Animation == 'Swing' ) then
            Angle = math.sin ( Delta ) * 4
            
        elseif ( Animation == '3d' ) then 
            local scaledDelta = math.cos(Delta) * 5 
            --math.cos(Delta * 2) + 1.5 * math.sin(Delta * 2) ^ 5
            --math.cos(Delta) * (math.sin(Delta)^6) * 7
            
            AngleOffset1 = scaledDelta
            AngleOffset2 = -scaledDelta
             
        end
        
        local Angle1 = ScaleProxy * Vector2.new(math.sin(Angle           + AngleOffset1), math.cos(Angle           + AngleOffset2))
        local Angle2 = ScaleProxy * Vector2.new(math.sin(Angle + HALFPI1 + AngleOffset1), math.cos(Angle + HALFPI1 + AngleOffset2))
        local Angle3 = ScaleProxy * Vector2.new(math.sin(Angle + HALFPI2 + AngleOffset1), math.cos(Angle + HALFPI2 + AngleOffset2))
        local Angle4 = ScaleProxy * Vector2.new(math.sin(Angle + HALFPI3 + AngleOffset1), math.cos(Angle + HALFPI3 + AngleOffset2))
        
        local ArmDistOffs = ( 2 + ArmDist ) -- armdist + some extra offset
        
        if ( Settings.MouseCursor:GetState() ) then 
            local position = inputService:GetMouseLocation()
            inputService.MouseIconEnabled = false 
            
            PosProxy = position
        else
            inputService.MouseIconEnabled = CursorPrev 
        end
        
        Arm1.From = PosProxy - ( Angle1 * ArmDistOffs )
        Arm1.To   = PosProxy - ( Angle1 * ArmDist )
        Arm2.From = PosProxy - ( Angle2 * ArmDistOffs )
        Arm2.To   = PosProxy - ( Angle2 * ArmDist )
        Arm3.From = PosProxy - ( Angle3 * ArmDistOffs )
        Arm3.To   = PosProxy - ( Angle3 * ArmDist )
        Arm4.From = PosProxy - ( Angle4 * ArmDistOffs )
        Arm4.To   = PosProxy - ( Angle4 * ArmDist )
        Dot.Position = PosProxy
        
        if ( OutlineEnabled ) then 
            
            Arm1Ol.From = Arm1.From
            Arm1Ol.To   = Arm1.To
            Arm2Ol.From = Arm2.From
            Arm2Ol.To   = Arm2.To
            Arm3Ol.From = Arm3.From
            Arm3Ol.To   = Arm3.To
            Arm4Ol.From = Arm4.From
            Arm4Ol.To   = Arm4.To
            
            DotOl.Position = PosProxy 
            
            Arm1Ol.Color = OutlineColor
            Arm2Ol.Color = OutlineColor
            Arm3Ol.Color = OutlineColor
            Arm4Ol.Color = OutlineColor
            DotOl.Color = OutlineColor
        end
    end

    function Style.Unload() 
        if ( Loaded == false ) then
            return
        end
                
        for _, obj in pairs( Objects ) do 
            obj:Remove()
        end
        
        Loaded = false 
    end
end

return Style 
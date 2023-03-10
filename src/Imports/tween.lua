--[[ 
Import: Tween
Description: Provides several functions for easily tweening instances, ranging 
from customizable to extremely simple
Version: v1.0.0
]]



-- yea this whole thing is kinda bloated but atleast it looks nice + works 

local TweenImport = {}
do
    local EasingStyle = Enum.EasingStyle
    local EasingDirection = Enum.EasingDirection
    
    local styleLinear = EasingStyle.Linear
    local styleExp = EasingStyle.Exponential        
    
    --- DURATED (duration-able? duratable? durationized?)
    -- Lets you pass a duration, automatically handles easing 
    
    -- Linearly tween `instance` using `properties`, with a duration of `duration`
    function TweenImport.Linear(instance: Instance, properties: table, duration: number) 
        local thisTween = tweenService:Create(
            instance,
            TweenInfo.new(duration, styleLinear),
            properties
        )
        
        thisTween:Play()
        
        return thisTween
    end
    -- Exponentially tween `instance` using `properties`, with a duration of `duration`
    function TweenImport.Exp(instance: Instance, properties: table, duration: number) 
        local thisTween = tweenService:Create(
            instance,
            TweenInfo.new(duration, styleExp),
            properties
        )
        
        thisTween:Play()
        
        return thisTween
    end
    -- Quadratically tween `instance` using `properties`, with a duration of `duration`
    function TweenImport.Quad(instance: Instance, properties: table, duration: number) 
        local thisTween = tweenService:Create(
            instance,
            TweenInfo.new(duration),
            properties
        )
        
        thisTween:Play()
        
        return thisTween
    end
    
    --- SIMPLE
    -- Automatically handles easing and duration
    
    -- Exponentially tween `instance` using `properties`, with a duration of 0.3
    function TweenImport.Quick(instance: Instance, properties: table) 
        local thisTween = tweenService:Create(
            instance,
            TweenInfo.new(0.3, styleExp),
            properties
        )
        
        thisTween:Play()
        
        return thisTween
    end
    
    --- CUSTOM
    -- Lets you pass a duration, easing style, and easing direction 
    
    -- Tween `instance` using `properties`, with a duration of `duration` and easingstyle of `style`
    function TweenImport.Custom(instance: Instance, properties: table, duration: number, style: string) 
        local thisTween = tweenService:Create(
            instance,
            TweenInfo.new(duration, EasingStyle[style]),
            properties
        )
        
        thisTween:Play()
        
        return thisTween
    end
    
    -- Tween `instance` using `properties`, with a duration of `duration`, easingstyle of `style`, and easingdirection of `direction`
    function TweenImport.FullCustom(instance: Instance, properties: table, duration: number, style: string, direction: string) 
        local thisTween = tweenService:Create(
            instance,
            TweenInfo.new(duration, EasingStyle[style], EasingDirection[direction]),
            properties
        )
        
        thisTween:Play()
        
        return thisTween
    end
    
    function TweenImport.CleanImport() 
        TweenImport = nil
    end
end

return TweenImport
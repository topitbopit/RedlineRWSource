--[[ 
Import: Silencer
Description: Provides several functions to help avoid common detections, like .Changed
Version: v1.0.0
]]

local SignalCache = setmetatable({}, {
    __mode = 'kv'
})

--[[
works by taking in a signal, getting its connections and storing whats enabled
when unmuting it gets those cached connections and re-enables whatever got disabled
i need the keys to be removed whenever that signal gets GC'd 
however its not finished yet, so    

1) actually make this functional    
2) try to figure out weak keys to make cached signals automatically clear up 
3) add v3 support?
]]--

local SilencerImport = {}
do 
    function SilencerImport:Mute( Signal: RBXScriptSignal )
        --[[local Connections = getconnections( Signal ) --SignalCache[ Signal ]
        print( 'Got new connections for ', Signal )
        if ( SignalCache[ Signal ] ) then
            
        else
            SignalCache[ Signal ] = {} 
            print('Made new cache for this signal') 
        end
        
        local Cache = SignalCache[ Signal ]
        
        for _, cn in ipairs( Connections ) do 
            local Func = cn.Function
            
            if ( Func and islclosure(Func) and isexecclosure(Func) == false ) then
                cn:Disable() 
                
                Cache[ #Cache + 1 ] = cn 
            end
        end]]
    end
    
    function SilencerImport:Unmute( Signal: RBXScriptSignal )
        --[[local Connections = SignalCache[ Signal ]
        
        if ( not Connections ) then
            print('[Unmute] No cached connections, returning')
            return
        end
        
        for _, cn in ipairs( Connections ) do 
            cn:Enable() 
        end
        
        print('[Unmute] Re-enabled', #Connections,'connections')]]
    end
end

return SilencerImport
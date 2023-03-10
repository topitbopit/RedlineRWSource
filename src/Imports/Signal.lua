--[[ 
Author: frick (modded by topit)
Import: Signal
Description: Emulates roblox script signals
Version: v1.0.0
]]


-- credits to frick for the signal lib
-- converted it to follow the import format 


local SignalImport = {} 
do 
    SignalImport.__index = SignalImport

    function SignalImport.new()
        local self = setmetatable({}, SignalImport)
    
        self._cns = {}
        self._tcns = {}
    
        return self
    end
    
    function SignalImport:Connect( func )
        local holder = {}
        local id = httpService:GenerateGUID()
    
        function holder:Disconnect()
            self._cns[id] = nil
        end
    
        self._cns[id] = func
    
        return holder
    end
    
    function SignalImport:Once( func )
        self._tcns[#self._tcns + 1] = func
    end
    
    function SignalImport:Wait()
        local currentThread = coroutine.running()
    
        self:Once(function( ... )
            coroutine.resume(currentThread, ...)
        end)
    
        return coroutine.yield()
    end
    
    function SignalImport:Fire( ... )
        for i, v in pairs( self._tcns ) do
            task.spawn(v, ...)
        
            self._tcns[i] = nil
        end
    
        for _, v in pairs( self._cns ) do
            task.spawn(v, ...)
        end
    end
    
    function SignalImport.CleanImport( )
        SignalImport = nil
    end
end
return SignalImport
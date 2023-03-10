--- RLBase
-- The base class for all elements 
local RLBase = {} do 
    --- Setup
    RLBase.__index = RLBase
    RLBase.class = 'RLBase'
    RLBase.rli = true -- rli = redline instance
    --- Interaction
    
    -- Connects the function `callback` to the event `eventName`.
    -- Pass callback as nil to disconnect the connection.
    function RLBase:Connect( eventName: string, callback )
        if ( typeof(callback) == 'function' ) then
            self.events[eventName] = callback 
            
        elseif ( callback == nil ) then
            self.events[eventName] = nil 
        end
        
        return self 
    end
    
    -- Fires the event `eventName` with args `...`
    -- **This is not meant for normal use, and is only used within the 
    -- interface library.**
    function RLBase:Fire( eventName: string, ... ) 
        local callback = self.events[eventName]
        
        if ( callback ) then
            task.spawn(callback, ...)
        end
        
        return self 
    end
    
    -- Connects the function `callback` to the **internal** event `eventName`.
    -- Pass callback as nil to disconnect the connection.
    -- **This is not meant for normal use, and is only used within the 
    -- interface library.**
    function RLBase:ConnectInternal (eventName: string, callback )
        if ( typeof(callback) == 'function' ) then
            self.eventsInternal[eventName] = callback 
            
        elseif ( callback == nil ) then
            self.eventsInternal[eventName] = nil 
        end
        
        return self 
    end
    
    -- Fires the **internal** event `eventName` with args `...`
    -- **This is not meant for normal use, and is only used within the 
    -- interface library.**
    function RLBase:FireInternal( eventName: string, ... ) 
        local callback = self.eventsInternal[eventName]
        
        if ( callback ) then
            task.spawn(callback, ...)
        end
        
        return self 
    end
    
    -- Gets this instance's parent
    function RLBase:GetParent()
        return self.parent 
    end
    
    -- Returns an array containing this instance's children 
    function RLBase:GetChildren() 
        return self.children
    end
    
    -- Returns the child with the matching name
    function RLBase:GetChild( ChildName: string ) 
        for _, c in ipairs( self.children ) do 
            if ( c.name == ChildName ) then
                return c  
            end
        end
    end
    
    --- Constructor 
    function RLBase.new()
        --- Setup 
        local this = setmetatable({}, RLBase)
        this.children = {}
        this.events = {} 
        this.eventsInternal = {} 
        this.parent = nil
        
        --- Finalization
        return this
    end
    
    --- Destructor
    function RLBase:Destroy() 
        -- Unlink from parent 
        if ( self.parent ) then 
            local parentChildren = self.parent.children 
            table.remove(parentChildren, table.find(parentChildren, self))
            
            self.parent = nil
        end
        
        -- Destroy all children 
        if ( self.children ) then 
            for _, c in ipairs( self.children ) do 
                c:Destroy() 
            end
            
            self.children = nil 
        end
        
        -- Destroy all UI instances
        if ( self.objects ) then 
            for _, o in pairs( self.objects ) do 
                o:Destroy()
            end
            
            self.objects = nil
        end
        
        -- Destroy all connections
        if ( self.connections ) then 
            for _, c in pairs( self.connections ) do 
                c:Disconnect()
            end
            
            self.connections = nil
        end
        
        -- Set everything to nil 
        self.events = nil
        self.eventsInternal = nil
        
        setmetatable(self, nil)
    end
end

return RLBase 
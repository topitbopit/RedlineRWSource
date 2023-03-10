--[[ 
Import: Logs
Description: Provides an interface to log errors, warnings, and information
Version: v1.0.0
]]

local logs = {}

--[[local LogObject = {} do 
    LogObject.Type = 'Info'
    LogObject.Time = tick()
    LogObject.Message = ''
    
    function LogObject.new() 
        
    end
end]]

local LogsImport = {}
do 
    LogsImport.__index = LogsImport
    
    -- Logging functions
    function LogsImport:Info(LogMessage: string) 
        table.insert(self.Logs, {
            Type = 'Info',
            Time = tick(),
            Log = LogMessage
        })
    end
    
    function LogsImport:Success(LogSuccess: success) 
        table.insert(self.Logs, {
            Type = 'Success',
            Time = tick(),
            Log = LogSuccess
        })
    end
    
    function LogsImport:Warning(LogWarning: string) 
        table.insert(self.Logs, {
            Type = 'Warning',
            Time = tick(),
            Log = LogWarning
        })
    end
    
    function LogsImport:Error(LogError: string) 
        table.insert(self.Logs, {
            Type = 'Error',
            Time = tick(),
            Log = LogError
        })
    end
    
    
    -- Log interaction functions
    function LogsImport:GetLogs() 
        return self.Logs 
    end
    
    function LogsImport:GetLog(index: number) 
        local log = self.Logs[index]
        return ('(%s) [%s] %s | %s'):format(self.Name, log.Time, log.Type, log.Log)
    end
    
    function LogsImport:FormatLog(log: table) 
        return ('(%s) [%s] %s | %s'):format(self.Name, log.Time, log.Type, log.Log)
    end
    
    function LogsImport:ClearLogs() 
        table.clear(self.Logs)
    end
    
    -- Destructor function
    function LogsImport:Destroy()
        table.remove(logs, table.find(logs, self))
        
        self.Logs = nil
        setmetatable(self, nil)    
    end
    
    -- Constructor function
    function LogsImport.new(LogName: string) 
        local self = setmetatable({}, LogsImport)
        self.Name = LogName
        self.Logs = {}
        table.insert(logs, self)
        
        return self
    end
    
    -- CleanImport
    function LogsImport.CleanImport()
        for _, log in ipairs(logs) do 
            log:Destroy()
        end 
        LogsImport = nil
    end
end


return LogsImport
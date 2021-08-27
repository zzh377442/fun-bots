class 'ClientConfManager'

-- UI Packet Event handler
-- @author Firjen <https://github.com/Firjens>
local MODULE_NAME = "Client Configuration Manager";

local CONFIG_FILE_TEMPLATE = nil;

local CONFIG_FILE_JSON = nil;


function ClientConfManager:__init()
    local s_start = SharedUtils:GetTimeMS()

    self:RegisterConsoleCommands();

    self:RegisterEvents();

	print("Enabled \"" .. MODULE_NAME .. "\" in " .. ReadableTimetamp(SharedUtils:GetTimeMS() - s_start, TimeUnits.FIT, 1))
end

function ClientConfManager:RegisterConsoleCommands()
    -- Command to send a test packet to the WebUI.
    Console:Register('config.fetch.json', 'Receive a JSON version of the server configuration file', function(args)
        -- @todo: add this
    end)

    -- Command to send a test packet to the WebUI.
    Console:Register('config.fetch.template', 'Receive a JSON version of the server configuration template', function(args)
        -- @todo: add this
    end)

end

-- Register events
function ClientConfManager:RegisterEvents()
    NetEvents:Subscribe('F:ConfigManager:ReceiveTemplate', function(data)
        print(MODULE_NAME .. "> Received template: " .. json.encode(data));
        CONFIG_FILE_TEMPLATE = data;
    end)

    NetEvents:Subscribe('F:ConfigManager:ReceiveConfig', function(data)
        print(MODULE_NAME .. "> Received config: " .. json.encode(data));
        CONFIG_FILE_JSON = data; -- Returns a JSON object
    end)
end

if g_clientConfigurationManager == nil then
	g_clientConfigurationManager = ClientConfManager()
end

return g_clientConfigurationManager

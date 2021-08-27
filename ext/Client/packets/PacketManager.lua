class 'ClientPacketManager'

-- UI Packet Event handler
-- @author Firjen <https://github.com/Firjens>
local MODULE_NAME = "Client Packet Manager";


function ClientPacketManager:__init()
    local s_start = SharedUtils:GetTimeMS()

    self:RegisterConsoleCommands();

	print("Enabled \"" .. MODULE_NAME .. "\" in " .. ReadableTimetamp(SharedUtils:GetTimeMS() - s_start, TimeUnits.FIT, 1))
end

function ClientPacketManager:RegisterConsoleCommands()
    -- Command to send a test packet to the WebUI.
    Console:Register('packet.send', 'Send custom packet to server', function(args)
        local result = NetEvents:Send(args[1], args[2])

        if result == nil then
            print("result nul");
        else
            print("Result: " .. result)
        end
    end)
end


if g_clientPacketManager == nil then
	g_clientPacketManager = ClientPacketManager()
end

return g_clientPacketManager

class 'ClientUIEventHandler'

require('ui/PacketOut');

-- UI Packet Event handler
-- @author Firjen <https://github.com/Firjens>
local MODULE_NAME = "ClientUI Event Handler";


function ClientUIEventHandler:__init()
    local s_start = SharedUtils:GetTimeMS()

    -- FUI is used for generic packets
    Events:Subscribe('FUI_PACKET', self, self.Receive)

    -- FUI is used for packets callback
    Events:Subscribe('FUI_CB', self, self.handlePacketCallback)

    -- Command to send a test packet to the WebUI.
    Console:Register('UI.send', 'Send packet to WebUI', function(args)
        if args[1] ~= nil and args[2] ~= nil then
            self:Send(args[1], args[2]);
        end
    end)

    -- Command to send a test packet to the WebUI.
    Console:Register('UI.open', 'Open WebUI', function(args)
        ClientUI:ShowLargeUI(true, true)
    end)

    -- Command to send a test packet to the WebUI.
    Console:Register('UI.close', 'Open WebUI', function(args)
        ClientUI:ShowLargeUI(false, true)
    end)

	print("Enabled \"" .. MODULE_NAME .. "\" in " .. ReadableTimetamp(SharedUtils:GetTimeMS() - s_start, TimeUnits.FIT, 1))
end


-- Send a packet to the WebUI
-- @param packet JSON-formatted packet
-- @author Firjen <https://github.com/Firjens>
function ClientUIEventHandler:Send(PacketOut, PacketData)
    print("Outgoing packet: " .. PacketOut) -- Temp debug data

    local s_packetData = json.encode(PacketData);

    --- todo: Check if WebUI is running
    WebUI:ExecuteJS('FUN_PACKET("' .. PacketOut .. '", ' .. s_packetData ..');')
end


-- Called upon a packet received from the fun-bots WebUI.
-- Will be decoded and parsed appropriately.
-- @param packet JSON-formatted packet
-- @author Firjen <https://github.com/Firjens>
function ClientUIEventHandler:Receive(PacketData)
    print("Received packet: " .. PacketData) -- Temp debug data

    -- @Todo: try catch
    -- Parse JSON data
    local s_packetData = json.encode(PacketData);

    -- Fetch packet ID from it.
    local s_packetId = s_packetData.id;
end


if g_clientUI == nil then
	g_clientUI = ClientUIEventHandler()
end

return g_clientUI

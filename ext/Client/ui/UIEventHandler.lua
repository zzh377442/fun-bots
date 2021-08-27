class 'ClientUIEventHandler'

require('ui/PacketOut');

-- UI Packet Event handler
-- @author Firjen <https://github.com/Firjens>
local MODULE_NAME = "ClientUI Event Handler";

local MOD_FUI_CONFIG = require('ui/modules/FUIConfigMod'); -- Config Module


function ClientUIEventHandler:__init()
    local s_start = SharedUtils:GetTimeMS()

    -- FUI is used for generic packets
    Events:Subscribe('FUI_PACKET', self, self.Receive)

    self:RegisterConsoleCommands();


	print("Enabled \"" .. MODULE_NAME .. "\" in " .. ReadableTimetamp(SharedUtils:GetTimeMS() - s_start, TimeUnits.FIT, 1))
end

function ClientUIEventHandler:RegisterConsoleCommands()

    -- Command to send a test packet to the WebUI.
    Console:Register('FUI.open', 'Open WebUI', function(args)
        ClientUI:ShowLargeUI(true, true)
    end)

    -- Command to send a test packet to the WebUI.
    Console:Register('FUI.close', 'Open WebUI', function(args)
        ClientUI:ShowLargeUI(false, true)
    end)

    -- Command to send a test packet to the WebUI.
    Console:Register('FUI.send', 'Debug - Send a manual packet to FUI packet handler', function(args)
        if args[1] ~= nil and args[2] ~= nil then
            self:Send(args[1], args[2]);
        end
    end)

    -- Command to send a test packet to the WebUI.
    Console:Register('FUI.test_notification', 'Debug - Show a test notification on screen', function(args)
        self:Send(PacketOut.SHOW_NOTIFICATION, json.encode({uuid = MathUtils:RandomGuid(), icon = {icon = "fas fa-user", color = "success", animation = "flash"} , text = "Hello world", expiration = 7500}))
    end)

    -- Command to send a test packet to the WebUI.
    Console:Register('FUI.test_alert', 'Debug - Show a test alert dialog on screen', function(args)
        self:Send(PacketOut.SHOW_ALERT, json.encode({uuid = MathUtils:RandomGuid()}))
    end)
end

-- Send a packet to the WebUI
-- @param packet JSON-formatted packet
-- @author Firjen <https://github.com/Firjens>
function ClientUIEventHandler:Send(PacketOut, PacketData)
    print("Outgoing packet: " .. PacketOut .. " - Body: " .. PacketData) -- Temp debug data

    --- todo: Check if WebUI is running
    WebUI:ExecuteJS('FUN_PACKET("' .. PacketOut .. '", ' .. PacketData ..');')
end


-- Called upon a packet received from the fun-bots WebUI.
-- Will be decoded and parsed appropriately.
-- @param packet JSON-formatted packet
-- @author Firjen <https://github.com/Firjens>
function ClientUIEventHandler:Receive(PacketData)
    local s_packetData, error = json.decode(PacketData);

    if s_packetData == nil then
        print("[FUI - Packet Handler] Step 1 Decode Error: " .. error);
    end

    if not s_packetData or s_packetData.packet == nil then
        print("[FUI - Packet Handler] Packet from FUI invalid. Missing Packet ID. Packet: " .. json.encode(s_packetData));
        do return end;
    end

    -- Packet "Toggle UI"
    if s_packetData.packet == "TOGGLE_UI" then
        ClientUI:ShowLargeUI(s_packetData.status, false);
        do return end;
    end

    -- @todo: log error - unknown packet received
    print("[FUI- Packet Handler] Unknown packet ID: " .. s_packetData.packet);
end


if g_clientUI == nil then
	g_clientUI = ClientUIEventHandler()
end

return g_clientUI

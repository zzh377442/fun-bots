class 'ClientUIInPacketHandler'

-- tba
-- @author Firjen
local MODULE_NAME = "ClientUI incoming packet handler";


function ClientUIInPacketHandler:__init()
    local s_start = SharedUtils:GetTimeMS()


	print("Enabled \"" .. MODULE_NAME .. "\" in " .. ReadableTimetamp(SharedUtils:GetTimeMS() - s_start, TimeUnits.FIT, 1))
end

-- Events
function ClientUIInPacketHandler:Handle(packetId, packetData)
	if (packetId == "TOGGLE_UI") then
        ClientUI:ShowLargeUI(packetData.status, false);
        do return end;
    end


end


if g_clientUI == nil then
	g_clientUI = ClientUIInPacketHandler()
end

return g_clientUI

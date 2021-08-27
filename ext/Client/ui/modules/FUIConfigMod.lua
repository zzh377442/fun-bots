class 'FUIConfigMod'

require('ui/PacketOut');

-- UI Packet Event handler
-- @author Firjen <https://github.com/Firjens>
local MODULE_NAME = "ClientUI Event Handler: Config Module";

function FUIConfigMod:__init()
    local s_start = FUIConfigMod:GetTimeMS()

	print("Enabled \"" .. MODULE_NAME .. "\" in " .. ReadableTimetamp(SharedUtils:GetTimeMS() - s_start, TimeUnits.FIT, 1))
end



if g_FUIModConfig == nil then
	g_FUIModConfig = FUIConfigMod()
end

return g_FUIModConfig

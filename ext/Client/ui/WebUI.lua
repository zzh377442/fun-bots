class 'ClientUI'

-- tba
-- @author Firjen
local MODULE_NAME = "ClientUI"

function ClientUI:__init()
    local s_start = SharedUtils:GetTimeMS()


	print("Enabled \"" .. MODULE_NAME .. "\" in " .. ReadableTimetamp(SharedUtils:GetTimeMS() - s_start, TimeUnits.FIT, 1))
end

if g_clientUI == nil then
	g_clientUI = ClientUI()
end

return g_clientUI

class 'ClientUI'

require('ui/PacketOut');

-- tba
-- @author Firjen
local MODULE_NAME = "ClientUI";

local CLIENT_HAS_LARGE_UI_OPEN = false;

local MODULE_UI_EVENT_HANDLER = nil;

function ClientUI:__init()
    -- Check if the UI is enabled in the registry.
    if not RegistryManager:Get(Registry.WEBUI.ENABLED, true, false) then
	    print("Module \"" .. MODULE_NAME .. "\" disabled in the registry.")
        do return end
    end

    local s_start = SharedUtils:GetTimeMS()

    MODULE_UI_EVENT_HANDLER = require('ui/UIEventHandler');

	print("Enabled \"" .. MODULE_NAME .. "\" in " .. ReadableTimetamp(SharedUtils:GetTimeMS() - s_start, TimeUnits.FIT, 1))
end

-- Events
function ClientUI:OnExtensionLoaded()
	WebUI:Init()
	WebUI:Show()
end

function ClientUI:OnExtensionUnloading()
	WebUI:Hide()
end

-- TBA
function ClientUI:OnClientUpdateInput()
	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F12) then
        -- If current editable menu is closed, open it
        if not CLIENT_HAS_LARGE_UI_OPEN then
            self.ShowLargeUI(true, true);
        else
            self.ShowLargeUI(false, true);
        end
    end
end

-- Show the large UI
function ClientUI:ShowLargeUI(status, packetOut)
        -- If current editable menu is closed, open it
        if status then
            -- Enable keyboard and mouse input
            WebUI:EnableKeyboard();
            WebUI:EnableMouse();
        else
            -- Disable keyboard and mouse input
            WebUI:ResetKeyboard();
            WebUI:ResetMouse();
        end
        
        CLIENT_HAS_LARGE_UI_OPEN = status;

        -- Tell the UI to show itself
        if packetOut == nil or packetOut then
            MODULE_UI_EVENT_HANDLER:Send(PacketOut.TOGGLE_UI, json.encode({status = status}))
        end

end

if g_clientUI == nil then
	g_clientUI = ClientUI()
end

return g_clientUI

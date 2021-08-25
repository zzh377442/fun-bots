class 'ClientUI'

-- tba
-- @author Firjen
local MODULE_NAME = "ClientUI";

local CLIENT_HAS_LARGE_UI_OPEN = false;

function ClientUI:__init()
    local s_start = SharedUtils:GetTimeMS()


	print("Enabled \"" .. MODULE_NAME .. "\" in " .. ReadableTimetamp(SharedUtils:GetTimeMS() - s_start, TimeUnits.FIT, 1))
end

-- Events
function ClientUI:OnExtensionLoaded()
	WebUI:Init()
	WebUI:Show()

    -- WebUI:ExecuteJS('testNotif();')
end

function ClientUI:OnExtensionUnloading()
	WebUI:Hide()
end

function ClientUI:OnClientUpdateInput()
	if InputManager:WentKeyDown(Config.OpenSettingsKey) then
        -- If current editable menu is closed, open it
        if not CLIENT_HAS_LARGE_UI_OPEN then
            self.ShowLargeUI(true);
        else
            self.ShowLargeUI(false);
        end


    end
end

-- Show the large UI
-- @param tba
-- @author Firjen
function ClientUI:ShowLargeUI(status)
        -- If current editable menu is closed, open it
        if status then
            CLIENT_HAS_LARGE_UI_OPEN = true;

            -- Tell the UI to show itself
            WebUI:ExecuteJS('showAll(true);')

            -- Enable keyboard and mouse input
            WebUI:EnableKeyboard();
            WebUI:EnableMouse();

        else
            CLIENT_HAS_LARGE_UI_OPEN = false;

            -- Tell the UI to show itself
            WebUI:ExecuteJS('showAll(false);')

            -- Disable keyboard and mouse input
            WebUI:ResetKeyboard();
            WebUI:ResetMouse();
        end
end

if g_clientUI == nil then
	g_clientUI = ClientUI()
end

return g_clientUI

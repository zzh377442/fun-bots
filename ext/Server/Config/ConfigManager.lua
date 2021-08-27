class('ConfigManager')

require('Config/confEnums')
require('Config/ConfigTemplate')

--[[
       Welcome to the configuration manager.

       Q: Where do I add new stuff to the config?
       A: Use ConfigTemplate.lua

       Q: Why is this in the server side and not shared.
       A: Security and expandability. Clients can receive it with a NetEvent upon joining.

       @author Firjen <https://github.com/Firjens>
]]
local MODULE_NAME = "Configuration Manager"

local m_Database = require('Database')

-- This function is solely run by someone with permissions running the in-game !bugreport command.
-- Param: p_Player - User who initiated the request
function ConfigManager:__init()
    local s_start = SharedUtils:GetTimeMS()

    if not (self:validate()) then
        print(MODULE_NAME .. "> Something went wrong, not sure what yet. :/")
    end

    self:registerEvents();

	print("Enabled \"" .. MODULE_NAME .. "\" in " .. ReadableTimetamp(SharedUtils:GetTimeMS() - s_start, TimeUnits.FIT, 1))
end

function ConfigManager:validate()
	print(MODULE_NAME .. "> Validating your configuration database...")

	-- @todo: Create the configuration table only if it doesn't exist yet.
	m_Database:CreateTable('configuration', {
		DatabaseField.PrimaryText,
		DatabaseField.Text,
		DatabaseField.Integer,
		DatabaseField.Integer
	}, {
		'key', -- config key (category.key) [Eg. auto_updater.check_version]
		'value', -- current value of the config key [Eg. 1]
        'version', -- version where it was added [Eg. 3]
		'timestamp' -- current ms [Eg. you know what this will look like] of last modification
	}, {
		'PRIMARY KEY("Key")'
	})

	print(MODULE_NAME .. "> Configuration database -> OK (1/2)")


    -- Check for newer configuration files;
	print(MODULE_NAME .. "> Checking for new configuration values -> OK (2/2)")

    -- Fetch the config file.
    self:load();

    return true;
end

--[[ Memory configuration Manager 
    This stuff below is used to manage the configuration while the server is running
]]

-- Init empty config data
local CONFIG_DATA = {};

-- List of loaded keys
local CONFIG_REGISTRY = {};

function ConfigManager:load()
	print(MODULE_NAME .. "> Loading configuration from database...")

    -- Fetch all existing keys from the database and check them with our template.
    local s_Configs = m_Database:Fetch('SELECT * FROM `configuration`')

    -- Handle the data from the database.
    if s_Configs == nil then
	    print(MODULE_NAME .. "> No configuration key(s) found in the database -> OK (1/2)")
	    print(MODULE_NAME .. "> Adding new configuration key(s) from fresh installation. This can take some time...")
    else
        -- Add all keys to the local variable.
        for l_Name, l_Value in pairs(s_Configs) do
            table.insert(CONFIG_DATA, {conf = l_Value.key, value = l_Value.value, ver = l_Value.version, time = l_Value.timestamp});
            CONFIG_REGISTRY[l_Value.key] = l_Value.value;
        end
    
        print(MODULE_NAME .. "> Loaded " .. #CONFIG_DATA .. " configuration key(s) to memory -> OK (1/2)")
    end

    local s_newKeyCount = 0;
    local s_validateKeycount = 0;
    local s_deletedKeycount = 0;
    -- Add missing keys if there are any missing
    -- l_Name returns category name and l_Value the items in the category.
    for l_Name, l_Value in pairs(ConfigTemplate) do
        -- Loop through the items in the category
        for k_Name, k_Value in pairs(l_Value) do
            -- Check if the key is not loaded
            if CONFIG_REGISTRY[string.lower(l_Name) .. "." .. string.lower(k_Name)] == nil then  -- Check if the key exists in the registry (format: category.key)
                self:addConfig(string.lower(k_Name), string.lower(l_Name), l_Value[k_Name])
                s_newKeyCount = s_newKeyCount + 1;
            else                                                                                 -- If not, do basic housekeeping
                local s_isDeleted = self:checkConfig(string.lower(l_Name), l_Value[k_Name]);
                s_validateKeycount = s_validateKeycount + 1;

                if s_isDeleted then
                    s_deletedKeycount = s_deletedKeycount + 1;
                end
            end
        end
    end

    -- Count deleted keys
    if (s_deletedKeycount > 0) then
        print(MODULE_NAME .. "> Removed " .. s_deletedKeycount .." key(s) from the database")
    end

    -- Count added keys
    if (s_newKeyCount > 0) then
        print(MODULE_NAME .. "> Added " .. s_newKeyCount .." key(s) to the database")
    end

    print(MODULE_NAME .. "> Validated " .. s_validateKeycount .. " key(s) -> OK (2/2)")

    return true;
end

-- Housekeeping - check that the config option is good
-- @author Firjen <https://github.com/Firjens>
function ConfigManager:checkConfig(configCategory, configData)
    -- @todo: Check if the current running version is good
    return false;
end

-- Housekeeping - check that the config option is good
-- @author Firjen <https://github.com/Firjens>
function ConfigManager:get(configCategory, configName)
    if CONFIG_REGISTRY[string.lower(configCategory) .. "." .. string.lower(configName)] == nil then
        if ConfigTemplate[configCategory][configName].data.def == nil then
            print(MODULE_NAME .. "> Missing configuration value: " .. configCategory .. "." .. configName .."! Not found in template either.")
            do return;
        end

        -- Announce it in console
        print(MODULE_NAME .. "> Missing configuration value: " .. configCategory .. "." .. configName .."! Returning: " .. ConfigTemplate[configCategory][configName].data.def)

        -- @Todo: log it

        -- Get the default value from the config template and return that
        return ConfigTemplate[configCategory][configName].data.def end;
    end

    return CONFIG_REGISTRY[string.lower(configCategory) .. "." .. string.lower(configName)];
end

-- Add new config
-- @author Firjen <https://github.com/Firjens>
function ConfigManager:addConfig(configName, configCategory, configData)
    -- We check the current running version requires this configuration key.
    -- minVer it checks if the minimum version is reached.
    -- maxVer is used for deprecation stuff. No action is needed as we are adding a new value and not changing an existing one.
    if (configData.minVer ~= nil and configData.minVer < Registry.VERSION.VERSION_ID) or (configData.maxVer ~= nil and configData.maxVer >= Registry.VERSION.VERSION_ID) then
        print(MODULE_NAME .. "> Key: [" .. configCategory .. "." .. configName .."] requires version: " .. configData.minVer)
        do return end;
    end

    -- All checks passed, add the key to the database.
    m_Database:Insert('configuration', {
        key = configCategory .. "." .. configName,
        value = configData.data.def,
        version = configData.ver,
        timestamp = 0;
    })

    print(MODULE_NAME .. "> [Debug: Temp] Added key: [" .. configCategory .. "." .. configName .."] to database")
end

-- Add new config
-- @author Firjen <https://github.com/Firjens>
function ConfigManager:removeConfig(configName, configCategory)
    -- Remove from the registry
    if CONFIG_REGISTRY[configName] ~= nil then
        CONFIG_REGISTRY[configName] = nil;
    end

    -- Remove from active configuration memory stuff
    -- @todo this - remove it from  CONFIG_DATA

    -- Remove from the SQL database
    m_Database:Delete('configuration', {
        key = configCategory .. "." .. configName
    });

    print(MODULE_NAME .. "> [Debug: Temp]  Removed key: [" .. configCategory .. "." .. configName .."] from database")
end


--[[ Packet configuration manager
    Communication client <-> server
]]
function ConfigManager:registerEvents()
    -- Client requests to receive the current ConfigTemplate.lua
    -- @todo - Permission check later on
    NetEvents:Subscribe('F:ConfigManager:RequestTemplate', function(player, data)
        self:sendTemplate(player);
    end)
    
    -- Client requests to receive the current ConfigTemplate.lua
    -- @todo - Permission check later on
    NetEvents:Subscribe('F:ConfigManager:RequestConfig', function(player, data)
        self:sendConfig(player);
    end)
end

function ConfigManager:sendTemplate(player)
    NetEvents:SendToLocal("F:ConfigManager:ReceiveTemplate", player, ConfigTemplate);
end

function ConfigManager:sendConfig(player)
    NetEvents:SendToLocal("F:ConfigManager:ReceiveConfig", player, CONFIG_DATA);
end

return ConfigManager:__init()
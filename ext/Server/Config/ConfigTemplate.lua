require('__shared/Constants/VersionType')
require('Config/confEnums')

--[[
        <!> STOP! Do not make any modifications to this file unless you know what you are doing!

        This files contains the configuration templates that will be loaded in the server by the ConfigManager.
        Do not make any modifications to this file as it won't end well and cause all data loss!
        
        Project developers, before making any changes, read the documentation: <https://github.com/Joe91/fun-bots/wiki>
        
        <!> Do not add any new categories or change existing ones.
        <!> Do not try to "customize" this file, one minor change can brick a mod.db
        <!> Contact Firjen <https://github.com/Firjens> or Joe91 <https://github.com/Joe91>
            via Discord <https://discord.funbots.dev> the moment you have a minor doubt about something.

        This list will be send once to any staff opening the F12 menu.
]]
ConfigTemplate = {
    -- Updates related to the auto updater
    GENERAL = {
        -- Is the auto updater to check for newer versions enabled?
        CHECK_VERSION = {
            enable = true,
            ver = 1,
            data = {
                type = DataTypes.bool,
                def = "1",
                cont = {
                    type = Container.checkbox
                }
            }
        },

        -- When check_version is true, check for development builds too instead of just RC and releases
        CHECK_VERSION_DEVBUILDS = {
            enable = true,
            ver = 1,
            data = {
                type = DataTypes.bool,
                def = "0",
                flag = {Flag.lockDevBuildTrue}, -- Locked on development builds
                cont = {
                    type = Container.checkbox
                }
            }
        },

        -- Is the auto updater to check for newer versions enabled?
        ALLOW_TELEMETRY = {
            enable = true,
            ver = 1,
            flag = {Flag.lockDevBuildTrue}, -- Locked on development builds to true
            data = {
                type = DataTypes.bool,
                def = "1",
                cont = {
                    type = Container.checkbox
                }
            }
        }
    }
}
PacketOut = {
    -- Returns a PONG packet.
    PING = "PING",

    -- Either open or close the current user UI
	TOGGLE_UI = "TOGGLE_UI",

    -- Update the configuration template stored on the server.
    UPDATE_CONFIG_TEMPLATE = "UPDATE_CONFIG_TEMPLATE";

    -- Update the configuration file stored on the server.
    UPDATE_CONFIG_FILE = "UPDATE_CONFIG_FILE";

    -- Show notif
    SHOW_NOTIFICATION = "SHOW_NOTIFICATION",

    -- Show alert
    SHOW_ALERT = "SHOW_ALERT"
}

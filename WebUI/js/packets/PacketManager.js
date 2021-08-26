const outgoingPacket = {
    UPDATE_UI_STATUS: "UPDATE_UI_STATUS"
}

/**
 * Cache map
 */
const packetManagerCache = new Map();

/**
 * Packet Manager
 */
class PacketManager {
    constructor() {
        console.log(`%c[FUNUI]%c (Packet Manager)%c Loading packet manager...`, 'color:blue;font-weight:bold;', 'font-weight:bold;', '')

        if (typeof WebUI == 'undefined') {
            console.log(`%c[FUNUI]%c (Packet Manager)%c Venice Unleashed WebUI support -> %cNOT FOUND`, 'color:blue;font-weight:bold;', 'font-weight:bold;', '', 'color:red')
            console.log(`%c[FUNUI]%c (Packet Manager)%c Missing WebUI support: running debug mode and simulation mode`, 'color:blue;font-weight:bold;', 'font-weight:bold;', '')
            packetManagerCache.set('vu_enabled', false);
            packetManagerCache.set('debug', true);
        } else {
            console.log(`%c[FUNUI]%c (Packet Manager)%c Venice Unleashed WebUI support -> %cOK`, 'color:blue;font-weight:bold;', 'font-weight:bold;', '', 'color:green')
            packetManagerCache.set('vu_enabled', true);
        }

        /* Load outgoing packet manager */
        this.out = new PacketManagerOut();

        /* Load incoming packet manager */
        this.in = new PacketManagerIn();

        console.log(`%c[FUNUI]%c (Packet Manager)%c Finished packet manager. Accepting new packets`, 'color:blue;font-weight:bold;', 'font-weight:bold;', '')
    }

    getOutgoingHandler() {
        return this.out;
    }

    getIncomingHandler() {
        return this.in;
    }
}

/**
 * Outgoing packet
 */
class PacketManagerOut {
    constructor() {
        console.log(`%c[FUNUI]%c (Packet Manager)%c Loaded outgoing packet manager -> %cOK`, 'color:blue;font-weight:bold;', 'font-weight:bold;', '', 'color:green')
    }

    /**
     * Send a packet to the VU client.
     * @param {string} packetId 
     * @param {JSON}} packetData 
     */
    send(packetId, packetData) {
        /* If VU is disabled, show it in logs. */
        if (!packetManagerCache.get("vu_enabled")) {
            console.log(`%c[FUNUI: Simulator]%c Sending packet to client. Packet name: '${packetId}' - Packet data: ${packetData}`, 'color:blue;font-weight:bold;', 'font-weight:bold;', '')
            return;
        }

        WebUI.Call('DispatchEventLocal', 'FUI_PACKET',packetData)
    }
}

/**
 * Incoming Packet Manager
 */
class PacketManagerIn {
    constructor() {
        console.log(`%c[FUNUI]%c (Packet Manager)%c Loaded incoming packet manager -> %cOK`, 'color:blue;font-weight:bold;', 'font-weight:bold;', '', 'color:green')
    }

    handle(packetId, packetData) {
        /* Validate JSON */

        try {
            var packetDataJSON = packetData;
        } catch(e) {
            console.error(`%c[FUNUI]%c (Packet Manager)%c Failed to parse JSON for incoming packet: ${packetId} - data: ${packetData}, rejected the packet.`, 'color:blue;font-weight:bold;', 'font-weight:bold;', '');

            /* Do something more, not sure what yet :) */

            return;
        }

        new IncomingPacketHandler(packetId, packetDataJSON);
    }
}

/**
 * Initiate the new packet manager
 */
 const packetManager = new PacketManager();

/**
 * This is used to intercept ALL packets from the Venice Unleashed client.
 * @param {String} packetId 
 * @param {JSON} packetData 
 * @author Firjen <https://github.com/Firjens>
 */
function FUN_PACKET(packetId, packetData) {
    // Todo: check if null
    packetManager.getIncomingHandler().handle(packetId, packetData);
}

/**
 * Send a packet back to the VU client.
 * @param {String} packetId Appropriate Packet ID
 * @param {JSON} packetData  JSON
 * @author {Firjen} <https://github.com/Firjens>
 */
function FUI_SEND(packetId, packetData) {
    // Todo: validate
    packetManager.getOutgoingHandler().send(packetId, packetData);
}
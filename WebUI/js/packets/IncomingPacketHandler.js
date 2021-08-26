/**
 * Incoming Packet Handler
 */
class IncomingPacketHandler {
    constructor(packetName, packetData) {
        /* Sort through the packet names */
        switch (packetName) {
            case 'PONG':
                FUI_SEND('PONG', `{"packet":"PONG"}`);
                break;
            case 'TOGGLE_UI':
                handleToggleUI(packetData);
                break;
            default:
                console.warn(`%c[FUNUI]%c (Incoming Packet Handler)%c Unknown packet ID: ${packetName} with data: ${JSON.stringify(packetData)}`, 'color:orange;font-weight:bold;', 'font-weight:bold;', '');
                return;
        }

        console.log(`%c[FUNUI]%c (Incoming Packet Handler)%c Handled incoming packet: ${packetName}`, 'color:blue;font-weight:bold;', 'font-weight:bold;', '')
    }
}

/* Incoming packets */
function handleToggleUI(data) {
    showAll(data.status);
}
/*
Firjeneerd by Firjen

*/

function testNotif() {
    createAlert(`{
        "uuid": "6baef61c-5688-4304-a7ea-64d286aa686c",
        "icon": "fas fa-user",
        "text": "Cowboy JSON stuff, idk man",
        "expiration": 30000,
        "animationData": {
            "color": "success",
            "animation": "flash"
        }
        }`);
}

/**
 * List of current alerts
 */
let notifications = new Map();

/**
 * JSON body {uuid, icon, text, expiration}
 * @param {*} alertData Create a new alert on the screen
 */
function createAlert(alertData) {
    new Alert(alertData);
}

colorMap = {
    success: "#55E923",
    warning: "#FFD000",
    error: "#E92323"
}

/**
 * Directly access map?
 * @param {*} string 
 * @returns 
 */
function colorMapGenerator(string) {
    if (string == "success")
        return colorMap.success;
    if (string == "warning")
        return colorMap.warning;
    if (string == "error")
        return colorMap.error;
    return "white";
}

class Alert {
    constructor(data) {
        this.alert = this;

        this.uuid = data.uuid;
        this.icon = data.icon;
        this.text = data.text;
        this.expiration = data.expiration;
        this.animationData = data.animationData;

        this.awaitingGC = false;

        notifications.set(this.uuid, this);
        this.add();
      }

      /**
       * Add the alert to the webpage
       */
      add() {

        if (this.icon != null) {
            this.localClass = ""

            if (this.animationData.animation != null)
            this.localClass = `animate__animated animate__${this.animationData.animation} animate__infinite`

            $("#funUI-notifications").append(`
            <div id="alert-${this.uuid}" class="alert animate__animated animate__bounceInDown">
                <div id="icon-${this.uuid}" class="${this.localClass}">
                    <i id="fa-${this.uuid}" class="icon ${this.icon}"></i>
                </div>
                <div id="text" class="text">
                    ${this.text}
                </div>
            </div>`);

            if (this.animationData.color != null) {
                $("#fa-" + this.uuid).css('color', colorMapGenerator(this.animationData.color));
            }
        } else {
            $("#funUI-notifications").append(`
            <div id="alert-${this.uuid}" class="alert animate__animated animate__bounceInDown">
                <div id="text" class="text">
                    ${this.text}
                </div>
            </div>`);
        }

        /* Remove alert after specified time */
        setTimeout($.proxy(this.remove, this), this.expiration);
      }

      remove() {
            /* Remove from map to prevent further references */
            notifications.delete(this.uuid);

            /* Used to listen when the animation end so we can clean up */
            const element = document.querySelector("#alert-" + this.uuid);

            /* Add animate.css move out effect */
            $("#alert-" + this.uuid).attr('class', 'alert animate__animated animate__backOutLeft');

            /* Clean up upon ending */
            element.addEventListener('animationend', () => {
                $("#alert-" + this.uuid).remove();
            });
      }
}
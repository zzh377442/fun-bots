/*
___________          __________        __          
\_   _____/_ __  ____\______   \ _____/  |_  ______
 |    __)|  |  \/    \|    |  _//  _ \   __\/  ___/          This code is part of the fun-bots project. Currently there is no license on any of the code present in this repository unless noted otherwise. 
 |     \ |  |  /   |  \    |   (  <_> )  |  \___ \           It may not be used elsewhere without the implicit permission of the author(s) of this, with the exception of direct fun-bots development.
 \___  / |____/|___|  /______  /\____/|__| /____  >          Created by Firjen with support from the fun-bots team. I now remember why I stopped doing Javascript.
     \/             \/       \/                 \/          
*/

/**
 * Show the large interactable menu.
 * @param {boolean} status true if the menu should be shown, otherwise it should be false.
 */
function showAll(status) {
    if (!status) {
        $("#funUI-menu").hide();
        return;
    }
    $("#funUI-menu").show();
}

/* Functions used for navigation */

/**
 * Current page (used to prevent double loading pages)
 */
var currentPage = "home"

/**
 * Populate the navigation bar
 */
function populateNavigator() {
    /* Get the JSON object. */
}

const navigator = `{
    "navigator": [
        {"id":"home", "action":"view", "path":"home", "icon":"fas fa-home"},
        {"id":"permissions", "action":"view", "path":"permissions", "icon":"fas fa-users-cogs"},
        {"id":"settings", "action":"view", "path":"settings", "icon":"fas fa-cogs"},
        {"id":"traces", "action":"view", "path":"traces", "icon":"fas fa-shoe-prints"},
        {"id":"quit", "action":"quit", "icon":"fas fa-times"}
    ],

    "sub-menu": {
        "home": [
            {"displayText":"Home", "path":"about","type":"WEB", "enabled":true},
            {"displayText":"About", "path":"about", "type":"WEB", "enabled":true}
        ],
        "permissions": [
            {"displayText":"Home", "path":"about", "type":"WEB", "enabled":true}
        ],
        "settings": [
            {"displayText":"Home", "path":"about", "type":"WEB", "enabled":true}
        ],
        "traces": [
            {"displayText":"Home", "path":"about", "type":"WEB", "enabled":true}
        ]
    }
}`

$(document).ready(function(){
    /* Clicking on navigation buttons */
    $( '[name^="navigation_button"]' ).on( "click", function() {
        console.log(`[FWEB] Clicked on navigation button: ` + $(this).attr('path'));

        if ($(this).attr('path') == null || currentPage == $(this).attr('path'))
            return;

        /* Catch close button */
        if ($(this).attr('path') == "quit") {
            showAll(false); // Hide the big UI from screen
            FUI_SEND('TOGGLE_UI', `{"packet":"TOGGLE_UI","status":false}`); // Return user mouse and keyboard
            return;
        }

        /* Check if the page exists */
        if (!$("#funbots-page-" + $(this).attr('path')).length) {
            console.error(`%c[FUNUI]%c (Page Manager)%c Page ${$(this).attr('path')} not found.`, 'color:red;font-weight:bold;', 'font-weight:bold;', '');
            return;
        }

        currentPage = $(this).attr('path')


        /* Hide all pages, open the new page. */
        $('[id^="funbots-page-"]').each(function(idx, el){
            $(el).hide();
        })

        $("#funbots-page-" + currentPage).show();
    });

    /* Clicking on header buttons */
});
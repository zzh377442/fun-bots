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

$(document).ready(function(){
    $( '[id^="navigation_button-"]' ).on( "click", function() {
        console.log(`[FWEB] Clicked on navigation button: ` + $(this).attr('path'));

        if ($(this).attr('path') == null || currentPage == $(this).attr('path'))
            return;

        currentPage = $(this).attr('path')

        /* Hide all pages, open the new page. */
        $('[id^="funbots-page-"]').each(function(idx, el){
            $(el).hide();
        })

        $("#funbots-page-" + currentPage).show();
    });
});
var IS_NIGHT_MODE = false;

function setFontSize(size) 
{
    if (size > 0)
        $("#ui-content").css("font-size", String(size + "px"));
}

function setNightMode(shouldUseNightMode) 
{
    IS_NIGHT_MODE = shouldUseNightMode;

    if (shouldUseNightMode) 
    {
        $("#index").addClass('dark');
    }
    else 
    {
        $("#index").removeClass('dark');
    }
}

function addExerciseMessage() 
{
    $("#index").addClass("hasExercise");

    var exerciseMessage = $('<div id="exercisemessage"><img src="Web/Images/dumbbell.png" width="36" height="18" /> <span>Press here for lesson exercises</span></div>');
    $("#ui-content").prepend(exerciseMessage);
    

    $("#exercisemessage").on('tap', function (e) 
    {
        simulateUrlRequest("ljapp:exercise");
    });
}

function simulateUrlRequest(url) 
{
    if (url) 
    {
      //window.location.href = url;
      var iframe = document.createElement("IFRAME");
      iframe.setAttribute("src", url);
      document.documentElement.appendChild(iframe);
      iframe.parentNode.removeChild(iframe);
      iframe = null;
    }
}

// document.ready fires inconsistently, so we use a custom 
// document initialization method called via Obj-C
function prepareDocument(isIpad) 
{
    var indexElement = $("#index");

    if (isIpad)
        indexElement.addClass('ipad');
    else
        indexElement.addClass('iphone');    

    // Hide iframes
    $("iframe").each(function (i, item) 
    {
        window.frames[i].stop(); // test
        var src = $(item).attr("src");
        $('<a class="video" href="' + src + '"><img src="Web/Images/video.png" alt="Watch Video" width="131" height="38" /></a>').insertBefore($(item));
        $(item).remove();
    });
	

    // Override kana reading hover items
    $(".popup").on('tap', function (e) 
    {
        if (e) { e.preventDefault() };

        var title = $(this).attr("title");
        var reading = title.split("-");
        var url = "ljapp:reading:" + reading[0] + ":" + reading[1] + ":" + $(this).text();

        simulateUrlRequest(url);
    });
	
    // Override kana reading hover items
    $("span.toggle").on('tap', function (e) 
    {
        if (e) { e.preventDefault(); }

        $(this).toggleClass("active");
    });

} // prepareDocument





function flip(targetID) 
{
	$("#"+targetID).toggleClass("hide");
}

function toggleAll(targetID) 
{
    $(targetID).toggleClass("showanswers");
}

function toggle(targetID) 
{
    $("#" + targetID + " .hide").addClass("show").removeClass("hide");
    $("#" + targetID + " .show").addClass("hide").removeClass("show");
}



function showModal(character)
{
    var syllabary = $("#ljappsyllabary").text();
    var url = "ljapp:" + syllabary + ":" + character;

    simulateUrlRequest(url);
}

function playClip(character) 
{
    var syllabary = $("#ljappsyllabary").text();
    var url = "ljapp:playclip:" + character;

    simulateUrlRequest(url);
    
    /*var fmt = '.mp3';

    if ($('#clip').length < 1) {
        var audioElement = $('<audio id="clip" src="" controls="true" onended="clipFinished(\'#clip\');" style="display: none;"> </audio>');
        $("#index").prepend(audioElement);
    }

	$('#clip').attr('src','Audio/' + character + fmt).load();

	var clip = document.getElementById("clip");
	clip.play();
	
	showPlayingDialog();*/
}


function playclip_inline(character) 
{
    var fmt = '.mp3';

    if ($('#clip_inline').length < 1) {
        var audioElement = $('<audio id="clip" src="" controls="true" onended="clipFinished(\'#clip_inline\');" style="display: none;"> </audio>');
        $("#index").prepend(audioElement);
    }

	$('#clip_inline').attr('src','Audio/' + character + fmt).load();
	
	var clip_inline = document.getElementById("clip_inline");
	clip_inline.play();
	
	showPlayingDialog();
}

function showPlayingDialog()
{    
    var playingDialog = $("#playingdialog");
    
    if (playingDialog.length > 0)
    {
        $("#playingdialog").hide();
    }
    else
    {
	    var dialog = $('<div id="playingdialog">Playing audio</div>');
	    $(".ui-page").prepend(dialog);
	    playingDialog = $("#playingdialog");
	    playingDialog.hide();
        playingDialog.on('tap', function (e) 
        {
            hidePlayingDialog();
        });
    }
    
    playingDialog.animate({ opacity: 1 });
}

function clipFinished(selector) {
    try {
        $(selector).attr('src', '').load();
        hidePlayingDialog();
    }
    catch (e) { }
}

function hidePlayingDialog()
{
    try
    {
        $("#playingdialog").animate({ opacity: 0 });
    }
    catch(e)
    {
        $("#playingdialog").hide();
    }
}


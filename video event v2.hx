import hxvlc.flixel.FlxVideoSprite;

public var video:FlxVideoSprite;
var vidList:Map<String, FlxVideoSprite> = [];
var autoPause = true;
var camVideo:FlxCamera;

function postCreate() {
	// Create the video camera
	camVideo = new FlxCamera(0, 0, FlxG.width, FlxG.height);
	camVideo.bgColor = 0x00000000;
	FlxG.cameras.add(camVideo, false);

	var events = PlayState.SONG.events;

	for (i in events) {
		if (i.name == "video event v2") {
			var vidName = i.params[0];
			var video = new FlxVideoSprite(0, 0);
			video.load(Assets.getPath(Paths.video(vidName)), [':no-audio']);
			video.play();
			video.visible = false;
			video.cameras = [camVideo];
			add(video);
		}
	}
}

// create the video
function makeVid(x, y, vidName, noAudio) {
	var video = new FlxVideoSprite(x, y);
	video.load(Assets.getPath(Paths.video(vidName)), [(noAudio ? ':no-audio' : ':audio')]);
	video.cameras = [camVideo];
	vidList.set(vidName, video);
	return video;
}

// the event, thanks to furo for the help for audio and fullscreen

function onEvent(eventEvent) {
	if (eventEvent.event.name == "video event v2") {
		var params = eventEvent.event.params;
		var vidName = params[0];
		var scale = params[1];
		var x = params[2];
		var y = params[3];
		var cam = params[4];
		var middle:Bool = params[5];
		var oppStrum:Bool = params[6];
		var playerStrum:Bool = params[7];
		var index = params[8];
		var audio = params[9];
		var fullscreen = params[10];

		video = vidList.get(vidName);
		if (video == null) {
			video = makeVid(x, y, vidName, !audio);
		}

		video.scale.set(scale, scale);
		video.visible = true;
		video.play();

		video.bitmap.onFormatSetup.add(function():Void {
			if (video.bitmap != null && video.bitmap.bitmapData != null) {
				if (fullscreen) {
					var scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);
					video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
					video.updateHitbox();
				}
				video.updateHitbox();
				if (middle) {
					video.screenCenter();
				}
			}
		});

		video.cameras = [camVideo];
		add(video);

		updateHUDVisibility(0);
		updateOppStrumVisibility(0);
		updatePlayerStrumVisibility(0);

		video.bitmap.onEndReached.add(() -> {
			video.destroy();
			updateHUDVisibility(1);
			updateOppStrumVisibility(1);
			updatePlayerStrumVisibility(1);
		});
	}
}

// alpha shit

function updateHUDVisibility(alpha:Float) {
    camHUD.alpha = alpha;
	for (hud in [iconP1, iconP2, healthBarBG, healthBar, scoreTxt, missesTxt]) {
		hud.alpha = alpha;
	}
}

function updateOppStrumVisibility(alpha:Float) {
	for (daStrum in cpuStrums.members) {
		FlxTween.tween(daStrum, {alpha: alpha}, 0.2);
	}
	for (daNote in cpuStrums.notes.members) {
		FlxTween.tween(daNote, {alpha: alpha}, 0.2);
	}
}

function updatePlayerStrumVisibility(alpha:Float) {
	for (daStrum in playerStrums.members) {
		FlxTween.tween(daStrum, {alpha: alpha}, 0.2);
	}
	for (daNote in playerStrums.notes.members) {
		FlxTween.tween(daNote, {alpha: alpha}, 0.2);
	}
}

// video pause

function onFocus() {
	if (video != null) {
		if (PlayState.instance.paused) {
			video.pause();
		} else {
			video.resume();
		}
	}
}

function onGamePause() {
	PlayState.instance.paused = true;
	persistentUpdate = false;
	persistentDraw = true;
	if (video != null) {
		video.pause();
	}
}

function update(elapsed) {
	if (!PlayState.instance.paused && video != null) {
		video.resume();
		autoPause = true;
	}
}

import flixel.tweens.FlxEase;
import flixel.text.FlxTextBorderStyle;
import flixel.system.frontEnds.SoundFrontEnd;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import funkin.menus.StoryMenuState;
import funkin.menus.FreeplayState;
import funkin.options.OptionsMenu;
import funkin.menus.credits.CreditsMain;
import funkin.menus.ModSwitchMenu;
import funkin.editors.EditorPicker;

// black yoshi stuff.
var blackYoshiPlushie:FlxSprite;
var blackYoshiIntroPlushie:FlxSprite;
var voiceTimer:Float = 0;
var nextVoiceTime:Float = 0;
var currentVoiceSound:FlxSound;
var mainBaseX:Float = 400;
var mainBaseY:Float = 400;
var currentBlackYoshiY:Float = 0;
var blackYoshiBaseX:Float = 680;
var blackYoshiBaseY:Float = 300;
var introFinished:Bool = false;
var isTalking:Bool = false;
var talkIntroFinished:Bool = false;
var introStartDelay:Float = 0.1;
var introTimer:Float = 0;
var introStarted:Bool = false;
var delayTimeragain:Float = 0;

function create() {
	FlxG.mouse.visible = true;
	CoolUtil.playMenuSong();
	nextVoiceTime = 0.01;
}

function postCreate() {

	blackYoshiIntroPlushie = new FlxSprite(635, -3);
	blackYoshiIntroPlushie.frames = Paths.getSparrowAtlas("menus/mainmenu/yoshi");
	blackYoshiIntroPlushie.scale.set(0.5, 0.5);
	blackYoshiIntroPlushie.animation.addByPrefix('intro', "intro", 24, false);
	
	blackYoshiIntroPlushie.antialiasing = true;
	add(blackYoshiIntroPlushie);

	blackYoshiPlushie = new FlxSprite(635, -5);
	blackYoshiPlushie.frames = Paths.getSparrowAtlas("menus/mainmenu/yoshi");
	blackYoshiPlushie.scale.set(0.5, 0.5);
	blackYoshiPlushie.animation.addByPrefix('idle', "idle");
	blackYoshiPlushie.animation.addByPrefix('intro', "intro", 24, false);
	blackYoshiPlushie.animation.addByPrefix('talk intro', "talk intro", 24, false);
	blackYoshiPlushie.animation.addByPrefix('talk out', "talk out", 24, false);
	blackYoshiPlushie.animation.addByPrefix('talk loop', "talk loop", 24, true);
	blackYoshiPlushie.alpha = 0;
	blackYoshiPlushie.antialiasing = true;
	add(blackYoshiPlushie);
}

function doBlackYoshiLogic(elapsed) 
{
	if (!introFinished) {
		if (!introStarted) {
			introTimer += elapsed;
			if (introTimer >= introStartDelay) {
				introStarted = true;
				blackYoshiIntroPlushie.animation.play("intro", false);

			}
			return;
		}
		
		if (introStarted) {
			delayTimeragain += elapsed;
			if (delayTimeragain >= 1) {
				introFinished = true;
				blackYoshiIntroPlushie.y = -5000; // very scuffed but idgaf
				blackYoshiIntroPlushie.alpha = 0;
				blackYoshiPlushie.alpha = 1;
				blackYoshiPlushie.animation.play("idle", true);
			}
			return;
		}
	}

	if (!introFinished) return;

	if(blackYoshiPlushie.animation.name == "talk out")
	{
		blackYoshiPlushie.offset.set(25, 0);
	}
	else 
	{
		blackYoshiPlushie.offset.set(0, 0);
	}

	if (FlxG.mouse.overlaps(main)) {
		blackYoshiBaseX = (((FlxG.mouse.screenX * -1) - 480) * 0.02) + 680;
		blackYoshiBaseY = (((FlxG.mouse.screenY * -1) - 360) * 0.02) + 300;
		blackYoshiPlushie.x = blackYoshiBaseX + FlxG.random.float(-2, 2);
		blackYoshiPlushie.y = blackYoshiBaseY + FlxG.random.float(-2, 2);
	} else {
		blackYoshiPlushie.x = (((FlxG.mouse.screenX * -1) - 480) * 0.02) + 680;
		blackYoshiPlushie.y = (((FlxG.mouse.screenY * -1) - 360) * 0.02) + 300;
		
		if (currentVoiceSound == null || !currentVoiceSound.playing) {
			blackYoshiPlushie.color = FlxColor.WHITE;
		}
	}

	voiceTimer += FlxG.elapsed;

	if (isTalking) {
		if (blackYoshiPlushie.animation.name == "talk intro" && blackYoshiPlushie.animation.finished && !talkIntroFinished) {
			blackYoshiPlushie.animation.play("talk loop", true);
			talkIntroFinished = true;
		}

		if (currentVoiceSound != null && !currentVoiceSound.playing && talkIntroFinished) {
			blackYoshiPlushie.animation.play("talk out", false);
			isTalking = false;
			talkIntroFinished = false;
		}
	} else {
		if (blackYoshiPlushie.animation.name == "talk out" && blackYoshiPlushie.animation.finished) {
			blackYoshiPlushie.animation.play("idle", true);
		}
	}

	if(voiceTimer >= nextVoiceTime && !isTalking && 
	   blackYoshiPlushie.animation.name != "talk intro" && 
	   blackYoshiPlushie.animation.name != "talk out" &&
	   blackYoshiPlushie.animation.name != "talk loop")
	{
		currentVoiceSound = FlxG.sound.play(Paths.sound("blackyoshi_voice_temp" + FlxG.random.int(1, 5)));

		isTalking = true;
		talkIntroFinished = false;
		blackYoshiPlushie.animation.stop();
		blackYoshiPlushie.animation.play("talk intro", true);

		voiceTimer = 0;
		nextVoiceTime = FlxG.random.float(10, 20);
	}

	if(currentVoiceSound != null && !currentVoiceSound.playing)
	{
		currentVoiceSound = null;
	}
}

function update(elapsed) {
	doBlackYoshiLogic(elapsed);
}

var logo:FlxSprite;
var cutsceneBar1:FlxSprite;
var cutsceneBar2:FlxSprite;
var glitch = new CustomShader("aaa");
var glitch2 = new CustomShader("aaa");

var shadersReady = false;

function postCreate() 
{
    preloadVideo("juniorswf");
}

function preloadVideo(vidName:String) {
    var preloadVid = new FlxVideoSprite(0, 0);
    preloadVid.load(Assets.getPath(Paths.video(vidName)), [':no-audio']);
    preloadVid.visible = false;
    preloadVid.alpha = 0;
    add(preloadVid);
    
    preloadVid.play();

    new FlxTimer().start(0.01, function(timer) {
        preloadVid.pause();
        preloadVid.visible = false;
    });
}

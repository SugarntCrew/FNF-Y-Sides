package substates;

import flixel.addons.display.FlxBackdrop;

import states.StoryMenuState;
import states.FreeplayState;

import objects.Character;

class ResultsScreen extends MusicBeatSubstate
{
    var stripeSpeed:Int = 25;
    var iconSpeed:Int = 15;
    var patternSpeed:Int = 15;

    public var boyfriend:Character;

    var scoreTxt:FlxText;
    var missesTxt:FlxText;
    var ratingTxt:FlxText;
    
    var statsTxt:FlxText;
    var sicksTxt:FlxText;
    var goodsTxt:FlxText;
    var badsTxt:FlxText;
    var shitsTxt:FlxText;

    var ratingName = '';
    var bfAnimName = '';

    var rating = PlayState.instance.ratingPercent * 100;

    override function create() 
    {
        super.create();

        FlxG.sound.playMusic(Paths.music('winScreen'));

        var bg = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, 0xFFCFC6F3);
        add(bg);

        var lines:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/lines'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else XY #end);
        lines.velocity.set(75, 75);
        lines.alpha = 0.45;
        lines.antialiasing = ClientPrefs.data.antialiasing;
        add(lines);

        var bgStripe = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/stripe'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);
        bgStripe.antialiasing = ClientPrefs.data.antialiasing;
        bgStripe.velocity.set(stripeSpeed, 0);
        bgStripe.blend = ADD;
        add(bgStripe);

        boyfriend = new Character(0, 150, 'bf-WinScreen');
        boyfriend.screenCenter(Y);
        boyfriend.y += -120;
        boyfriend.antialiasing = ClientPrefs.data.antialiasing;
        boyfriend.isPlayer = true;
        boyfriend.alpha = 0;

        boyfriend.animation.finishCallback = function(name:String)
        {
            boyfriend.playAnim('${name}loop');
        }
        add(boyfriend);

        var bfIconLeft = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/icon'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else Y #end);
        bfIconLeft.velocity.set(0, -iconSpeed);
        bfIconLeft.antialiasing = ClientPrefs.data.antialiasing;
        add(bfIconLeft);
        
        var bfIconRight = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/icon'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else Y #end);
        bfIconRight.x = FlxG.width - bfIconRight.width;
        bfIconRight.velocity.set(0, iconSpeed);
        bfIconRight.antialiasing = ClientPrefs.data.antialiasing;
        add(bfIconRight);

        var patternDown = new ResultsScreenPattern(0, 0);
        patternDown.y = FlxG.height - patternDown.height;
        patternDown.darkPattern.velocity.set(patternSpeed, 0);
        patternDown.lightPattern.velocity.set(-patternSpeed, 0);
        patternDown.antialiasing = ClientPrefs.data.antialiasing;
        add(patternDown);

        var patternUp = new ResultsScreenPattern(0, 0, true);
        patternUp.y = 0;
        patternUp.flipY = true;
        patternUp.darkPattern.velocity.set(-patternSpeed, 0);
        patternUp.lightPattern.velocity.set(patternSpeed, 0);
        patternUp.antialiasing = ClientPrefs.data.antialiasing;
        add(patternUp);

        var board = new FlxSprite();
        board.loadGraphic(Paths.image('resultsScreen/newResultsScreen/board'));
        board.screenCenter();
        board.x += FlxG.width / 6;
        board.antialiasing = ClientPrefs.data.antialiasing;
        add(board);

        boyfriend.x = board.x - 380;

        scoreTxt = new FlxText(0, board.y + 30, 0, "SCORE: " + PlayState.instance.songScore);
        scoreTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, LEFT);
        scoreTxt.x = board.x + 25;
        add(scoreTxt);

        missesTxt = new FlxText(board.x + 30, scoreTxt.y, board.width - 80, "MISSES: " + PlayState.instance.songMisses);
        missesTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, RIGHT);
        missesTxt.x = board.x + 25;
        add(missesTxt);

        ratingTxt = new FlxText(0, missesTxt.y + 45, 0, "RATING: " + rating);
        ratingTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, LEFT);
        ratingTxt.x = board.x + 25;
        add(ratingTxt);

        statsTxt = new FlxText(0, ratingTxt.y + 100, 0, "STATUS:");
        statsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, LEFT);
        statsTxt.x = board.x + 25;
        add(statsTxt);

        sicksTxt = new FlxText(0, statsTxt.y + 40, 0, "Sicks: 0");
        sicksTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        sicksTxt.x = board.x + 25;
        add(sicksTxt);

        goodsTxt = new FlxText(0, sicksTxt.y + 25, 0, "Goods: 0");
        goodsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        goodsTxt.x = board.x + 25;
        add(goodsTxt);

        badsTxt = new FlxText(0, goodsTxt.y + 25, 0, "Bads: 0");
        badsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        badsTxt.x = board.x + 25;
        add(badsTxt);

        shitsTxt = new FlxText(0, badsTxt.y + 25, 0, "Shits: 0");
        shitsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        shitsTxt.x = board.x + 25;
        add(shitsTxt);

        ratingAnimData();
        startBfAnim();
    }

    function startBfAnim()
    {
        boyfriend.alpha = 1;
        //ranks.alpha = 1;

        boyfriend.playAnim(bfAnimName);
        //ranks.animation.play(ratingName);
    }

    function ratingAnimData()
    {
        if(rating >= 90)
        {
            bfAnimName = '90%';
            ratingName = 'S';
        }
        else if(rating >= 75 && rating < 90)
        {
            bfAnimName = '75%';
            ratingName = 'A';
        }
        else if(rating >= 65 && rating < 75)
        {
            bfAnimName = '65%';
            ratingName = 'B';
        }
        else if(rating >= 55 && rating < 65)
        {
            bfAnimName = '55%';
            ratingName = 'C';
        }
        else if(rating >= 40 && rating < 55)
        {
            bfAnimName = '0%';
            ratingName = 'D';
        }
        else
        {
            bfAnimName = '0%';
            ratingName = 'E';
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(controls.BACK)
        {
            if(PlayState.isStoryMode)
            {
		    	FlxTransitionableState.skipNextTransIn = true;
		    	FlxTransitionableState.skipNextTransOut = true;
                MusicBeatState.switchState(new StoryMenuState());
            }
            else
            {
		    	FlxTransitionableState.skipNextTransIn = true;
		    	FlxTransitionableState.skipNextTransOut = true;
                MusicBeatState.switchState(new FreeplayState());
            }
        }
    }
}

/**
 * Lettabox
 */
class ResultsScreenPattern extends FlxSpriteGroup
{
    public var darkPattern:FlxBackdrop;
    public var lightPattern:FlxBackdrop;

    public function new(x:Float, y:Float, flipPatternY:Bool = false)
    {
        super(x, y);

        darkPattern = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/lettaBoxDark'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);
        darkPattern.antialiasing = ClientPrefs.data.antialiasing;
        add(darkPattern);

        lightPattern = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/lettaBoxLight'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);
        lightPattern.y = flipPatternY ? darkPattern.y : darkPattern.y + darkPattern.height - lightPattern.height;
        lightPattern.antialiasing = ClientPrefs.data.antialiasing;
        add(lightPattern);
    }
}
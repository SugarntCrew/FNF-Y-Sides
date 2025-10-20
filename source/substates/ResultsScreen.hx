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

    var bg:FlxSprite;
    var lines:FlxBackdrop;
    var bgStripe:FlxBackdrop;

    public var boyfriend:Character;

    var bfIconLeft:FlxBackdrop;
    var bfIconRight:FlxBackdrop;
    var patternDown:ResultsScreenPattern;
    var patternUp:ResultsScreenPattern;
    var board:FlxSprite;

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

    var sick:Int = 0;
    var good:Int = 0;
    var bad:Int = 0;
    var shit:Int = 0;

    var rank:ResultsScreenRank;
    var rankName:String = "";

    var blackBackground:FlxSprite;
    var whiteBackground:FlxSprite;

    override function create() 
    {
        super.create();

        sick = PlayState.instance.ratingsData[0].hits;
        good = PlayState.instance.ratingsData[1].hits;
        bad = PlayState.instance.ratingsData[2].hits;
        shit = PlayState.instance.ratingsData[3].hits;

        rank = new ResultsScreenRank(0, 0, getRankName());

        //FlxG.sound.playMusic(Paths.music(getRankName() == 'e' ? 'winScreenbad' : 'winScreen'));
        //Conductor.bpm = getRankName() == 'e' ? 100 : 127;

        bg = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, 0xFFCFC6F3);
        bg.alpha = 0;
        add(bg);

        FlxTween.tween(bg, {alpha: 1}, 0.7);

        lines = new FlxBackdrop(Paths.image('gallery/lines'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else XY #end);
        lines.velocity.set(75, 75);
        lines.alpha = 0;
        lines.antialiasing = ClientPrefs.data.antialiasing;
        add(lines);

        FlxTween.tween(lines, {alpha: 0.45}, 0.7);

        bgStripe = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/stripe'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);
        bgStripe.antialiasing = ClientPrefs.data.antialiasing;
        bgStripe.velocity.set(stripeSpeed, 0);
        bgStripe.blend = ADD;
        bgStripe.alpha = 0;
        add(bgStripe);

        FlxTween.tween(bgStripe, {alpha: 1}, 0.7);

        blackBackground = new FlxSprite();
        blackBackground.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        blackBackground.alpha = 0;
        add(blackBackground);

        FlxTween.tween(blackBackground, {alpha: 0.5}, 0.7);

        whiteBackground = new FlxSprite();
        whiteBackground.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        whiteBackground.alpha = 0;
        add(whiteBackground);

        boyfriend = new Character(0, 300, 'bf-WinScreen');
        boyfriend.screenCenter(Y);
        boyfriend.y += 20;
        boyfriend.antialiasing = ClientPrefs.data.antialiasing;
        boyfriend.isPlayer = true;
        boyfriend.alpha = 0;

        boyfriend.animation.finishCallback = function(name:String)
        {
            boyfriend.playAnim('${name}loop');
        }
        add(boyfriend);

        bfIconLeft = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/icon'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else Y #end);
        bfIconLeft.velocity.set(0, -iconSpeed);
        bfIconLeft.antialiasing = ClientPrefs.data.antialiasing;
        add(bfIconLeft);
        
        bfIconRight = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/icon'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else Y #end);
        bfIconRight.x = FlxG.width - bfIconRight.width;
        bfIconRight.velocity.set(0, iconSpeed);
        bfIconRight.antialiasing = ClientPrefs.data.antialiasing;
        add(bfIconRight);

        patternDown = new ResultsScreenPattern(0, 0);
        patternDown.y = FlxG.height;
        patternDown.darkPattern.velocity.set(patternSpeed, 0);
        patternDown.lightPattern.velocity.set(-patternSpeed, 0);
        patternDown.antialiasing = ClientPrefs.data.antialiasing;
        add(patternDown);

        FlxTween.tween(patternDown, {y: FlxG.height - patternDown.height}, 1, {ease: FlxEase.expoOut});

        patternUp = new ResultsScreenPattern(0, 0, true);
        patternUp.y = 0 - patternUp.height;
        patternUp.flipY = true;
        patternUp.darkPattern.velocity.set(-patternSpeed, 0);
        patternUp.lightPattern.velocity.set(patternSpeed, 0);
        patternUp.antialiasing = ClientPrefs.data.antialiasing;
        add(patternUp);

        FlxTween.tween(patternUp, {y: 0}, 1, {ease: FlxEase.expoOut});

        board = new FlxSprite();
        board.loadGraphic(Paths.image('resultsScreen/newResultsScreen/board'));
        board.screenCenter();
        board.x += FlxG.width / 6;
        board.antialiasing = ClientPrefs.data.antialiasing;
        add(board);

        //boyfriend.x = board.x - 390;
        boyfriend.x = 0 - boyfriend.width - 100;
        FlxTween.tween(boyfriend, {x: board.x - 400}, 1.2, {ease: FlxEase.quartOut, startDelay: 0.25});

        scoreTxt = new FlxText(0, board.y + 30, 0, "SCORE: 0");
        scoreTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, LEFT);
        scoreTxt.x = board.x + 25;
        scoreTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(scoreTxt);

        missesTxt = new FlxText(board.x + 30, scoreTxt.y, board.width - 80, "MISSES: 0");
        missesTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, RIGHT);
        missesTxt.x = board.x + 25;
        missesTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(missesTxt);

        ratingTxt = new FlxText(0, missesTxt.y + 45, 0, "RATING: 0%");
        ratingTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, LEFT);
        ratingTxt.x = board.x + 25;
        ratingTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(ratingTxt);

        statsTxt = new FlxText(0, ratingTxt.y + 100, 0, "STATUS:");
        statsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, LEFT);
        statsTxt.x = board.x + 25;
        statsTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(statsTxt);

        sicksTxt = new FlxText(0, statsTxt.y + 40, 0, "Sicks: 0");
        sicksTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        sicksTxt.x = board.x + 25;
        sicksTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(sicksTxt);

        goodsTxt = new FlxText(0, sicksTxt.y + 25, 0, "Goods: 0");
        goodsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        goodsTxt.x = board.x + 25;
        goodsTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(goodsTxt);

        badsTxt = new FlxText(0, goodsTxt.y + 25, 0, "Bads: 0");
        badsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        badsTxt.x = board.x + 25;
        badsTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(badsTxt);

        shitsTxt = new FlxText(0, badsTxt.y + 25, 0, "Shits: 0");
        shitsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        shitsTxt.x = board.x + 25;
        shitsTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(shitsTxt);

        rank.x = board.x + board.width - rank.width - 30;
        rank.y = board.y + board.height - rank.height - 20;
        rank.antialiasing = ClientPrefs.data.antialiasing;
        add(rank);

        FlxTween.angle(rank, -5, 5, 4, {ease: FlxEase.quartInOut, type: PINGPONG});

        ratingAnimData();
        bfAnimChoose();
        //startBfAnim();

        new FlxTimer().start(2, (_) -> {
            var tweenDur:Float = 1;
            FlxTween.num(0, PlayState.instance.songScore, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                scoreTxt.text = 'SCORE: ${Std.int(value)}';
            });

            FlxTween.num(0, PlayState.instance.songMisses, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                missesTxt.text = 'MISSES: ${Std.int(value)}';
            });

            rating = FlxMath.roundDecimal(rating, 2);
            FlxTween.num(0, rating, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                ratingTxt.text = 'RATING: ${FlxMath.roundDecimal(value, 2)}%';
            });

            FlxTween.num(0, sick, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                sicksTxt.text = 'Sicks: ${Std.int(value)}';
            });
            
            FlxTween.num(0, good, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                goodsTxt.text = 'Goods: ${Std.int(value)}';
            });
            
            FlxTween.num(0, bad, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                badsTxt.text = 'Bads: ${Std.int(value)}';
            });
            
            FlxTween.num(0, shit, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                shitsTxt.text = 'Shits: ${Std.int(value)}';
            });

            new FlxTimer().start(1, (_) -> {
                startBeating = true;
                FlxG.sound.playMusic(Paths.music(getRankName() == 'e' ? 'winScreenbad' : 'winScreen'));
                Conductor.bpm = getRankName() == 'e' ? 100 : 127;

                if(getRankName() == 'e')
                {
                    trace('curbeat 0');
                    FlxTween.cancelTweensOf(PlayState.instance.camOther.zoom);

                    PlayState.instance.camOther.zoom = 1.03;
                    FlxTween.tween(PlayState.instance.camOther, {zoom: 1}, Conductor.crochet / 1000, {ease: FlxEase.quartOut});
                }
            });
        });
    }

    function getRankName():String
    {
        if (rating >= 90) return 's';
        if (rating >= 75) return 'a';
        if (rating >= 65) return 'b';
        if (rating >= 55) return 'c';
        if (rating >= 40) return 'd';
        return 'e';
    }

    function bfAnimChoose()
    {
        boyfriend.alpha = 1;
        boyfriend.playAnim('choose');
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
        switch(getRankName())
        {
            case 's': bfAnimName = '90%'; ratingName = 'S';
            case 'a': bfAnimName = '75%'; ratingName = 'A';
            case 'b': bfAnimName = '65%'; ratingName = 'B';
            case 'c': bfAnimName = '55%'; ratingName = 'C';
            case 'd': bfAnimName = '0%'; ratingName = 'D';
            case 'e': bfAnimName = '0%'; ratingName = 'E';
            default: bfAnimName = '90%'; ratingName = 'S';
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		FlxG.watch.addQuick("beatShit", curBeat);

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

	var lastBeatHit:Int = -1;
    var sickBeats:Int = 1;
    var startBeating:Bool = false;

    override function beatHit()
    {
        trace('BEAT HIT: ' + curBeat);

        if(startBeating) sickBeats++;
        trace('SIIIICK BEAT HIT: ' + sickBeats);
        switch(sickBeats)
        {
            case 2 | 3:
                trace('curbeat $sickBeats');

                FlxTween.cancelTweensOf(PlayState.instance.camOther.zoom);

                PlayState.instance.camOther.zoom = 1.03;
                FlxTween.tween(PlayState.instance.camOther, {zoom: 1}, Conductor.crochet / 1000, {ease: FlxEase.quartOut});

                if(sickBeats == 3)
                {
                    startBfAnim();

                    boyfriend.scale.set(1.05, 1.05);
                    FlxTween.tween(boyfriend, {"scale.x": 1, "scale.y": 1}, 1, {ease: FlxEase.quartOut});
                    FlxTween.angle(boyfriend, -3, 3, 3, {ease: FlxEase.cubeInOut, type: PINGPONG});

                    FlxTween.tween(blackBackground, {alpha: getRankName() == 'e' ? 0.25 : 0}, 0.5);

                    whiteBackground.alpha = 1;
                    FlxTween.tween(whiteBackground, {alpha: 0}, 0.5);
                }
        }

        super.beatHit();
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

class ResultsScreenRank extends FlxSprite
{
    public function new(x:Float, y:Float, rank:String)
    {
        super(x, y);

        if(rank == null || rank == '') rank = 's'; // duh avoiding silly crashes

        var graphic = Paths.image('resultsScreen/newResultsScreen/ranks');
        //var iSize = Math.round(graphic.width / graphic.height);
        loadGraphic(graphic, true, 228, 232);

		animation.add(rank, [for(i in 0...frames.frames.length) i], 0, false, false);
		animation.play(rank);

        animation.curAnim.curFrame = switch(rank)
        {
            case 's': 0;
            case 'a': 1;
            case 'b': 2;
            case 'c': 3;
            case 'd': 4;
            case 'e': 5;
            default: 0;
        }
    }
}
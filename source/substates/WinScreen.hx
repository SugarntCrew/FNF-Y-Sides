package substates;

import backend.WeekData;
import flixel.addons.display.FlxBackdrop;
import states.FreeplayState;
import states.StoryMenuState;

import objects.Character;

class WinScreen extends MusicBeatSubstate
{
    public var purpleBg:FlxSprite;
    public var icons:FlxBackdrop;
    public var boyfriend:Character;
    public var scoreChart:FlxSprite;
    public var scoreChartTriangle:FlxBackdrop;

    public var songName:FlxText;
    public var scoreText:FlxText;
    public var missesText:FlxText;
    public var ratingText:FlxText;

    public var ranks:FlxSprite;
    public var otherRanks:FlxSprite;

    public var blackScreen:FlxSprite;

    override function create() 
    {
        super.create();

        purpleBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFEEE4FF);
        purpleBg.alpha = 0;
        add(purpleBg);

        FlxTween.tween(purpleBg, {alpha: 1}, 0.4);

		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.velocity.set(40, 0);
		icons.alpha = 0;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		add(icons);

        FlxTween.tween(icons, {alpha: 0.4}, 0.4);

        boyfriend = new Character(0, 150, 'bf-WinScreen');
        boyfriend.screenCenter(Y);
        boyfriend.y += -60;
        boyfriend.antialiasing = ClientPrefs.data.antialiasing;
        boyfriend.isPlayer = true;
        boyfriend.alpha = 0;

        boyfriend.animation.finishCallback = function(name:String)
        {
            boyfriend.playAnim('${name}loop');
        }
        add(boyfriend);

        scoreChart = new FlxSprite(0, 0).makeGraphic(470, FlxG.height, 0xFF130024);
        scoreChart.alpha = 0;
		scoreChart.antialiasing = ClientPrefs.data.antialiasing;
        add(scoreChart);

		scoreChartTriangle = new FlxBackdrop(Paths.image('resultsScreen/lettabox'), Y);
        scoreChartTriangle.x = scoreChart.width;
		scoreChartTriangle.velocity.set(0, -25);
        scoreChartTriangle.alpha = 0;
		scoreChartTriangle.antialiasing = ClientPrefs.data.antialiasing;
		add(scoreChartTriangle);

        boyfriend.x = scoreChart.width + 275;

        var score:Int = 0;
        var misses:Int = 0;
        var rating:Int = 0;
        
        if(PlayState.isStoryMode)
        {
            score = PlayState.campaignScore;
            misses = PlayState.campaignMisses;
            rating = Std.int(PlayState.campaignRating / PlayState.instance.totalSongsPlayed);
        }
        else
        {
            score = PlayState.instance.songScore;
            misses = PlayState.instance.songMisses;
            rating = Std.int(PlayState.instance.ratingPercent * 100);
        }

        songName = new FlxText(0, scoreChart.y + 40, scoreChart.width, '');
        if(PlayState.isStoryMode) {
            songName.text = WeekData.getCurrentWeek().weekName.toUpperCase();
        }
        else songName.text = PlayState.instance.curSong.toUpperCase();
		songName.setFormat(Paths.font("FredokaOne-Regular.ttf"), 55, CENTER);
		songName.antialiasing = ClientPrefs.data.antialiasing;
        add(songName);
        
        scoreText = new FlxText(scoreChart.x + 30, songName.y + songName.height + 40, 398, 'Score: 0');
		scoreText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 35);
		scoreText.antialiasing = ClientPrefs.data.antialiasing;
        add(scoreText);
        
        missesText = new FlxText(scoreChart.x + 30, scoreText.y + scoreText.height + 15, 398, 'Misses: 0');
		missesText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 35);
		missesText.antialiasing = ClientPrefs.data.antialiasing;
        add(missesText);

        ratingText = new FlxText(scoreChart.x + 30, missesText.y + missesText.height + 15, 398, 'Rating: 0%');
		ratingText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 35);
		ratingText.antialiasing = ClientPrefs.data.antialiasing;
        add(ratingText);

        var rating = PlayState.instance.ratingPercent * 100;
        var ratingName = '';
        var bfAnimName = '';

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

        ranks = new FlxSprite(30, ratingText.y + ratingText.height + 150);
        ranks.frames = Paths.getSparrowAtlas('resultsScreen/rank-coso');
        ranks.animation.addByPrefix('S', 'S', 24);
        ranks.animation.addByPrefix('A', 'A', 24);
        ranks.animation.addByPrefix('B', 'B', 24);
        ranks.animation.addByPrefix('C', 'C', 24);
        ranks.animation.addByPrefix('D', 'D', 24);
        ranks.animation.addByPrefix('E', 'E', 24);
        ranks.animation.play(ratingName);
		ranks.antialiasing = ClientPrefs.data.antialiasing;
        ranks.scale.set(1.1, 1.1);
        ranks.x = scoreChart.width / 2 - ranks.width / 2;
        ranks.alpha = 0;
        add(ranks);

        otherRanks = new FlxSprite(0, 10);
        otherRanks.frames = Paths.getSparrowAtlas('resultsScreen/rank_WinScreen');
        otherRanks.animation.addByPrefix('nofc', 'Nofc');
        otherRanks.animation.addByPrefix('fc', 'fc');
        otherRanks.animation.addByPrefix('gfc', 'gfc');
        otherRanks.animation.addByPrefix('sfc', 'sfc');
        otherRanks.animation.play('sfc');
		otherRanks.antialiasing = ClientPrefs.data.antialiasing;
        otherRanks.x = FlxG.width - otherRanks.width - 30;
        otherRanks.y = songName.y + songName.height / 2 - otherRanks.height / 2;
        add(otherRanks);
        
        FlxTween.tween(scoreChart, {alpha: 1}, 0.4);
        FlxTween.tween(scoreChartTriangle, {alpha: 1}, 0.4);
        FlxTween.tween(songName, {alpha: 1}, 0.4);
        FlxTween.tween(scoreText, {alpha: 1}, 0.4);
        FlxTween.tween(missesText, {alpha: 1}, 0.4);
        FlxTween.tween(ratingText, {alpha: 1}, 0.4);
        FlxTween.tween(ranks, {alpha: 1}, 0.4);
        FlxTween.tween(otherRanks, {alpha: 1}, 0.4);

        switch(PlayState.instance.ratingFC)
        {
            case 'SFC': otherRanks.animation.play('sfc');
            case 'GFC': otherRanks.animation.play('gfc');
            case 'FC': otherRanks.animation.play('fc');
            default: otherRanks.animation.play('nofc');
        }

        new FlxTimer().start(0.5, function(tmr:FlxTimer)
        {
            FlxTween.num(0, score, 0.5, {ease: FlxEase.linear}, function(v:Float)
            {
                scoreText.text = 'Score: ${Std.int(v)}';
            });
            FlxTween.num(0, misses, 0.5, {ease: FlxEase.linear}, function(v:Float)
            {
                missesText.text = 'Misses: ${Std.int(v)}';
            });
            FlxTween.num(0, rating, 0.5, {ease: FlxEase.linear}, function(v:Float)
            {
                ratingText.text = 'Rating: ${Std.int(v)}%';
            });

            new FlxTimer().start(1, function(tmr:FlxTimer)
            {        
                boyfriend.alpha = 1;
                ranks.alpha = 1;

                boyfriend.playAnim(bfAnimName);
                ranks.animation.play(ratingName);
            });
        });

        blackScreen = new FlxSprite().makeGraphic(1280, 720, 0xFF000000);
        blackScreen.alpha = 0;
        add(blackScreen);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.ACCEPT) 
        {
            FlxTween.tween(blackScreen, {alpha: 1}, 0.7, {onComplete: function(twn:FlxTween)
            {
                close();
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
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
            }});
        }
    }
}
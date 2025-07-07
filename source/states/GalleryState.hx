package states;

import flixel.addons.display.FlxBackdrop;

class GalleryState extends MusicBeatState
{
    var bg:FlxSprite;
    var bars:FlxSprite;
    var lines:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/lines'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else XY #end);
	var bfIconsTop:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/bfIcon'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);
	var bfIconsBottom:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/bfIcon'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);

    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;

    var optGrp:FlxTypedGroup<FlxSprite>;
    var optArray:Array<String> = [
        'outdated_concepts'
    ];

    override function create() 
    {
        super.create();

        FlxG.mouse.visible = true;
        
        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('gallery/bg'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);

        lines.velocity.set(75, 75);
        lines.alpha = 0.45;
        lines.antialiasing = ClientPrefs.data.antialiasing;
        add(lines);

        bars = new FlxSprite();
        bars.loadGraphic(Paths.image('gallery/bars'));
        bars.antialiasing = ClientPrefs.data.antialiasing;
        add(bars);

        bfIconsTop.velocity.set(-50, 0);
        bfIconsTop.antialiasing = ClientPrefs.data.antialiasing;
		add(bfIconsTop);

        bfIconsBottom.flipX = true;
        bfIconsBottom.velocity.set(50, 0);
        bfIconsBottom.y = FlxG.height - bfIconsBottom.height;
        bfIconsBottom.antialiasing = ClientPrefs.data.antialiasing;
        add(bfIconsBottom);

        leftArrow = new FlxSprite(15, 0);
        leftArrow.loadGraphic(Paths.image('gallery/arrow'));
        leftArrow.screenCenter(Y);
        leftArrow.antialiasing = ClientPrefs.data.antialiasing;
        add(leftArrow);

        rightArrow = new FlxSprite(30, 0);
        rightArrow.loadGraphic(Paths.image('gallery/arrow'));
        rightArrow.screenCenter(Y);
        rightArrow.antialiasing = ClientPrefs.data.antialiasing;
        rightArrow.x = FlxG.width - rightArrow.width - 30;
        rightArrow.flipX = true;
        add(rightArrow);

        optGrp = new FlxTypedGroup<FlxSprite>();
        add(optGrp);

        for(i in 0...optArray.length)
        {
            var spr = new FlxSprite();
            spr.loadGraphic(Paths.image('gallery/' + optArray[i]));
            spr.antialiasing = ClientPrefs.data.antialiasing;
            spr.screenCenter();
            spr.x += FlxG.width * i;
            optGrp.add(spr);
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(controls.BACK)
        {
            MusicBeatState.switchState(new MainMenuState());
        }
    }
}
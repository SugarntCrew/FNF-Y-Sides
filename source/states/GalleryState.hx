package states;

import haxe.Json;
import flixel.addons.display.FlxBackdrop;
import shaders.WiggleEffect;

class GalleryState extends MusicBeatState
{
    var bg:FlxSprite;
    var barTop:FlxSprite;
    var barBottom:FlxSprite;
    var lines:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/lines'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else XY #end);
	var bfIconsTop:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/bfIcon'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);
	var bfIconsBottom:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/bfIcon'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);

    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;

    var optGrp:FlxTypedGroup<GalleryObject>;
    var optArray:Array<String> = [
        'outdated_concepts',
        'music'
    ];

	var wiggle:WiggleEffect = null;
	var wiggleBg:WiggleEffect = null;

    public static var linesPos:Array<Float> = [0, 0];
    private static var curSelected:Int = 0;

    override function create() 
    {
        super.create();

        FlxG.mouse.visible = true;

		wiggle = new WiggleEffect(2, 4, 0.002, WiggleEffectType.DREAMY);
		wiggleBg = new WiggleEffect(2, 4, 0.002, WiggleEffectType.DREAMY);

		var colorBg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFFBFB4F1);
		add(colorBg);
        
        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('gallery/bg'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.shader = wiggleBg;
        add(bg);

        lines.velocity.set(75, 75);
        lines.alpha = 0.45;
        lines.antialiasing = ClientPrefs.data.antialiasing;
        lines.setPosition(GalleryState.linesPos[0], GalleryState.linesPos[1]);
        add(lines);

        if(!GalleryStateImages.comingFromImageGallery) {
            lines.alpha = 0;
            FlxTween.tween(lines, {alpha: 0.45}, 1);
        }

        optGrp = new FlxTypedGroup<GalleryObject>();
        add(optGrp);

        leftArrow = new FlxSprite(45, 0);
        leftArrow.loadGraphic(Paths.image('gallery/arrow'));
        leftArrow.screenCenter(Y);
        leftArrow.antialiasing = ClientPrefs.data.antialiasing;
        add(leftArrow);

        var leftOGY:Float = leftArrow.y;
        leftArrow.y = 800;
        FlxTween.tween(leftArrow, {y: leftOGY - 10}, 0.8, {ease: FlxEase.quartOut, onComplete: function(t:FlxTween)
        {
            FlxTween.tween(leftArrow, {y: leftArrow.y + 20}, 7, {ease: FlxEase.quartInOut, type: PINGPONG});
        }});

        rightArrow = new FlxSprite(45, 0);
        rightArrow.loadGraphic(Paths.image('gallery/arrow'));
        rightArrow.screenCenter(Y);
        rightArrow.antialiasing = ClientPrefs.data.antialiasing;
        rightArrow.x = FlxG.width - rightArrow.width - 45;
        rightArrow.flipX = true;
        add(rightArrow);

        var rightOGY:Float = rightArrow.y;
        rightArrow.y = 800;
        FlxTween.tween(rightArrow, {y: rightOGY - 10}, 0.8, {ease: FlxEase.quartOut, startDelay: 0.2, onComplete: function(t:FlxTween)
        {
            FlxTween.tween(rightArrow, {y: rightArrow.y + 20}, 7, {ease: FlxEase.quartInOut, type: PINGPONG});
        }});

        for(i in 0...optArray.length)
        {
            var spr = new GalleryObject();
            spr.loadGraphic(Paths.image('gallery/' + optArray[i]));
            spr.antialiasing = ClientPrefs.data.antialiasing;
            spr.screenCenter();
            spr.targetX = i;
            spr.x += FlxG.width * i;
            spr.shader = wiggle;
            optGrp.add(spr);

            var ogY:Float = spr.y;
            spr.y = 800;
            FlxTween.tween(spr, {y: ogY - 10}, 0.8, {ease: FlxEase.quartOut, startDelay: 0.1, onComplete: function(t:FlxTween)
            {
                FlxTween.tween(spr, {y: spr.y + 20}, 7, {ease: FlxEase.quartInOut, type: PINGPONG});
            }});
        }

        barTop = new FlxSprite();
        barTop.loadGraphic(Paths.image('gallery/bars'));
        barTop.antialiasing = ClientPrefs.data.antialiasing;
        add(barTop);

        barBottom = new FlxSprite();
        barBottom.loadGraphic(Paths.image('gallery/bars'));
        barBottom.antialiasing = ClientPrefs.data.antialiasing;
        barBottom.y = FlxG.height - barBottom.height;
        barBottom.flipY = true;
        add(barBottom);

        bfIconsTop.velocity.set(-50, 0);
        bfIconsTop.antialiasing = ClientPrefs.data.antialiasing;
		add(bfIconsTop);

        bfIconsBottom.flipX = true;
        bfIconsBottom.velocity.set(50, 0);
        bfIconsBottom.y = FlxG.height - bfIconsBottom.height;
        bfIconsBottom.antialiasing = ClientPrefs.data.antialiasing;
        add(bfIconsBottom);

        // transition
        if(GalleryStateImages.comingFromImageGallery) {

            GalleryStateImages.comingFromImageGallery = false;

            bfIconsTop.alpha = 0;
            bfIconsBottom.alpha = 0;

            FlxTween.tween(bfIconsTop, {alpha: 1}, 0.6);
            FlxTween.tween(bfIconsBottom, {alpha: 1}, 0.6);
        }
        else { //intro
            barTop.y += -barTop.height;
            barBottom.y += barBottom.height;

            bfIconsTop.alpha = 0;
            bfIconsBottom.alpha = 0;

            FlxTween.tween(barTop, {y: 0}, 0.3, {ease: FlxEase.quartOut});
            FlxTween.tween(barBottom, {y: FlxG.height - barBottom.height}, 0.3, {ease: FlxEase.quartOut, onComplete: function(t:FlxTween)
            {
                FlxTween.tween(bfIconsTop, {alpha: 1}, 0.4);
                FlxTween.tween(bfIconsBottom, {alpha: 1}, 0.4);
            }});
        }

        changeSelect();
    }

    var alreadyPressedSmth:Bool = false;
    var updateArrowScale:Bool = true;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

		if (wiggle != null) {
			wiggle.update(elapsed);
		}

		if (wiggleBg != null) {
			wiggleBg.update(elapsed);
		}

        var leftMult:Float = FlxMath.lerp(leftArrow.scale.x, 1, elapsed * 9);
        if(updateArrowScale) leftArrow.scale.set(leftMult, leftMult);

        var rightMult:Float = FlxMath.lerp(rightArrow.scale.x, 1, elapsed * 9);
        if(updateArrowScale) rightArrow.scale.set(rightMult, rightMult);

        if(!alreadyPressedSmth)
        {
            if(controls.BACK)
            {
                alreadyPressedSmth = true;
                updateArrowScale = false;

                FlxTween.cancelTweensOf(barTop);
                FlxTween.cancelTweensOf(barBottom);
                FlxTween.cancelTweensOf(bfIconsTop);
                FlxTween.cancelTweensOf(bfIconsBottom);
                FlxTween.cancelTweensOf(bg);
                FlxTween.cancelTweensOf(lines);
                FlxTween.cancelTweensOf(leftArrow);
                FlxTween.cancelTweensOf(optGrp.members[curSelected]);
                FlxTween.cancelTweensOf(rightArrow);

                FlxTween.tween(barTop, {y: -barTop.height}, 0.3, {ease: FlxEase.quartOut});
                FlxTween.tween(barBottom, {y: FlxG.height}, 0.3, {ease: FlxEase.quartOut});
                FlxTween.tween(bfIconsTop, {y: -bfIconsTop.height}, 0.3, {ease: FlxEase.quartOut});
                FlxTween.tween(bfIconsBottom, {y: FlxG.height}, 0.3, {ease: FlxEase.quartOut});

                FlxTween.tween(bg, {alpha: 0}, 0.7);
                FlxTween.tween(lines, {alpha: 0}, 0.7);
                FlxTween.tween(leftArrow, {y: 800}, 0.4, {ease: FlxEase.quartOut});
                FlxTween.tween(optGrp.members[curSelected], {y: 800}, 0.4, {ease: FlxEase.quartOut});
                FlxTween.tween(rightArrow, {y: 800}, 0.4, {ease: FlxEase.quartOut});

                StoryMenuState.backFromStoryMode = true;

                new FlxTimer().start(0.8, function(t:FlxTimer)
                {
		    		FlxTransitionableState.skipNextTransIn = true;
		    		FlxTransitionableState.skipNextTransOut = true;
                    MusicBeatState.switchState(new MainMenuState());
                });
            }

            if(controls.UI_RIGHT_P)
            {
                changeSelect(1);
                rightArrow.scale.set(1.25, 1.075);
            }
            if(controls.UI_LEFT_P)
            {
                changeSelect(-1);
                leftArrow.scale.set(1.25, 1.075);
            }

            if(controls.ACCEPT)
            {
                alreadyPressedSmth = true;
                var selectedItem:String = optArray[curSelected];
                switch(selectedItem)
                {
                    case 'outdated_concepts':
                        FlxG.sound.play(Paths.sound('confirmMenu'));

                        FlxTween.cancelTweensOf(leftArrow);
                        for(obj in optGrp)
                        {
                            FlxTween.cancelTweensOf(obj);
                        }
                        FlxTween.cancelTweensOf(rightArrow);

                        FlxTween.tween(leftArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn});
                        FlxTween.tween(optGrp.members[curSelected], {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.1});
                        FlxTween.tween(rightArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.2});

                        FlxTween.tween(bfIconsTop, {alpha: 0}, 0.6);
                        FlxTween.tween(bfIconsBottom, {alpha: 0}, 0.6);

                        new FlxTimer().start(0.8, function(t:FlxTimer)
                        {
		    			    GalleryState.linesPos.insert(0, lines.x);
		    			    GalleryState.linesPos.insert(1, lines.y);

		    				FlxTransitionableState.skipNextTransIn = true;
		    				FlxTransitionableState.skipNextTransOut = true;
                            MusicBeatState.switchState(new GalleryStateImages(selectedItem));
                        });
                    case 'music':
                        FlxG.sound.play(Paths.sound('confirmMenu'));

                        FlxTween.cancelTweensOf(leftArrow);
                        for(obj in optGrp)
                        {
                            FlxTween.cancelTweensOf(obj);
                        }
                        FlxTween.cancelTweensOf(rightArrow);

                        FlxTween.tween(leftArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn});
                        FlxTween.tween(optGrp.members[curSelected], {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.1});
                        FlxTween.tween(rightArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.2});

                        FlxTween.tween(bfIconsTop, {alpha: 0}, 0.6);
                        FlxTween.tween(bfIconsBottom, {alpha: 0}, 0.6);

                        new FlxTimer().start(0.8, function(t:FlxTimer)
                        {
		    			    GalleryState.linesPos.insert(0, lines.x);
		    			    GalleryState.linesPos.insert(1, lines.y);

		    				FlxTransitionableState.skipNextTransIn = true;
		    				FlxTransitionableState.skipNextTransOut = true;
                            MusicBeatState.switchState(new GalleryStateMusic());
                        });
                    default:
                }
            }
        }
    }

    function changeSelect(change:Int = 0)
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, optArray.length - 1);

		for (num => item in optGrp.members)
		{
			item.targetX = num - curSelected;
			item.alpha = 0.6;
			if (item.targetX == 0) item.alpha = 1;
		}
    }
}

class GalleryObject extends FlxSprite
{
    public var targetX:Float = 0;
    public var distancePerItem:FlxPoint = new FlxPoint(1280, 0);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);
    
    public function new(x:Float = 0, y:Float = 0, ?graphic:Dynamic = null)
    {
        super(x, y, graphic);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		var lerpVal:Float = Math.exp(-elapsed * 9.6);
		x = FlxMath.lerp((targetX * distancePerItem.x) + startPosition.x, x, lerpVal);
    }
}

typedef ImageData = 
{
    var name:String;
    var description:String;
}

class GalleryStateImages extends MusicBeatState
{
    var imageDataArray:Array<ImageData> = [];
    var imageGrp:FlxTypedGroup<GalleryObject>;
    
    var bg:FlxSprite;
    var barTop:FlxSprite;
    var barBottom:FlxSprite;
    var titleText:FlxText;
    var descText:FlxText;
    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;
    
    var lines:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/lines'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else XY #end);

	var wiggleBg:WiggleEffect = null;

    private static var curSelected:Int = 0;
    public static var comingFromImageGallery:Bool = false;

    public function new(folderName:String)
    {
        super();

        FlxG.mouse.visible = true;

		wiggleBg = new WiggleEffect(2, 4, 0.002, WiggleEffectType.DREAMY);
        
        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('gallery/bg'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.shader = wiggleBg;
        add(bg);
        
        lines.velocity.set(75, 75);
        lines.alpha = 0.45;
        lines.antialiasing = ClientPrefs.data.antialiasing;
        lines.setPosition(GalleryState.linesPos[0], GalleryState.linesPos[1]);
        add(lines);

        imageGrp = new FlxTypedGroup<GalleryObject>();
        add(imageGrp);

        leftArrow = new FlxSprite(45, 0);
        leftArrow.loadGraphic(Paths.image('gallery/arrow'));
        leftArrow.screenCenter(Y);
        leftArrow.antialiasing = ClientPrefs.data.antialiasing;
        leftArrow.scale.set(0.8, 0.8);
        leftArrow.updateHitbox();
        add(leftArrow);

        rightArrow = new FlxSprite(45, 0);
        rightArrow.loadGraphic(Paths.image('gallery/arrow'));
        rightArrow.screenCenter(Y);
        rightArrow.antialiasing = ClientPrefs.data.antialiasing;
        rightArrow.x = FlxG.width - rightArrow.width - 45;
        rightArrow.flipX = true;
        rightArrow.scale.set(0.8, 0.8);
        rightArrow.updateHitbox();
        add(rightArrow);

        barTop = new FlxSprite();
        barTop.loadGraphic(Paths.image('gallery/bars'));
        barTop.antialiasing = ClientPrefs.data.antialiasing;
        add(barTop);

        barBottom = new FlxSprite();
        barBottom.loadGraphic(Paths.image('gallery/bars'));
        barBottom.antialiasing = ClientPrefs.data.antialiasing;
        barBottom.y = FlxG.height - barBottom.height;
        barBottom.flipY = true;
        add(barBottom);

        titleText = new FlxText(0, 20, FlxG.width, 'A');
        titleText.setFormat(Paths.font('vcr.ttf'), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE);
        titleText.antialiasing = ClientPrefs.data.antialiasing;
        titleText.y = barTop.y + (barTop.height / 2) - (titleText.height / 2);
        add(titleText);

        descText = new FlxText(0, 20, FlxG.width, 'A');
        descText.setFormat(Paths.font('vcr.ttf'), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE);
        descText.antialiasing = ClientPrefs.data.antialiasing;
        descText.y = barBottom.y + (barBottom.height / 2) - (descText.height / 2);
        add(descText);

        var imagesOnFolder = FileSystem.readDirectory('assets/shared/images/gallery/$folderName');
        
        //remove the .json files (lmao)
        for(obj in imagesOnFolder)
        {
            if(StringTools.endsWith(obj, '.json'))
            {
                imagesOnFolder.remove(obj);
            }
        }

        #if debug trace('lol: $imagesOnFolder'); #end
        for(num => image in imagesOnFolder)
        {
            #if debug
                trace(' * $image');
            #end
            
            // removing the extension .png
            var imageName = StringTools.replace(image, '.png', '');

            try {
                var content = File.getContent('assets/shared/images/gallery/$folderName/$imageName.json');
                var imageData = Json.parse(content);

                #if debug
                trace('$num: ${imageData.name}');
                trace('$num: ${imageData.description}');
                #end

                imageDataArray.push(imageData);
            } 
            catch(exc)
            {
                #if debug trace('No json has been found for the image with ID $num'); #end
            }

            var spr = new GalleryObject();
            spr.loadGraphic(Paths.image('gallery/$folderName/$imageName'));
            #if debug
            trace(' - [$num] Path: ${'assets/shared/images/gallery/$folderName/$imageName.png'}');
            #end
            spr.antialiasing = ClientPrefs.data.antialiasing;
            spr.screenCenter();
            spr.startPosition = new FlxPoint(spr.x, spr.y);
            spr.targetX = num;
            spr.x += FlxG.width * num;
            imageGrp.add(spr);
        }

        changeSelect();
    }

    override function create() 
    {
        super.create();

        titleText.alpha = 0;
        descText.alpha = 0;

        FlxTween.tween(titleText, {alpha: 1}, 0.3);
        FlxTween.tween(descText, {alpha: 1}, 0.3);
    }

    var alreadyPressedSmth:Bool = false;
    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (wiggleBg != null) {
            wiggleBg.update(elapsed);
        }

        var leftMult:Float = FlxMath.lerp(leftArrow.scale.x, 0.8, elapsed * 12);
        leftArrow.scale.set(leftMult, leftMult);

        var rightMult:Float = FlxMath.lerp(rightArrow.scale.x, 0.8, elapsed * 12);
        rightArrow.scale.set(rightMult, rightMult);
        
        if(!alreadyPressedSmth)
        {
            if(controls.UI_RIGHT_P)
            {
                changeSelect(1);
                rightArrow.scale.set(0.9, 0.85);
            }
            if(controls.UI_LEFT_P)
            {
                changeSelect(-1);
                leftArrow.scale.set(0.9, 0.85);
            }

            if(controls.BACK)
            {
                alreadyPressedSmth = true;
                FlxG.sound.play(Paths.sound('cancelMenu'));

                FlxTween.cancelTweensOf(leftArrow);
                for(obj in imageGrp)
                {
                    FlxTween.cancelTweensOf(obj);
                }
                FlxTween.cancelTweensOf(rightArrow);

                FlxTween.tween(leftArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn});
                FlxTween.tween(imageGrp.members[curSelected], {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.1});
                FlxTween.tween(rightArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.2});

                comingFromImageGallery = true;

                new FlxTimer().start(0.8, function(t:FlxTimer)
                {
		    		GalleryState.linesPos.insert(0, lines.x);
		    		GalleryState.linesPos.insert(1, lines.y);

		    		FlxTransitionableState.skipNextTransIn = true;
		    		FlxTransitionableState.skipNextTransOut = true;
                    MusicBeatState.switchState(new GalleryState());
                });
            }
        }
    }
    
    function changeSelect(change:Int = 0)
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, imageGrp.length - 1);

		for (num => item in imageGrp.members)
		{
			item.targetX = num - curSelected;
			item.alpha = 0.6;
			if (item.targetX == 0) item.alpha = 1;
		}

        if(imageDataArray[curSelected] != null)
        {
            FlxTween.cancelTweensOf(titleText);
            FlxTween.cancelTweensOf(descText);

            titleText.alpha = 0;
            descText.alpha = 0;

            FlxTween.tween(titleText, {alpha: 1}, 0.3);
            FlxTween.tween(descText, {alpha: 1}, 0.3);

            titleText.text = imageDataArray[curSelected].name != null ? imageDataArray[curSelected].name : 'Untitled';
            descText.text = imageDataArray[curSelected].description != null ? imageDataArray[curSelected].description : 'No description available.';
        }
    }
}

class GalleryStateMusic extends MusicBeatState
{
    var bg:FlxSprite;
    var barLeft:FlxSprite;
    var barRight:FlxSprite;
    var lines:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/lines'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else XY #end);
	var diskIconsLeft:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/music/disk'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else Y, 0, 12 #end);
	var diskIconsRight:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/music/disk'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else Y, 0, 12 #end);

    var panel:FlxSprite;
    var bf:FlxSprite;
    var arrowUp:FlxSprite;
    var arrowDown:FlxSprite;

	var wiggle:WiggleEffect = null;
	var wiggleBg:WiggleEffect = null;

    var musicSongsGrp:FlxTypedGroup<GalleryMusicObject>;
    var musicSongsArray:Array<String> = [
        'tutorial',
        'bopeebo',
        'fresh',
        'dad-battle',
    ];

    public function new()
    {
        super();

		wiggle = new WiggleEffect(2, 4, 0.002, WiggleEffectType.DREAMY);
		wiggleBg = new WiggleEffect(2, 4, 0.002, WiggleEffectType.DREAMY);

		var colorBg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFFBFB4F1);
		add(colorBg);
        
        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('gallery/bg'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.shader = wiggleBg;
        add(bg);

        lines.velocity.set(75, 75);
        lines.alpha = 0.45;
        lines.antialiasing = ClientPrefs.data.antialiasing;
        lines.setPosition(GalleryState.linesPos[0], GalleryState.linesPos[1]);
        add(lines);

        barLeft = new FlxSprite();
        barLeft.loadGraphic(Paths.image('gallery/bars_vertical'));
        barLeft.antialiasing = ClientPrefs.data.antialiasing;
        add(barLeft);

        barRight = new FlxSprite();
        barRight.loadGraphic(Paths.image('gallery/bars_vertical'));
        barRight.antialiasing = ClientPrefs.data.antialiasing;
        barRight.flipX = true;
        barRight.x = FlxG.width - barRight.width;
        add(barRight);

        diskIconsLeft.velocity.set(0, -50);
        diskIconsLeft.antialiasing = ClientPrefs.data.antialiasing;
        diskIconsLeft.x = barLeft.x + (barLeft.width / 2) - (diskIconsLeft.width / 2) - (17 / 2);
		add(diskIconsLeft);

        diskIconsRight.flipX = true;
        diskIconsRight.velocity.set(0, 50);
        diskIconsRight.y = FlxG.height - diskIconsRight.height;
        diskIconsRight.antialiasing = ClientPrefs.data.antialiasing;
        diskIconsRight.x = barRight.x + (barRight.width / 2) - (diskIconsRight.width / 2) + (17 / 2);
        add(diskIconsRight);

        panel = new FlxSprite(775, 0);
        panel.loadGraphic(Paths.image('gallery/music/panel'));
        panel.antialiasing = ClientPrefs.data.antialiasing;
        panel.screenCenter(Y);
        add(panel);

        bf = new FlxSprite(0, 0);
        bf.loadGraphic(Paths.image('gallery/music/bf'));
        bf.antialiasing = ClientPrefs.data.antialiasing;
        bf.screenCenter(Y);
        bf.x = panel.x + (panel.width / 2) - (bf.width / 2) - 15;
        bf.y = panel.y + (panel.height / 2) - (bf.height / 2) - 15;
        add(bf);

        musicSongsGrp = new FlxTypedGroup<GalleryMusicObject>();
        add(musicSongsGrp);

        arrowUp = new FlxSprite(355, 130);
        arrowUp.loadGraphic(Paths.image('gallery/music/arrow'));
        arrowUp.antialiasing = ClientPrefs.data.antialiasing;
        add(arrowUp);

        arrowDown = new FlxSprite(355, 530);
        arrowDown.loadGraphic(Paths.image('gallery/music/arrow'));
        arrowDown.antialiasing = ClientPrefs.data.antialiasing;
        arrowDown.flipY = true;
        add(arrowDown);

        for(i in 0...musicSongsArray.length)
        {
            var spr = new GalleryMusicObject();
		    spr.loadGraphic(Paths.image('songCards/${Paths.formatToSongPath(musicSongsArray[i])}'));
            spr.antialiasing = ClientPrefs.data.antialiasing;
            spr.screenCenter(Y);
            spr.x = arrowUp.x + (arrowUp.width / 2) - (spr.width / 2);
            spr.startPosition = new FlxPoint(spr.x, spr.y);
            spr.targetY = i;
            spr.y += FlxG.height * i;
            spr.shader = wiggle;
            musicSongsGrp.add(spr);

            var ogY:Float = spr.y;
            spr.y = 800;
            FlxTween.tween(spr, {y: ogY - 10}, 0.8, {ease: FlxEase.quartOut, startDelay: 0.1, onComplete: function(t:FlxTween)
            {
                FlxTween.tween(spr, {y: spr.y + 20}, 7, {ease: FlxEase.quartInOut, type: PINGPONG});
            }});
        }
    }

    var alreadyPressedSmth:Bool = false;
    var updateArrowScale:Bool = true;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

		if (wiggle != null) {
			wiggle.update(elapsed);
		}

		if (wiggleBg != null) {
			wiggleBg.update(elapsed);
		}

        var upMult:Float = FlxMath.lerp(arrowUp.scale.x, 1, elapsed * 9);
        if(updateArrowScale) arrowUp.scale.set(upMult, upMult);

        var rightMult:Float = FlxMath.lerp(arrowDown.scale.x, 1, elapsed * 9);
        if(updateArrowScale) arrowDown.scale.set(rightMult, rightMult);

        if(!alreadyPressedSmth)
        {
            if(controls.UI_DOWN_P)
            {
                changeSelect(1);
                arrowDown.scale.set(0.9, 0.85);
            }
            if(controls.UI_UP_P)
            {
                changeSelect(-1);
                arrowUp.scale.set(0.9, 0.85);
            }

            if(controls.BACK)
            {
                MusicBeatState.switchState(new GalleryState());
            }
        }
    }
    
    private static var curSelected:Int = 0;
    function changeSelect(change:Int = 0)
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, musicSongsGrp.length - 1);

		for (num => item in musicSongsGrp.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
		}
    }
}

class GalleryMusicObject extends FlxSprite
{
    public var targetY:Float = 0;
    public var distancePerItem:FlxPoint = new FlxPoint(0, 720);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);
    
    public function new(x:Float = 0, y:Float = 0, ?graphic:Dynamic = null)
    {
        super(x, y, graphic);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		var lerpVal:Float = Math.exp(-elapsed * 9.6);
		y = FlxMath.lerp((targetY * distancePerItem.y) + startPosition.y, y, lerpVal);
    }
}
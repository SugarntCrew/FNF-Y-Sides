package states;

import flixel.FlxObject;
import objects.AttachedSprite;
import flixel.addons.display.FlxBackdrop;
import shaders.WiggleEffect;

class CreditsStateYSides extends MusicBeatState
{
	public static var watchingCredits:Bool = false;
	public static var backFromCredits:Bool = false;
	var wentBack:Bool = false;

    var developers:Array<Dynamic> = [
        ['gBv2209',         'gbv',      ['Director', 'Concept Artist', 'Artist', 'Animator', 'Musician', 'Charter', 'Coder'], 		[['yt', 'https://www.youtube.com/@gBv2209'], ['x', 'https://x.com/gbv2209']], 0xFF2F6662],
        ['Mr. Madera',      'madera',   ['Director', 'Main Coder', 'Charter'], 						                                [['yt', 'https://www.youtube.com/@mrmadera1235'], ['x', 'https://x.com/MrMadera625']], 0xFF8ACCE1],
        ['SFoxyDAC',        'foxy',     ['Co-Director', 'Artist', 'Animator'], 					                                    [['yt', 'https://www.youtube.com/@SFoxyDAC'], ['x', 'https://x.com/SFoxyDAC']], 0xFFDC7D6F],
        ['Zhadnii',         'ema',  ['Musician'], 					                                                [['yt', 'https://youtube.com/@zhadnii_']], 0xFF363676],
        ['FlashMan07',      'flash',    ['Musician', 'Concept Artist', 'Artist'],                                       [['yt', 'https://www.youtube.com/@FlashMan07']], 0xFF912197],
        ['Heromax',         'hero',     ['Concept Artist', 'Artist', 'Charter'], 			                            [['x', 'https://x.com/heromax_2498']], 0xFF424452],
        ['Snowlui',         'snowlui',  ['Musician'], 			                            							[['yt', 'https://www.youtube.com/channel/UCSt4Fyu2syVMeGBHeZaWzyA'], ['x', 'https://x.com/Snowlui0831']], 0xFF9C0053],
        ['ItsTapiiii',      'tapi',     ['Musician'], 					                                                [['yt', 'https://www.youtube.com/@ItsTapiiii']], 0xFF363676],
        ['EmmaPSX',      	'emma',     ['Charter'], 					                                                [['yt', 'https://www.youtube.com/channel/UCbTvTX7u7sYJfS5fIriLc_g'], ['x', 'https://x.com/emmapsx20']], 0xFFB56134],
        ['E1000',           'emil',    ['Artist', 'Charter'], 					                                        [['yt', 'https://www.youtube.com/@E1000YT/videos'], ['x', 'https://x.com/E1000TWOF ']], 0xFF1A8758]
    ];

	var bg:FlxSprite;

    var currentCharacter:FlxSprite;
    var devInfo:InfoAboutPerson;

	var psychText:FlxText;
	var icons:FlxBackdrop;

	var topY:Float;
	var bottomY:Float = 850;

	var tweenDuration:Float = 0.1;
    static var curSelected:Int = 0;

	var leftArrow:Alphabet;
	var rightArrow:Alphabet;

	override function create() 
	{
		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

		bg = new FlxSprite(-80).makeGraphic(1280, 720, 0xFFBFB4F1);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.velocity.set(10, 10);
		icons.alpha = 0.45;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		icons.scrollFactor.set();
		add(icons);

		icons.setPosition(MainMenuState.iconsPos[0], MainMenuState.iconsPos[1]);

        currentCharacter = new FlxSprite(60, 200);
		currentCharacter.loadGraphic(Paths.image('credits2/people/gbv'));
        currentCharacter.screenCenter(Y);
		currentCharacter.antialiasing = ClientPrefs.data.antialiasing;
		add(currentCharacter);

        devInfo = new InfoAboutPerson('gbv2209', 		['Concept Artist', 'Artist', 'Animator', 'Musician', 'Charter', 'Coder'], 		[['yt', 'https://www.youtube.com/@gBv2209'], ['x', 'https://x.com/gbv2209']], 0xFF666666);
        devInfo.x += 200;
        add(devInfo);

		psychText = new FlxText(0, 0, FlxG.width, 'Press TAB to view Psych Engine credits', 16);
		psychText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		psychText.borderSize = 1.25;
		psychText.y = FlxG.height - psychText.height - 10;
		psychText.scrollFactor.set(0, 1);
		psychText.antialiasing = ClientPrefs.data.antialiasing;
		add(psychText);

		leftArrow = new Alphabet(10, 300, '<', true);
		add(leftArrow);

		rightArrow = new Alphabet(10, 300, '>', true);
		rightArrow.x = FlxG.width - rightArrow.width - 10;
		add(rightArrow);

        changeSelection();
		super.create();
	}

	var psychScale:Float = 1;
	override function update(elapsed:Float) {

		super.update(elapsed);

		if (controls.BACK && !watchingCredits) {

			FlxG.sound.play(Paths.sound('cancelMenu'));
			wentBack = true;
		
			backFromCredits = true;
			watchingCredits = false;
            
			MainMenuState.iconsPos.insert(0, icons.x);
			MainMenuState.iconsPos.insert(1, icons.y);

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        if(controls.UI_LEFT_P)
        {
            changeSelection(-1);
        }

        if(controls.UI_RIGHT_P)
        {
            changeSelection(1);
        }

		if(FlxG.keys.justPressed.TAB)
		{
			watchingCredits = false;
			FlxTransitionableState.skipNextTransIn = false;
			FlxTransitionableState.skipNextTransOut = false;

			MusicBeatState.switchState(new CreditsState());	
		}

		FlxG.mouse.visible = true;
	}

    function changeSelection(change:Int = 0)
    {
		FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected = FlxMath.wrap(curSelected + change, 0, developers.length - 1);

		FlxTween.cancelTweensOf(currentCharacter);

		currentCharacter.scale.set(1.05, 1.05);
		FlxTween.tween(currentCharacter, {"scale.x": 1, "scale.y": 1}, 0.3, {ease: FlxEase.quartOut});

        // reload char
		currentCharacter.loadGraphic(Paths.image('credits2/people/${developers[curSelected][1]}'));
        currentCharacter.screenCenter(Y);
		currentCharacter.antialiasing = ClientPrefs.data.antialiasing;
		add(currentCharacter);

        // reload info
        devInfo.refresh(developers[curSelected][0], developers[curSelected][2], developers[curSelected][3], developers[curSelected][4]);
    }
}

class InfoAboutPerson extends FlxSpriteGroup
{
	var squareBg:FlxSprite;
	var personName:Alphabet;
	var rolsGrp:FlxSpriteGroup;
	var socialMediasGrp:FlxSpriteGroup;
	var socialMedias:Array<Dynamic> = [];

	public function new(name:String, rols:Array<String>, avaibleSocialMedias:Array<Dynamic>, color:FlxColor)
	{
		super();

		socialMedias = avaibleSocialMedias;

		squareBg = new FlxSprite();
		//squareBg.makeGraphic(600, 550, 0xFF000000);
		squareBg.loadGraphic(Paths.image('credits2/background'));
		squareBg.alpha = 0.7;
		squareBg.scrollFactor.set();
		squareBg.screenCenter();
		add(squareBg);

		personName = new Alphabet(0, squareBg.y + 10, name, true);
		personName.setScale(0.85);
		personName.x = squareBg.x + squareBg.width / 2 - personName.width / 2;
		personName.scrollFactor.set();
		personName.color = color;
		add(personName);

		rolsGrp = new FlxSpriteGroup();
		add(rolsGrp);

		socialMediasGrp = new FlxSpriteGroup();
		add(socialMediasGrp);

		for(i in 0...rols.length)
		{
			var rolTxt = new Alphabet(0, 0, rols[i], true);
			rolTxt.setScale(0.7);
			if(rols[i] == 'Director' || rols[i] == 'Co-Director') rolTxt.color = 0xFFECD032;
			rolTxt.y = personName.y + personName.height + 30 + ((rolTxt.height + 10) * i);
			rolTxt.scrollFactor.set();
			rolTxt.screenCenter(X);
			rolsGrp.add(rolTxt);
		}

		for(i in 0...avaibleSocialMedias.length)
		{
			if(socialMediasGrp.members[i-1] != null) socialMediasGrp.members[i-1].x -= socialMediasGrp.members[i-1].width;

			var socialMediaIcon = new FlxSprite();
			trace('Loading the following social media ($name): ${avaibleSocialMedias[i][0]}');
			switch(avaibleSocialMedias[i][0])
			{
				case 'yt':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/yt'));
				case 'disc':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/disc'));
				case 'x':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/X'));
			}
			socialMediaIcon.scrollFactor.set();
			socialMediaIcon.y = squareBg.y + squareBg.height - socialMediaIcon.height - 10;
			socialMediaIcon.x = squareBg.x + squareBg.width - socialMediaIcon.width - 10;
			socialMediaIcon.ID = i;
			socialMediasGrp.add(socialMediaIcon);
		}
	}

    public function refresh(name:String, rols:Array<String>, avaibleSocialMedias:Array<Dynamic>, color:FlxColor)
    {
		socialMedias = avaibleSocialMedias;

        personName.text = name;
		personName.x = squareBg.x + squareBg.width / 2 - personName.width / 2;
		if(color != personName.color) personName.color = color;
        
        // reset groups
        rolsGrp.forEach(function(obj:FlxSprite) { rolsGrp.remove(obj); });
        socialMediasGrp.forEach(function(obj:FlxSprite) { socialMediasGrp.remove(obj); });

		for(i in 0...rols.length)
		{
			var rolTxt = new Alphabet(0, 0, rols[i], true);
			rolTxt.setScale(0.7);
			if(rols[i] == 'Director' || rols[i] == 'Co-Director') rolTxt.color = 0xFFECD032;
			rolTxt.y = personName.y + personName.height + 30 + ((rolTxt.height + 10) * i);
			rolTxt.scrollFactor.set();
			rolTxt.screenCenter(X);
			rolsGrp.add(rolTxt);
		}

		for(i in 0...avaibleSocialMedias.length)
		{
			if(socialMediasGrp.members[i-1] != null) socialMediasGrp.members[i-1].x -= socialMediasGrp.members[i-1].width;

			var socialMediaIcon = new FlxSprite();
			trace('Loading the following social media ($name): ${avaibleSocialMedias[i][0]}');
			switch(avaibleSocialMedias[i][0])
			{
				case 'yt':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/yt'));
				case 'disc':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/disc'));
				case 'x':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/X'));
			}
			socialMediaIcon.scrollFactor.set();
			socialMediaIcon.y = squareBg.y + squareBg.height - socialMediaIcon.height - 10;
			socialMediaIcon.x = squareBg.x + squareBg.width - socialMediaIcon.width - 210;
			socialMediaIcon.ID = i;
			socialMediasGrp.add(socialMediaIcon);
		}
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		socialMediasGrp.forEach(function(spr:FlxSprite)
		{
			if(FlxG.mouse.overlaps(spr))
			{
				spr.alpha = 1;
				if(FlxG.mouse.justPressed)
				{
					CoolUtil.browserLoad(socialMedias[spr.ID][1]);
				}
			}
			else spr.alpha = 0.7;
		});
	}
}
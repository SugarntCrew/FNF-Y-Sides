package states;

import flixel.FlxObject;
import objects.AttachedSprite;
import flixel.addons.display.FlxBackdrop;

class CreditsState2 extends MusicBeatState
{
	public static var watchingCredits:Bool = false;
	public static var backFromCredits:Bool = false;
	var wentBack:Bool = false;

	var bg:FlxSprite;

	var owner:FlxSprite;
	var coOwner:FlxSprite;
	var devs:FlxSprite;

	var gbv:FlxSprite;
	var madera:FlxSprite;
	var foxy:FlxSprite;

	var bunny:FlxSprite;
	var ema:FlxSprite;
	var flash:FlxSprite;
	var hero:FlxSprite;
	var tapi:FlxSprite;
	var e1000:FlxSprite;

	var psych:FlxSprite;
	var icons:FlxBackdrop;

	var camPos:FlxObject;
	var camPosLerp:FlxObject;
	var topY:Float;
	var bottomY:Float = 850;

	var tweenDuration:Float = 0.1;

	override function create() 
	{
		camPos = new FlxObject(0, 385, 1, 1);
		topY = camPos.y;
		add(camPos);

		camPosLerp = new FlxObject(0, 385, 1, 1);
		add(camPosLerp);

		bg = new FlxSprite(-80).makeGraphic(1280, 720, 0xFFBFB4F1);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		FlxG.camera.follow(camPosLerp);

		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.velocity.set(10, 10);
		icons.alpha = 0.45;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		icons.scrollFactor.set();
		add(icons);

		icons.setPosition(MainMenuState.iconsPos[0], MainMenuState.iconsPos[1]);

		owner = new FlxSprite(150, 90);
		owner.loadGraphic(Paths.image('credits2/owners'));
		owner.updateHitbox();
		owner.scrollFactor.set(0, 1);
		owner.antialiasing = ClientPrefs.data.antialiasing;
		add(owner);

		owner.alpha = 0;
		FlxTween.tween(owner, {alpha: 1}, tweenDuration);

		coOwner = new FlxSprite(650, 60);
		coOwner.loadGraphic(Paths.image('credits2/coOwners'));
		coOwner.updateHitbox();
		coOwner.scrollFactor.set(0, 1);
		coOwner.antialiasing = ClientPrefs.data.antialiasing;
		add(coOwner);

		coOwner.alpha = 0;
		FlxTween.tween(coOwner, {alpha: 1}, tweenDuration, {startDelay: 0.05});

		gbv = new FlxSprite(120, 200);
		gbv.frames = Paths.getSparrowAtlas('credits2/people/gbv');
		gbv.animation.addByPrefix('idle', 'gbv_neutral', 24, true);
		gbv.animation.addByPrefix('select', 'gbv_selected', 24, true);
		gbv.animation.play('idle');
		gbv.scrollFactor.set(0, 1);
		gbv.antialiasing = ClientPrefs.data.antialiasing;
		add(gbv);

		gbv.alpha = 0;
		FlxTween.tween(gbv, {alpha: 1}, tweenDuration, {startDelay: 0.1});

		madera = new FlxSprite(330, 230);
		madera.frames = Paths.getSparrowAtlas('credits2/people/madera');
		madera.animation.addByPrefix('idle', 'madera_neutral', 24, true);
		madera.animation.addByPrefix('select', 'madera_selected', 24, true);
		madera.animation.play('idle');
		madera.scrollFactor.set(0, 1);
		madera.antialiasing = ClientPrefs.data.antialiasing;
		add(madera);

		madera.alpha = 0;
		FlxTween.tween(madera, {alpha: 1}, tweenDuration, {startDelay: 0.15});
	
		foxy = new FlxSprite(700, 200);
		foxy.frames = Paths.getSparrowAtlas('credits2/people/foxy');
		foxy.animation.addByPrefix('idle', 'sfoxy_neutral', 24, true);
		foxy.animation.addByPrefix('select', 'sfoxy_selected', 24, true);
		foxy.animation.play('idle');
		foxy.scrollFactor.set(0, 1);
		foxy.antialiasing = ClientPrefs.data.antialiasing;
		add(foxy);

		foxy.alpha = 0;
		FlxTween.tween(foxy, {alpha: 1}, tweenDuration, {startDelay: 0.2});

		hero = new FlxSprite(880, 200);
		hero.frames = Paths.getSparrowAtlas('credits2/people/hero');
		hero.animation.addByPrefix('idle', 'heromax_neutral', 24, true);
		hero.animation.addByPrefix('select', 'heromax_selected', 24, true);
		hero.animation.play('idle');

		hero.scale.set(0.8, 0.8);
		hero.updateHitbox();

		hero.scrollFactor.set(0, 1);
		hero.antialiasing = ClientPrefs.data.antialiasing;
		add(hero);
		
		hero.alpha = 0;
		FlxTween.tween(hero, {alpha: 1}, tweenDuration, {startDelay: 0.25});

		devs = new FlxSprite(500, 510);
		devs.loadGraphic(Paths.image('credits2/devs'));
		devs.screenCenter(X);
		devs.updateHitbox();
		devs.scrollFactor.set(0, 1);
		devs.antialiasing = ClientPrefs.data.antialiasing;
		add(devs);

		devs.alpha = 0;
		FlxTween.tween(devs, {alpha: 1}, tweenDuration, {startDelay: 0.3});

		bunny = new FlxSprite(20, 620);
		bunny.frames = Paths.getSparrowAtlas('credits2/people/bunny');
		bunny.animation.addByPrefix('idle', 'bunny_neutral', 24, true);
		bunny.animation.addByPrefix('select', 'bunny_selected', 24, true);
		bunny.animation.play('idle');
		bunny.scrollFactor.set(0, 1);
		bunny.antialiasing = ClientPrefs.data.antialiasing;
		add(bunny);

		bunny.alpha = 0;
		FlxTween.tween(bunny, {alpha: 1}, tweenDuration, {startDelay: 0.35});

		ema = new FlxSprite(bunny.x + 250, 620);
		ema.frames = Paths.getSparrowAtlas('credits2/people/ema');
		ema.animation.addByPrefix('idle', 'ema_neutral', 24, true);
		ema.animation.addByPrefix('select', 'ema_selected', 24, true);
		ema.animation.play('idle');
		ema.scrollFactor.set(0, 1);
		ema.antialiasing = ClientPrefs.data.antialiasing;
		add(ema);

		ema.alpha = 0;
		FlxTween.tween(ema, {alpha: 1}, tweenDuration, {startDelay: 0.4});

		flash = new FlxSprite(ema.x + 250, 620);
		flash.frames = Paths.getSparrowAtlas('credits2/people/flash');
		flash.animation.addByPrefix('idle', 'flash_neutral', 24, true);
		flash.animation.addByPrefix('select', 'flash_selected', 24, true);
		flash.animation.play('idle');
		flash.scrollFactor.set(0, 1);
		flash.antialiasing = ClientPrefs.data.antialiasing;
		add(flash);

		flash.alpha = 0;
		FlxTween.tween(flash, {alpha: 1}, tweenDuration, {startDelay: 0.45});

		e1000 = new FlxSprite(flash.x + 250, 620);
		e1000.frames = Paths.getSparrowAtlas('credits2/people/emil');
		e1000.animation.addByPrefix('idle', 'emil_neutral', 24, true);
		e1000.animation.addByPrefix('select', 'emil_selected', 24, true);
		e1000.animation.play('idle');
		e1000.scrollFactor.set(0, 1);
		e1000.antialiasing = ClientPrefs.data.antialiasing;
		add(e1000);

		e1000.alpha = 0;
		FlxTween.tween(e1000, {alpha: 1}, tweenDuration, {startDelay: 0.5});

		tapi = new FlxSprite(e1000.x + 250, 620);
		tapi.frames = Paths.getSparrowAtlas('credits2/people/tapi');
		tapi.animation.addByPrefix('idle', 'tapi_neutral', 24, true);
		tapi.animation.addByPrefix('select', 'tapi_selected', 24, true);
		tapi.animation.play('idle');
		tapi.scrollFactor.set(0, 1);
		tapi.antialiasing = ClientPrefs.data.antialiasing;
		add(tapi);

		tapi.alpha = 0;
		FlxTween.tween(tapi, {alpha: 1}, tweenDuration, {startDelay: 0.55});

		psych = new FlxSprite(500, 1010);
		psych.loadGraphic(Paths.image('credits2/psychTeam'));
		psych.screenCenter(X);
		psych.updateHitbox();
		psych.scrollFactor.set(0, 1);
		psych.antialiasing = ClientPrefs.data.antialiasing;
		add(psych);

		psych.alpha = 0;
		FlxTween.tween(psych, {alpha: 1}, tweenDuration, {startDelay: 0.6});
	}

	var psychScale:Float = 1;
	override function update(elapsed:Float) {
		if (controls.BACK && !watchingCredits) {
			wentBack = true;
			
			FlxTween.tween(owner, {alpha: 0}, tweenDuration);
			FlxTween.tween(coOwner, {alpha: 0}, tweenDuration, {startDelay: 0.025});
			FlxTween.tween(gbv, {alpha: 0}, tweenDuration, {startDelay: 0.05});
			FlxTween.tween(madera, {alpha: 0}, tweenDuration, {startDelay: 0.075});
			FlxTween.tween(foxy, {alpha: 0}, tweenDuration, {startDelay: 0.1});
			FlxTween.tween(hero, {alpha: 0}, tweenDuration, {startDelay: 0.125});
			FlxTween.tween(devs, {alpha: 0}, tweenDuration, {startDelay: 0.15});
			FlxTween.tween(bunny, {alpha: 0}, tweenDuration, {startDelay: 0.175});
			FlxTween.tween(ema, {alpha: 0}, tweenDuration, {startDelay: 0.2});
			FlxTween.tween(flash, {alpha: 0}, tweenDuration, {startDelay: 0.225});
			FlxTween.tween(e1000, {alpha: 0}, tweenDuration, {startDelay: 0.25});
			FlxTween.tween(tapi, {alpha: 0}, tweenDuration, {startDelay: 0.275});
			FlxTween.tween(psych, {alpha: 0}, tweenDuration, {startDelay: 0.3});

			new FlxTimer().start(0.45, function(tmr:FlxTimer)
			{
				backFromCredits = true;
				watchingCredits = false;

				MainMenuState.iconsPos.insert(0, icons.x);
				MainMenuState.iconsPos.insert(1, icons.y);
	
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new MainMenuState());
			});
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if(FlxG.mouse.wheel != 0 && !watchingCredits) {
			if(FlxG.mouse.wheel > 0) {
				camPos.y -= 100;
				if(camPos.y < topY) 
				{
					camPos.y = topY;
				}
			}

			if(FlxG.mouse.wheel < 0) {
				camPos.y += 100;
				if(camPos.y > bottomY)
				{
					camPos.y = bottomY;
				} 
			}
		}

		camPosLerp.y = FlxMath.lerp(camPosLerp.y, camPos.y, elapsed * 8);

		/*
		automateSprites(gbv, new InfoAboutPerson('gBv2209', 		['Artist', 'Composer'], 		['yt']));
		automateSprites(madera, new InfoAboutPerson('Mr. Madera', 	['Coder'], 						['yt']));
		automateSprites(foxy, new InfoAboutPerson('SFoxyDAC', 		['Animator'], 					['yt']));
		automateSprites(eli, new InfoAboutPerson('EliAnima', 		['Musician'], 					['yt']));
		automateSprites(bunny, new InfoAboutPerson('Bunny', 		['Charter'], 					['yt']));
		automateSprites(ema, new InfoAboutPerson('Zhadnii', 		['Musician'], 					['yt']));
		automateSprites(flash, new InfoAboutPerson('FlashDriveVGM', ['Musician', 'Concept Artist'], ['yt']));
		automateSprites(hero, new InfoAboutPerson('Heromax', 		['Artist'], 					['yt']));
		automateSprites(tapi, new InfoAboutPerson('Tapii', 			['Musician'], 					['yt']));
		*/

		//automateSprites(psych, new CreditsState());

		automateSprites(gbv, 		['gbv2209', 		['Concept Artist', 'Artist', 'Animator', 'Musician', 'Charter', 'Coder'], 		[['yt', 'https://www.youtube.com/@gBv2209'], ['x', 'https://x.com/gbv2209']]]);
		automateSprites(madera, 	['Mr. Madera', 		['Main Coder', 'Charter'], 						[['yt', 'https://www.youtube.com/@mrmadera1235'], ['x', 'https://x.com/MrMadera625']]]);
		automateSprites(foxy, 		['SFoxyDAC', 		['Artist', 'Animator'], 					[['yt', 'https://www.youtube.com/@SFoxyDAC'], ['x', 'https://x.com/SFoxyDAC']]]);
		automateSprites(bunny, 		['b.unnyb', 		['Charter'], 					[['x', ['https://x.com/ArchDolphin_']]]]);
		automateSprites(ema, 		['Zhadnii', 		['Musician'], 					[['yt', 'https://youtube.com/@zhadnii_']]]);
		automateSprites(flash, 		['FlashDriveVGM', 	['Musician', 'Concept Artist', 'Artist'], [['yt', 'https://www.youtube.com/@FlashMan07']]]);
		automateSprites(hero, 		['Heromax', 		['Concept Artist', 'Artist', 'Charter'], 			[['x', 'https://x.com/heromax_2498']]]);
		automateSprites(tapi, 		['Tapii', 			['Musician'], 					[['yt', 'https://www.youtube.com/@ItsTapiiii']]]);
		automateSprites(e1000, 		['e1000', 			['Artist', 'Charter'], 					[['yt', 'https://www.youtube.com/@E1000YT/videos'], ['x', 'https://x.com/E1000TWOF ']]]);

		var mult = FlxMath.lerp(psych.scale.x, psychScale, elapsed * 7);
		psych.scale.set(mult, mult);

		if(FlxG.mouse.overlaps(psych) && !watchingCredits)
		{
			psychScale = 1.1;
			if(FlxG.mouse.justPressed)
			{
				watchingCredits = false;
				MusicBeatState.switchState(new CreditsState());	
			}
		}
		else psychScale = 1;

		super.update(elapsed);

		FlxG.mouse.visible = true;
	}

	function automateSprites(spr:FlxSprite, info:Dynamic) {
		if(FlxG.mouse.overlaps(spr) && !watchingCredits && !wentBack) {
			spr.animation.play('select');
			if(FlxG.mouse.justPressed) {
				var xd = new InfoAboutPerson(info[0], info[1], info[2]);
				watchingCredits = true;
				persistentUpdate = true;
				openSubState(xd);
			}
		}
		else spr.animation.play('idle');
	}
}

class InfoAboutPerson extends MusicBeatSubstate
{
	var squareBg:FlxSprite;
	var personName:Alphabet;
	var rolsGrp:FlxTypedGroup<Alphabet>;
	var socialMediasGrp:FlxTypedGroup<FlxSprite>;
	var socialMedias:Array<Dynamic> = [];

	public function new(name:String, rols:Array<String>, avaibleSocialMedias:Array<Dynamic>)
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
		add(personName);

		rolsGrp = new FlxTypedGroup<Alphabet>();
		add(rolsGrp);

		socialMediasGrp = new FlxTypedGroup<FlxSprite>();
		add(socialMediasGrp);

		for(i in 0...rols.length)
		{
			var rolTxt = new Alphabet(0, 0, rols[i], true);
			rolTxt.setScale(0.7);
			rolTxt.y = personName.y + personName.height + 30 + ((rolTxt.height + 10) * i);
			rolTxt.scrollFactor.set();
			rolTxt.screenCenter(X);
			rolsGrp.add(rolTxt);
		}

		for(i in 0...avaibleSocialMedias.length)
		{
			if(socialMediasGrp.members[i-1] != null) socialMediasGrp.members[i-1].x -= socialMediasGrp.members[i-1].width;

			var socialMediaIcon = new FlxSprite();
			trace('Loading the following social media: ${avaibleSocialMedias[i][0]}');
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

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(controls.BACK)
		{
			CreditsState2.watchingCredits = false;
			close();
		}

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
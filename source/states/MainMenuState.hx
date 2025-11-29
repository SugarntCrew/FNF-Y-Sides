package states;

import flixel.addons.display.FlxBackdrop;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import openfl.geom.ColorTransform;

enum MainMenuColumn {
	LEFT;
	RIGHT;
}

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var curColumn:MainMenuColumn = LEFT;
	var allowMouse:Bool = true; //Turn this off to block mouse movement in menus

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuItems2:FlxTypedGroup<FlxSprite>;
	var leftItem:FlxSprite;
	var rightItem:FlxSprite;

	public static var iconsPos:Array<Float> = [0, 0];

	//Centered/Text options
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits'
	];

	var optionShit2:Array<String> = [
		'options',
		'awards',
		'gallery'
	];

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var icons:FlxBackdrop;
	var characters:FlxSprite;
	var charactersWhite:FlxSprite;
	var camFollow:FlxObject;
	var transition:FlxSprite;
	var backgroundGradientBottom:FlxSprite;

	static var showOutdatedWarning:Bool = true;
	override function create()
	{
		super.create();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80).makeGraphic(1280, 720, 0xFFBFB4F1);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).makeGraphic(1280, 720, 0xFFBFB4F1);
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		add(magenta);

		backgroundGradientBottom = new FlxSprite();
		backgroundGradientBottom.loadGraphic(Paths.image('titleState/gradientBottom'));
		backgroundGradientBottom.antialiasing = ClientPrefs.data.antialiasing;
		backgroundGradientBottom.scale.set(1, 1.3);
		backgroundGradientBottom.blend = ADD;
		backgroundGradientBottom.alpha = 0.38;
		backgroundGradientBottom.y = FlxG.height - backgroundGradientBottom.height;
		add(backgroundGradientBottom);
		
		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.velocity.set(10, 10);
		icons.alpha = 0.45;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		add(icons);
		
		icons.setPosition(MainMenuState.iconsPos[0], MainMenuState.iconsPos[1]);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		menuItems2 = new FlxTypedGroup<FlxSprite>();
		add(menuItems2);

		var scale:Float = 0.9;
		for (num => option in optionShit)
		{
			var item:FlxSprite = createMenuItem(option, -350, (num * 205) + 10);
			item.scale.set(scale, scale);
			item.updateHitbox();
			if(num == 1) item.y += 30;
			if(num == 0 || num == 2) item.x += 30;
			//item.y += (4 - optionShit.length) * 70; // Offsets for when you have anything other than 4 items
			//item.screenCenter(X);

			switch(num)
			{
				case 0 | 2:
					FlxTween.tween(item, {x: 85}, 1.25, {ease: FlxEase.quartOut, startDelay: 0.1 * num});
				case 1:
					FlxTween.tween(item, {x: 55}, 1.25, {ease: FlxEase.quartOut, startDelay: 0.1 * num});
				default:
					FlxTween.tween(item, {x: 55}, 1.25, {ease: FlxEase.quartOut, startDelay: 0.1 * num});
			}
		}

		characters = new FlxSprite(500, 0);
		characters.frames = Paths.getSparrowAtlas('mainmenu/menu_characters');
		characters.animation.addByPrefix('idle', 'characters', 24, true);
		characters.animation.play('idle');
		characters.antialiasing = ClientPrefs.data.antialiasing;
		characters.screenCenter(Y);
		add(characters);

		charactersWhite = new FlxSprite(500, 0);
		charactersWhite.frames = Paths.getSparrowAtlas('mainmenu/menu_characters_white');
		charactersWhite.animation.addByPrefix('idle', 'characters', 24, true);
		charactersWhite.animation.play('idle');
		charactersWhite.antialiasing = ClientPrefs.data.antialiasing;
		charactersWhite.screenCenter(Y);
		charactersWhite.alpha = 0;
		add(charactersWhite);

		if(StoryMenuState.backFromStoryMode) {
			StoryMenuState.backFromStoryMode = false;
			
			icons.alpha = 0;
			FlxTween.tween(icons, {alpha: 0.45}, 0.7, {ease: FlxEase.quartOut});

			characters.alpha = 0;
			FlxTween.cancelTweensOf(characters);
			FlxTween.tween(characters, {alpha: 1}, 0.7, {ease: FlxEase.quartOut});
		}
		else if(CreditsStateYSides.backFromCredits) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.sound.music.fadeIn(1);
			CreditsStateYSides.backFromCredits = false;

			characters.alpha = 0;
			FlxTween.cancelTweensOf(characters);
			FlxTween.tween(characters, {alpha: 1}, 0.7, {ease: FlxEase.quartOut});
		}

		for(num => option in optionShit2)
		{
			var item:FlxSprite = createMenuItem(option, FlxG.width + 10, (num * 155) + 170, true);
			item.scale.set(scale, scale);
			item.updateHitbox();

			FlxTween.tween(item, {x: FlxG.width - 190}, 1.25, {ease: FlxEase.quartOut, startDelay: 0.1 * num});
		}
		
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
			#if MODS_ALLOWED
				Achievements.reloadList();
			#end
		#end

		#if CHECK_FOR_UPDATES
		if (showOutdatedWarning && ClientPrefs.data.checkForUpdates && substates.OutdatedSubState.updateVersion != psychEngineVersion) {
			persistentUpdate = false;
			showOutdatedWarning = false;
			openSubState(new substates.OutdatedSubState());
		}
		#end

		if(AchievementsMenuState.comingFromAchievements) {
			AchievementsMenuState.comingFromAchievements = false;
			actualRightColumn = true;
		}

		if(OptionsState.comingFromOptions) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.sound.music.fadeIn(1);
			OptionsState.comingFromOptions = false;
			actualRightColumn = true;
		}

		transition = new FlxSprite(FlxG.width, 0);
		transition.antialiasing = ClientPrefs.data.antialiasing;
		transition.loadGraphic(Paths.image('transition'));
		transition.scale.set(1, 1.2);
		add(transition);

		if(CreditsStateYSides.creditsTransition)
		{
			CreditsStateYSides.creditsTransition = false;
			transition.x = -650;
			selectedSomethin = true;
			FlxTween.tween(transition, {x: -2100}, 0.5, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
			{
				selectedSomethin = false;
				transition.x = FlxG.width;
			}});
		}

		//FlxG.camera.follow(camFollow, null, 0.15);
	}

	function createMenuItem(name:String, x:Float, y:Float, rightColumn:Bool = false):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite(x, y);
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_$name');
		menuItem.animation.addByPrefix('idle', '$name basic', 24, true);
		menuItem.animation.addByPrefix('selected', '$name white', 24, true);
		menuItem.animation.play('idle');
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.data.antialiasing;
		rightColumn ? menuItems2.add(menuItem) : menuItems.add(menuItem);
		return menuItem;
	}

	var actualRightColumn:Bool = false;
	var timeNotMoving:Float = 0;
	var selectedSomethin:Bool = false;
	var scrollMultiplier:Float = 3;

	override function update(elapsed:Float)
	{
		final hudMousePos = FlxG.mouse.getScreenPosition(FlxG.cameras.list[FlxG.cameras.list.length - 1]);

		var multX = (hudMousePos.x - (FlxG.width / 2)) / (FlxG.width / 2);
		var multY = (hudMousePos.y - (FlxG.height / 2)) / (FlxG.height / 2);

		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (multX * scrollMultiplier), elapsed * 10);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (multY * scrollMultiplier), elapsed * 10);

		if (!selectedSomethin)
		{
			if (FlxG.sound.music.volume < 0.8)
				FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

			var allowMouse:Bool = allowMouse;
			if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
			{
				allowMouse = false;
				FlxG.mouse.visible = true;
				timeNotMoving = 0;

				var selectedItem:FlxSprite;
				switch(curColumn)
				{
					case LEFT:
						selectedItem = menuItems.members[curSelected];
					case RIGHT:
						selectedItem = menuItems2.members[curSelected];
				}

				var dist2:Float = -1;
				var distItem2:Int = -1;
				for (i in 0...optionShit2.length)
				{
					var memb2:FlxSprite = menuItems2.members[i];
					if(FlxG.mouse.overlaps(memb2))
					{
						var distance:Float = Math.sqrt(Math.pow(memb2.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb2.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
						if (dist2 < 0 || distance < dist2)
						{
							dist2 = distance;
							distItem2 = i;
							allowMouse = true;
						}
					}
				}

				if(distItem2 != -1 && selectedItem != menuItems2.members[distItem2])
				{
					actualRightColumn = true;
					curColumn = RIGHT;
					curSelected = distItem2;
					changeItem();
				}
				
				var dist:Float = -1;
				var distItem:Int = -1;
				for (i in 0...optionShit.length)
				{
					var memb:FlxSprite = menuItems.members[i];
					if(FlxG.mouse.overlaps(memb))
					{
						var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
						if (dist < 0 || distance < dist)
						{
							dist = distance;
							distItem = i;
							allowMouse = true;
						}
					}
				}

				if(distItem != -1 && selectedItem != menuItems.members[distItem])
				{
					actualRightColumn = false;
					curColumn = LEFT;
					curSelected = distItem;
					changeItem();
				}
			}
			else
			{
				timeNotMoving += elapsed;
				if(timeNotMoving > 2) FlxG.mouse.visible = false;
			}

			if(controls.UI_LEFT_P)
			{
				curColumn = LEFT;
				actualRightColumn = false;
				changeItem(0, actualRightColumn);
			}
	
			if(controls.UI_RIGHT_P)
			{
				curColumn = RIGHT;
				actualRightColumn = true;
				changeItem(0, actualRightColumn);
			}
	
			if(controls.UI_DOWN_P)
			{
				changeItem(1, actualRightColumn);
			}
	
			if(controls.UI_UP_P)
			{
				changeItem(-1, actualRightColumn);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				transitionBack();
			}

			if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse))
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				selectedSomethin = true;
				FlxG.mouse.visible = false;

				if (ClientPrefs.data.flashing)
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				var item:FlxSprite;
				var option:String;
				switch(curColumn)
				{
					case LEFT:
						option = optionShit[curSelected];
						item = menuItems.members[curSelected];

					case RIGHT:
						option = optionShit2[curSelected];
						item = menuItems2.members[curSelected];
				}

				switch (option)
				{
					case 'story_mode':
						transitionToStoryMenu();
					case 'freeplay':
						transitionToFreeplay();
					case 'awards':
						transitionToAwards();
					case 'credits':
						transitionToCredits();
					case 'options':
						transitionToOptions();
					case 'gallery':
						transitionToGallery();
					default:
						trace('Menu Item ${option} doesn\'t do anything');
						selectedSomethin = false;
						item.visible = true;
				}

				FlxFlicker.flicker(item, 1, 0.06, false, false, null);
				
				for (memb in menuItems)
				{
					if(memb == item)
						continue;

					FlxTween.tween(memb, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				}

				for (memb in menuItems2)
				{
					if(memb == item)
						continue;

					FlxTween.tween(memb, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				}
			}
			#if (desktop && debug)
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function transitionBack()
	{
		for (memb in menuItems)
		{
			FlxTween.tween(memb, {x: -350}, 0.5, {ease: FlxEase.quadOut});
		}

		for (memb in menuItems2)
		{
			FlxTween.tween(memb, {x: FlxG.width + 10}, 0.5, {ease: FlxEase.quadOut});
		}

		FlxTween.tween(FlxG.camera, {zoom: 1.05}, 0.3, {ease: FlxEase.quadOut});
		FlxG.camera.fade(0xFF000000, 0.4, false, null, true);

		new FlxTimer().start(1, function(t:FlxTimer) 
		{
			MusicBeatState.switchState(new TitleState());
		});
	}

	function transitionToStoryMenu()
	{
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			//FlxTween.tween(icons, {alpha: 0}, 0.15);
			FlxTween.tween(charactersWhite, {alpha: 1}, 0.25, {onComplete: function(twn:FlxTween)
			{
				new FlxTimer().start(0.35, function(tmr:FlxTimer)
				{
					FlxTween.tween(icons, {alpha: 0}, 0.3, {ease: FlxEase.quartIn});
					FlxTween.tween(charactersWhite, {"scale.x": 15, "scale.y": 15}, 0.3, {ease: FlxEase.quartIn,onComplete: function(twn2:FlxTween) {
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						MusicBeatState.switchState(new StoryMenuState());
					}});
				});
			}});

			FlxTween.cancelTweensOf(characters);
			FlxTween.tween(characters, {alpha: 0}, 0.25);
		});
	}

	function transitionToFreeplay()
	{
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			FlxTween.tween(icons, {alpha: 0}, 0.35);

			FlxTween.tween(menuItems.members[curSelected], {y: 500, alpha: 0, angle: -15}, 0.75, {ease: FlxEase.quartIn});

			FlxTween.cancelTweensOf(characters);
			FlxTween.tween(characters, {y: 500, alpha: 0, angle: 15}, 0.75, {ease: FlxEase.quartIn, onComplete: function(twn:FlxTween)
			{
				new FlxTimer().start(0.15, function(tmr:FlxTimer)
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					MusicBeatState.switchState(new FreeplayState());
				});
			}});

			FlxTween.tween(characters, {alpha: 0}, 0.25);
		});
	}

	function transitionToAwards()
	{
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			FlxTween.cancelTweensOf(characters);
			FlxTween.tween(characters, {alpha: 0}, 0.35, {ease: FlxEase.quartIn, onComplete: function(twn:FlxTween)
			{
				new FlxTimer().start(0.15, function(tmr:FlxTimer)
				{
					#if ACHIEVEMENTS_ALLOWED
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						MusicBeatState.switchState(new AchievementsMenuState());

						iconsPos.insert(0, icons.x);
						iconsPos.insert(1, icons.y);
					#end
				});
			}});
		});
	}

	function transitionToCredits()
	{
		FlxG.sound.music.fadeOut(0.65);
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			FlxTween.tween(transition, {x: -650}, 1, {ease: FlxEase.quartOut});
			FlxTween.cancelTweensOf(characters);
			FlxTween.tween(characters, {alpha: 0, y: characters.y + 10}, 0.35, {ease: FlxEase.quartIn, onComplete: function(twn:FlxTween)
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					#if ACHIEVEMENTS_ALLOWED
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						MusicBeatState.switchState(new CreditsStateYSides());

						iconsPos.insert(0, icons.x);
						iconsPos.insert(1, icons.y);
					#end
				});
			}});
		});
	}

	function transitionToOptions()
	{
		FlxG.sound.music.fadeOut(0.65);
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			FlxTween.cancelTweensOf(characters);
			FlxTween.tween(characters, {alpha: 0, y: characters.y + 10}, 0.35, {ease: FlxEase.quartIn, onComplete: function(twn:FlxTween)
			{
				new FlxTimer().start(0.15, function(tmr:FlxTimer)
				{
					#if ACHIEVEMENTS_ALLOWED
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;

						OptionsState.iconsPos.insert(0, icons.x);
						OptionsState.iconsPos.insert(1, icons.y);
						
						MusicBeatState.switchState(new OptionsState());
						OptionsState.onPlayState = false;
						if (PlayState.SONG != null)
						{
							PlayState.SONG.arrowSkin = null;
							PlayState.SONG.splashSkin = null;
							PlayState.stageUI = 'normal';
						}

						iconsPos.insert(0, icons.x);
						iconsPos.insert(1, icons.y);
					#end
				});
			}});
		});
	}

	function transitionToGallery()
	{
		new FlxTimer().start(0.4, function(tmr:FlxTimer)
		{
			FlxTween.cancelTweensOf(icons);
			FlxTween.tween(icons, {alpha: 0}, 0.35);

			FlxTween.cancelTweensOf(characters);
			FlxTween.tween(characters, {alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, 0.35, {ease: FlxEase.quartIn, onComplete: function(twn:FlxTween)
			{
				new FlxTimer().start(0.15, function(tmr:FlxTimer)
				{
					#if ACHIEVEMENTS_ALLOWED
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						
						MusicBeatState.switchState(new states.gallery.GalleryState());
					#end
				});
			}});
		});
	}

	function changeItem(change:Int = 0, ?rightColumn:Bool)
	{
		if(rightColumn) curSelected = FlxMath.wrap(curSelected + change, 0, optionShit2.length - 1);
		else curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'));

		for (item in menuItems)
		{
			item.animation.play('idle');
			item.centerOffsets();
		}

		for (item in menuItems2)
		{
			item.animation.play('idle');
			item.centerOffsets();
		}

		var selectedItem:FlxSprite;
		switch(curColumn)
		{
			case LEFT:
				selectedItem = menuItems.members[curSelected];
			case RIGHT:
				selectedItem = menuItems2.members[curSelected];
		}
		if(selectedItem != null) {
			selectedItem.animation.play('selected');
			selectedItem.centerOffsets();
			camFollow.y = selectedItem.getGraphicMidpoint().y;
		}
	}
}
package states;

import openfl.filters.ShaderFilter;
import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;

import objects.MenuItem;
import objects.MenuCharacter;

import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import backend.StageData;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var bg:FlxSprite;
	var icons:FlxBackdrop;
	var tv:FlxSprite;
	var escapeButton:FlxSprite;
	var tracksSpriteBack:FlxSprite;
	var songSpriteBack:FlxSprite;

	var weekArrowUp:FlxSprite;
	var weekArrowDown:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	var weekBackground:FlxSprite;
	var weekCharacter:FlxSprite;
	//var shaderFilter:ShaderFilter;

	public static var backFromStoryMode:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR STORY MODE\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		if(curWeek >= WeekData.weeksList.length) curWeek = 0;

		bg = new FlxSprite();
		bg.makeGraphic(1280, 720, 0xFFBFB4F1);
		add(bg);

		weekBackground = new FlxSprite();
		weekBackground.alpha = 0;
		//weekBackground.loadGraphic(Paths.image('storymenu/bgs/week1'));
		add(weekBackground);

		FlxTween.tween(weekBackground, {alpha: 1}, 1, {ease: FlxEase.quartOut});

		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.velocity.set(-25, 0);
		icons.alpha = 0.3;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		//add(icons);

		weekCharacter = new FlxSprite();
		weekCharacter.alpha = 0;
		weekCharacter.antialiasing = ClientPrefs.data.antialiasing;
		add(weekCharacter);

		FlxTween.tween(weekCharacter, {alpha: 1}, 1, {ease: FlxEase.quartOut});

		tv = new FlxSprite();
		tv.loadGraphic(Paths.image('storymenu/TV'));
		tv.y = FlxG.height;
		tv.antialiasing = ClientPrefs.data.antialiasing;
		add(tv);

		FlxTween.tween(tv, {y: FlxG.height - tv.height}, 1, {ease: FlxEase.quartOut});

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(40, tv.y + 310, WeekData.weeksList[i]);
				//weekThing.y += ((weekThing.height + 20) * num);
				weekThing.ID = num;
				grpWeekText.add(weekThing);
				ogY = weekThing.y;
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.antialiasing = ClientPrefs.data.antialiasing;
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		weekArrowUp = new FlxSprite(0, 0);
		//weekArrowUp.loadGraphic(Paths.image('storymenu/weekArrows_up'));
		weekArrowUp.frames = Paths.getSparrowAtlas('storymenu/weekArrows_up');
		weekArrowUp.animation.addByPrefix('idle', 'arrow_static');
		weekArrowUp.animation.addByPrefix('press', 'arrow_UP', 24, false);
		weekArrowUp.animation.play('idle');
		weekArrowUp.x = tv.x + tv.width/2 - weekArrowUp.width/2;
		weekArrowUp.y = 1000;
		weekArrowUp.antialiasing = ClientPrefs.data.antialiasing;
		add(weekArrowUp);

		FlxTween.tween(weekArrowUp, {y: 510}, 1, {ease: FlxEase.quartOut});

		weekArrowDown = new FlxSprite(40, 0);
		//weekArrowDown.loadGraphic(Paths.image('storymenu/weekArrows_down'));
		weekArrowDown.frames = Paths.getSparrowAtlas('storymenu/weekArrows_down');
		weekArrowDown.animation.addByPrefix('idle', 'arrow_static');
		weekArrowDown.animation.addByPrefix('press', 'arrow_DOWN', 24, false);
		weekArrowDown.animation.play('idle');
		weekArrowDown.x = tv.x + tv.width/2 - weekArrowDown.width/2;
		weekArrowDown.y = 1000;
		weekArrowDown.antialiasing = ClientPrefs.data.antialiasing;
		add(weekArrowDown);

		FlxTween.tween(weekArrowDown, {y: 510}, 1, {ease: FlxEase.quartOut});

		escapeButton = new FlxSprite(10, 10);
		//escapeButton.loadGraphic(Paths.image('storymenu/escape'));
		escapeButton.frames = Paths.getSparrowAtlas('storymenu/escape');
		escapeButton.animation.addByPrefix('idle', 'esc_normal');
		escapeButton.animation.addByPrefix('select', 'esc_selected');
		escapeButton.animation.addByPrefix('selectAnim', 'esc_selectedAnim');
		escapeButton.animation.play('idle');
		escapeButton.y = 0 - escapeButton.height;
		escapeButton.antialiasing = ClientPrefs.data.antialiasing;
		add(escapeButton);

		FlxTween.tween(escapeButton, {y: 10}, 1, {ease: FlxEase.quartOut});

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(850, 450);
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		leftArrow.frames = Paths.getSparrowAtlas('storymenu/arrow_left');
		leftArrow.animation.addByPrefix('idle', "arrow_left_static");
		leftArrow.animation.addByPrefix('press', "arrow_left_press");
		leftArrow.animation.play('idle');
		leftArrow.alpha = 0;
		difficultySelectors.add(leftArrow);

		FlxTween.tween(leftArrow, {y: leftArrow.y - 10, alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.1});

		Difficulty.resetList();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefault();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		sprDifficulty.alpha = 0;
		difficultySelectors.add(sprDifficulty);

		FlxTween.tween(sprDifficulty, {y: sprDifficulty.y - 10, alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.2});

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		rightArrow.frames = Paths.getSparrowAtlas('storymenu/arrow_right');
		rightArrow.animation.addByPrefix('idle', 'arrow_right_static');
		rightArrow.animation.addByPrefix('press', "arrow_right_press");
		rightArrow.animation.play('idle');
		rightArrow.alpha = 0;
		difficultySelectors.add(rightArrow);

		FlxTween.tween(rightArrow, {y: rightArrow.y - 10, alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.3});

		tracksSpriteBack = new FlxSprite(0, 0).loadGraphic(Paths.image('storymenu/songThing'));
		tracksSpriteBack.antialiasing = ClientPrefs.data.antialiasing;
		tracksSpriteBack.x = FlxG.width - tracksSpriteBack.width - 10;
		tracksSpriteBack.y = 0 - tracksSpriteBack.height;
		add(tracksSpriteBack);

		FlxTween.tween(tracksSpriteBack, {y: 0}, 1, {ease: FlxEase.quartOut});

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSpriteBack.y + 120, tracksSpriteBack.width - 30, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = Paths.font("FredokaOne-Regular.ttf");
		txtTracklist.color = 0xFFB996D4;
		txtTracklist.antialiasing = ClientPrefs.data.antialiasing;
		add(txtTracklist);

		songSpriteBack = new FlxSprite();
		songSpriteBack.loadGraphic(Paths.image('storymenu/scoreThing'));
		songSpriteBack.x = FlxG.width - songSpriteBack.width;
		songSpriteBack.y = FlxG.height;
		songSpriteBack.antialiasing = ClientPrefs.data.antialiasing;
		add(songSpriteBack);

		FlxTween.tween(songSpriteBack, {y: FlxG.height - songSpriteBack.height}, 1, {ease: FlxEase.quartOut});

		scoreText = new FlxText(songSpriteBack.x + 25, 0, 0, Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]), 36);
		scoreText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 32);
		scoreText.y = songSpriteBack.y + songSpriteBack.height/2 - scoreText.height/2 + 25;
		scoreText.antialiasing = ClientPrefs.data.antialiasing;
		add(scoreText);

		changeWeek();
		changeDifficulty();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
		{
			if (controls.BACK && !movedBack && !selectedWeek)
			{
				FlxTween.cancelTweensOf(weekBackground);
				FlxTween.cancelTweensOf(weekCharacter);
				FlxTween.cancelTweensOf(tv);
				FlxTween.cancelTweensOf(escapeButton);
				FlxTween.cancelTweensOf(leftArrow);
				FlxTween.cancelTweensOf(sprDifficulty);
				FlxTween.cancelTweensOf(rightArrow);
				FlxTween.cancelTweensOf(tracksSpriteBack);
				FlxTween.cancelTweensOf(songSpriteBack);

				FlxTween.tween(weekBackground, {alpha: 0}, 1, {ease: FlxEase.quartOut});
				FlxTween.tween(weekCharacter, {alpha: 0}, 1, {ease: FlxEase.quartOut});
				FlxTween.tween(tv, {y: FlxG.height}, 1, {ease: FlxEase.quartOut});
				FlxTween.tween(escapeButton, {y: -escapeButton.height}, 1, {ease: FlxEase.quartOut});
				FlxTween.tween(leftArrow, {y: leftArrow.y + 10, alpha: 0}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.1});
				FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 10, alpha: 0}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.2});
				FlxTween.tween(rightArrow, {y: rightArrow.y + 10, alpha: 0}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.3});
				FlxTween.tween(tracksSpriteBack, {y: -tracksSpriteBack.height}, 1, {ease: FlxEase.quartOut});
				FlxTween.tween(songSpriteBack, {y: FlxG.height}, 1, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					MusicBeatState.switchState(new MainMenuState());
				}});

				FlxG.sound.play(Paths.sound('cancelMenu'));
				movedBack = true;
			}
			super.update(elapsed);
			return;
		}

		if(tv != null) grpWeekText.members[curWeek].y = tv.y + 310;
		if(tracksSpriteBack != null) txtTracklist.y = tracksSpriteBack.y + 120;
		if(songSpriteBack != null) scoreText.y = songSpriteBack.y + songSpriteBack.height/2 - scoreText.height/2;

		// scoreText.setFormat(Paths.font("vcr.ttf"), 32);
		if(intendedScore != lerpScore)
		{
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
			if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;
	
			scoreText.text = Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]);
		}

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var changeDiff = false;
			if (controls.UI_UP_P)
			{
				weekArrowUp.animation.play('press');
				weekArrowUp.animation.finishCallback = function(name:String)
				{
					if(name == 'press') weekArrowUp.animation.play('idle');
				}
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeDiff = true;
			}

			if (controls.UI_DOWN_P)
			{
				weekArrowDown.animation.play('press');
				weekArrowDown.animation.finishCallback = function(name:String)
				{
					if(name == 'press') weekArrowDown.animation.play('idle');
				}
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeDiff = true;
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press');
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);
			else if (changeDiff)
				changeDifficulty();

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
				selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;

			FlxTween.cancelTweensOf(weekBackground);
			FlxTween.cancelTweensOf(weekCharacter);
			FlxTween.cancelTweensOf(tv);
			FlxTween.cancelTweensOf(escapeButton);
			FlxTween.cancelTweensOf(leftArrow);
			FlxTween.cancelTweensOf(sprDifficulty);
			FlxTween.cancelTweensOf(rightArrow);
			FlxTween.cancelTweensOf(tracksSpriteBack);
			FlxTween.cancelTweensOf(weekArrowUp);
			FlxTween.cancelTweensOf(weekArrowDown);
			FlxTween.cancelTweensOf(songSpriteBack);

			FlxTween.tween(weekBackground, {alpha: 0}, 0.6, {ease: FlxEase.quartOut});
			FlxTween.tween(weekCharacter, {alpha: 0}, 0.6, {ease: FlxEase.quartOut});
			FlxTween.tween(tv, {y: FlxG.height}, 0.6, {ease: FlxEase.quartOut});
			FlxTween.tween(escapeButton, {y: -escapeButton.height}, 0.6, {ease: FlxEase.quartOut});
			FlxTween.tween(leftArrow, {y: leftArrow.y + 10, alpha: 0}, 0.3, {ease: FlxEase.quartOut, startDelay: 0.1});
			FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 10, alpha: 0}, 0.3, {ease: FlxEase.quartOut, startDelay: 0.2});
			FlxTween.tween(rightArrow, {y: rightArrow.y + 10, alpha: 0}, 0.3, {ease: FlxEase.quartOut, startDelay: 0.3});
			FlxTween.tween(tracksSpriteBack, {y: -tracksSpriteBack.height}, 0.6, {ease: FlxEase.quartOut});
			FlxTween.tween(weekArrowUp, {y: 1000}, 1, {ease: FlxEase.quartOut});
			FlxTween.tween(weekArrowDown, {y: 1000}, 1, {ease: FlxEase.quartOut});
			FlxTween.tween(songSpriteBack, {y: FlxG.height}, 0.6, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				backFromStoryMode = true;
				MusicBeatState.switchState(new MainMenuState());
			}});
		}

		super.update(elapsed);

		for (num => lock in grpLocks.members)
			lock.y = grpWeekText.members[lock.ID].y + grpWeekText.members[lock.ID].height/2 - lock.height/2;
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			try
			{
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
				selectedWeek = true;
	
				var diffic = Difficulty.getFilePath(curDifficulty);
				if(diffic == null) diffic = '';
	
				PlayState.storyDifficulty = curDifficulty;
	
				Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');
				return;
			}
			
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].isFlashing = true;
				stopspamming = true;
			}

			var directory = StageData.forceNextDirectory;
			LoadingState.loadNextDirectory();
			StageData.forceNextDirectory = directory;

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			LoadingState.prepareToSong();
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
			
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = Difficulty.getString(curDifficulty, false);
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Mods.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - leftArrow.height/2 - sprDifficulty.height/2;

			FlxTween.cancelTweensOf(sprDifficulty);
			FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 30, alpha: 1}, 0.07);
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 49324858;
	var intendedScore:Int = 0;
	var ogY:Float = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (num => item in grpWeekText.members)
		{
			item.alpha = 0;
			if (num - curWeek == 0 && unlocked) {
				item.alpha = 1;
			}
		}

		PlayState.storyWeek = curWeek;

		Difficulty.loadFromWeek();
		difficultySelectors.visible = unlocked;

		weekBackground.loadGraphic(Paths.image('storymenu/bgs/${leWeek.fileName}'));
		weekCharacter.loadGraphic(Paths.image('storymenu/characters/${leWeek.weekCharacters[0]}'));
		weekCharacter.screenCenter(XY);

		weekCharacter.y += 5;
		weekCharacter.alpha = 0;

		FlxTween.cancelTweensOf(weekCharacter);
		FlxTween.tween(weekCharacter, {alpha: 1, y: weekCharacter.y - 10}, 0.1, {ease: FlxEase.quartOut});

		if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x = tracksSpriteBack.x + 15;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}

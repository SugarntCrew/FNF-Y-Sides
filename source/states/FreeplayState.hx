package states;

import flixel.FlxObject;
import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;

import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;
import flixel.addons.display.FlxBackdrop;

import openfl.utils.Assets;

import haxe.Json;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<FlxSprite> = [];
	private var eachCenter:Array<Float> = [];

	var bg:FlxSprite;
	var intendedColor:Int;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var icons:FlxBackdrop;
	var bottomString:String;
	var bf:FlxSprite;
	var cloud:FlxSprite;
	var currentIcon:FlxSprite;
	var scoreThing:FlxSprite;
	var backgroundGradientBottom:FlxSprite;

	var player:MusicPlayer;

	var diffArrowUp:FlxSprite;
	var diffArrowDown:FlxSprite;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length)
		{
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		var colorBg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFFBFB4F1);
		add(colorBg);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFBFB4F1);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.alpha = 0;
		add(bg);
		bg.screenCenter();

		backgroundGradientBottom = new FlxSprite();
		backgroundGradientBottom.loadGraphic(Paths.image('titleState/gradientBottom'));
		backgroundGradientBottom.antialiasing = ClientPrefs.data.antialiasing;
		backgroundGradientBottom.scale.set(1, 1.3);
		backgroundGradientBottom.blend = ADD;
		backgroundGradientBottom.alpha = 0.38;
		backgroundGradientBottom.y = FlxG.height - backgroundGradientBottom.height;
		add(backgroundGradientBottom);

		FlxTween.tween(bg, {alpha: 1}, 0.6, {ease: FlxEase.quartOut});

		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.velocity.set(40, 0);
		icons.alpha = 0;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		add(icons);

		FlxTween.tween(icons, {alpha: 0.35}, 1);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, 220, songs[i].songName, true);
			songText.targetY = i;
			songText.screenCenter(X);
			eachCenter.push(songText.x);
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			if(songText.targetY == curSelected - 1) {
				songText.alpha = 0;
				FlxTween.tween(songText, {alpha: 1}, 0.2);
				trace('tween -1');
			}

			if(songText.targetY == curSelected) {
				songText.alpha = 0;
				FlxTween.tween(songText, {alpha: 1}, 0.2, {startDelay: 0.2});
				trace('tween 0');
			}

			if(songText.targetY == curSelected + 1) {
				songText.alpha = 0;
				FlxTween.tween(songText, {alpha: 1}, 0.2, {startDelay: 0.4});
				trace('tween 1');
			}

			Mods.currentModDirectory = songs[i].folder;
			var icon:FlxSprite = new FlxSprite();
			icon.loadGraphic(Paths.image('freePlay/icons/icon-${songs[i].songCharacter}'));
			//icon.sprTracker = songText;

			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}
		WeekData.setDirectoryFromWeek();

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		missingTextBG.antialiasing = ClientPrefs.data.antialiasing;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		missingText.antialiasing = ClientPrefs.data.antialiasing;
		add(missingText);

		scoreThing = new FlxSprite(75, 720);
		scoreThing.loadGraphic(Paths.image('freePlay/scoreThing'));
		scoreThing.antialiasing = ClientPrefs.data.antialiasing;
		add(scoreThing);

		scoreText = new FlxText(85, 360, scoreThing.width - 20, "", 32);
		scoreText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 32, FlxColor.WHITE, CENTER);
		scoreText.antialiasing = ClientPrefs.data.antialiasing;

		diffText = new FlxText(scoreText.x, scoreText.y + scoreText.height + 40, scoreThing.width - 20, "", 78);
		diffText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 70, FlxColor.WHITE, CENTER);
		diffText.antialiasing = ClientPrefs.data.antialiasing;
		add(diffText);

		add(scoreText);

		diffArrowUp = new FlxSprite();
		diffArrowUp.loadGraphic(Paths.image('freePlay/freeplay_diff_arrow'));
		diffArrowUp.setPosition(diffText.x + (diffText.width / 2) - (diffArrowUp.width / 2), scoreThing.y + 160);
		diffArrowUp.scale.set(0.9, 0.9);
		diffArrowUp.antialiasing = ClientPrefs.data.antialiasing;
		add(diffArrowUp);

		diffArrowDown = new FlxSprite();
		diffArrowDown.loadGraphic(Paths.image('freePlay/freeplay_diff_arrow'));
		diffArrowDown.setPosition(diffText.x + (diffText.width / 2) - (diffArrowDown.width / 2), diffArrowUp.y + 100);
		diffArrowDown.scale.set(0.9, 0.9);
		diffArrowDown.antialiasing = ClientPrefs.data.antialiasing;
		diffArrowDown.flipY = true;
		add(diffArrowDown);

		cloud = new FlxSprite(750, 720);
		cloud.loadGraphic(Paths.image('freePlay/cloud'));
		cloud.antialiasing = ClientPrefs.data.antialiasing;
		add(cloud);

		currentIcon = new FlxSprite(cloud.x, cloud.y);
		currentIcon.antialiasing = ClientPrefs.data.antialiasing;
		add(currentIcon);

		bf = new FlxSprite(0, 0);
		bf.frames = Paths.getSparrowAtlas('freePlay/bf');
		bf.animation.addByPrefix('idle', 'coso', 24, false);
		bf.animation.play('idle');
		bf.screenCenter(X);
		bf.antialiasing = ClientPrefs.data.antialiasing;
		bf.y = 720;
		add(bf);

		bopTweenAnim(scoreThing, 350, 0);
		bopTweenAnim(diffArrowUp, 350 + 100, 0);
		bopTweenAnim(diffArrowDown, 350 + 100 + 130, 0);
		bopTweenAnim(bf, 475, 0.3);
		bopTweenAnim(cloud, 300, 0.45);

		if(curSelected >= songs.length) curSelected = 0;
		//bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		var leText:String = Language.getPhrase("freeplay_tip", "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.");
		bottomString = leText;
		var size:Int = 16;
		
		player = new MusicPlayer(this);
		add(player);
		
		changeSelection(true, false);
		updateTexts();
		super.create();
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	var holdTime:Float = 0;

	var stopMusicPlay:Bool = false;
	var iconTimer:Float = 0;
	var iconAngleReverse:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		
		iconTimer += elapsed;
		if(iconTimer > 1) {
			iconTimer = 0;
			iconAngleReverse = !iconAngleReverse;
			currentIcon.angle = iconAngleReverse ? -5 : 5;
		}

		if(scoreThing != null && scoreText != null) scoreText.setPosition(scoreThing.x + 10, scoreThing.y + 20);
		if(scoreThing != null && scoreText != null && diffText != null) diffText.setPosition(scoreText.x, scoreText.y + scoreText.height + 40);

		if(currentIcon != null && cloud != null) {
			currentIcon.x = cloud.x + cloud.width/2 - currentIcon.width/2 + 70;
			currentIcon.y = cloud.y + cloud.height/2 - currentIcon.height/2;
		}

		if(WeekData.weeksList.length < 1)
			return;

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (!player.playingMusic)
		{
			scoreText.text = Language.getPhrase('personal_best', 'PERSONAL BEST: {1} ({2}%)', [lerpScore, ratingSplit.join('.')]);
			
			if(songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;	
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
				if (controls.UI_LEFT_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_LEFT ? -shiftMult : shiftMult));
				}

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				}
			}

			if (controls.UI_UP_P)
			{
				changeDiff(1);
				_updateSongLastDifficulty();
			}
			else if (controls.UI_DOWN_P)
			{
				changeDiff(-1);
				_updateSongLastDifficulty();
			}
		}

		if (controls.BACK)
		{
			if (player.playingMusic)
			{
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				instPlaying = -1;

				player.playingMusic = false;
				player.switchPlayMusic();

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			}
			else 
			{
				persistentUpdate = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				//MusicBeatState.switchState(new MainMenuState());

				for(item in grpSongs.members)
				{
					FlxTween.cancelTweensOf(item);
					FlxTween.tween(item, {alpha: 0}, 0.2, {onComplete: function(twn:FlxTween)
					{
						//item.kill();
					}});
				}

				FlxTween.cancelTweensOf(icons);
				FlxTween.cancelTweensOf(bg);
				FlxTween.cancelTweensOf(scoreThing);
				FlxTween.cancelTweensOf(diffArrowUp);
				FlxTween.cancelTweensOf(diffArrowDown);
				FlxTween.cancelTweensOf(bf);
				FlxTween.cancelTweensOf(cloud);
				FlxTween.cancelTweensOf(currentIcon);

				FlxTween.tween(icons, {alpha: 0}, 0.2);

				FlxTween.color(bg, 0.4, bg.color, 0xFFFFFFFF);

				bopTweenAnim(scoreThing, 820, 0);
				bopTweenAnim(diffArrowUp, 820, 0);
				bopTweenAnim(diffArrowDown, 820, 0);
				bopTweenAnim(bf, 820, 0);
				bopTweenAnim(cloud, 820, 0);

				FlxTween.tween(scoreThing, {alpha: 0}, 0.2);
				FlxTween.tween(diffArrowUp, {alpha: 0}, 0.2);
				FlxTween.tween(diffArrowDown, {alpha: 0}, 0.2);
				FlxTween.tween(bf, {alpha: 0}, 0.2);
				FlxTween.tween(cloud, {alpha: 0}, 0.2);
				FlxTween.tween(currentIcon, {alpha: 0}, 0.2);

				StoryMenuState.backFromStoryMode = true; //loool

				new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					MusicBeatState.switchState(new MainMenuState());
				});
			}
		}

		if(FlxG.keys.justPressed.CONTROL && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(FlxG.keys.justPressed.SPACE)
		{
			if(instPlaying != curSelected && !player.playingMusic)
			{
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
				{
					vocals = new FlxSound();
					try
					{
						var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
						if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
						
						if(loadedVocals != null && loadedVocals.length > 0)
						{
							vocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(vocals);
							vocals.persist = vocals.looped = true;
							vocals.volume = 0.8;
							vocals.play();
							vocals.pause();
						}
						else vocals = FlxDestroyUtil.destroy(vocals);
					}
					catch(e:Dynamic)
					{
						vocals = FlxDestroyUtil.destroy(vocals);
					}
					
					opponentVocals = new FlxSound();
					try
					{
						//trace('please work...');
						var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
						
						if(loadedVocals != null && loadedVocals.length > 0)
						{
							opponentVocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(opponentVocals);
							opponentVocals.persist = opponentVocals.looped = true;
							opponentVocals.volume = 0.8;
							opponentVocals.play();
							opponentVocals.pause();
							//trace('yaaay!!');
						}
						else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
					catch(e:Dynamic)
					{
						//trace('FUUUCK');
						opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
				}

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
				FlxG.sound.music.pause();
				instPlaying = curSelected;

				player.playingMusic = true;
				player.curTime = 0;
				player.switchPlayMusic();
				player.pauseOrResume(true);
			}
			else if (instPlaying == curSelected && player.playingMusic)
			{
				player.pauseOrResume(!player.playing);
			}
		}
		else if (controls.ACCEPT && !player.playingMusic)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

			try
			{
				Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			}
			catch(e:haxe.Exception)
			{
				trace('ERROR! ${e.message}');

				var errorStr:String = e.message;
				if(errorStr.contains('There is no TEXT asset with an ID of')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
				else errorStr += '\n\n' + e.stack;

				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			#if !debug LoadingState.prepareToSong(); #end
			LoadingState.loadAndSwitchState(new PlayState());
			#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
			stopMusicPlay = true;

			destroyFreeplayVocals();
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else if(controls.RESET && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateTexts(elapsed);
		super.update(elapsed);
	}
	
	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		catch (e:Dynamic) {}
		return null;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function changeDiff(change:Int = 0)
	{
		if (player.playingMusic)
			return;

		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		var displayDiff:String = Difficulty.getString(curDifficulty);
		diffText.text = displayDiff.toUpperCase();

		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true, updateAlpha:Bool = true)
	{
		if (player.playingMusic)
			return;

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);
		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 1, bg.color, intendedColor);
		}

		for (num => item in grpSongs.members)
		{
			var icon:FlxSprite = iconArray[num];

			if(updateAlpha) {
				item.alpha = 0.6;
				icon.alpha = 0.6;
			}
			if (item.targetY == curSelected)
			{
				var different:Bool = false;
				if(currentIcon.frames != icon.frames) {
					different = true;
					currentIcon.frames = icon.frames;
					currentIcon.animation = icon.animation;
					currentIcon.animation.play(icon.animation.name);
		
					currentIcon.x = cloud.x + cloud.width/2 - currentIcon.width/2 + 70;
					currentIcon.y = cloud.y + cloud.height/2 - currentIcon.height/2;
	
					currentIcon.y += 10;
				}

				if(updateAlpha) {
					item.alpha = 1;
					icon.alpha = 1;

					if(different) {
						currentIcon.alpha = 0;
						FlxTween.cancelTweensOf(currentIcon);
						FlxTween.tween(currentIcon, {y: currentIcon.y - 10, alpha: 1}, 0.2, {ease: FlxEase.quartOut});
					}
				}
			}
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !Difficulty.list.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	override function beatHit()
	{
		super.beatHit();

		bf.animation.play('idle');
	}

	inline private function _updateSongLastDifficulty()
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty, false);

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:Alphabet = grpSongs.members[i];
			item.visible = item.active = true;
			
			var xSpacing:Float = 16;
			item.x = (((item.targetY - lerpSelected) * item.distancePerItem.x) * xSpacing) + item.startPosition.x + eachCenter[item.targetY];

			var diff:Float = item.targetY - lerpSelected;
			var yOffset:Float = diff * 1.3 * item.distancePerItem.y;

			if(diff > 0) {
			    yOffset *= -1;
			}

			item.y = yOffset + item.startPosition.y;

			var icon:FlxSprite = iconArray[i];
			icon.visible = icon.active = true;
			_lastVisibles.push(i);
		}
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing && !stopMusicPlay)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}

	function bopTweenAnim(obj:FlxObject, y:Float, startDelay:Float = 0)
	{
		FlxTween.tween(obj, {y: y - 20}, 0.25, {ease: FlxEase.quartOut, startDelay: startDelay, onComplete: function(twn:FlxTween)
		{
			FlxTween.tween(obj, {y: y}, 0.1, {ease: FlxEase.quartIn});
		}});
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
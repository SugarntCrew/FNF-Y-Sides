package substates;

import backend.Highscore;
import backend.Song;
import backend.WeekData;
import flixel.addons.display.FlxBackdrop;

import flixel.util.FlxStringUtil;
import flixel.math.FlxMath;
import states.StoryMenuState;
import states.FreeplayState;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuItems:FlxTypedGroup<FlxSprite>;
	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 1; // Restart empieza seleccionado (centro)

	var pauseMusic:FlxSound;
	var bg:FlxSprite;
	var dots:FlxBackdrop;
	var barTop:FlxSprite;
	var thing:FlxSprite;
	var ogYThing:Float;
	var barBottom:FlxSprite;

	public static var songName:String = null;

	override function create()
	{
		// Música de pausa
		pauseMusic = new FlxSound();
		try {
			var pauseSong:String = getPauseSong();
			if (pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		} catch (e:Dynamic) {}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);

		// Fondo oscuro
		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0; // empieza invisible para el fade in
		bg.scrollFactor.set();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		dots = new FlxBackdrop(Paths.image('gallery/lines'), XY);
		dots.velocity.set(10, 10);
		dots.alpha = 0;
		dots.antialiasing = ClientPrefs.data.antialiasing;
		add(dots);

		FlxTween.tween(dots, {alpha: 0.25}, 0.5, {ease: FlxEase.linear});

		barTop = new FlxSprite();
        barTop.loadGraphic(Paths.image('pause/up'));
		barTop.y = -200;
        barTop.antialiasing = ClientPrefs.data.antialiasing;
        add(barTop);

		barBottom = new FlxSprite();
		barBottom.loadGraphic(Paths.image('pause/bottom'));
		barBottom.y = 200;
		barBottom.antialiasing = ClientPrefs.data.antialiasing;
		add(barBottom);

		// Info canción
		var levelInfo:FlxText = new FlxText(20, 120, 0, PlayState.SONG.song, 32);
		levelInfo.x = 50;
		//levelInfo.alpha = 0;
		levelInfo.setFormat(Paths.font("FredokaOne-Regular.ttf"), 32, FlxColor.WHITE);
		levelInfo.antialiasing = ClientPrefs.data.antialiasing;
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, levelInfo.y + levelInfo.height + 10, 0, Difficulty.getString().toUpperCase(), 28);
		levelDifficulty.x = 50;
		//levelDifficulty.alpha = 0;
		levelDifficulty.setFormat(Paths.font("FredokaOne-Regular.ttf"), 28, FlxColor.WHITE);
		levelDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, levelDifficulty.y + levelDifficulty.height + 10, 0, "Blueballed: " + PlayState.deathCounter, 28);
		blueballedTxt.x = 50;
		//blueballedTxt.alpha = 0;
		blueballedTxt.setFormat(Paths.font("FredokaOne-Regular.ttf"), 28, FlxColor.WHITE);
		blueballedTxt.antialiasing = ClientPrefs.data.antialiasing;
		add(blueballedTxt);

		// Grupo de sprites del menú
		grpMenuItems = new FlxTypedGroup<FlxSprite>();
		add(grpMenuItems);

		thing = new FlxSprite(0, 0);
		thing.frames = Paths.getSparrowAtlas('pause/pausesos');
		thing.animation.addByPrefix('exit', 'exit', 24, true);
		thing.animation.addByPrefix('resum', 'resum', 24, true);
		thing.animation.addByPrefix('restarr', 'restarr', 24, true);
		thing.animation.play('resum');
		thing.antialiasing = ClientPrefs.data.antialiasing;
		thing.screenCenter(X);
		add(thing);

		FlxTween.tween(barTop, {y: -20}, 0.25, {ease: FlxEase.backOut});
		FlxTween.tween(barBottom, {y: 20}, 0.25, {ease: FlxEase.backOut});

		regenMenu();

		// CamOther para todo
		cameras = [FlxG.cameras.list[1]];

		super.create();
	}

	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if (formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;
		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Fade in suave
		if (bg.alpha < 0.6) bg.alpha = FlxMath.lerp(bg.alpha, 0.6, 10 * elapsed);

		// ESC = Resume
		if (controls.BACK) {
			close(); // igual que presionar Resume
			return;
		}

		if (controls.UI_LEFT_P) changeSelection(-1);
		if (controls.UI_RIGHT_P) changeSelection(1);

		if (controls.ACCEPT) {
			var daSelected:String = menuItems[curSelected];
			switch (daSelected) {
				case "Resume":
					close();

				case "Restart Song":
					restartSong();

				case "Exit to menu":
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					Mods.loadTopMod();
					if (PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else
						MusicBeatState.switchState(new FreeplayState());
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
			}
		}

		// Animación con LERP (más suave y progresiva)
		for (num => item in grpMenuItems.members)
		{
			var targetScale:Float = (num == curSelected) ? 1.1 : 1;
			var targetAlpha:Float = (num == curSelected) ? 1 : 0.6;

			item.scale.x = FlxMath.lerp(item.scale.x, targetScale, 12 * elapsed);
			item.scale.y = FlxMath.lerp(item.scale.y, targetScale, 12 * elapsed);
			item.alpha   = FlxMath.lerp(item.alpha, targetAlpha, 12 * elapsed);
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true;
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;
		if(noTrans) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		if (curSelected == 0) {
			thing.animation.play('resum');

			thing.y = ogYThing + 20;
			FlxTween.tween(thing, {y: thing.y - 20}, 0.1, {ease: FlxEase.circOut});
		}

		if (curSelected == 1) {
			thing.animation.play('restarr');

			thing.y = ogYThing + 20;
			FlxTween.tween(thing, {y: thing.y - 20}, 0.1, {ease: FlxEase.circOut});
		}

		if (curSelected == 2) {
			thing.animation.play('exit');

			thing.y = ogYThing + 20;
			FlxTween.tween(thing, {y: thing.y - 20}, 0.1, {ease: FlxEase.circOut});
		}
	}

	function regenMenu():Void
	{
		while (grpMenuItems.members.length > 0) {
			var obj:FlxSprite = grpMenuItems.members[0];
			obj.kill();
			grpMenuItems.remove(obj, true);
			obj.destroy();
		}

		// Posiciones (Restart en el centro, otros a los lados)
		var positions:Array<Float> = [
			FlxG.width * 0.25, // Resume izquierda
			FlxG.width * 0.5,  // Restart centro
			FlxG.width * 0.75  // Exit derecha
		];

		for (num => str in menuItems) {
			var item:FlxSprite = new FlxSprite(0, 0);
			item.loadGraphic(Paths.image('pause/' + str));
			item.x = positions[num] - (item.width / 2);
			item.scrollFactor.set();
			item.screenCenter(Y);
			item.y += 100;
			item.scale.set(1, 1);
			item.alpha = 0.6;
			item.antialiasing = ClientPrefs.data.antialiasing;
			grpMenuItems.add(item);
		}

		thing.y = grpMenuItems.members[curSelected].y - grpMenuItems.members[curSelected].height - 30;
		ogYThing = thing.y;

		curSelected = 0; // Restart por defecto
	}
}

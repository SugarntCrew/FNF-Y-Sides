package states;

import states.gallery.GalleryStateMusic;
import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;

class PerformanceWarning extends MusicBeatState
{
	public static var leftState:Bool = false;

	var bg:FlxSprite;
	var warnText:FlxText;
	var iUnderstand:FlxText;

	override function create()
	{
		super.create();

		GalleryStateMusic.preloadMusic();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Warning!\n
			This Mod may have memory leaks and severe lags if you have a low-end pc\n
			We recommend you to activate the low quality setting in the options menu to avoid them");
		warnText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		warnText.alpha = 0;
		warnText.y += 10;
		add(warnText);

		FlxTween.tween(warnText, {alpha: 1, y: warnText.y - 10}, 0.2);

		iUnderstand = new FlxText(0, 0, FlxG.width, 'I understand');
		iUnderstand.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		iUnderstand.y = (warnText.y + warnText.height) + 44;
		//iUnderstand.x += (128 * i) - 80;
        iUnderstand.screenCenter(X);
		iUnderstand.y += 10;
		iUnderstand.alpha = 0;
		add(iUnderstand);

		FlxTween.tween(iUnderstand, {alpha: 1, y: iUnderstand.y - 10}, 0.2);
	}

	override function update(elapsed:Float)
	{
		if(leftState) {
			super.update(elapsed);
			return;
		}

		if (controls.ACCEPT) {
			leftState = true;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			FlxTween.tween(warnText, {alpha: 0, y: warnText.y - 10}, 0.2);
			FlxTween.tween(iUnderstand, {alpha: 0, y: iUnderstand.y - 10}, 0.2);

			new FlxTimer().start(1, function(t:FlxTimer)
			{
				MusicBeatState.switchState(new TitleState());
			});
		}
		super.update(elapsed);
	}
}

package states.stages;

import states.stages.objects.*;
import objects.Character;

class PicoStage extends BaseStage
{
    var guards:BGSprite;
    var signs:BGSprite;

	override function create()
	{
		var bg:BGSprite = new BGSprite('bg_pico', -1009, -728, 1, 1);
        bg.scale.set(0.9, 0.9);
        bg.updateHitbox();
        bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		guards = new BGSprite('guards', -470, -70, 1, 1, ['idle1', 'idle2']);
        guards.scale.set(1.3, 1.3);
        guards.animOffsets = [ [3, -8], [0, 5] ];
        guards.antialiasing = ClientPrefs.data.antialiasing;
        guards.updateHitbox();
        guards.animation.play('idle1');
        guards.offset.set(guards.animOffsets[0][0], guards.animOffsets[0][1]);
		add(guards);

		var lights:BGSprite = new BGSprite('lightslol', -1016, -737, 1, 1);
        lights.scale.set(0.9, 0.9);
        lights.updateHitbox();
        lights.antialiasing = ClientPrefs.data.antialiasing;
		add(lights);
	}

    override function createPost() 
    {
		var lights2:BGSprite = new BGSprite('lightsfr', -1079, -808, 1, 1);
        lights2.antialiasing = ClientPrefs.data.antialiasing;
        lights2.updateHitbox();
        lights2.blend = ADD;
        lights2.alpha = 0.5;
		add(lights2);

		signs = new BGSprite('signs', -1168, -959, 1.5, 1.5);
        signs.alpha = 0.95;
        signs.updateHitbox();
        signs.antialiasing = ClientPrefs.data.antialiasing;
		add(signs);
    }

    var signsVisible:Bool = true;
    override function update(elapsed:Float)
    {
        if(game.camGame.zoom > 0.65 && signsVisible) {
            signsVisible = false;

            FlxTween.cancelTweensOf(signs);
            FlxTween.tween(signs, {alpha: 0}, 0.5, {ease: FlxEase.circInOut});
        }
        else if(game.camGame.zoom <= 0.65 && !signsVisible) {
            signsVisible = true;

            FlxTween.cancelTweensOf(signs);
            FlxTween.tween(signs, {alpha: 0}, 0.5, {ease: FlxEase.circInOut});
        }
    }

    override function beatHit()
    {
        if(curBeat % 2 == 0) 
        {
            guards.animation.play('idle1');
            guards.offset.set(guards.animOffsets[0][0], guards.animOffsets[0][1]);
        }
        else
        {
            guards.animation.play('idle2');
            guards.offset.set(guards.animOffsets[1][0], guards.animOffsets[1][1]);
        }
    }
}
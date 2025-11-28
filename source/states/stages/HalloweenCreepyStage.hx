package states.stages;

import openfl.filters.ShaderFilter;
import shaders.BloomShader;
import shaders.ChromaticAberration;
import shaders.DropShadowShader;

class HalloweenCreepyStage extends BaseStage
{
	override function create()
	{
		var sky:BGSprite = new BGSprite('spooky/monster/sky', -1248, -1041, 1, 1);
		add(sky);

		var moon:BGSprite = new BGSprite('spooky/monster/moon', -1315, -995, 0.1, 0.1);
		add(moon);

		var clouds:BGSprite = new BGSprite('spooky/monster/clouds', -1286, -1146, 0.2, 0.2);
		add(clouds);

		var buildings:BGSprite = new BGSprite('spooky/monster/buildings', -1288, -1235, 0.6, 0.6);
		add(buildings);

		var bgmain:BGSprite = new BGSprite('spooky/monster/bgmain', -1230, -1378, 1, 1);
		add(bgmain);

	}

	override function createPost()
	{

		var gradient:BGSprite = new BGSprite('spooky/monster/gradient', -1230, -1378, 1, 1);
		gradient.blend = ADD;
		add(gradient);

		var bloom = new BloomShader();

		bloom.dim.value = [1.8]; // 1.8
		bloom.Directions.value = [4.0]; // 2.0, 100.0 to remove
		bloom.Quality.value = [8.0]; // 8.0
		bloom.Size.value = [4.0]; // 8.0, 1.0

		var shaderFilter = new ShaderFilter(bloom);
		FlxG.camera.filters = [shaderFilter];

		var chromaticAberration = new ChromaticAberration();
		chromaticAberration.rOffset.value = [0.002];
		chromaticAberration.gOffset.value = [0.0];
		chromaticAberration.bOffset.value = [-0.002];

		var shaderFilter2 = new ShaderFilter(chromaticAberration);
		FlxG.camera.filters.push(shaderFilter2);

		// lights on characters
		var rimBF = new DropShadowShader();
		rimBF.setAdjustColor(-46, -38, -25, -20);
		rimBF.color = 0xFFE9001F;
		game.boyfriend.shader = rimBF;
		rimBF.attachedSprite = game.boyfriend;

		game.boyfriend.animation.callback = function()
		{
			if (game.boyfriend != null)
			{
				rimBF.updateFrameInfo(game.boyfriend.frame);
			}
		};

		var rimGF = new DropShadowShader();
		rimGF.setAdjustColor(-46, -38, -25, -20);
		rimGF.color = 0xFFE9001F;
		game.gf.shader = rimGF;
		rimGF.attachedSprite = game.gf;
		rimGF.distance = 10;

		game.gf.animation.callback = function()
		{
			if (game.gf != null)
			{
				rimGF.updateFrameInfo(game.gf.frame);
			}
		};

		var rimDad = new DropShadowShader();
		rimDad.setAdjustColor(-46, -38, -25, -20);
		rimDad.color = 0xFFE9001F;
		game.dad.shader = rimDad;
		rimDad.attachedSprite = game.dad;
		rimDad.angle = 180;

		game.dad.animation.callback = function()
		{
			if (game.dad != null)
			{
				rimDad.updateFrameInfo(game.dad.frame);
			}
		};

		if (game.player3 != null)
		{
			var rimPlayer3 = new DropShadowShader();
			rimPlayer3.setAdjustColor(-46, -38, -25, -20);
			rimPlayer3.color = 0xFFE9001F;
			game.player3.shader = rimPlayer3;
			rimPlayer3.attachedSprite = game.player3;
			rimPlayer3.angle = 180;
			game.player3.animation.callback = function()
			{
				if (game.player3 != null)
				{
					rimPlayer3.updateFrameInfo(game.player3.frame);
				}
			};
		}
	}
}
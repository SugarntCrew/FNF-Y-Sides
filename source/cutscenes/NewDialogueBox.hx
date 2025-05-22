package cutscenes;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.text.FlxTypeText;

typedef DialogueData =
{
	public var speechBackground:String;
	public var speechBackgroundPos:Array<Dynamic>; // if ["", ""] the speech automatically goes to the center bottom
	public var speechBackgroundSize:Array<Dynamic>; // if ["", ""] the speech automatically goes to the center bottom
	public var speechBackgroundAnim:Array<String>;
	@:optional public var speechBackFramerate:Int;
	@:optional public var speechBackLoop:Bool;

	public var speechTextFont:String;

    public var speechContinueThingSprite:String;
	public var speechContinueThingOffsets:Array<Float>;

	public var dialogues:Array<DialogueInfo>;
}

typedef DialogueInfo =
{
	public var dialogue:String;
	public var textSpeed:Float;
	public var speechTextOffsets:Array<Float>;
	public var speechTextWidth:Int;
	@:optional public var currentCharacter:Character;
	@:optional public var music:DialogueMusic;
	@:optional public var sounds:DialogueSound;
	@:optional public var cameraEffects:CameraEffects;
	@:optional public var background:Background;
}

typedef Background =
{
	var name:String;
	var position:Array<Float>;
	var anims:Array<String>;
}

typedef Character =
{
	var name:String;
	var position:Array<Float>;
	var anims:Array<Array<Dynamic>>;
	var sounds:Array<String>;
	var addBehind:Bool;
}

typedef DialogueMusic =
{
	@:optional var musicName:String;
	@:optional var musicVolume:Float;
	@:optional var fadeIn:Float; // if 0, no fade in
	@:optional var fadeOut:Float; // if 0, no fade out
}

typedef DialogueSound =
{
	var soundName:String;
	var soundVolume:Float;
}

typedef CameraEffects =
{
	var type:String;
	var properties:Array<Dynamic>;
}


class NewDialogueBox extends FlxSpriteGroup
{
	public var spriteBackground:FlxSprite;
	public var speechBackground:FlxSprite;
	private var lights:FlxSprite;
	public var speechText:FlxTypeText;
	public var speechContinueThing:FlxSprite;
	public var dialogue:DialogueData;
	public var behindGroup:FlxSpriteGroup;
	public var backgroundGroup:FlxSpriteGroup;

	public var finishThing:Void->Void;

	public function new(_dialogue:DialogueData)
	{
		super();

		dialogue = _dialogue;

		preloadRequieredAssets();

		backgroundGroup = new FlxSpriteGroup();
		add(backgroundGroup);

		spriteBackground = new FlxSprite();
		if (dialogue.dialogues[0].background != null)
		{
			if (dialogue.dialogues[0].background.anims.length > 0)
			{
				spriteBackground.frames = Paths.getSparrowAtlas(dialogue.dialogues[0].background.name);
				for (i in 0...dialogue.dialogues[0].background.anims.length)
				{
					spriteBackground.animation.addByPrefix(dialogue.dialogues[0].background.anims[i], dialogue.dialogues[0].background.anims[i]);
				}
				spriteBackground.animation.play(dialogue.dialogues[0].background.anims[0]);
			}
			else
			{
				spriteBackground.loadGraphic(Paths.image(dialogue.dialogues[0].background.name));
			}
			spriteBackground.setPosition(dialogue.dialogues[0].background.position[0], dialogue.dialogues[0].background.position[1]);
		}
		spriteBackground.antialiasing = ClientPrefs.data.antialiasing;
		backgroundGroup.add(spriteBackground);

		behindGroup = new FlxSpriteGroup();
		add(behindGroup);

		speechBackground = new FlxSprite();

		if (dialogue.speechBackground == '')
			speechBackground.makeGraphic(1155, 235, 0xFF000000);
		else if (dialogue.speechBackgroundAnim.length > 0)
		{
			speechBackground.frames = Paths.getSparrowAtlas(dialogue.speechBackground);
			for (i in 0...dialogue.speechBackgroundAnim.length)
			{
				speechBackground.animation.addByPrefix(dialogue.speechBackgroundAnim[i], dialogue.speechBackgroundAnim[i], dialogue.speechBackFramerate,
					dialogue.speechBackLoop);
			}
			speechBackground.animation.play(dialogue.speechBackgroundAnim[0]);
		}
		else
			speechBackground.loadGraphic(Paths.image(dialogue.speechBackground));

		if (dialogue.speechBackgroundPos[0] == '')
			speechBackground.screenCenter(X);
		else
			speechBackground.x = dialogue.speechBackgroundPos[0];

		if (dialogue.speechBackgroundPos[1] == '')
			speechBackground.y = FlxG.height - speechBackground.height - 40;
		else
			speechBackground.y = dialogue.speechBackgroundPos[1];

        if(dialogue.speechBackgroundSize[0] == '') {}
        else speechBackground.scale.x = dialogue.speechBackgroundSize[0];

        if(dialogue.speechBackgroundSize[1] == '') {}
        else speechBackground.scale.y = dialogue.speechBackgroundSize[1];

		speechBackground.antialiasing = ClientPrefs.data.antialiasing;
		speechBackground.updateHitbox();
		add(speechBackground);

		lights = new FlxSprite(speechBackground.x + 15, speechBackground.y + 13);
		lights.frames = Paths.getSparrowAtlas('dialogue/lighty');
		lights.animation.addByPrefix('idle', 'lighty', 24, true);
		lights.animation.play('idle');
		lights.antialiasing = ClientPrefs.data.antialiasing;
		add(lights);

		speechText = new FlxTypeText(speechBackground.x + 15, speechBackground.y + 15, dialogue.dialogues[0].speechTextWidth, '', 24);
		if (dialogue.speechTextFont == '')
			speechText.font = Paths.font('vcr.ttf');
		else
			speechText.font = Paths.font(dialogue.speechTextFont);
		speechText.color = 0xFFBBBBBB;
		speechText.sounds = [FlxG.sound.load(Paths.sound('dialogue'), 0.6)];
		speechText.borderStyle = SHADOW;
		//speechText.setPosition(speechText.x + dialogue.speechTextOffsets[0], speechText.y + dialogue.speechTextOffsets[1]);
		speechText.width = dialogue.dialogues[0].speechTextWidth;
		speechText.borderColor = 0xFF666666;
		speechText.shadowOffset.set(2, 2);
		speechText.antialiasing = ClientPrefs.data.antialiasing;
		add(speechText);

		speechContinueThing = new FlxSprite(speechBackground.x + speechBackground.width - 50, speechBackground.y + speechBackground.height - 25);

		if (dialogue.speechContinueThingSprite != '') speechContinueThing.loadGraphic(Paths.image(dialogue.speechContinueThingSprite));
        else speechContinueThing.makeGraphic(40, 40, 0xFFFFFFFF);

		speechContinueThing.scale.set(0, 0);
		speechContinueThing.antialiasing = ClientPrefs.data.antialiasing;
		speechContinueThing.angle = 15;
		speechContinueThing.setPosition(speechContinueThing.x + dialogue.speechContinueThingOffsets[0],
			speechContinueThing.y + dialogue.speechContinueThingOffsets[1]);
		add(speechContinueThing);

		startDialogue();
	}

	function preloadRequieredAssets()
	{
		var precachedMusic:Map<String, Dynamic> = new Map<String, Dynamic>();
		var precachedSound:Map<String, Dynamic> = new Map<String, Dynamic>();

		for(array in dialogue.dialogues)
		{
			if(array.music != null) {
				if(array.music.musicName != null) {
					trace('precached ${array.music.musicName}');
					precachedMusic.set(array.music.musicName, FlxG.sound.load(Paths.music(array.music.musicName), 1));
					//FlxG.sound.playMusic(array.music.musicName, 0.001);
				}
			}

			if(array.sounds != null) {
				if(array.sounds.soundName != null) {
					trace('precached ${array.sounds.soundName}');
					precachedSound.set(array.sounds.soundName, FlxG.sound.load(Paths.sound(array.sounds.soundName), 1));
					//FlxG.sound.play(array.sounds.soundName, 0.001);
				}
			}
		}
	}

	var finishedWholeDialogue:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER && !finishedWholeDialogue)
		{
			if (startedDialogue && !endedDialogue)
			{
				speechText.skip();
				return;
			}

			startedDialogue = false;
			playContinueThingAnim(END);

			if (character != null)
				character.destroy();

			behindGroup.forEach(function(s:FlxSprite) s.destroy());
			behindGroup.clear();

			if (dialogue.dialogues[0].music != null)
			{
				if (dialogue.dialogues[0].music.fadeOut != 0)
					FlxG.sound.music.fadeOut(dialogue.dialogues[0].music.fadeOut, 0);
			}

			dialogue.dialogues.remove(dialogue.dialogues[0]);
			if (dialogue.dialogues.length > 0)
				startDialogue();
			else
			{
				finishedWholeDialogue = true;
				speechBackground.destroy();
				lights.destroy();
				if (spriteBackground != null)
					spriteBackground.destroy();
				speechText.destroy();
				finishThing();
				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					destroy();
				});
			}
		}
	}

	var startedDialogue:Bool = false;
	var endedDialogue:Bool = false;

	function startDialogue()
	{
		trace('Starting dialogue...');

		if (spriteBackground != null)
			spriteBackground.destroy();
		backgroundGroup.forEach(function(s:FlxSprite) s.destroy());
		backgroundGroup.clear();

		speechText.setPosition(speechBackground.x + 15 + dialogue.dialogues[0].speechTextOffsets[0], speechBackground.y + 15 + dialogue.dialogues[0].speechTextOffsets[1]);
		speechText.width = dialogue.dialogues[0].speechTextWidth;

		spriteBackground = new FlxSprite();
		if (dialogue.dialogues[0].background != null)
		{
			if (dialogue.dialogues[0].background.anims.length > 0)
			{
				spriteBackground.frames = Paths.getSparrowAtlas(dialogue.dialogues[0].background.name);
				for (i in 0...dialogue.dialogues[0].background.anims.length)
				{
					spriteBackground.animation.addByPrefix(dialogue.dialogues[0].background.anims[i], dialogue.dialogues[0].background.anims[i]);
				}
				spriteBackground.animation.play(dialogue.dialogues[0].background.anims[0]);
			}
			else
			{
				spriteBackground.loadGraphic(Paths.image(dialogue.dialogues[0].background.name));
			}
			spriteBackground.setPosition(dialogue.dialogues[0].background.position[0], dialogue.dialogues[0].background.position[1]);
			spriteBackground.visible = true;
		}
		else
		{
			spriteBackground.visible = false;
		}
		backgroundGroup.add(spriteBackground);

		startedDialogue = true;
		endedDialogue = false;

		if (dialogue.dialogues[0].music != null)
		{
			var name = dialogue.dialogues[0].music.musicName == null ? '' : dialogue.dialogues[0].music.musicName;
			var volume = dialogue.dialogues[0].music.musicVolume == null ? 1 : dialogue.dialogues[0].music.musicVolume;

			if (name != '') FlxG.sound.playMusic(Paths.music(name), volume);

			if (dialogue.dialogues[0].music.fadeIn != 0)
				FlxG.sound.music.fadeIn(dialogue.dialogues[0].music.fadeIn, 0, 1);
		}

		if (dialogue.dialogues[0].sounds != null)
		{
			FlxG.sound.play(Paths.sound(dialogue.dialogues[0].sounds.soundName), dialogue.dialogues[0].sounds.soundVolume);
		}

		if (dialogue.dialogues[0].cameraEffects != null)
		{
			applyCameraEffect(dialogue.dialogues[0].cameraEffects.type, dialogue.dialogues[0].cameraEffects.properties);
		}

		if (dialogue.dialogues[0].currentCharacter != null)
		{
			createCharacter(dialogue.dialogues[0].currentCharacter.name, dialogue.dialogues[0].currentCharacter.position,
				dialogue.dialogues[0].currentCharacter.anims);
		}

		speechText.resetText(dialogue.dialogues[0].dialogue);
		speechText.start(dialogue.dialogues[0].textSpeed, true);
		speechText.sounds = [FlxG.sound.load(Paths.sound('dialogue'), 0.6)];
		if (dialogue.dialogues[0].currentCharacter != null)
		{
			if (dialogue.dialogues[0].currentCharacter.sounds.length > 0)
			{
				var shittyArray:Dynamic = [];
				for (i in 0...dialogue.dialogues[0].currentCharacter.sounds.length)
				{
					trace('loaded sound ${dialogue.dialogues[0].currentCharacter.sounds[i]}');
					shittyArray.push(FlxG.sound.load(Paths.sound(dialogue.dialogues[0].currentCharacter.sounds[i]), 0.6));
				}
				speechText.sounds = shittyArray;
			}
		}
		speechText.completeCallback = function()
		{
			if (dialogue.dialogues[0].currentCharacter != null)
			{
				if (dialogue.dialogues[0].currentCharacter.anims.length > 1)
				{
					if (character != null && character.animation.exists(dialogue.dialogues[0].currentCharacter.anims[1][0]))
					{
						trace('character: end animation found!');
						character.offset.set(dialogue.dialogues[0].currentCharacter.anims[1][1][0], dialogue.dialogues[0].currentCharacter.anims[1][1][1]);
						character.animation.play(dialogue.dialogues[0].currentCharacter.anims[1][0]);
					}
				}
			}
			endedDialogue = true;
			playContinueThingAnim(START);
		};
	}

	function applyCameraEffect(type:String, properties:Array<Dynamic>)
	{
		switch (type.toLowerCase())
		{
			case 'shake':
				FlxG.camera.shake(properties[0], properties[1]);
			case 'fade':
				FlxG.camera.fade(properties[0], properties[1], properties[2]);
		}
	}

	var character:FlxSprite;

	function createCharacter(name:String, pos:Array<Float>, anims:Array<Array<Dynamic>>)
	{
		character = new FlxSprite();
		if (anims.length > 0)
		{
			character.frames = Paths.getSparrowAtlas(name);
			for (i in 0...anims.length)
			{
				character.animation.addByPrefix(anims[i][0], anims[i][0]);
			}
			character.offset.set(anims[0][1][0], anims[0][1][1]);
			character.animation.play(anims[0][0]);
		}
		character.setPosition(pos[0], pos[1]);
		character.antialiasing = ClientPrefs.data.antialiasing;
		if (dialogue.dialogues[0].currentCharacter.addBehind)
			behindGroup.add(character);
		else
			add(character);

		trace('character: successfully created ($name)');
	}

	function playContinueThingAnim(type:Anim)
	{
		switch (type)
		{
			case START:
				speechContinueThing.visible = true;
				speechContinueThing.scale.set(0, 0);

				FlxTween.cancelTweensOf(speechContinueThing);
				FlxTween.tween(speechContinueThing, {"scale.x": 1.1, "scale.y": 1.1}, 0.13, {
					ease: FlxEase.expoIn,
					onComplete: function(t:FlxTween)
					{
						FlxTween.tween(speechContinueThing, {"scale.x": 1, "scale.y": 1}, 0.3, {ease: FlxEase.expoOut});
					}
				});

				speechContinueThing.angle = 15;
				FlxTween.tween(speechContinueThing, {angle: -15}, 2, {ease: FlxEase.quartInOut, type: PINGPONG});
			case END:
				FlxG.sound.play(Paths.sound('dialogueSelect'));

				FlxTween.cancelTweensOf(speechContinueThing);
				FlxTween.tween(speechContinueThing, {"scale.x": 1.1, "scale.y": 1.1}, 0.05, {
					ease: FlxEase.expoIn,
					onComplete: function(t:FlxTween)
					{
						FlxTween.tween(speechContinueThing, {"scale.x": 0, "scale.y": 0}, 0.17, {ease: FlxEase.expoOut});
					}
				});
		}
	}

    public static function returnJsonData(jsonPath:String)
    {
        var rawJson:String = null;
        if(FileSystem.exists(jsonPath))
        {
            rawJson = File.getContent(jsonPath);

            return cast Json.parse(rawJson);
        }
        else trace('No file was found at $jsonPath');
        return null;
    }
}

enum Anim
{
	START;
	END;
}
package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'face', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public var isAnimated:Bool = false;
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			if(FileSystem.exists('assets/shared/images/' + name + '.xml')) isAnimated = true; //Check if xml file exists
			
			if(isAnimated)
			{
				#if debug trace('Created animated icon! ($name)'); #end
				var spritesheet = Paths.getSparrowAtlas(name);
				frames = spritesheet;
				animation.addByPrefix('normal-loop', 'normal_loop', 24, true);
				animation.addByPrefix('normalToLose', 'normal_to_lose', 24, false);
				animation.addByPrefix('lose-loop', 'lose_loop', 24, true);
				animation.addByPrefix('loseToNormal', 'lose_to_normal', 24, false);
				animation.play('normal-loop');
				
				var graphic = Paths.image(name, allowGPU);
				var iSize:Float = Math.round(graphic.width / graphic.height);

				iconOffsets[0] = (width - 150) / iSize;
				iconOffsets[1] = (height - 150) / iSize;
				updateHitbox();
			}
			else
			{
				var graphic = Paths.image(name, allowGPU);
				var iSize:Float = Math.round(graphic.width / graphic.height);
				loadGraphic(graphic, true, Math.floor(graphic.width / iSize), Math.floor(graphic.height));
				iconOffsets[0] = (width - 150) / iSize;
				iconOffsets[1] = (height - 150) / iSize;
				updateHitbox();

				animation.add(char, [for(i in 0...frames.frames.length) i], 0, false, isPlayer);
				animation.play(char);
			}
			this.char = char;

			if(char.endsWith('-pixel'))
				antialiasing = false;
			else
				antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	public var autoAdjustOffset:Bool = true;
	override function updateHitbox()
	{
		super.updateHitbox();
		if(autoAdjustOffset)
		{
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		}
	}

	public function getCharacter():String {
		return char;
	}
}

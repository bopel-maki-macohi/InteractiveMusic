package inmic;

import flixel.FlxGame;

class Main extends FlxGame
{
	public static final version = Macro.getVersion();

	public function new()
	{
		super(0, 0, PlayState);
	}
}

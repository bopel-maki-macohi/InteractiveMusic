package inmic;

import flixel.FlxG;
import flixel.FlxSprite;

class CTP extends FlxSprite
{
	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (FlxG.mouse.justPressed)
            FlxG.switchState(Main.startingState.toNextState());
	}
}

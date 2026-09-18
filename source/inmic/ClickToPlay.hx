package inmic;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;

class ClickToPlay extends FlxState
{
	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (FlxG.mouse.justPressed)
            FlxG.switchState(Main.startingState.toNextState());
	}
}

package inmic;

import flixel.util.typeLimit.NextState.InitialState;
import js.html.Document;
import openfl.events.Event;
import flixel.FlxGame;

class Main extends FlxGame
{
	public static final version = Macro.getVersion();

	public static final startingState:InitialState = PlayState;

	public function new()
	{
		super(0, 0, #if (html5 && debug) CTP #else startingState #end);
	}
}

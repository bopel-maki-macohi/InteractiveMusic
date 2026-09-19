package inmic;

import flixel.util.typeLimit.NextState.InitialState;
import flixel.FlxGame;

class Main extends FlxGame
{
	public static final version = Macro.getVersion();

	public static final startingState:InitialState = inmic.ui.play.PlayState;

	public function new()
	{
		var startState = startingState.toNextState();

		#if (html5 && debug)
		startState = () -> new ClickToPlay();
		#end

		super(0, 0, startState.getConstructor());
	}
}

package inmic.ui;

import inmic.ui.play.PlayState;
import flixel.text.FlxInputText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxSubState;

class Prompt extends FlxSubState
{
	var bg:FlxSprite;

	var textInput:FlxInputText;

	override function create()
	{
		super.create();

		add(bg = new FlxSprite().makeGraphic(1, 1));
		bg.color = FlxColor.BLACK;
		bg.alpha = 0.3;
		bg.scale.set(FlxG.width * 1.01, FlxG.height * 1.01);
		bg.updateHitbox();
		bg.screenCenter();

		add(textInput = new FlxInputText(0, 0, Math.floor(FlxG.width * 0.9), 'Event', 16));
		textInput.maxChars = 95;
		textInput.multiline = false;
        textInput.alignment = CENTER;
		textInput.screenCenter();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) onClose();

		if (FlxG.keys.justPressed.ENTER)
		{
			// PlayState.instance.songEventMarkers.push({
			// 	time: PlayState.instance.songTimeMS,
			// 	event: textInput.text,
			// });
            // PlayState.instance.editorRefreshEventMarkers();

			onClose();
		}
	}

	function onClose()
	{
		// PlayState.instance.IN_PROMPT = false;
		close();
	}
}

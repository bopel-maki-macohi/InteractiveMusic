package inmic;

import flixel.sound.FlxSound;
import lime.media.AudioSource;
import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import openfl.media.SoundChannel;
import openfl.Assets;
import openfl.media.Sound;
import flixel.FlxG;
import flixel.FlxState;

class PlayState extends FlxState
{
	var EDITOR_MODE:Bool = false;

	var PAUSED:Bool = false;

	var song:FlxSound;

	var songName = 'Lead';
	var songTimeMS(get, null):Float;

	function get_songTimeMS():Float return (song == null) ? 0 : song.time;

	var songLengthMS(get, null):Float;

	function get_songLengthMS():Float return (song == null) ? 0 : song.length;

	var timeBar:FlxBar;
	var timeText:FlxText;

	override function create()
	{
		super.create();

		FlxG.sound.list.add(song = new FlxSound().load('assets/songs/$songName.ogg'));
		song.play();

		add(timeBar = new FlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width, 16, this, 'songTimeMS', 0, songLengthMS, false));
		timeBar.createFilledBar(0xFF000000, 0xFF00FF00);

		add(timeText = new FlxText());
		timeText.screenCenter(X);

		updateEditorMode();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) togglePaused();
		if (FlxG.keys.justPressed.F7) toggleEditorMode();

		timeText.text = '${songTimeMS / 1000} / ${songLengthMS / 1000}';
	}

	function togglePaused()
	{
        if (EDITOR_MODE) return;

		PAUSED = !PAUSED;

		updatePaused();
	}

	function updatePaused()
	{
		if (PAUSED || EDITOR_MODE) if (song.playing) song.pause();
		if (!PAUSED && !EDITOR_MODE) if (!song.playing) song.play();
	}

	function toggleEditorMode()
	{
		EDITOR_MODE = !EDITOR_MODE;

		updateEditorMode();
	}

	function updateEditorMode()
	{
		updatePaused();

		timeText.alpha = (EDITOR_MODE) ? 0.75 : 0.001;
	}
}

package inmic;

import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
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
	static final editorShiftMS:Float = 1 * 1000;
	static final editorMoveMS:Float = 5 * 1000;

	var editorShiftTick:Int = 0;
	var editorShiftTickThreshold:Int = 50;

	var editorShifting(get, null):Bool;

	function get_editorShifting():Bool return editorShiftTick >= editorShiftTickThreshold;

	var editorEventMarkers:FlxSpriteContainer;

	var EDITOR_MODE:Bool = false;

	var PAUSED:Bool = false;

	var song:FlxSound;

	var songName = 'Lead';
	var songTimeMS(get, set):Float;

	function get_songTimeMS():Float return (song == null) ? 0 : song.time;

	function set_songTimeMS(ms:Float):Float return (song == null) ? 0 : song.time = ms;

	var songLengthMS(get, null):Float;

	function get_songLengthMS():Float return (song == null) ? 0 : song.length;

	var songEventMarkers = [
		{
			time: 2500,
			event: 'intro'
		},
		{
			time: 5000,
			event: 'outtro'
		},
		{
			time: 10000,
			event: 'what'
		}
	];

	var timeBar:FlxBar;
	var timeText:FlxText;

	override function create()
	{
		super.create();

		FlxG.sound.list.add(song = new FlxSound().load('assets/songs/$songName.ogg'));
		song.play();

		add(timeBar = new FlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width, 16, this, 'songTimeMS', 0, songLengthMS, false));
		timeBar.createFilledBar(0xFF000000, 0xFF00FF00);

		add(editorEventMarkers = new FlxSpriteContainer());

		add(timeText = new FlxText());

		updateEditorMode();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) togglePaused();
		if (FlxG.keys.justPressed.F7) toggleEditorMode();

		if (EDITOR_MODE)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (song.playing) song.pause();
				else song.play();
			}

			if (!song.playing) editorTimeShifting();
		}

		timeText.text = '${songTimeMS / 1000} / ${songLengthMS / 1000}';
		timeText.screenCenter(X);
	}

	function togglePaused()
	{
		if (EDITOR_MODE)
		{
			PAUSED = false;
			return;
		}

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

		editorEventMarkers.alpha = (EDITOR_MODE) ? 1 : 0.001;
		timeText.alpha = (EDITOR_MODE) ? 0.75 : 0.001;

		editorShiftTick = 0;

		editorRefreshEventMarkers();
	}

	function editorTimeShifting()
	{
		var shifting = (FlxG.keys.pressed.CONTROL) ? 0.5 : 1;
		if (FlxG.keys.pressed.ALT) shifting *= 2;

		final leftJP = FlxG.keys.anyJustPressed([A, LEFT]);
		final rightJP = FlxG.keys.anyJustPressed([D, RIGHT]);

		final leftP = FlxG.keys.anyPressed([A, LEFT]);
		final rightP = FlxG.keys.anyPressed([D, RIGHT]);

		if (editorShifting)
		{
			if (leftP) songTimeMS -= editorShiftMS * shifting;
			if (rightP) songTimeMS += editorShiftMS * shifting;
		}
		else
		{
			if (leftJP) songTimeMS -= editorMoveMS * shifting;
			if (rightJP) songTimeMS += editorMoveMS * shifting;

			if (leftP || rightP) editorShiftTick += 1;
		}

		if (!leftP && !rightP) editorShiftTick = 0;

		if (songTimeMS < 0) songTimeMS = 0;
		if (songTimeMS > songLengthMS) songTimeMS = songLengthMS;
	}

	function editorRefreshEventMarkers()
	{
		for (sprite in editorEventMarkers)
		{
			editorEventMarkers.remove(sprite);
			sprite.destroy();
			sprite = null;
		}

		for (marker in songEventMarkers)
		{
			var markerSprite = new FlxSprite().makeGraphic(1, 1);
			markerSprite.scale.set(2, timeBar.barHeight);
			markerSprite.updateHitbox();

			markerSprite.x = timeBar.barWidth * (marker.time / songLengthMS);

			editorEventMarkers.add(markerSprite);
		}
	}
}

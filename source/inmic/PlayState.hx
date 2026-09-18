package inmic;

import inmic.ui.Prompt;
import inmic.song.EventMarker;
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
	public static var instance:PlayState;

	public var IN_PROMPT:Bool = false;

	public var EDITOR_MODE:Bool = false;
	public var PAUSED:Bool = false;

	public final editorShiftMS:Float = 1 * 1000;
	public final editorMoveMS:Float = 5 * 1000;
	public final editorShiftTickThreshold:Int = 50;

	public var editorShiftTick(default, null):Int = 0;

	public var editorShifting(get, null):Bool;

	function get_editorShifting():Bool return editorShiftTick >= editorShiftTickThreshold;

	/**
	 * TODO : I want to have these in it's own little section so multiple events can be easily seen
	 */
	public var editorEventMarkers(default, null):FlxSpriteContainer;

	public var song(default, null):FlxSound;

	public var songName(default, null):String = 'Lead';
	public var songTimeMS(get, set):Float;

	function get_songTimeMS():Float return (song == null) ? 0 : song.time;

	function set_songTimeMS(ms:Float):Float return (song == null) ? 0 : song.time = ms;

	public var songLengthMS(get, null):Float;

	function get_songLengthMS():Float return (song == null) ? 0 : song.length;

	public var songEventMarkers(default, null):Array<EventMarker> = [
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

	public var timeBar(default, null):FlxBar;
	public var timeText(default, null):FlxText;

	override function create()
	{
		super.create();

		if (instance != null) instance = null;
		instance = this;

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
		if (FlxG.keys.justPressed.SEVEN) toggleEditorMode();

		if (EDITOR_MODE && !IN_PROMPT)
		{
			if (FlxG.keys.justPressed.ENTER) addEventMarker();

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

	public function updatePaused()
	{
		if (PAUSED || EDITOR_MODE) if (song.playing) song.pause();
		if (!PAUSED && !EDITOR_MODE) if (!song.playing) song.play();
	}

	function toggleEditorMode()
	{
		EDITOR_MODE = !EDITOR_MODE;

		updateEditorMode();
	}

	public function updateEditorMode()
	{
		updatePaused();

		editorEventMarkers.alpha = (EDITOR_MODE) ? 1 : 0.001;
		timeText.alpha = (EDITOR_MODE) ? 0.75 : 0.001;

		editorShiftTick = 0;

		editorRefreshEventMarkers();
	}

	function editorTimeShifting()
	{
		var shifting = (FlxG.keys.pressed.SHIFT) ? 0.5 : (FlxG.keys.pressed.CONTROL) ? 0.25 : (FlxG.keys.pressed.ALT) ? 0.1 : 1;

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

	public function editorRefreshEventMarkers()
	{
		for (sprite in editorEventMarkers)
		{
			editorEventMarkers.remove(sprite);
			sprite.destroy();
			sprite = null;
		}

		if (timeBar == null) return;

		for (marker in songEventMarkers)
		{
			var markerSprite = new FlxSprite().makeGraphic(1, 1);
			markerSprite.scale.set(2, timeBar.barHeight);
			markerSprite.updateHitbox();

			final fraction:Float = (marker.time) / timeBar.max;
			final scaleInterval:Float = timeBar.barWidth / timeBar.numDivisions;
			final interval:Float = Math.round(Std.int(fraction * timeBar.barWidth / scaleInterval) * scaleInterval);

			markerSprite.x = interval;

			editorEventMarkers.add(markerSprite);
		}
	}

	function addEventMarker()
	{
		IN_PROMPT = true;

		openSubState(new Prompt());
	}
}

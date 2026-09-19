package inmic.ui.play;

import flixel.FlxBasic;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.FlxObject;
import haxe.Json;
import openfl.net.FileReference;
import inmic.song.EventMarker;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.sound.FlxSound;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import openfl.Assets;
import flixel.FlxG;

class GameplayState extends FlxTypedContainer<FlxBasic>
{
	public var editor(get, null):EditorState;

	function get_editor():EditorState return PlayState.instance.editor;

	public var PAUSED:Bool = false;

	public var song(default, null):FlxSound;

	public var songName(default, null):String = 'Lead';
	public var songTimeMS(get, set):Float;

	function get_songTimeMS():Float return (song == null) ? 0 : song.time;

	function set_songTimeMS(ms:Float):Float return (song == null) ? 0 : song.time = ms;

	public var songLengthMS(get, null):Float;

	function get_songLengthMS():Float return (song == null) ? 0 : song.length;

	public var songEventMarkers(default, null):Array<EventMarker> = [];

	public var timeBar(default, null):FlxBar;

	public function create()
	{
		songEventMarkers = Json.parse(Assets.getText('assets/songs/$songName/events.json'));
		FlxG.sound.list.add(song = new FlxSound().load('assets/songs/$songName/song.ogg'));

		add(timeBar = new FlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width, 16, this, 'songTimeMS', 0, songLengthMS, false));
		timeBar.createFilledBar(0xFF000000, 0xFF00FF00);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) togglePaused();
	}

	public function togglePaused()
	{
		if (editor.active)
		{
			PAUSED = false;
			updatePaused();

			return;
		}

		PAUSED = !PAUSED;

		updatePaused();
	}

	public function updatePaused()
	{
		if (PAUSED || editor.active) if (song.playing) song.pause();
		if (!PAUSED && !editor.active) if (!song.playing) song.play();
	}
}

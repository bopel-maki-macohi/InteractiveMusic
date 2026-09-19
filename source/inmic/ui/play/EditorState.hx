package inmic.ui.play;

import flixel.util.FlxSort;
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
import inmic.ui.play.PlayState;
import flixel.FlxObject;

class EditorState extends FlxTypedContainer<FlxBasic>
{
	public var gameplay(get, null):GameplayState;

	function get_gameplay():GameplayState return PlayState.instance.gameplay;

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

	public var timeText:FlxText;

	public function create()
	{
		add(editorEventMarkers = new FlxSpriteContainer());
		add(timeText = new FlxText());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (PlayState.instance.IN_PROMPT) return;

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S) editorSave();

		if (FlxG.keys.justPressed.ENTER) addEventMarker();

		if (FlxG.keys.justPressed.SPACE)
		{
			if (gameplay.song.playing) gameplay.song.pause();
			else gameplay.song.play();
		}

		if (!gameplay.song.playing) editorTimeShifting();

		timeText.text = '${gameplay.songTimeMS / 1000} / ${gameplay.songLengthMS / 1000}';
		timeText.screenCenter(X);
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
			if (leftP) gameplay.songTimeMS -= editorShiftMS * shifting;
			if (rightP) gameplay.songTimeMS += editorShiftMS * shifting;
		}
		else
		{
			if (leftJP) gameplay.songTimeMS -= editorMoveMS * shifting;
			if (rightJP) gameplay.songTimeMS += editorMoveMS * shifting;

			if (leftP || rightP) editorShiftTick += 1;
		}

		if (!leftP && !rightP) editorShiftTick = 0;

		if (gameplay.songTimeMS < 0) gameplay.songTimeMS = 0;
		if (gameplay.songTimeMS > gameplay.songLengthMS) gameplay.songTimeMS = gameplay.songLengthMS;
	}

	public function editorRefreshEventMarkers()
	{
		for (sprite in editorEventMarkers)
		{
			editorEventMarkers.remove(sprite);
			sprite.destroy();
			sprite = null;
		}

		if (gameplay.timeBar == null) return;

		for (marker in gameplay.songEventMarkers)
		{
			var markerSprite = new FlxSprite().makeGraphic(1, 1);
			markerSprite.scale.set(2, gameplay.timeBar.barHeight);
			markerSprite.updateHitbox();

			final fraction:Float = (marker.time) / gameplay.timeBar.max;
			final scaleInterval:Float = gameplay.timeBar.barWidth / gameplay.timeBar.numDivisions;
			final interval:Float = Math.round(Std.int(fraction * gameplay.timeBar.barWidth / scaleInterval) * scaleInterval);

			markerSprite.x = interval;

			editorEventMarkers.add(markerSprite);
		}
	}

	function addEventMarker()
	{
		PlayState.instance.IN_PROMPT = true;
		PlayState.instance.openSubState(new Prompt());
	}

	public function editorSave()
	{
		var fileRef = new FileReference();
		gameplay.songEventMarkers.sort((a, b) -> return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
		fileRef.save(Json.stringify(gameplay.songEventMarkers, '\t'), 'events.json');
	}
}

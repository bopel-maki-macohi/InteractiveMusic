package inmic.ui.play;

import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.sound.FlxSound;
import flixel.FlxState;

class PlayState extends FlxState
{
	public static var instance:PlayState;

	public var gameplay:GameplayState;
	public var editor:EditorState;

	public var IN_PROMPT:Bool = false;

	public var PAUSED(get, null):Bool;

	function get_PAUSED():Bool return gameplay.PAUSED;

	public var EDITOR_MODE(get, null):Bool;

	function get_EDITOR_MODE():Bool return editor.active;

	override function create()
	{
		super.create();

		if (instance != null) instance = null;
		instance = this;

		add(gameplay = new GameplayState());
		add(editor = new EditorState());

		gameplay.create();
		editor.create();

		toggleEditorMode();

		gameplay.song.play();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.SEVEN) toggleEditorMode();
	}

	public function toggleEditorMode()
	{
		editor.visible = editor.active = !editor.active;
		editor.editorRefreshEventMarkers();

		gameplay.togglePaused();
	}
}

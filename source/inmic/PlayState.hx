package inmic;

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
	var song:Sound;
	var songSoundChannel:SoundChannel;
	var songAudioSource:AudioSource;

	var songName = 'Lead';
	var songTime(get, null):Float;

	function get_songTime():Float
	{
		return (songSoundChannel == null) ? 0 : ((songCompleted) ? songLength : songSoundChannel.position);
	}

	var songLength(get, null):Float;

	function get_songLength():Float
	{
		return (song == null) ? 0 : song.length;
	}

	var songCompleted:Bool = false;

	var timeBar:FlxBar;

	override function create()
	{
		super.create();

		song = Assets.getSound('assets/songs/$songName.ogg');
		songSoundChannel = song.play();

		@:privateAccess
		songAudioSource = songSoundChannel.__audioSource;

		songAudioSource.onComplete.add(() ->
		{
            trace('DONE');
			songCompleted = true;
		});

		add(timeBar = new FlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width, 16, this, 'songTime', 0, songLength, false));
		timeBar.createFilledBar(0xFF000000, 0xFF00FF00);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

package inmic;

import openfl.Assets;
import openfl.media.Sound;
import flixel.FlxG;
import flixel.FlxState;

class PlayState extends FlxState
{
    var song:Sound;
    var songName = 'Lead';

	override function create()
	{
		super.create();

        song = Assets.getSound('assets/songs/$songName.ogg');
        song.play();
	}
}

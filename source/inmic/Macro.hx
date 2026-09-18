package inmic;

class Macro
{
	public static macro function getVersion()
	{
		var result = 'Unfindable Version File';
		#if !debug
		result = '0.000';
		#end

		#if sys
		result = sys.io.File.getContent('version.txt');
		#end

        return macro $v{result};
	}
}

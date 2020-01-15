package lib.shoot
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	// A lightweight version of my Config file code I wrote for the level editor. This version only supports opening and not saving config files.
	public class Config
	{
		private var settings:Dictionary = new Dictionary();
		
		private var fileLines:Array;
		
		public function Config(fileLines:Array)
		{
			this.fileLines = fileLines;
		}
		
		public function getValue(key:String)
		{
			if(!(key in this.settings))
			{
				throw new ArgumentError("Key '" + key + "' not found!");
			}
			
			return this.settings[key];
		}
		
		// Thanks to this StackOverflow user for the solution on reading files in Flash/AS3: https://stackoverflow.com/a/888089
		public function load()
		{
			for each(var line in this.fileLines)
			{
				var lineSplit:Array = line.split("=");
				
				var key:String = lineSplit[0];
				var val:String = lineSplit[1];
				
				this.settings[key] = val;
			}
		}
	}
}
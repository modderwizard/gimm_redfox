package lib.shoot.level
{
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;

	public class TileEntry
	{
		public static var tileEntries:Array = new Array();
		
		public var id:int;
		public var solid:Boolean, canSwim:Boolean;
		public var classMap:String;
		
		public function TileEntry(id:int, solid:Boolean, canSwim:Boolean, classMap:String)
		{
			this.id = id;
			this.solid = solid;
			this.canSwim = canSwim;
			this.classMap = classMap;
		}
		
		public function createInstance():MovieClip
		{
			var tileClass:Class = getDefinitionByName(this.classMap) as Class;
			var instance:MovieClip = new tileClass();
			
			return instance;
		}
		
		// Static initializer
		{
			TileEntry.tileEntries[0] = new TileEntry(0, false, false, null);
			TileEntry.tileEntries[1] = new TileEntry(1, false, false, "lib.shoot.level.TileDirt");
			TileEntry.tileEntries[2] = new TileEntry(2, true, false, "lib.shoot.level.TileGrass");
			TileEntry.tileEntries[3] = new TileEntry(3, true, false, "lib.shoot.level.TileStump");
			TileEntry.tileEntries[4] = new TileEntry(4, false, false, "lib.shoot.level.TileWater");
		}
	}
}
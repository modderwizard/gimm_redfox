package lib.shoot.level
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import lib.shoot.entity.Entity;
	
	public class EntityEntry
	{
		public static var entityEntries:Dictionary = new Dictionary();
		
		public var name:String;
		public var classMap:String;
		
		public function EntityEntry(name:String, classMap:String)
		{
			this.name = name;
			this.classMap = classMap;
		}
		
		public function createInstance():Entity
		{
			var entityClass:Class = getDefinitionByName(this.classMap) as Class;
			var instance:Entity = new entityClass();
			
			return instance;
		}
		
		// Static initializer
		{
			EntityEntry.entityEntries["Player"] = new EntityEntry("Player", "lib.shoot.entity.EntityPlayer");
			EntityEntry.entityEntries["Raccoon"] = new EntityEntry("Raccoon", "lib.shoot.entity.EntityRacoon");
		}
	}
}
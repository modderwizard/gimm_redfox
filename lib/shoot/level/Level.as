package lib.shoot.level
{
	import flash.display.MovieClip;	
	
	import lib.shoot.Config;
	import lib.shoot.CameraManager;
	import lib.shoot.Physics;
	import lib.shoot.Quadrilateral;
	import lib.shoot.entity.Entity;
	import lib.shoot.entity.EntityPlayer;
	
	public class Level
	{
		private var width:int, height:int;
		
		private var loadTileData:Array;
		private var loadTileMetaData:Array;
		private var loadEntityData:Array;
		private var loadEntityMetaData:Array;
		
		private var entities:Array = new Array();
		public var entitiesToAdd:Array = new Array();
		public var entitiesToRemove:Array = new Array();

		private var tiles:Array = new Array();
		
		private var tileHitboxes:Array = new Array();
		private var emptyArray:Array = new Array();
		
		public function update(delta:Number):void
		{
			for each(var entity:Entity in this.entities)
			{
				if(entity.canRemove)
				{
					this.entities.removeAt(this.entities.indexOf(entity));
					this.entitiesToRemove.push(entity);
				}
				else
				{
					entity.update(delta);
					
					if(entity is EntityPlayer)
					{
						Physics.entityUpdatePhysics(entity, this.tileHitboxes, this.entities, delta);
					}
					
					if(entity.posX < -10000 || entity.posX > 10000 || entity.posY < -10000 || entity.posY > 10000)
					{
						entity.setDead();
					}
				}
			}
		}
		
		public function load(fileLines:Array):void
		{
			var config:Config = new Config(fileLines);
			config.load();
			
			// Load level size
			this.width = parseInt(config.getValue("Width"));
			this.height = parseInt(config.getValue("Height"));
			
			// Set up the loaded data arrays
			this.loadTileData = new Array(this.width * this.height);
			this.loadTileMetaData = new Array(this.width * this.height);
			this.loadEntityData = new Array(this.width * this.height);
			this.loadEntityMetaData = new Array(this.width * this.height);
			
			// Load stuff from file
			var tileDataArray:Array = config.getValue("TileData").split(",");
			var tileMetaDataArray:Array = config.getValue("TileMetaData").split(",");
			var entityDataArray:Array = config.getValue("EntityData").split(",");
			var entityMetaDataArray:Array = config.getValue("EntityMetaData").split(",");
			
			// Convert the string data into it's correct type
			for(var i:int = 0; i < tileDataArray.length; i++)
			{
				this.loadTileData[i] = parseInt(tileDataArray[i]);
				this.loadTileMetaData[i] = parseInt(tileMetaDataArray[i]);
				
				this.loadEntityData[i] = null;
				if(entityDataArray[i] != "")
				{
					this.loadEntityData[i] = entityDataArray[i];
				}
				
				this.loadEntityMetaData[i] = parseInt(entityMetaDataArray[i]);
			}
		}
		
		public function setupLevel(firstTime:Boolean = true):Array
		{
			// Clear the arrays first
			this.entities.length = 0;
			this.entitiesToAdd.length = 0;
			this.entitiesToRemove.length = 0;
			this.tileHitboxes.length = 0;
			
			var tileMovieClips:Array = new Array();
			
			for(var i:int = 0; i < this.loadTileData.length; i++)
			{					
				var gridX:int = this.indexToX(i);
				var gridY:int = this.indexToY(i);
				
				if(this.loadTileData[i] != 0 && firstTime)
				{
					if(TileEntry.tileEntries[this.loadTileData[i]].solid)
					{
						var collider:Quadrilateral = new Quadrilateral().fromPositionAndSize(gridX * 24, gridY * 24, 24, 24);
					
						// Quicky hack to make the stumps have a smaller hitbox
						if(this.loadTileData[i] == 3)
						{
							collider = new Quadrilateral().fromPositionAndSize(gridX * 24, gridY * 24 + 13, 24, 11);
						}
						
						this.tileHitboxes.push(collider);
					}
					
					var tileInstance:MovieClip = (TileEntry.tileEntries[this.loadTileData[i]] as TileEntry).createInstance();
					tileInstance.gotoAndStop(this.loadTileMetaData[i] + 1);
					tileInstance.x = gridX * 24;
					tileInstance.y = gridY * 24;
					
					tileMovieClips.push(tileInstance);
				}
				
				if(this.loadEntityData[i] != null)
				{
					var entityInstance:Entity = (EntityEntry.entityEntries[this.loadEntityData[i]] as EntityEntry).createInstance();
					(entityInstance as MovieClip).x = gridX * 24;
					(entityInstance as MovieClip).y = gridY * 24;
					entityInstance.direction = this.loadEntityMetaData[i];
					
					// TODO: Fix the level editor so it doesn't save invalid metadata for entities. This is a quick fix.
					entityInstance.direction = entityInstance.direction == 0 ? 1 : entityInstance.direction;
					
					entityInstance.posX = gridX * 24;
					entityInstance.posY = gridY * 24;
					
					if(entityInstance is EntityPlayer)
					{
						CameraManager.setEntityTracking(entityInstance);
					}
					
					this.addEntity(entityInstance);
				}
			}
			
			return tileMovieClips;
		}
		
		private function indexToX(index:int):int
		{
			return index % this.width;
		}
		
		private function indexToY(index:int):int
		{
			return index / this.width;
		}
		
		private function xyToIndex(x:int, y:int):int
		{
			return y * this.width + x;
		}
		
		public function addEntity(entity:Entity)
		{
			this.entities.push(entity);
			this.entitiesToAdd.push(entity);
		}
		
		public function getEntities():Array
		{
			return this.entities;
		}
		
		public function getTileHitboxes():Array
		{
			return this.tileHitboxes;
		}
	}
}
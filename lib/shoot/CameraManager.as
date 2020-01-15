package lib.shoot
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import lib.shoot.entity.Entity;
	
	public class CameraManager
	{
		private static var entityTracking:Entity = null;
		
		public static var screenScale:Number = 3;
		
		private static var posX:Number = 0;
		private static var posY:Number = 0;
		
		// TODO: 
		public static function update(delta:Number):void
		{
			var trackingX:Number = CameraManager.entityTracking.getBoundingBox().getCenterPoint().x;
			var trackingY:Number = CameraManager.entityTracking.getBoundingBox().getCenterPoint().y;
			
			// Correct camera X position
			var cameraXZone:Number = 100;
			
			if(trackingX < CameraManager.posX + cameraXZone)
			{
				CameraManager.posX -= (CameraManager.posX + cameraXZone) - trackingX;
			}
			
			if(trackingX > CameraManager.posX + 320 - cameraXZone)
			{
				CameraManager.posX += trackingX - (CameraManager.posX + 320 - cameraXZone);
			}
			
			// Correct camera Y position
			var cameraYZone:Number = 50;
			
			if(trackingY < CameraManager.posY + cameraYZone)
			{
				CameraManager.posY -= (CameraManager.posY + cameraYZone) - trackingY;
			}
			
			if(trackingY > CameraManager.posY + 240 - cameraYZone)
			{
				CameraManager.posY += trackingY - (CameraManager.posY + 240 - cameraYZone);
			}
		}
		
		public static function getCameraPosition():Point
		{
			return new Point(CameraManager.posX, CameraManager.posY);
		}
		
		public static function getCameraRect():Rectangle
		{
			return new Rectangle(CameraManager.posX, CameraManager.posY, 320, 240);
		}
		
		public static function getEntityTracking():Entity
		{
			return CameraManager.entityTracking;
		}
		
		public static function setEntityTracking(entity:Entity):void
		{
			CameraManager.entityTracking = entity;
			
			if(entity != null)
			{
				CameraManager.posX = entity.posX + (entity.width / 2) - 160;
				CameraManager.posY = entity.posY + (entity.height / 2) - 190;
			}
		}
	}
}
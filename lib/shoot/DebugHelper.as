package lib.shoot
{	
	import flash.display.MovieClip;
	import flash.events.Event;
	import lib.shoot.entity.Entity;
	import flash.geom.Point;
	
	public class DebugHelper extends MovieClip
	{
		private static var instance:DebugHelper = null;
		
		public static function getInstance():DebugHelper
		{
			if(DebugHelper.instance == null)
			{
				DebugHelper.instance = new DebugHelper();
			}
			
			return DebugHelper.instance;
		}
		
		public function DebugHelper()
		{
			DebugHelper.instance = this;
			
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(evt:Event):void
		{
			this.graphics.clear();
		}
		
		public static function drawLine(line:LineSegment, color:uint = 0, opacity:Number = 0.5):void
		{
			DebugHelper.instance.graphics.lineStyle(1, color, opacity);
			
			DebugHelper.instance.graphics.moveTo(line.p0.x - CameraManager.getCameraPosition().x, line.p0.y - CameraManager.getCameraPosition().y);
			DebugHelper.instance.graphics.lineTo(line.p1.x - CameraManager.getCameraPosition().x, line.p1.y - CameraManager.getCameraPosition().y);
		}
		
		public static function drawQuadrilateral(quad:Quadrilateral, color:uint = 0, opacity:Number = 0.5)
		{
			for each(var line:LineSegment in quad.getLines())
			{
				DebugHelper.drawLine(line, color, 0.5);
			}
		}
		
		public static function drawRectangleFill(quad:Quadrilateral, color:uint = 0, opacity:Number = 0.5)
		{
			DebugHelper.instance.graphics.lineStyle(0, 0, 0);
			
			DebugHelper.instance.graphics.beginFill(color, opacity);
			DebugHelper.instance.graphics.drawRect(quad.getContainerRect().topLeft.x  - CameraManager.getCameraPosition().x, quad.getContainerRect().topLeft.y - CameraManager.getCameraPosition().y, quad.width, quad.height);
			DebugHelper.instance.graphics.endFill();
		}
		
		public static function drawCircle(center:Point, radius:Number, color:uint = 0, opacity:Number = 0.5):void
		{
			DebugHelper.instance.graphics.lineStyle(1, color, opacity);
			DebugHelper.instance.graphics.drawCircle(center.x - CameraManager.getCameraPosition().x, center.y - CameraManager.getCameraPosition().y, radius);
		}
		
		public static function setDebugTextLeft(text:String)
		{
			DebugHelper.instance.debugTextLeft.text = text;
		}
	}
}
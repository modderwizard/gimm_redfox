package lib.shoot
{
	import flash.geom.Point;

	public class LineIntersectionResult
	{
		public static const NONE:String = "NONE";
		public static const POINT:String = "POINT";
		public static const INFINITE:String = "INFINITE";
		
		public var intersectionType:String;
		public var intersectionPoint:Point;
		
		public function LineIntersectionResult(intrType:String, intrPoint:Point)
		{
			this.intersectionType = intrType;
			this.intersectionPoint = intrPoint;
		}
	}
}

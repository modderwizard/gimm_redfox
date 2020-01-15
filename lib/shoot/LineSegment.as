package lib.shoot
{
	import flash.geom.Point;

	public class LineSegment
	{
		public var p0:Point, p1:Point;
		
		public function LineSegment(p0:Point, p1:Point)
		{
			this.setPoints(p0, p1);
		}
		
		public function setPoints(p0:Point, p1:Point):LineSegment
		{
			this.p0 = p0;
			this.p1 = p1;
			
			return this;
		}
		
		public function getSlope():Number
		{
			return (p1.y - p0.y) / (p1.x - p0.x);
		}
		
		public function isVertical():Boolean
		{
			return this.getSlope() == Number.POSITIVE_INFINITY || this.getSlope() == Number.NEGATIVE_INFINITY || isNaN(this.getSlope());
		}
		
		public function getYIntercept():Number
		{
			return p0.y - (p0.x * this.getSlope());
		}
		
		public function getXIntercept():Number
		{
			return (p0.y - this.getYIntercept()) / this.getSlope();
		}
		
		public function getMinimum():Point
		{
			return new Point(Math.min(p0.x, p1.x), Math.min(p0.y, p1.y));
		}
		
		public function getMaximum():Point
		{
			return new Point(Math.max(p0.x, p1.x), Math.max(p0.y, p1.y));
		}
		
		public function getDistance():Number
		{
			var distX:Number = this.p1.x - this.p0.x;
			var distY:Number = this.p1.y - this.p0.y;
			
			return Math.sqrt(distX * distX + distY * distY);
		}
	}
}

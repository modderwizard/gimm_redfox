package lib.shoot
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Quadrilateral
	{
		public var topLeft:Point, topRight:Point, bottomLeft:Point, bottomRight:Point;
		public var topLine:LineSegment, rightLine:LineSegment, bottomLine:LineSegment, leftLine:LineSegment;
		
		public var width:Number, height:Number;
		
		public var isAxisAligned:Boolean;
		
		public function fromPoints(p0:Point, p1:Point, p2:Point, p3:Point):Quadrilateral
		{
			this.topLeft = p0;
			this.topRight = p1;
			this.bottomLeft = p2;
			this.bottomRight = p3;
			
			this.topLine = new LineSegment(this.topLeft, this.topRight);
			this.rightLine = new LineSegment(this.topRight, this.bottomRight);
			this.bottomLine = new LineSegment(this.bottomRight, this.bottomLeft);
			this.leftLine = new LineSegment(this.bottomLeft, this.topLeft);
			
			this.width = this.topRight.x - this.topLeft.x;
			this.height = this.bottomLeft.y - this.topLeft.y;
			
			this.isAxisAligned = (this.topLeft.x == this.bottomLeft.x) && (this.topRight.x == this.bottomRight.x) && (this.topLeft.y == this.topRight.y) && (this.bottomLeft.y == this.bottomRight.y);
			
			return this;
		}
		
		public function fromPositionAndSize(x:Number, y:Number, width:Number, height:Number):Quadrilateral
		{
			this.topLeft = new Point(x, y);
			this.topRight = new Point(x + width, y);
			this.bottomLeft = new Point(x, y + height);
			this.bottomRight = new Point(x + width, y + height);
			
			this.topLine = new LineSegment(this.topLeft, this.topRight);
			this.rightLine = new LineSegment(this.topRight, this.bottomRight);
			this.bottomLine = new LineSegment(this.bottomRight, this.bottomLeft);
			this.leftLine = new LineSegment(this.bottomLeft, this.topLeft);
			
			this.width = width;
			this.height = height;
			
			this.isAxisAligned = true;
			
			return this;
		}
		
		// Gets a point consisting of the lowest
		public function getMinimumPoint():Point
		{
			var minX:Number = Math.min(this.topLeft.x, this.bottomLeft.x);
			var minY:Number = Math.min(this.topLeft.y, this.topRight.y);
			
			return new Point(minX, minY);
		}
		
		// Gets a point consisting of the highest x and y values of the parallelogram
		public function getMaximumPoint():Point
		{
			var maxX:Number = Math.max(this.topRight.x, this.bottomRight.x);
			var maxY:Number = Math.max(this.bottomLeft.y, this.bottomRight.y);
			
			return new Point(maxX, maxY);
		}
		
		public function getCenterPoint():Point
		{
			var centerX:Number = this.getMinimumPoint().x + (this.getMaximumPoint().x - this.getMinimumPoint().x) / 2;
			var centerY:Number = this.getMinimumPoint().y + (this.getMaximumPoint().y - this.getMinimumPoint().y) / 2;
			
			return new Point(centerX, centerY);
		}
		
		// Gets the minimum sized axis-aligned rectangle that can contain this parallelogram
		public function getContainerRect():Rectangle
		{
			var topLeft:Point = this.getMinimumPoint();
			var bottomRight:Point = this.getMaximumPoint();
			
			var width:Number = bottomRight.x - topLeft.x;
			var height:Number = bottomRight.y - topLeft.y;
			
			return new Rectangle(topLeft.x, topLeft.y, width, height);
		}
		
		public function createCopy():Quadrilateral
		{
			var newShape:Quadrilateral = new Quadrilateral();
			return newShape.fromPoints(this.topLeft, this.topRight, this.bottomLeft, this.bottomRight);
		}
		
		public function offsetBy(point:Point):Quadrilateral
		{
			return this.fromPoints(this.topLeft.add(point), this.topRight.add(point), this.bottomLeft.add(point), this.bottomRight.add(point));
		}
		
		public function getLines():Array
		{
			return new Array(this.topLine, this.rightLine, this.bottomLine, this.leftLine);
		}
		
		public function clipPointTo(point:Point):void
		{
			point.x = MathHelper.clamp(point.x, this.getMinimumPoint().x, this.getMaximumPoint().x);
			point.y = MathHelper.clamp(point.y, this.getMinimumPoint().y, this.getMaximumPoint().y);
		}
	}
}

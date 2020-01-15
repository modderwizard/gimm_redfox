package lib.shoot
{
	import flash.utils.Dictionary;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import lib.shoot.entity.Ability;
	import lib.shoot.entity.Entity;

	public class Physics
	{
		private static var lineSegmentTemp:LineSegment = new LineSegment(null, null);
		
		public static function entityUpdatePhysics(entity:Entity, levelCollisions:Array, entities:Array, delta:Number):void
		{
			if(!entity.physicsEnabled)
			{
				return;
			}
			
			var entityPathCollider:Quadrilateral = Physics.entityGetPathCollision(entity);
			var feetCheck:Quadrilateral = new Quadrilateral().fromPositionAndSize(entity.posX + entity.getBoundingBoxXOffset(), entity.posY + entity.height, entity.width, 1);
			
			// TODO: This plays a part in the wiggling problem, check it
			//if(!entity.onGround)
			{
				entity.yVel += 0.075 * delta;
			}
			
			if(entity.yVel != 0 && entity.onGround)
			{
				entity.onGround = false;
			}
			
			entity.xVel = MathHelper.clamp(entity.xVel, -20, 20);
			entity.yVel = MathHelper.clamp(entity.yVel, -20, 20);
			
			// Check entity collisions
			for each(var entity2:Entity in entities)
			{
				if(entity != entity2 && entity2.physicsEnabled && lineSegmentTemp.setPoints(entity.getBoundingBox().getCenterPoint(), entity2.getBoundingBox().getCenterPoint()).getDistance() < 32)
				{
					var quad2:Quadrilateral = entity2.getBoundingBox();
				
					if(Physics.doShapesCollide(feetCheck, quad2) || Physics.doShapesCollide(entityPathCollider, quad2) || Physics.doShapesCollide(entity.getBoundingBox(), quad2))
					{
						if(entity.yVel > 0 && entity.posYPrev + (entity.height / 2) < entity2.posY && entity.hasAbility(Ability.STOMP))
						{
							entity.posY = (quad2.topLine.getMinimum().y - entity.height) - 0.1;
							entity.yVel -= 0.5;
							entity.yVel = Math.min(entity.yVel * -1, -2);
							
							entity2.onAttacked(entity);
						}
						else
						{
							entity.onAttacked(entity2);
						}
						
						return;
					}
				}
			}			
			
			// Check level collisions
			for each(var quad:Quadrilateral in levelCollisions)
			{
				if(Physics.doShapesCollide(entityPathCollider, quad) || Physics.doShapesCollide(entity.getBoundingBox(), quad))
				{
					var posLeftRight:String = entity.getBoundingBoxPrev().getCenterPoint().x < quad.getCenterPoint().x ? "LEFT" : "RIGHT";
					var posTopBottom:String = entity.getBoundingBoxPrev().getCenterPoint().y < quad.getCenterPoint().y ? "TOP" : "BOTTOM";
					
					var comparePoint:Point = null;
					var sideLineHit:LineSegment = null;
					
					// Check which side is hit
					if(posTopBottom == "TOP" && posLeftRight == "LEFT")
					{
						comparePoint = Physics.getComparisonPoint(new LineSegment(quad.topLeft, new Point(1, 1).add(quad.topLeft)), entity.getBoundingBoxPrev().getCenterPoint());
						
						if(entity.getBoundingBox().getCenterPoint().x < comparePoint.x)
						{
							sideLineHit = quad.leftLine;
						}
						else
						{
							sideLineHit = quad.topLine;
						}
					}
					else if(posTopBottom == "TOP" && posLeftRight == "RIGHT")
					{
						comparePoint = Physics.getComparisonPoint(new LineSegment(quad.topRight, new Point(1, -1).add(quad.topRight)), entity.getBoundingBoxPrev().getCenterPoint());
						
						if(entity.getBoundingBox().getCenterPoint().x < comparePoint.x)
						{
							sideLineHit = quad.topLine;
						}
						else
						{
							sideLineHit = quad.rightLine;
						}
					}
					else if(posTopBottom == "BOTTOM" && posLeftRight == "LEFT")
					{
						comparePoint = Physics.getComparisonPoint(new LineSegment(quad.bottomLeft, new Point(1, -1).add(quad.bottomLeft)), entity.getBoundingBoxPrev().getCenterPoint());
						
						if(entity.getBoundingBox().getCenterPoint().x < comparePoint.x)
						{
							sideLineHit = quad.leftLine;
						}
						else
						{
							sideLineHit = quad.bottomLine;
						}
					}
					else if(posTopBottom == "BOTTOM" && posLeftRight == "RIGHT")
					{
						comparePoint = Physics.getComparisonPoint(new LineSegment(quad.bottomRight, new Point(1, 1).add(quad.bottomRight)), entity.getBoundingBoxPrev().getCenterPoint());
						
						if(entity.getBoundingBox().getCenterPoint().x < comparePoint.x)
						{
							sideLineHit = quad.bottomLine;
						}
						else
						{
							sideLineHit = quad.rightLine;
						}
					}
					
					// Use the hit side to determine new position
					if(sideLineHit == quad.topLine)
					{
						entity.posY = quad.topLine.getMinimum().y - entity.height;
						entity.yVel = 0;
						entity.onGround = true;
					}
					else if(sideLineHit == quad.bottomLine)
					{
						entity.posY = quad.bottomLine.getMaximum().y + 0.1;
						entity.yVel = 0;
					}
					else if(sideLineHit == quad.leftLine && entity.xVel > 0)
					{
						entity.posX = quad.leftLine.getMinimum().x - entity.width - entity.getBoundingBoxXOffset();
						entity.xVel = 0; 
					}
					else if(sideLineHit == quad.rightLine && entity.xVel < 0)
					{
						entity.posX = quad.rightLine.getMaximum().x - entity.getBoundingBoxXOffset();
						entity.xVel = 0;
					}
				}
			}
		}
		
		private static function getComparisonPoint(line:LineSegment, toCompare:Point):Point
		{
			var compareX:Number = (toCompare.y - line.getYIntercept()) / line.getSlope();
			var compareY:Number = (line.getSlope() * toCompare.x) + line.getYIntercept();
			
			return new Point(compareX, compareY);
		}
		
		public static function entityGetPathCollision(entity:Entity):Quadrilateral
		{
			if(entity.xVel < 0 || (entity.xVel == 0 && entity.direction == -1))
			{
				return new Quadrilateral().fromPoints(entity.getBoundingBoxPrev().topLeft, entity.getBoundingBoxPrev().bottomRight, entity.getBoundingBox().topLeft, entity.getBoundingBox().bottomRight);
			}
			
			return new Quadrilateral().fromPoints(entity.getBoundingBoxPrev().bottomLeft, entity.getBoundingBoxPrev().topRight, entity.getBoundingBox().bottomLeft, entity.getBoundingBox().topRight);
		}
		
		// Checks if two given quadrilaterals intersect
		public static function doShapesCollide(shape0:Quadrilateral, shape1:Quadrilateral):Boolean
		{
			// If both shapes are axis-aligned, use rectangular intersection detection instead
			if(shape0.isAxisAligned && shape1.isAxisAligned)
			{
				var rectangle0:Rectangle = new Rectangle(shape0.topLeft.x, shape0.topLeft.y, shape0.width, shape0.height);
				var rectangle1:Rectangle = new Rectangle(shape1.topLeft.x, shape1.topLeft.y, shape1.width, shape1.height);
				
				return rectangle0.intersects(rectangle1);
			}
			
			// Check if shape0 has points inside shape1 and vice-versa
			var checks:Array = new Array
			(
				checkPoint(shape0.topLeft, shape1),
				checkPoint(shape0.topRight, shape1),
				checkPoint(shape0.bottomLeft, shape1),
				checkPoint(shape0.bottomRight, shape1),
			
				checkPoint(shape1.topLeft, shape0),
				checkPoint(shape1.topRight, shape0),
				checkPoint(shape1.bottomLeft, shape0),
				checkPoint(shape1.bottomRight, shape0)
			);
			
			for each(var check:Boolean in checks)
			{
				if(check)
				{
					return true;
				}
			}
			
			// Check if any lines intersect
			var shape0Lines:Array = new Array(shape0.topLine, shape0.rightLine, shape0.bottomLine, shape0.leftLine);
			var shape1Lines:Array = new Array(shape1.topLine, shape1.rightLine, shape1.bottomLine, shape1.leftLine);
			
			for each(var line0:LineSegment in shape0Lines)
			{
				for each(var line1 in shape1Lines)
				{
					if(checkLines(line0, line1))
					{
						return true;
					}
				}
			}
			
			return false;
		}
		
		// Checks if a given point is inside of a given quadrilateral
		public static function checkPoint(point:Point, shape:Quadrilateral):Boolean
		{
			// If the point is outside the container rectangle, it is not inside the Quadrilateral either
			if(!shape.getContainerRect().containsPoint(point))
			{
				return false;
			}
			
			// Points on the quadrilateral's edges to test against
			// x = (y - b) / m
			// y = m * x + b
			var compareLeft:Point = new Point((point.y - shape.leftLine.getYIntercept()) / shape.leftLine.getSlope(), point.y);
			var compareRight:Point = new Point((point.y - shape.rightLine.getYIntercept()) / shape.rightLine.getSlope(), point.y);
			
			var compareTop:Point = new Point(point.x, shape.topLine.getSlope() * point.x + shape.topLine.getYIntercept());
			var compareBottom:Point = new Point(point.x, shape.bottomLine.getSlope() * point.x + shape.bottomLine.getYIntercept());
			
			// Correct for the issue where when a side line is completely vertical, the slope will be 0, which screws up everything
			compareLeft = shape.leftLine.getSlope() == 0 ? new Point(shape.leftLine.p0.x, point.y) : compareLeft;
			compareRight = shape.rightLine.getSlope() == 0 ? new Point(shape.rightLine.p0.x, point.y) : compareRight;
			
			// Check if the point is within the comparison points
			return (point.x >= compareLeft.x && point.x <= compareRight.x && point.y >= compareTop.y && point.y <= compareBottom.y);
		}
		
		// Checks if two line segments intersect
		public static function checkLines(line0:LineSegment, line1:LineSegment):Boolean
		{
			// If the slopes are the same, the lines are either the same or parallel
			if(line0.getSlope() == line1.getSlope())
			{
				var isRangeShared:Boolean = checkLinesRangeShared(line0, line1) || checkLinesRangeShared(line1, line0);
				
				return line0.getYIntercept() == line1.getYIntercept() && isRangeShared;
			}
			
			// The coordinates of where the lines meet
			var intersectionX:Number = (line1.getYIntercept() - line0.getYIntercept()) / (line0.getSlope() - line1.getSlope());
			var intersectionY:Number = line0.getSlope() * intersectionX + line0.getYIntercept();
			
			// Check if the point of intersection is within the segment constraints
			var isInsideLine0X:Boolean = intersectionX >= line0.getMinimum().x && intersectionX <= line0.getMaximum().x;
			var isInsideLine0Y:Boolean = intersectionY >= line0.getMinimum().y && intersectionY <= line0.getMaximum().y;
			var isInsideLine1X:Boolean = intersectionX >= line1.getMinimum().x && intersectionX <= line1.getMaximum().x;
			var isInsideLine1Y:Boolean = intersectionY >= line1.getMinimum().y && intersectionY <= line1.getMaximum().y;
			
			return isInsideLine0X && isInsideLine0Y && isInsideLine1X && isInsideLine1Y;
		}
		
		// Gets they type of intersection between two lines (NONE, INFINITE, and POINT), and the location of the intersection if applicable
		public static function linesGetIntersectionPoint(line0:LineSegment, line1:LineSegment):LineIntersectionResult
		{
			if(!checkLinesRangeShared(line0, line1) && !checkLinesRangeShared(line1, line0))
			{
				return new LineIntersectionResult(LineIntersectionResult.NONE, null);
			}
			
			// If both lines are vertical...
			if(line0.isVertical() && line1.isVertical())
			{
				// If they have the same x values, they are the same line
				if(line0.p0.x == line1.p0.x)
				{
					return new LineIntersectionResult(LineIntersectionResult.INFINITE, null);
				}
				
				return new LineIntersectionResult(LineIntersectionResult.NONE, null);
			}
			
			// If both lines share the same slope...
			if(line0.getSlope() == line1.getSlope())
			{
				// If they share the same y-intercept as well, they are the same line
				if(line0.getYIntercept() == line1.getYIntercept())
				{
					return new LineIntersectionResult(LineIntersectionResult.INFINITE, null);
				}
				
				return new LineIntersectionResult(LineIntersectionResult.NONE, null);
			}
			
			var intersectionX:Number = (line1.getYIntercept() - line0.getYIntercept()) / (line0.getSlope() - line1.getSlope());
			if(MathHelper.isNumberInvalid(intersectionX))
			{
				// If a line is vertical, intersectionX will equal that line's x value
				intersectionX = line0.isVertical() ? line0.p0.x : line1.isVertical() ? line1.p0.x : intersectionX;
			}
			
			var intersectionY:Number = line0.getSlope() * intersectionX + line0.getYIntercept();
			if(MathHelper.isNumberInvalid(intersectionY))
			{
				intersectionY = line1.getSlope() * intersectionX + line1.getYIntercept();
			}
			
			if(!line0.isVertical() && !line1.isVertical())
			{
				if(MathHelper.isNumberInvalid(intersectionX))
				{
					trace("intersectionX is invalid depsite the fact no lines are vertical!");
				}
			}
			
			return new LineIntersectionResult(LineIntersectionResult.POINT, new Point(intersectionX, intersectionY));
		}
		
		public static function checkLinesRangeShared(line0:LineSegment, line1:LineSegment):Boolean
		{
			var line0RangeX:Point = new Point(line0.getMinimum().x, line0.getMaximum().x);
			var line0RangeY:Point = new Point(line0.getMinimum().y, line0.getMaximum().y);
			
			return (line1.p0.x >= line0RangeX.x && line1.p0.x <= line0RangeX.y) && (line1.p0.y >= line0RangeY.x && line1.p0.y <= line0RangeY.y);
		}
	}
}

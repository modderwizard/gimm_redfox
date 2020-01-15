package lib.shoot.entity
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import lib.shoot.DebugHelper;
	import lib.shoot.GameSettings;
	import lib.shoot.Quadrilateral;
	
	public class Entity extends MovieClip
	{
		// State
		protected var stateMaster = "GROUND";
		protected var stateMinor = "IDLE";
		protected var lastStateComposite = "";
		
		public var health:Number;
		public var score:Number;
		public var isDead:Boolean;
		public var canRemove:Boolean;
		public var hopsInAir:int;
		protected var isInvulnerable:Boolean;
		
		protected var abilities:Array;
		
		// Position
		public var posX:Number;
		public var posY:Number;
		public var posXPrev:Number;
		public var posYPrev:Number;
		
		// Facing
		public var direction:Number;
		public var directionPrev:Number;
		
		// Velocity
		public var xVel:Number;
		public var yVel:Number;
		public var xVelPrev:Number;
		public var yVelPrev:Number;
		
		// Physics
		public var onGround:Boolean;
		protected var jumps:int;
		protected var boundingBox:Quadrilateral;
		protected var boundingBoxPrev:Quadrilateral;
		
		public var physicsEnabled:Boolean;
		
		public function Entity()
		{
			this.health = 1;
			this.score = 0;
			this.isDead = false;
			this.canRemove = false;
			this.hopsInAir = 0;
			this.isInvulnerable = false;
			
			this.abilities = new Array();
			
			this.posX = x;
			this.posY = y;
			this.posXPrev = x;
			this.posYPrev = y;
			
			this.direction = 1;
			this.directionPrev = 1;
			
			this.xVel = 0;
			this.yVel = 0;
			this.xVelPrev = 0;
			this.yVelPrev = 0;
			
			this.onGround = false;
			this.jumps = 0;
			
			this.physicsEnabled = true;
			
			this.boundingBox = new Quadrilateral();
			this.boundingBoxPrev = new Quadrilateral();
		}
		
		public function update(delta:Number):void
		{
			// Update 'previous' values
			this.xVelPrev = this.xVel;
			this.yVelPrev = this.yVel;
			
			this.posXPrev = posX;
			this.posYPrev = posY;
			
			this.directionPrev = this.direction;
			
			if(this.physicsEnabled)
			{
				this.posX += xVel;
				this.posY += yVel;
			}
			
			// Set new x and y position, clamp to integers if enabled
			this.x = GameSettings.clampToWholePixels ? int(this.posX) : this.posX;
			this.y = GameSettings.clampToWholePixels ? int(this.posY) : this.posY;
			
			if(this.onGround)
			{
				this.hopsInAir = 0;
				this.jumps = 0;
			}
		}
		
		public function getBoundingBox():Quadrilateral
		{
			return this.boundingBox.fromPositionAndSize(this.posX + this.getBoundingBoxXOffset(), this.posY, this.width, this.height);
		}
		
		public function getBoundingBoxPrev():Quadrilateral
		{
			return this.boundingBoxPrev.fromPositionAndSize(this.posXPrev + this.getBoundingBoxXOffset(), this.posYPrev, this.width, this.height);
		}
		
		public function getBoundingBoxXOffset():Number
		{
			return this.direction == -1 ? -this.width : 0;
		}
		
		public function getCenterPrev():Point
		{
			return new Point(this.posXPrev + this.getBoundingBoxXOffset() + (this.width / 2), this.posYPrev + (this.width / 2));
		}
		
		protected function getStateComposite():String
		{
			return this.stateMaster + "_" + this.stateMinor;
		}
		
		protected function updateAnimation(delta:Number):void
		{
			// Checks if direction has changed
			if(this.direction != this.directionPrev)
			{
				// Change the scale to mirror the animation properly
				this.scaleX = this.direction;
				
				// Offset the player position as needed since the origin is not centered
				this.posX += this.width * -this.direction;
			}
			
			this.lastStateComposite = this.getStateComposite();
		}
		
		public function onAttacked(attacker:Entity):void
		{
			if(attacker is EntityPlayer)
			{
				this.health--;
							
				if(this.health <= 0)
				{
					this.setDead();
					
					attacker.addScore(1);
				}
			}
		}
		
		public function setDead():void
		{
			this.isDead = true;
			this.canRemove = true;
		}
		
		public function setInvulnverable(invulnerable:Boolean):void
		{
			this.isInvulnerable = invulnerable;
		}
		
		public function isInvulnverable():Boolean
		{
			return this.isInvulnerable;
		}
		
		public function addScore(toAdd:Number):void
		{
			this.score += toAdd * this.hopsInAir;
		}
		
		public function hasAbility(ability:Ability):Boolean
		{
			return this.abilities.indexOf(ability) >= 0;
		}
		
		public function getGravityMultiplier():Number
		{
			return 1.0;
		}
	}
}
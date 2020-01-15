package lib.shoot.entity 
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import fl.motion.Color;
	
	import com.greensock.*; 
	import com.greensock.easing.*;
	
	import lib.shoot.InputManager;
	import lib.shoot.MathHelper;
	import lib.shoot.Quadrilateral;
	import flash.text.engine.TabAlignment;
	import flash.events.Event;
	
	public class EntityPlayer extends Entity 
	{
		private var invulnTimer:Timer;
		private var deathTimer:Timer;
		
		public function EntityPlayer()
		{
			this.health = 3;
			
			this.abilities.push(Ability.STOMP);
			this.abilities.push(Ability.BOUNCEBACK);
		}
		
		public override function update(delta:Number):void
		{
			// Walking, jumping, etc.
			var walkingSpeed:Number = 0.25;
			var walkingSpeedMax:Number = 1.5;
			
			var friction:Number = this.onGround ? 0.2 : 0.1;
			var controlModifier:Number = this.onGround ? 1 : 0.5;
			
			if(InputManager.inputEnabled)
			{
				// Left/right movement
				if(InputManager.isKeyDown(InputManager.Control_MoveLeft))
				{
					this.xVel -= walkingSpeed * delta * controlModifier;
					this.direction = -1;
				}
				else if(InputManager.isKeyDown(InputManager.Control_MoveRight))
				{
					this.xVel += walkingSpeed * delta * controlModifier;
					this.direction = 1;
				}
				
				// Running
				if(InputManager.isKeyDown(InputManager.Control_Run))
				{
					walkingSpeedMax *= 2;
					walkingSpeed *= 2;
					
					this.stateMinor = "SPRINT";
				}
				
				// Change this to allow the player to have double-jump, triple-jump, and so on
				var maxJumpsInAir:int = 0;
				
				// Jump
				if(InputManager.isKeyPressed(InputManager.Control_Jump) && (this.onGround || this.jumps < maxJumpsInAir + 1))
				{
					this.yVel = -2;
					this.posY -= 0.1;
					
					this.jumps++;
					this.onGround = false;
				}
			}
			
			// Noclip movement
			if(!this.physicsEnabled && !this.isDead)
			{
				if(InputManager.isKeyDown(InputManager.Control_MoveLeft))
				{
					this.posX -= 2 * delta;
				}
				if(InputManager.isKeyDown(InputManager.Control_MoveRight))
				{
					this.posX += 2 * delta;
				}
				
				if(InputManager.isKeyDown(InputManager.Control_LookUp))
				{
					this.posY -= 2 * delta;
				}
				if(InputManager.isKeyDown(InputManager.Control_Crouch))
				{
					this.posY += 2 * delta;
				}
			}
			
			// Update x velocity
			this.xVel = MathHelper.clamp(this.xVel, -walkingSpeedMax * delta, walkingSpeedMax * delta);
			this.xVel = MathHelper.moveTowardsZero(this.xVel, friction * delta);
			
			this.updateAnimation(delta);
			
			super.update(delta);
		}
		
		protected override function updateAnimation(delta:Number):void
		{
			if(this.onGround)
			{
				this.stateMaster = "GROUND";
				
				this.direction = xVel < 0 ? -1 : xVel > 0 ? 1 : this.direction;
				this.stateMinor = this.posX == this.posXPrev ? "IDLE" : xVel == 0 ? "IDLE" : "WALK";
			}
			else
			{
				this.stateMaster = "AIR";
				
				this.stateMinor = yVel < 0 ? "JUMP" : "FALL";
			}
			
			// Check if the state has changed (don't play same animation if it's already playing)
			var stateComposite = this.getStateComposite();
			
			if(this.lastStateComposite != stateComposite)
			{
				this.gotoAndPlay(stateComposite);
			}
			
			super.updateAnimation(delta);
		}
		
		public override function onAttacked(attacker:Entity):void
		{
			if(!this.isInvulnerable)
			{
				this.health--;
			}
			
			if(this.health <= 0)
			{
				this.setDead();
			}
		}
		
		public override function setDead():void
		{
			InputManager.inputEnabled = false;
			
			this.physicsEnabled = false;
			this.isDead = true;
			this.canRemove = false;
			
			this.deathTimer = new Timer(2.5 * 1000, 1);
			this.deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onActuallyDead);
			this.deathTimer.start();
			
			TweenLite.to(this, 1, {scaleX:0.01 * this.scaleX, scaleY:0.01, rotation:360});
		}
		
		private function onActuallyDead(evt:Event):void
		{
			this.canRemove = true;
		}
		
		public override function setInvulnverable(invulnerable:Boolean):void
		{
			if(!this.isInvulnerable)
			{
				this.isInvulnerable = invulnerable;
			
				var invulnTimeSeconds:Number = 1;
				var invlinTicksPerSecond:Number = 64;
				
				this.invulnTimer = new Timer((invulnTimeSeconds / invlinTicksPerSecond) * 1000, invulnTimeSeconds * invlinTicksPerSecond);
				this.invulnTimer.addEventListener(TimerEvent.TIMER, onInvulnTimerTick);
				this.invulnTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onInvulnTimerEnd);
				this.onInvulnTimerTick(null);
				this.invulnTimer.start();
			}
		}
		
		private function onInvulnTimerTick(evt:TimerEvent):void
		{
			if(this.invulnTimer.running)
			{
				if(this.alpha < 1)
				{
					this.alpha = 1;
				}
				else
				{
					this.alpha = 0.25;
				}
			}
		}
		
		private function onInvulnTimerEnd(evt:TimerEvent):void
		{
			this.isInvulnerable = false;
			
			this.transform.colorTransform.alphaMultiplier = 1;
		}
	}
}

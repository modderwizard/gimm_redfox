package lib.shoot.entity 
{
	import flash.display.MovieClip;
	
	import com.greensock.*; 
	import com.greensock.easing.*;
	
	import lib.shoot.InputManager;
	import lib.shoot.MathHelper;
	import lib.shoot.Quadrilateral;
	
	public class EntityRacoon extends Entity 
	{
		public function EntityRacoon()
		{
			this.abilities.push(Ability.TOUCH_HURT);
		}
		
		public override function update(delta:Number):void
		{
			this.updateAnimation(delta);
			
			if((this.scaleX > 0 && this.scaleX <= 0.1) || (this.scaleX < 0 && this.scaleX >= -0.1))
			{
				this.canRemove = true;
			}
			
			super.update(delta);
		}
		
		protected override function updateAnimation(delta:Number):void
		{
			// Check if the state has changed (don't play same animation if it's already playing)
			var stateComposite = this.getStateComposite();
			
			if(this.lastStateComposite != stateComposite)
			{
				this.gotoAndPlay(stateComposite);
			}
			
			super.updateAnimation(delta);
		}
		
		public override function setDead():void
		{
			this.isDead = true;
			this.physicsEnabled = false;
			TweenLite.to(this, 1, {scaleX:0.1 * this.scaleX, scaleY:0.1, rotation:360});
		}
	}
}

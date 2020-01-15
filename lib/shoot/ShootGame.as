package lib.shoot
{
	import flash.display.MovieClip
	import flash.events.Event;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import fl.VirtualCamera;
	
	import lib.shoot.entity.Entity;
	import lib.shoot.entity.EntityPlayer;
	import lib.shoot.entity.EntityRacoon;
	import lib.shoot.level.Level;
	import lib.shoot.level.LevelDataInternal;
	import lib.shoot.level.Tile;
	
	public class ShootGame extends MovieClip
	{
		private var level:Level = new Level();
		
		private var interfaceElements:Array = new Array();
		
		private var timeStart:Number = 0;
		private var framesElasped:Number = 0;
		private var fpsCurrent:Number = 0;
		
		private var pauseScreen:PauseScreen;
		private var paused:Boolean = false;
		
		public function ShootGame()
		{
			// Event listeners
			this.addEventListener(Event.ENTER_FRAME, update);
			
			this.timeStart = getTimer();
			
			this.level.load(LevelDataInternal.level1);
			
			this.restartLevel();
		}
		
		private function update(evt:Event):void
		{
			var delta:Number = 60.0 / stage.frameRate;
			var doRestart:Boolean = false;
			
			CameraManager.update(delta);
			
			// Set our position to the inverse of the Camera's position
			this.x = -CameraManager.getCameraPosition().x;
			this.y = -CameraManager.getCameraPosition().y;
			
			if(InputManager.isKeyPressed(Keyboard.ESCAPE))
			{
				if(this.paused)
				{
					this.interfaceElements.removeAt(this.interfaceElements.indexOf(this.pauseScreen));
					this.removeChild(this.pauseScreen);
					this.pauseScreen = null;
				}
				else
				{
					this.pauseScreen = new PauseScreen();
					this.addChild(this.pauseScreen);
					this.interfaceElements.push(this.pauseScreen);
				}
				
				this.paused = !this.paused;
			}
			
			if(this.level != null && !this.paused)
			{
				this.level.update(delta);
				
				for each(var entity:Entity in this.level.entitiesToAdd)
				{
					if(entity is EntityPlayer)
					{
						CameraManager.setEntityTracking(entity);
					}
					
					this.addChild(entity);
				}
				for each(entity in this.level.entitiesToRemove)
				{
					if(entity is EntityPlayer)
					{
						var deathFade:DeathFade = new DeathFade();
						this.addChild(deathFade);
						this.interfaceElements.push(deathFade);
					}
					
					this.removeChild(entity);
				}
				
				this.level.entitiesToAdd.length = 0;
				this.level.entitiesToRemove.length = 0;
			}
			
			for each(var interfaceElement:MovieClip in this.interfaceElements)
			{
				interfaceElement.x = CameraManager.getCameraPosition().x;
				interfaceElement.y = CameraManager.getCameraPosition().y;
				
				if(interfaceElement is HUD)
				{
					var hud:HUD = HUD(interfaceElement);
					
					if(CameraManager.getEntityTracking() != null)
					{
						hud.health.textHealth.text = hud.health.textHealthShadow.text = CameraManager.getEntityTracking().health;
						hud.score.textPoints.text = hud.score.textPointsShadow.text = CameraManager.getEntityTracking().score;
					}
				}
			}
			
			this.doDebugInfo();
			
			InputManager.updateForNext();
			
			// Update framerate
			var timeCurrent:Number = (getTimer() - this.timeStart) / 1000;
			this.framesElasped++;
			
			if(timeCurrent > 1)
			{
				this.fpsCurrent = this.framesElasped / timeCurrent;
				this.timeStart = getTimer();
				this.framesElasped = 0;
			}
		}
		
		public function restartLevel():void
		{
			this.removeChildren();
			this.interfaceElements.length = 0;
			
			// Add the level background
			var staticBackground:StaticBackground = new StaticBackground(1);
			this.addChild(staticBackground);
			
			// Setup the level
			var tileMovieClips:Array = this.level.setupLevel();
			for each(var tile:MovieClip in tileMovieClips)
			{
				this.addChild(tile);
			}
			
			// Interface elements
			this.interfaceElements.push(new HUD());
			this.interfaceElements.push(DebugHelper.getInstance());
			this.interfaceElements.push(new CircleFade());
			this.interfaceElements.push(new LevelSign());
			
			for each(var interfaceElement:MovieClip in this.interfaceElements)
			{
				this.addChild(interfaceElement);
			}
			
			this.interfaceElements.push(staticBackground);
		}
		
		private function doDebugInfo():void
		{
			var debugText:String = "";
			
			if(InputManager.isKeyPressed(Keyboard.NUMBER_1) && GameSettings.enableDebugHotkeys)
			{
				GameSettings.enableDebugInfo = !GameSettings.enableDebugInfo;
			}
			
			if(InputManager.isKeyPressed(Keyboard.NUMBER_2) && GameSettings.enableDebugHotkeys && CameraManager.getEntityTracking() != null)
			{
				CameraManager.getEntityTracking().yVel = CameraManager.getEntityTracking().xVel = 0;
				CameraManager.getEntityTracking().physicsEnabled = !CameraManager.getEntityTracking().physicsEnabled;
			}
			
			if(InputManager.isKeyPressed(Keyboard.NUMBER_3) && GameSettings.enableDebugHotkeys && CameraManager.getEntityTracking() != null)
			{
				var racc:EntityRacoon = new EntityRacoon();
				racc.posX = CameraManager.getEntityTracking().posX + 30;
				racc.posY = CameraManager.getEntityTracking().posY;
				this.level.addEntity(racc);
			}
			
			if(InputManager.isKeyPressed(Keyboard.NUMBER_4) && GameSettings.enableDebugHotkeys)
			{
				CameraManager.getEntityTracking().setDead();
			}
			
			if(GameSettings.enableDebugInfo)
			{
				for each(var quad:Quadrilateral in this.level.getTileHitboxes())
				{
					DebugHelper.drawQuadrilateral(quad, 0xFF0000, 1);
				}
				
				for each(var entity in this.level.getEntities())
				{
					if(entity.physicsEnabled)
					{
						// Draw bounding box and path collider
						DebugHelper.drawQuadrilateral(entity.getBoundingBox(), entity is EntityPlayer ? 0x00FF00 : 0x0000FF);
						DebugHelper.drawQuadrilateral(entity.getBoundingBoxPrev(), entity is EntityPlayer ? 0x00FF00 : 0x0000FF, 0.15);
						DebugHelper.drawQuadrilateral(Physics.entityGetPathCollision(entity), entity is EntityPlayer ? 0x00FF00 : 0x0000FF);
					}
				}
				
				debugText += "FPS: " + this.fpsCurrent.toFixed(0) + ", Entities: " + this.level.getEntities().length + "\n";
				
				if(CameraManager.getEntityTracking() != null)
				{
					debugText += "Tracking " + CameraManager.getEntityTracking() + "\n";
					debugText += "X: " + CameraManager.getEntityTracking().posX.toFixed(3) + ", Y: " + CameraManager.getEntityTracking().posY.toFixed(3) + ", Xvel: " + CameraManager.getEntityTracking().xVel.toFixed(3) + ", Yvel: " + CameraManager.getEntityTracking().yVel.toFixed(3) + "\n";
					debugText += "Facing: " + CameraManager.getEntityTracking().direction + ", On ground: " + CameraManager.getEntityTracking().onGround + ", Invulnerable: " + CameraManager.getEntityTracking().isInvulnverable() + "\n";
				}
				else
				{
					debugText += "Camera tracking entity is null!\n";
				}
			}
			
			DebugHelper.setDebugTextLeft(debugText);
		}
	}
}
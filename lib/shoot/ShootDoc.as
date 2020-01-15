package lib.shoot
{
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.ui.Keyboard;
	import flash.text.TextField;
	
	import lib.shoot.gui.GuiScreen;
	import lib.shoot.gui.GuiScreenStart;
	import lib.shoot.gui.GuiScreenOptions;
	
	import flash.system.Capabilities;
	
	public dynamic class ShootDoc extends MovieClip
	{
		private var currentScreen:GuiScreen;
		private var intro:Intro;
		
		public function ShootDoc()
		{
			this.setScreen(new GuiScreenStart());
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// Scale manually since we no longer use VirtualCamera
			this.scaleX = CameraManager.screenScale;
			this.scaleY = CameraManager.screenScale;
		}
		
		private function onAddedToStage(evt:Event):void
		{
			InputManager.initialize(this.stage);
			
			stage.scaleMode = StageScaleMode.SHOW_ALL;
		}
		
		public function setScreen(screen:GuiScreen):void
		{
			if(this.currentScreen != null)
			{
				this.removeCurrentScreen();
			}
			
			// Then change to the new screen and run it's 'startup' stuff
			this.currentScreen = screen;
			this.addChild(this.currentScreen as MovieClip);
			this.currentScreen.onOpening();
		}
		
		private function removeCurrentScreen():void
		{
			// Let the current screen run it's 'shutdown' stuff
			this.currentScreen.onClosing();
			this.removeChild(this.currentScreen as MovieClip);
		}
		
		public function playIntro():void
		{
			this.removeCurrentScreen();
			
			this.intro = new Intro();
			this.addChild(this.intro);
		}
		
		public function startGame():void
		{
			this.removeChild(this.intro);
			
			var game:ShootGame = new ShootGame();
			
			this.addChild(game);
		}
	}
}
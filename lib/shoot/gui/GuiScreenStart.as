package lib.shoot.gui
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import lib.shoot.ShootDoc;
	
	public dynamic class GuiScreenStart extends MovieClip implements GuiScreen
	{
		public function onOpening():void
		{
			this.buttonStartGame.addEventListener(MouseEvent.CLICK, startGame);
			this.buttonSettings.addEventListener(MouseEvent.CLICK, openSettings);
		}
		
		public function onClosing():void
		{
			this.buttonStartGame.removeEventListener(MouseEvent.CLICK, startGame);
			this.buttonSettings.removeEventListener(MouseEvent.CLICK, openSettings);
		}
		
		private function startGame(evt:MouseEvent):void
		{
			(this.parent as ShootDoc).playIntro();
		}
		
		private function openSettings(evt:MouseEvent):void
		{
			(this.parent as ShootDoc).setScreen(new GuiScreenOptions());
		}
	}
}

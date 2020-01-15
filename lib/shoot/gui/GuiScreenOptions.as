package lib.shoot.gui
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import lib.shoot.GameSettings;
	import lib.shoot.ShootDoc;
	
	public class GuiScreenOptions extends MovieClip implements GuiScreen
	{
		public function onOpening():void
		{
			this.buttonBackToTitle.addEventListener(MouseEvent.CLICK, onMouseClick);
			//this.buttonEnableSound.addEventListener(MouseEvent.CLICK, onMouseClick);
			this.buttonEnableDebugHotkeys.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			this.updateValueLabels();
		}
		
		public function onClosing():void
		{
			this.buttonBackToTitle.removeEventListener(MouseEvent.CLICK, onMouseClick);
			//this.buttonEnableSound.removeEventListener(MouseEvent.CLICK, onMouseClick);
			this.buttonEnableDebugHotkeys.removeEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		private function onMouseClick(evt:MouseEvent):void
		{
			if(evt.target == this.buttonBackToTitle) // Return to title screen
			{
				(this.parent as ShootDoc).setScreen(new GuiScreenStart());
			}
			if(evt.target == this.buttonEnableSound) // Toggle enable gamepad
			{
				GameSettings.enableSound = !GameSettings.enableSound;
				this.updateValueLabels();
			}
			if(evt.target == this.buttonEnableDebugHotkeys) // Toggle enable debug hotkeys
			{
				GameSettings.enableDebugHotkeys = !GameSettings.enableDebugHotkeys;
				this.updateValueLabels();
			}
		}
		
		private function updateValueLabels():void
		{
			this.valueEnableGamepad.gotoAndStop(GameSettings.enableSound ? 2 : 1);
			this.valueEnableDebugHotkeys.gotoAndStop(GameSettings.enableDebugHotkeys ? 2 : 1);
		}
	}
}

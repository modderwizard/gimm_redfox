package lib.shoot
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Intro extends MovieClip
	{
		public function Intro()
		{
			this.addEventListener(MouseEvent.CLICK, endIntro);
		}
		
		private function endIntro(evt:Event = null):void
		{
			this.removeEventListener(MouseEvent.CLICK, endIntro);
			
			this.stop();

			if(this.parent is ShootDoc)
			{
				(this.parent as ShootDoc).startGame();
			}
		}
	}
}
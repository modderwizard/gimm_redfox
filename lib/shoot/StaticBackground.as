package lib.shoot
{
	import flash.display.MovieClip;

	public class StaticBackground extends MovieClip
	{
		public function StaticBackground(id:int)
		{
			this.gotoAndPlay(id);
		}
	}
}
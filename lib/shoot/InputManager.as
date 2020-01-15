package lib.shoot
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class InputManager
	{
		public static var inputEnabled:Boolean = false;
		
		public static const Control_MoveLeft:uint = Keyboard.LEFT;
		public static const Control_MoveRight:uint = Keyboard.RIGHT;
		public static const Control_LookUp:uint = Keyboard.UP;
		public static const Control_Crouch:uint = Keyboard.DOWN;
		public static const Control_Run:uint = Keyboard.SHIFT;
		public static const Control_Jump:uint = Keyboard.SPACE;
		
		private static var keyStatesCurrent:Array = new Array();
		private static var keyStatesPrevious:Array = new Array();
		
		public static function initialize(stage:Stage):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		// Every frame, push the current key states into the previous key states array
		public static function updateForNext():void
		{
			keyStatesPrevious = keyStatesCurrent;
			
			// Change 'press' to 'down'
			for(var i:uint = 0; i < keyStatesCurrent.length; i++)
			{
				if(keyStatesCurrent[i] == 1)
				{
					keyStatesCurrent[i] = 2;
				}
			}
		}
		
		private static function onKeyDown(evt:KeyboardEvent):void
		{
			if(keyStatesCurrent[evt.keyCode] == null)
			{
				keyStatesCurrent[evt.keyCode] = 1;
			}
		}
		
		private static function onKeyUp(evt:KeyboardEvent):void
		{
			keyStatesCurrent[evt.keyCode] = null;
		}
		
		// Returns true if the key is being held down
		public static function isKeyDown(key:uint):Boolean
		{
			return keyStatesCurrent[key] != null;
		}
		
		// Returns true for the first frame that a key is held down
		public static function isKeyPressed(key:uint):Boolean
		{
			return keyStatesCurrent[key] == 1;
		}
		
		// Returns true for the first frame that a key is released
		public static function isKeyReleased(key:uint):Boolean
		{
			return keyStatesCurrent[key] == null && keyStatesPrevious[key] != null;
		}
	}
}
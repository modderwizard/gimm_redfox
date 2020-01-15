package lib.shoot
{	
	public class MathHelper
	{
		public static function wrap(value:Number, min:Number, max:Number):Number
		{
            var newValue:Number = value;

            while(newValue < min)
            {
                newValue += max;
            }
            while(newValue > max)
            {
                newValue -= max;
            }

            return newValue;
		}
		
		public static function clamp(value:Number, min:Number, max:Number):Number
        {
            return value < min ? min : value > max ? max : value;
        }
		
		public static function moveTowardsZero(value:Number, change:Number):Number
        {
            var newValue:Number = value + ((value < 0) ? change : (value > 0) ? -change : 0);
			
			if((newValue <= 0 && value >= 0) || (newValue >= 0 && value <= 0))
			{
				newValue = 0;
			}
			
			return newValue;
        }
		
		public static function isInRange(value:Number, min:Number, max:Number, minInclusive:Boolean = true, maxInclusive:Boolean = true)
		{
			var fitsMin:Boolean = minInclusive ? value >= min : value > min;
			var fitsMax:Boolean = maxInclusive ? value <= max : value < max;
			
			return fitsMin && fitsMax;
		}
		
		public static function isNumberInvalid(value:Number):Boolean
		{
			return value == Number.POSITIVE_INFINITY || value == Number.NEGATIVE_INFINITY || isNaN(value);
		}
	}
}
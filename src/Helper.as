package  
{
	/**
	 * ...
	 * @author Ittipon
	 */
	public class Helper 
	{
		// Random between 2 number
		public static function randomRange(minNum:Number, maxNum:Number):Number   
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);  
		}
	}

}
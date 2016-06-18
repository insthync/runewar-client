package gameplay 
{
	/**
	 * ...
	 * @author Ittipon
	 */
	public class CharacterIndex 
	{
		public static const INDEX_ARCHER:int = 0;
		public static const INDEX_ASSASIN:int = 1;
		public static const INDEX_FIGHTER:int = 2;
		public static const INDEX_KNIGHT:int = 3;
		public static const INDEX_HERMIT:int = 4;
		public static const INDEX_MAGE:int = 5;
		public static const INDEX_TOTAL:int = 6;
		public static function random():int {
			var idx:int = Math.round(Math.random() * (CharacterIndex.INDEX_TOTAL - 1));
			if (idx > CharacterIndex.INDEX_TOTAL - 1) 
				idx = CharacterIndex.INDEX_TOTAL - 1;
			if (idx < 0)
				idx = 0;
			return idx;
		}
	}

}
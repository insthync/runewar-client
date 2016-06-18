package assets 
{
	import flash.utils.Dictionary;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class CharacterTextureHelper 
	{
		// Index for each texture atlas
		public static const ANIM_IDLE:int = 0;
		public static const ANIM_RUN:int = 1;
		public static const ANIM_ATTACK:int = 2;
		// Animation in lobby scene
		public static const ANIM_LOBBY:int = 3;
		// Index for each character texture atlas
		
		public static const CHAR_ARCHER:int = 0;
		public static const CHAR_ASSASIN:int = 1;
		public static const CHAR_FIGHTER:int = 2;
		public static const CHAR_KNIGHT:int = 3;
		public static const CHAR_HERMIT:int = 4;
		public static const CHAR_MAGE:int = 5;
		
		public static var list_avatars_path:Array;
		public static var list_skill_path:Array;
		
		public static const runeTextureName:Array = new Array("Archer", "Assasin", "Fighter", "Knight", "Hermit", "Mage");
		
		public static var list_avatars_textures:Dictionary = new Dictionary();
		public static var list_avatars_icon_textures:Dictionary = new Dictionary();
		public static var list_avatars_status_textures:Dictionary = new Dictionary();
		public static var list_skills_icon_textures:Dictionary = new Dictionary();
	}

}
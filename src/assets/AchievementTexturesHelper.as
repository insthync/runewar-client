package assets 
{
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class AchievementTexturesHelper 
	{
		[Embed(source="../../media/textures/Achievement_Set01.xml", mimeType = "application/octet-stream")]
		private static const AchievementAssetData:Class;
		
		[Embed(source="../../media/textures/Achievement_Set01.png")]
		private static const AchievementAssetTexture:Class;
		
		private static const _d:XML = XML(new AchievementAssetData());
		public static function getTextureAtlas():TextureAtlas {
			return new TextureAtlas(Texture.fromBitmap(new AchievementAssetTexture(), false), _d);
		}
	}

}
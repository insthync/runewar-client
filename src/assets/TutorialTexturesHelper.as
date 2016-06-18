package assets 
{
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class TutorialTexturesHelper 
	{
		[Embed(source="../../media/textures/Tutorial_Sprite.xml", mimeType = "application/octet-stream")]
		private static const TutorialAssetData:Class;
		
		[Embed(source="../../media/textures/Tutorial_Sprite.png")]
		private static const TutorialAssetTexture:Class;
		
		private static const _d:XML = XML(new TutorialAssetData());
		public static function getTextureAtlas():TextureAtlas {
			return new TextureAtlas(Texture.fromBitmap(new TutorialAssetTexture(), false), _d);
		}
	}

}
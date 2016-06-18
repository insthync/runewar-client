package assets 
{
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class CountDownTexturesHelper 
	{
		[Embed(source="../../media/textures/countdown_number/number.xml", mimeType = "application/octet-stream")]
		private static const CountDownAssetData:Class;
		
		[Embed(source="../../media/textures/countdown_number/number.png")]
		private static const CountDownAssetTexture:Class;
		
		private static const _dCountdown:XML = XML(new CountDownAssetData());
		public static function getTextureAtlas():TextureAtlas {
			return new TextureAtlas(Texture.fromBitmap(new CountDownAssetTexture(), false), _dCountdown);
		}
	}

}
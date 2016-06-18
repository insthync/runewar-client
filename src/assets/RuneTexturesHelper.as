package assets 
{
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class RuneTexturesHelper 
	{
		[Embed(source="../../media/textures/runes/runes_sprite.xml", mimeType = "application/octet-stream")]
		private static const RuneAssetData:Class;
		
		[Embed(source="../../media/textures/runes/runes_sprite.png")]
		private static const RuneAssetTexture:Class;
		
		private static const _d:XML = XML(new RuneAssetData());
		public static function getTextureAtlas():TextureAtlas {
			return new TextureAtlas(Texture.fromBitmap(new RuneAssetTexture(), false), _d);
		}
	}

}
package assets 
{
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class EffectsTexturesHelper 
	{
		[Embed(source="../../media/textures/effects/effect_sprite.xml", mimeType = "application/octet-stream")]
		private static const EffectsAssetData1:Class;
		
		[Embed(source="../../media/textures/effects/effect_sprite.png")]
		private static const EffectsAssetTexture1:Class;
		
		private static const _d1:XML = XML(new EffectsAssetData1());
		private static const _ta1:TextureAtlas = new TextureAtlas(Texture.fromBitmap(new EffectsAssetTexture1(), false), _d1);
		public static function getTextureAtlas1():TextureAtlas {
			return _ta1;
		}
		
		[Embed(source="../../media/textures/effects/X5skill_Sprite.xml", mimeType = "application/octet-stream")]
		private static const EffectsAssetData2:Class;
		
		[Embed(source="../../media/textures/effects/X5skill_Sprite.png")]
		private static const EffectsAssetTexture2:Class;
		
		private static const _d2:XML = XML(new EffectsAssetData2());
		private static const _ta2:TextureAtlas = new TextureAtlas(Texture.fromBitmap(new EffectsAssetTexture2(), false), _d2);
		public static function getTextureAtlas2():TextureAtlas {
			return _ta2;
		}
	}

}
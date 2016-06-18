package assets 
{
	import flash.display.Bitmap;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class GameTexturesHelper
	{
		// Assets as texture atlas
		[Embed(source="../../media/textures/environments/environments_sprite.xml", mimeType = "application/octet-stream")]
		private static const GameAssetData:Class;
		
		[Embed(source="../../media/textures/environments/environments_sprite.png")]
		private static const GameAssetTexture:Class;
		
		[Embed(source="../../media/textures/environments/CannonSprite.xml", mimeType = "application/octet-stream")]
		private static const CannonAssetData:Class;
		
		[Embed(source="../../media/textures/environments/CannonSprite.png")]
		private static const CannonAssetTexture:Class;
		
		// Another textures
		[Embed(source="../../media/textures/BG_Fight.jpg")]
		private static const BackgroundFight:Class;
		
		// Assets for game environment atlas
		private static const _dEnv:XML = XML(new GameAssetData());
		public static function getEnvTextureAtlas():TextureAtlas {
			return new TextureAtlas(Texture.fromBitmap(new GameAssetTexture(), false), _dEnv);
		}
		
		// Assets for cannon atlas
		private static const _dCannon:XML = XML(new CannonAssetData());
		public static function getCannonTextureAtlas():TextureAtlas {
			return new TextureAtlas(Texture.fromBitmap(new CannonAssetTexture(), false), _dCannon);
		}
		
		public static function getTexture(name:String):Texture {
			var texture:Texture;
			var data:Object = new GameTexturesHelper[name]();
			if (data is Bitmap)
				texture = Texture.fromBitmap(data as Bitmap, false);
			if (data is ByteArray)
				texture = Texture.fromAtfData(data as ByteArray);
			
			return texture;
		}
	}

}
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
	public class LobbyTexturesHelper
	{
		// Assets as texture atlas
		[Embed(source="../../media/textures/GUI_Sprite.xml", mimeType = "application/octet-stream")]
		private static const LobbyAssetData:Class;
		
		[Embed(source="../../media/textures/GUI_Sprite.png")]
		private static const LobbyAssetTexture:Class;
		
		[Embed(source="../../media/textures/Shop_Sprite.xml", mimeType="application/octet-stream")]
		private static const ShopAssetData:Class;
		
		[Embed(source="../../media/textures/Shop_Sprite.png")]
		private static const ShopAssetTexture:Class;
		
		[Embed(source="../../media/textures/ArenaGUI_Sprite.xml", mimeType="application/octet-stream")]
		private static const ArenaAssetData:Class;
		
		[Embed(source="../../media/textures/ArenaGUI_Sprite.png")]
		private static const ArenaAssetTexture:Class;
		
		// Another textures
		[Embed(source="../../media/textures/BG_Lobby.jpg")]
		private static const BackgroundLobby:Class;
		
		[Embed(source = "../../media/textures/BG_Arena.jpg")]
		private static const BackgroundArena:Class;
		
		[Embed(source = "../../media/textures/icon.png")]
		private static const Icon:Class;
		
		public static var list_profile_textures:Dictionary = new Dictionary();
		
		// Variable and method for Lobby Texture Atlas
		private static const _dLobby:XML = XML(new LobbyAssetData());
		public static function getTextureAtlasLobby():TextureAtlas {
			return new TextureAtlas(Texture.fromBitmap(new LobbyAssetTexture(), false), _dLobby);
		}
		
		// Variable and method for Lobby - Shop Texture Atlas
		private static const _dShop:XML = XML(new ShopAssetData());
		public static function getTextureAtlasShop():TextureAtlas {
			return new TextureAtlas(Texture.fromBitmap(new ShopAssetTexture(), false), _dShop);
		}
		
		// Variable and method for Lobby - Arena Texture Atlas
		private static const _dArena:XML = XML(new ArenaAssetData());
		public static function getTextureAtlasArena():TextureAtlas {
			return new TextureAtlas(Texture.fromBitmap(new ArenaAssetTexture(), false), _dArena);
		}
		
		public static function getTexture(name:String):Texture {
			var texture:Texture;
			var data:Object = new LobbyTexturesHelper[name]();
			if (data is Bitmap)
				texture = Texture.fromBitmap(data as Bitmap, false);
			if (data is ByteArray)
				texture = Texture.fromAtfData(data as ByteArray);
			
			return texture;
		}
	}

}
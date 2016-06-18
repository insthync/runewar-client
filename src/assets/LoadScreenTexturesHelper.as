package assets 
{
	import flash.display.Bitmap;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import starling.textures.Texture;
	
	public class LoadScreenTexturesHelper 
	{
		[Embed(source="../../media/textures/logo.png")]
		private static const Logo:Class;
		
		[Embed(source="../../media/textures/preloader.png")]
		private static const Preloader:Class;
		
		// Another textures
		[Embed(source="../../media/textures/BG_Loading.jpg")]
		private static const BackgroundLoading:Class;
		
		public static function getTexture(name:String):Texture {
			var texture:Texture;
			var data:Object = new LoadScreenTexturesHelper[name]();
			if (data is Bitmap)
				texture = Texture.fromBitmap(data as Bitmap, false);
			if (data is ByteArray)
				texture = Texture.fromAtfData(data as ByteArray);
			
			return texture;
		}
		
	}

}
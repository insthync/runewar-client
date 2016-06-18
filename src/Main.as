package 
{
	import assets.CharacterTextureHelper;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import starling.core.Starling;
	import starling.events.ResizeEvent;
	import scene.SceneManager;
	import flash.system.Security;
	
	/**
	 * ...
	 * @author Ittipon
	 */
	[SWF(frameRate=60, backgroundColor="#000000", wmode="direct")]
	public class Main extends Sprite 
	{
		public static var userid:int;
		public static var token:String;
		public static var serviceurl:String;
		public static var server_ip:String;
		public static var server_port:int;
		public static var loaderContext:LoaderContext;
		// An assets
		[Embed(source="../media/fonts/00layiji_TarMineTine1.ttf", embedAsCFF="false", fontFamily="RWFont")]
		private static const Font:Class;
		private var instance:Starling;
		private var shapeScaler:Shape;
		private var originalViewPort:Rectangle;
		public function Main():void 
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			
			// Real init
			try {
				ExternalInterface.call("showRW");
			} catch (ex:Error) {
				trace(ex);
			}
			
			var gameVars:Object = loaderInfo.parameters;
			if (gameVars.userid != null
				&& gameVars.token != null
				&& gameVars.serviceurl != null
				&& gameVars.server_ip != null
				&& gameVars.server_port != null
				&& gameVars.crossdomainurl != null
				&& gameVars.list_avatars_path != null
				&& gameVars.list_skill_path != null
				&& gameVars.list_player_exp != null)
			{
				userid = gameVars.userid;
				token = gameVars.token;
				serviceurl = gameVars.serviceurl;
				server_ip = gameVars.server_ip;
				server_port = gameVars.server_port;
				Security.loadPolicyFile(gameVars.crossdomainurl);
				CharacterTextureHelper.list_avatars_path = gameVars.list_avatars_path.split(',');
				CharacterTextureHelper.list_skill_path = gameVars.list_skill_path.split(',');
				GlobalVariables.player_exp = gameVars.list_player_exp.split(',');
				initApp();
			} else {
				Main.server_ip = "127.0.0.1";
				Main.server_port = 5501;
				Main.serviceurl = "http://127.0.0.1/runewar/";
				Security.loadPolicyFile("http://127.0.0.1/crossdomain.xml");
				CharacterTextureHelper.list_avatars_path = "http://127.0.0.1/runewar/xml/list_char_archer_avatar.xml,http://127.0.0.1/runewar/xml/list_char_assasin_avatar.xml,http://127.0.0.1/runewar/xml/list_char_fighter_avatar.xml,http://127.0.0.1/runewar/xml/list_char_knight_avatar.xml,http://127.0.0.1/runewar/xml/list_char_hermit_avatar.xml,http://127.0.0.1/runewar/xml/list_char_mage_avatar.xml".split(',');
				CharacterTextureHelper.list_skill_path = "http://127.0.0.1/runewar/xml/list_char_archer_skill.xml,http://127.0.0.1/runewar/xml/list_char_assasin_skill.xml,http://127.0.0.1/runewar/xml/list_char_fighter_skill.xml,http://127.0.0.1/runewar/xml/list_char_knight_skill.xml,http://127.0.0.1/runewar/xml/list_char_hermit_skill.xml,http://127.0.0.1/runewar/xml/list_char_mage_skill.xml".split(',');
				GlobalVariables.player_exp = "0,83,257,533,921,1433,2083,2884,3853,5007,6365,7949,9782,11889,14300,17046,20161,23684,27657,32127,37145,42769,49063,56091,63933,72673,82403,93227,105258,118621,133454,149910,168157,188381,210787".split(',');
				initApp();
				
				
				// Error warning
				if (gameVars.userid == null) {
					try {
						ExternalInterface.call("alertFromFlash", "userid is empty !!");
					} catch (ex:Error) {
						trace(ex);
					}
				}
				if (gameVars.token == null) {
					try {
						ExternalInterface.call("alertFromFlash", "token is empty !!");
					} catch (ex:Error) {
						trace(ex);
					}
				}
				if (gameVars.serviceurl == null) {
					try {
						ExternalInterface.call("alertFromFlash", "serviceurl is empty !!");
					} catch (ex:Error) {
						trace(ex);
					}
				}
				if (gameVars.crossdomainurl == null) {
					try {
						ExternalInterface.call("alertFromFlash", "crossdomainurl is empty !!");
					} catch (ex:Error) {
						trace(ex);
					}
				}
				if (gameVars.list_avatars_path == null) {
					try {
						ExternalInterface.call("alertFromFlash", "list_avatars_path is empty !!");
					} catch (ex:Error) {
						trace(ex);
					}
				}
				if (gameVars.list_skill_path == null) {
					try {
						ExternalInterface.call("alertFromFlash", "list_skill_path is empty !!");
					} catch (ex:Error) {
						trace(ex);
					}
				}
				if (gameVars.list_player_exp == null) {
					try {
						ExternalInterface.call("alertFromFlash", "list_player_exp is empty !!");
					} catch (ex:Error) {
						trace(ex);
					}
				}
				try {
					ExternalInterface.call("alertFromFlash", "Error occurs !!");
				} catch (ex:Error) {
					trace(ex);
				}
			}
		}
		
		private function initApp():void {
			try {
				loaderContext = new LoaderContext(true);
				originalViewPort = new Rectangle(0,0,GlobalVariables.screenWidth,GlobalVariables.screenHeight);
				shapeScaler = new Shape();
				shapeScaler.graphics.beginFill(0);
				shapeScaler.graphics.drawRect(originalViewPort.x, originalViewPort.y, originalViewPort.width, originalViewPort.height);
				shapeScaler.graphics.endFill();
				instance = new Starling(SceneManager, stage, originalViewPort, null, "auto", "baseline");
				instance.antiAliasing = 0;
				//instance.showStats = true;
				instance.start();
				Starling.current.stage.addEventListener(ResizeEvent.RESIZE, starlingStageResizeListener);
				starlingStageResize(stage.stageWidth, stage.stageHeight);
			} catch (ex:Error) {
				try {
					ExternalInterface.call("alertFromFlash", ex);
				} catch (err:Error) {
					trace(ex);
					trace(err);
				}
			}
		}
 
		private function starlingStageResizeListener(evt:ResizeEvent):void {
			starlingStageResize(evt.width, evt.height);
		}
 
		private function starlingStageResize(_width:Number, _height:Number):void {
			shapeScaler.width = _width;
			shapeScaler.height = _height;
 
			// choose the larger scale property and match the other to it;
			( shapeScaler.scaleX < shapeScaler.scaleY ) ? shapeScaler.scaleY = shapeScaler.scaleX : shapeScaler.scaleX = shapeScaler.scaleY;
 
			// choose the smaller scale property and match the other to it;
			( shapeScaler.scaleX > shapeScaler.scaleY ) ? shapeScaler.scaleY = shapeScaler.scaleX : shapeScaler.scaleX = shapeScaler.scaleY;
 
			Starling.current.viewPort = new Rectangle((_width - shapeScaler.width)/2,(_height - shapeScaler.height)/2,shapeScaler.width,shapeScaler.height);
 
			// choose the smaller scale property and match the other to it;
 
			//Uncommenting these lines destroys the scaling capability completely, does not keep things in perspective...
			//Starling.current.stage.stageWidth = shapeScaler.width;
			//Starling.current.stage.stageHeight = shapeScaler.height;
 
			trace('stage resized to:', _width,_height,' and viewPort resized to',shapeScaler.width,shapeScaler.height);
		}
	}
	
}
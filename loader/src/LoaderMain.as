package 
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLVariables;
	import flash.system.Security;
	/**
	 * ...
	 * @author 
	 */
	public class LoaderMain extends Sprite 
	{
		private var loader:Loader;
		private var requester:URLRequest;
		public function LoaderMain():void 
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			if (stage) initLoader();
			else addEventListener(Event.ADDED_TO_STAGE, initLoader);
		}
		private function initLoader(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, initLoader);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.HIGH;
			var gameVars:Object = loaderInfo.parameters;
			var flashvars:URLVariables;
			if (gameVars.filepath != null 
				&& gameVars.userid != null 
				&& gameVars.token != null 
				&& gameVars.serviceurl != null 
				&& gameVars.server_ip != null
				&& gameVars.server_port != null
				&& gameVars.crossdomainurl != null 
				&& gameVars.list_avatars_path != null 
				&& gameVars.list_skill_path != null 
				&& gameVars.list_player_exp != null)
			{
				flashvars = new URLVariables();
				loader = new Loader();
				
				flashvars.userid = gameVars.userid;
				flashvars.token = gameVars.token;
				flashvars.serviceurl = gameVars.serviceurl;
				flashvars.server_ip = gameVars.server_ip;
				flashvars.server_port = gameVars.server_port;
				flashvars.crossdomainurl = gameVars.crossdomainurl;
				flashvars.list_avatars_path = gameVars.list_avatars_path;
				flashvars.list_skill_path = gameVars.list_skill_path;
				flashvars.list_player_exp = gameVars.list_player_exp;
				
				requester = new URLRequest(gameVars.filepath + "?" + flashvars.toString());
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onRunewarComplete);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onRunewarProgress);
				loader.load(requester);
			} else {
				// Error warning
				/*
				// Test
				flashvars = new URLVariables();
				flashvars.filepath = "http://61.91.229.207/swf/runewar.swf";
				flashvars.userid = 6;
				flashvars.token = "97496779dd59f180c7e7d2b9cd637376";
				flashvars.server_ip = "61.91.229.207";
				flashvars.server_port = 5501;
				flashvars.serviceurl = "http://61.91.229.207/";
				flashvars.crossdomainurl = "http://61.91.229.207/crossdomain.xml";
				flashvars.list_avatars_path = "http://61.91.229.207/xml/list_char_archer_avatar.xml,http://61.91.229.207/xml/list_char_assasin_avatar.xml,http://61.91.229.207/xml/list_char_fighter_avatar.xml,http://61.91.229.207/xml/list_char_knight_avatar.xml,http://61.91.229.207/xml/list_char_hermit_avatar.xml,http://61.91.229.207/xml/list_char_mage_avatar.xml";
				flashvars.list_skill_path = "http://61.91.229.207/xml/list_char_archer_skill.xml,http://61.91.229.207/xml/list_char_assasin_skill.xml,http://61.91.229.207/xml/list_char_fighter_skill.xml,http://61.91.229.207/xml/list_char_knight_skill.xml,http://61.91.229.207/xml/list_char_hermit_skill.xml,http://61.91.229.207/xml/list_char_mage_skill.xml";
				flashvars.list_player_exp = "0,83,257,533,921,1433,2083,2884,3853,5007,6365,7949,9782,11889,14300,17046,20161,23684,27657,32127,37145,42769,49063,56091,63933";
				
				trace(flashvars.toString());
				loader = new Loader();
				requester = new URLRequest("http://61.91.229.207/swf/runewar.swf?" + flashvars.toString());
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onRunewarComplete);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onRunewarProgress);
				loader.load(requester);
				*/
				if (gameVars.filepath == null) {
					try {
						ExternalInterface.call("alertFromFlash", "filepath is empty !!");
					} catch (ex:Error) {
						trace(ex);
					}
				}
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
					ExternalInterface.call("alertFromFlash", "Loading failed !!");
				} catch (ex:Error) {
					trace(ex);
				}
			}
			
		}
		private function onRunewarProgress(e:ProgressEvent):void 
		{
			trace("Rune War - Loading : " + e.bytesLoaded + "/" + e.bytesTotal);
			try {
				ExternalInterface.call("contentLoadPC", "Contents Loading... (" + e.bytesLoaded + "/" + e.bytesTotal + ")");
			} catch (ex:Error) {
				trace(ex);
			}
		}
		private function onRunewarComplete(e:Event):void 
		{
			addChild(loader);
		}
	}
	
}
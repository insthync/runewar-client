package service 
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import player.PlayerInformation;
	import scene.SceneManager;
	/**
	 * ...
	 * @author 
	 */
	public class GeneralService extends ServiceBase
	{
		public function GeneralService(sceneMgr:SceneManager) 
		{
			super(sceneMgr);
		}
		
		public function initPublicProfileLoader(userID:int, finishFunc:Function):void {
			super.init();
			
			requestVars.userid = userID;
			
			request.url = Main.serviceurl + "user_general_public.php";
			request.data = requestVars;
			request.method = URLRequestMethod.GET;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					var info:Object = jsonObj.info as Object;
					finishFunc(new PlayerInformation(PlayerInformation.MODE_LOBBY, info));
				} else {
					// Error
				}
			});
		}
	}

}
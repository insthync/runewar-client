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
	 * @author Ittipon
	 */
	public class ArenaService extends ServiceBase
	{
		public function ArenaService(sceneMgr:SceneManager) 
		{
			super(sceneMgr);
		}
		
		public function initArenaLoader(userInfo:PlayerInformation):void {
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			
			request.url = Main.serviceurl + "arena.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					var targets:Array = jsonObj.targets as Array;
					var isTutorial:Boolean = jsonObj.isTutorial as Boolean;
					sceneMgr.initSceneLoadingArena(userInfo, targets, isTutorial);
					sceneMgr.CurrentState = SceneManager.STATE_LOADING_ARENA;
				} else {
					// Error
				}
			});
		}
	}

}
package gameload 
{
	import player.PlayerInformation;
	import scene.SceneManager;
	import starling.events.EnterFrameEvent;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class LoadingLobbyScene extends LoadingScene
	{
		private var userInfo:PlayerInformation;
		private var friends:Array;
		private var friendsInfo:Vector.<PlayerInformation>;
		private var isTutorial:Boolean;
		public function LoadingLobbyScene(sceneMgr:SceneManager, userInfo:PlayerInformation, friends:Array, isTutorial:Boolean = false) 
		{
			super(sceneMgr);
			this.userInfo = userInfo;
			this.friends = friends;
			this.isTutorial = isTutorial;
			friendsInfo = new Vector.<PlayerInformation>();
			friendsInfo.length = friends.length;
			for (var i:int = 0; i < friendsInfo.length; ++i) {
				friendsInfo[i] = new PlayerInformation(PlayerInformation.MODE_LOBBY, friends[i]);
			}
		}
		
		public override function start():void {
			super.start();
		}
		
		private function friendsLoaded():Boolean {
			for (var i:int = 0; i < friendsInfo.length; ++i) {
				if (friendsInfo[i] == null || !friendsInfo[i].Loaded)
					return false;
			}
			return true;
		}
		
		protected override function loading(e:EnterFrameEvent):void {
			super.loading(e);
			if (Loaded) {
				// Go to lobby scene
				Manager.initScenePlayingLobby(userInfo, friendsInfo, isTutorial);
				Manager.CurrentState = SceneManager.STATE_PLAYING_LOBBY;
			}
			loaded = userInfo.Loaded && friendsLoaded();
		}
	}

}
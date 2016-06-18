package gameload 
{
	import player.PlayerInformation;
	import scene.SceneManager;
	import starling.events.EnterFrameEvent;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class LoadingArenaScene extends LoadingScene
	{
		private var userInfo:PlayerInformation;
		private var targets:Array;
		private var targetsInfo:Vector.<PlayerInformation>;
		private var isTutorial:Boolean;
		public function LoadingArenaScene(sceneMgr:SceneManager, userInfo:PlayerInformation, targets:Array, isTutorial:Boolean = false) 
		{
			super(sceneMgr);
			this.userInfo = userInfo;
			this.targets = targets;
			this.isTutorial = isTutorial;
			targetsInfo = new Vector.<PlayerInformation>();
			targetsInfo.length = targets.length;
			for (var i:int = 0; i < targetsInfo.length; ++i) {
				targetsInfo[i] = new PlayerInformation(PlayerInformation.MODE_LOBBY, targets[i]);
			}
		}
		
		public override function start():void {
			super.start();
		}
		
		private function targetsLoaded():Boolean {
			for (var i:int = 0; i < targetsInfo.length; ++i) {
				if (targetsInfo[i] == null || !targetsInfo[i].Loaded)
					return false;
			}
			return true;
		}
		
		protected override function loading(e:EnterFrameEvent):void {
			super.loading(e);
			if (Loaded) {
				// Go to arena scene
				Manager.initScenePlayingArena(userInfo, targetsInfo, isTutorial);
				Manager.CurrentState = SceneManager.STATE_PLAYING_ARENA;
			}
			loaded = targetsLoaded();
		}
	}

}
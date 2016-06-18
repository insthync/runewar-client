package gameload 
{
	import player.PlayerInformation;
	import scene.SceneManager;
	import starling.events.EnterFrameEvent;
	import gameplay.GameModes;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class LoadingGameScene extends LoadingScene
	{
		private var battleid:int;
		private var atkInfo:PlayerInformation;
		private var defInfo:PlayerInformation;
		private var gameMode:int;
		private var isTutorial:Boolean;
		public function LoadingGameScene(sceneMgr:SceneManager, battleid:int, atkInfo:PlayerInformation, defInfo:PlayerInformation, gameMode:int, isTutorial:Boolean = false) 
		{
			super(sceneMgr);
			this.battleid = battleid;
			this.atkInfo = atkInfo;
			this.defInfo = defInfo;
			this.gameMode = gameMode;
			this.isTutorial = isTutorial;
		}
		
		public override function start():void {
			super.start();
		}
		
		protected override function loading(e:EnterFrameEvent):void {
			super.loading(e);
			if (Loaded) {
				// Go to battle scene
				var playersInfo:Vector.<PlayerInformation> = new Vector.<PlayerInformation>();
				playersInfo.length = 2;
				playersInfo[0] = atkInfo;
				playersInfo[1] = defInfo;
				Manager.initScenePlayingBattle(battleid, playersInfo, gameMode, isTutorial);
				Manager.CurrentState = SceneManager.STATE_PLAYING_BATTLE;
			}
			loaded = atkInfo.Loaded && defInfo.Loaded;
		}
	}

}
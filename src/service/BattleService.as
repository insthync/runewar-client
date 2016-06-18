package service
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import gameplay.GameModes;
	import gameplay.UIFightResult;
	import scene.SceneManager;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class BattleService extends ServiceBase
	{
		public static const BATTLE_RESULT_FLAG_WIN:int = 0;
		public static const BATTLE_RESULT_FLAG_LOSE:int = 1;
		public static const BATTLE_RESULT_FLAG_DRAW:int = 2;
		public function BattleService(sceneMgr:SceneManager) 
		{
			super(sceneMgr);
		}
		
		public function initBattleStart(defenderid:int):void {
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			requestVars.defenderid = defenderid;
			
			request.url = Main.serviceurl + "battle_start.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					var battleid:int = jsonObj.battleid as int;
					var attacker:Object = jsonObj.attacker as Object;
					var defender:Object = jsonObj.defender as Object;
					var isTutorial:Boolean = jsonObj.isTutorial as Boolean;
					sceneMgr.initSceneLoadingBattle(battleid, attacker, defender, GameModes.SINGLEPLAYER, isTutorial);
					sceneMgr.CurrentState = SceneManager.STATE_LOADING_BATTLE;
				} else {
					// Error
				}
			});
		}
		
		public function initBattleStartOnline(attackerid:int, defenderid:int, mode:int):void {
			if (mode == GameModes.SINGLEPLAYER)
				return;
				
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			requestVars.attackerid = attackerid;
			requestVars.defenderid = defenderid;
			
			request.url = Main.serviceurl + "battle_start_online.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					var attacker:Object = jsonObj.attacker as Object;
					var defender:Object = jsonObj.defender as Object;
					sceneMgr.initSceneLoadingBattle(0, attacker, defender, mode);
					sceneMgr.CurrentState = SceneManager.STATE_LOADING_BATTLE;
				} else {
					// Error
				}
			});
		}
		
		public function initBattleEnd(battleid:int, attackerkills:int, defenderkills:int, result_flag:int, ui:UIFightResult):void {
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			requestVars.battleid = battleid;
			requestVars.attackerkills = attackerkills;
			requestVars.defenderkills = defenderkills;
			requestVars.result_flag = result_flag;
			
			request.url = Main.serviceurl + "battle_end.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					var rewards:Array = jsonObj.rewards as Array;
					ui.setRewards(rewards);
					ui.open();
				} else {
					// Error
				}
			});
		}
	}

}
package service
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import gamelobby.UIOtherPlayers;
	import gamelobby.UIStore;
	import gamelobby.UIStoreItem;
	import scene.SceneManager;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class LobbyService extends ServiceBase
	{
		public function LobbyService(sceneMgr:SceneManager) 
		{
			super(sceneMgr);
		}
		
		public function initLobbyLoader(userid:int = 0, fromPanel:UIOtherPlayers = null):void {
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			if (userid > 0) {
				requestVars.targetid = userid;
			}
			
			request.url = Main.serviceurl + "lobby.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					var user:Object = jsonObj.user as Object;
					var friends:Array = jsonObj.friends as Array;
					var isTutorial:Boolean = jsonObj.isTutorial as Boolean;
					if (fromPanel != null) {
						fromPanel.touchable = true;
					}
					sceneMgr.initSceneLoadingLobby(user, friends, isTutorial);
					sceneMgr.CurrentState = SceneManager.STATE_LOADING_LOBBY;
				} else {
					// Error
					if (fromPanel != null) {
						fromPanel.touchable = true;
					}
				}
			});
		}
		
		public function initAvatarShopLoader(char_index:int, store:UIStore):void {
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			requestVars.char_index = char_index;
			
			request.url = Main.serviceurl + "list_item_avatar.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					var results:Array = jsonObj.results as Array;
					store.setItems(results);
				} else {
					// Error
				}
			});
		}
		
		public function initSkillShopLoader(char_index:int, store:UIStore):void {
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			requestVars.char_index = char_index;
			
			request.url = Main.serviceurl + "list_item_skill.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					var results:Array = jsonObj.results as Array;
					store.setItems(results);
				} else {
					// Error
				}
			});
		}
		
		public function initAvatarUsageLoader(avatarid:int, char_index:int, store:UIStore, caller:UIStoreItem):void {
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			requestVars.char_index = char_index;
			requestVars.avatarid = avatarid;
			
			request.url = Main.serviceurl + "usage_avatar.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					// Change avatar information
					store.PlayerInfo.updateAvailableCharacter(char_index, avatarid);
					initAvatarShopLoader(char_index, store);
					start();
				} else {
					// Error
					caller.enableButtons();
				}
			});
		}
		
		public function initSkillUsageLoader(skillid:int, char_index:int, store:UIStore, caller:UIStoreItem):void {
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			requestVars.char_index = char_index;
			requestVars.skillid = skillid;
			
			request.url = Main.serviceurl + "usage_skill.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					// Change skill information
					store.PlayerInfo.updateAvailableSkill(char_index, skillid);
					initSkillShopLoader(char_index, store);
					start();
				} else {
					// Error
					caller.enableButtons();
				}
			});
		}
		
		public function initAvatarBuyLoader(avatarid:int, char_index:int, purse_type:int, store:UIStore, caller:UIStoreItem):void {
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			requestVars.char_index = char_index;
			requestVars.avatarid = avatarid;
			requestVars.purse_type = purse_type;
			
			request.url = Main.serviceurl + "buy_avatar.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					// Change avatar information
					initAvatarShopLoader(char_index, store);
					start();
				} else {
					// Error
					caller.enableButtons();
				}
			});
		}
		
		public function initSkillBuyLoader(skillid:int, char_index:int, purse_type:int, store:UIStore, caller:UIStoreItem):void {
			super.init();
			
			requestVars.userid = Main.userid;
			requestVars.token = Main.token;
			requestVars.char_index = char_index;
			requestVars.skillid = skillid;
			requestVars.purse_type = purse_type;
			
			request.url = Main.serviceurl + "buy_skill.php";
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				trace(e.target.data);
				var jsonObj:Object = JSON.parse(e.target.data);
				if (jsonObj.msgid != null && jsonObj.msgid == ServiceBase.MESSAGE_SUCCESS) {
					// Change avatar information
					initSkillShopLoader(char_index, store);
					start();
				} else {
					// Error
					caller.enableButtons();
				}
			});
		}
	}

}
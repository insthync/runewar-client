package gamelobby 
{
	import assets.*;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import gametutorial.UIArrow;
	import gametutorial.UINPC;
	import gametutorial.UITutorial;
	import player.PlayerInformation;
	import scene.Scene;
	import scene.SceneManager;
	import service.LobbyService;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class Arena extends Scene
	{
		private var background:Image;
		private var homeBtn:Button;
		private var envPlayerControl:UIPlayerControl;
		private var envTargets:UIOtherPlayers;
		private var envFightStart:UIFightStart;
		private var targets:Vector.<PlayerInformation>;
		private var playerInfosKeeper:Dictionary;
		private var userInfo:PlayerInformation;
		private var atlas:TextureAtlas;
		private var arenaAtlas:TextureAtlas;
		private var achievementAtlas:TextureAtlas;
		// Tutorial
		private var isTutorial:Boolean;
		private var tutorialAtlas:TextureAtlas;
		private var tutorialArrow:UIArrow;
		private var tutorialDialog:UITutorial;
		private var tutorialNPC:UINPC;
		private var tutorialState:int;
		public function Arena(mgr:SceneManager, userInfo:PlayerInformation, targets:Vector.<PlayerInformation>, isTutorial:Boolean = false) 
		{
			super(mgr);
			this.userInfo = userInfo;
			this.targets = targets;
			playerInfosKeeper = new Dictionary();
			for (var i:int = 0; i < targets.length; ++i) {
				var info:PlayerInformation = targets[i];
				playerInfosKeeper["" + info.UserID] = info;
			}
			this.isTutorial = isTutorial;
			InitEvironment();
		}
		
		public function findTarget(id:String):PlayerInformation {
			return playerInfosKeeper[id] as PlayerInformation;
		}
		
		private function InitEvironment():void {
			// Adding arena background
			atlas = LobbyTexturesHelper.getTextureAtlasLobby();
			arenaAtlas = LobbyTexturesHelper.getTextureAtlasArena();
			achievementAtlas = AchievementTexturesHelper.getTextureAtlas();
			background = new Image(LobbyTexturesHelper.getTexture("BackgroundArena"));
			background.blendMode = BlendMode.NONE;
			addChild(background);
			// Adding go to arena button
			homeBtn = new Button(atlas.getTexture("Home_btn"));
			homeBtn.addEventListener(Event.TRIGGERED, goToHome);
            homeBtn.x = 1013;
            homeBtn.y = 673;
			addChild(homeBtn);
			// Adding player control
			envPlayerControl = new UIPlayerControl(atlas, achievementAtlas, this, userInfo);
			addChild(envPlayerControl);
			// Adding target list
			envTargets = new UIOtherPlayers(atlas, achievementAtlas, this, userInfo, targets, UIOtherPlayers.TYPE_TARGET);
			addChild(envTargets);
			// Adding fight dialog
			envFightStart = new UIFightStart(atlas, arenaAtlas, this, userInfo);
			addChild(envFightStart);
			
			// Tutorial
			if (isTutorial) {
				// Add a tutorial scene
				tutorialAtlas = TutorialTexturesHelper.getTextureAtlas();
				tutorialArrow = new UIArrow(tutorialAtlas, this);
				tutorialDialog = new UITutorial(tutorialAtlas, this);
				tutorialNPC = new UINPC(tutorialAtlas, this);
				addChild(tutorialArrow);
				tutorialArrow.visible = false;
				addChild(tutorialDialog);
				addChild(tutorialNPC);
			}
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, loading);
			try {
				ExternalInterface.addCallback("updateUserInfo", updateUserInfo);
			} catch (ex:Error) {
				trace(ex);
			}
		}
		
		private function loading(e:EnterFrameEvent):void {
			if (userInfo.Loaded) {
				removeEventListener(EnterFrameEvent.ENTER_FRAME, loading);
				if (isTutorial) {
					TutorialState = 0;
				}
			}
		}
		
		private function updateUserInfo(data:Object):void {
			userInfo.Level = data.level;
			userInfo.Exp = data.exp;
			userInfo.Heart = data.heartnum;
			userInfo.Gold = data.gold;
			userInfo.Crystal = data.crystal;
		}
		
		private function goToHome(e:Event):void {
			homeBtn.touchable = false;
			Manager.SFXSoundManager.play("click_button");
			var lobbyService:LobbyService = new LobbyService(Manager);
			lobbyService.initLobbyLoader();
			lobbyService.start();
		}
		
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			trace("Arena disposing...");
			homeBtn.removeEventListeners(Event.TRIGGERED);
			background.texture.dispose();
			removeAndDisposeChildren();
			var t:Texture;
			for each (t in atlas.getTextures()) 
				t.dispose();
			atlas.dispose();
			for each (t in arenaAtlas.getTextures())
				t.dispose();
			arenaAtlas.dispose();
			for each (t in achievementAtlas.getTextures())
				t.dispose();
			achievementAtlas.dispose();
			if (isTutorial) {
				for each (t in tutorialAtlas.getTextures())
					t.dispose();
				tutorialAtlas.dispose();
			}
		}
		
		// An tutorial methods
		private function doTutorial():void {
			var that:Arena = this;
			if (!isTutorial)
				return;
			switch (tutorialState) {
				case 0:
					// Dialog 2
					tutorialDialog.setMessages("ดีมาก ! ตอนนี้ท่านอยู่ในหน้า Arena แล้ว ท่านสามารถ\nเลือกคู่ต่อสู้ที่ท่านต้องการต่อสู้ด้วยได้หนึ่งคน \n\nหลังจากนั้นคลิกปุ่ม Fight เกมจะส่งท่านไปยังหน้าต่อสู้\nทันที \n\nลองกดดูสิ");
					tutorialDialog.removeAllOKButtonTriggerEvents();
					tutorialDialog.addOKButtonTriggerEvent(function(evt:Event):void {
						if (that != null) {
							that.TutorialState = 1;
						}
					});
					tutorialDialog.open();
					tutorialNPC.open();
				break;
				case 1:
					// Dialog 2
					tutorialDialog.close();
					tutorialNPC.close();
					tutorialDialog.removeAllOKButtonTriggerEvents();
					tutorialArrow.visible = true;
					tutorialArrow.setPosRot(165, 505, 0);
				break;
				case 2:
					tutorialDialog.removeAllOKButtonTriggerEvents();
					tutorialArrow.visible = true;
					tutorialArrow.setPosRot(810, 360, 45);
				break;
				case 3:
					tutorialArrow.visible = false;
				break;
			}
		}
		public function get Atlas():TextureAtlas {
			return atlas;
		}
		public function get ArenaAtlas():TextureAtlas {
			return arenaAtlas;
		}
		public function get EnvPlayerControl():UIPlayerControl {
			return envPlayerControl;
		}
		public function get EnvTargets():UIOtherPlayers {
			return envTargets;
		}
		public function get EnvFightStart():UIFightStart {
			return envFightStart;
		}
		public function get AchievementAtlas():TextureAtlas {
			return achievementAtlas;
		}
		// Tutorial
		public function get TutorialAtlas():TextureAtlas {
			return tutorialAtlas;
		}
		public function get IsTutorial():Boolean {
			return isTutorial;
		}
		public function get TutorialState():int {
			return tutorialState;
		}
		public function set TutorialState(value:int):void {
			tutorialState = value;
			doTutorial();
		}
	}

}
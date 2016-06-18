package gamelobby 
{
	import assets.*;
	import character.CharacterLobby;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import gametutorial.UINPC;
	import gametutorial.UITutorial;
	import player.PlayerInformation;
	import scene.Scene;
	import scene.SceneManager;
	import service.ArenaService;
	import service.LobbyService;
	import starling.display.Button;
	import starling.display.Sprite;
	import player.PlayerTypes;
	import starling.animation.Tween;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.core.Starling;
	import gametutorial.UIArrow;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class Lobby extends Scene
	{
		private var background:Image;
		private var arenaBtn:Button;
		private var envPlayerControl:UIPlayerControl;
		private var envFriends:UIOtherPlayers;
		private var envFightStart:UIFightStart;
		private var friends:Vector.<PlayerInformation>;
		private var playerInfosKeeper:Dictionary;
		private var characters:Vector.<CharacterLobby>;
		private var userInfo:PlayerInformation;
		private var charInfoState:Boolean;
		private var charactersContainer:Sprite;
		private var atlas:TextureAtlas;
		private var arenaAtlas:TextureAtlas;
		private var shopAtlas:TextureAtlas;
		private var achievementAtlas:TextureAtlas;
		// Tutorial
		private var isTutorial:Boolean;
		private var tutorialAtlas:TextureAtlas;
		private var tutorialArrow:UIArrow;
		private var tutorialDialog:UITutorial;
		private var tutorialNPC:UINPC;
		private var tutorialState:int;
		public function Lobby(mgr:SceneManager, userInfo:PlayerInformation, friends:Vector.<PlayerInformation>, isTutorial:Boolean = false) 
		{
			super(mgr);
			this.userInfo = userInfo;
			this.friends = friends;
			playerInfosKeeper = new Dictionary();
			for (var i:int = 0; i < friends.length; ++i) {
				var info:PlayerInformation = friends[i];
				playerInfosKeeper["" + info.UserID] = info;
			}
			this.isTutorial = isTutorial;
			InitEvironment();
			addEventListener(Event.ADDED_TO_STAGE, startAnim);
			charInfoState = false;
		}
		
		public function findFriend(id:String):PlayerInformation {
			return playerInfosKeeper[id] as PlayerInformation;
		}
		
		private function startAnim(e:Event):void {
			for (var i:int = 0; i < characters.length; ++i) {
				characters[i].restartAnim();
			}
		}
		
		private function InitEvironment():void {
			// Adding lobby background
			atlas = LobbyTexturesHelper.getTextureAtlasLobby();
			arenaAtlas = LobbyTexturesHelper.getTextureAtlasArena();
			shopAtlas = LobbyTexturesHelper.getTextureAtlasShop();
			achievementAtlas = AchievementTexturesHelper.getTextureAtlas();
			background = new Image(LobbyTexturesHelper.getTexture("BackgroundLobby"));
			background.blendMode = BlendMode.NONE;
			addChild(background);
			// Adding character in lobby
			charactersContainer = new Sprite();
			addChild(charactersContainer);
			characters = new Vector.<CharacterLobby>();
			// Adding go to arena button
			if (userInfo.UserID == Main.userid) {
				arenaBtn = new Button(atlas.getTexture("Fight_btn"));
				arenaBtn.addEventListener(Event.TRIGGERED, goToArena);
			} else {
				arenaBtn = new Button(atlas.getTexture("Home_btn"));
				arenaBtn.addEventListener(Event.TRIGGERED, goToHome);
			}
            arenaBtn.x = 1013;
            arenaBtn.y = 673;
			addChild(arenaBtn);
			
			// Adding player control
			envPlayerControl = new UIPlayerControl(atlas, achievementAtlas, this, userInfo);
			addChild(envPlayerControl);
			// Adding friend list
			envFriends = new UIOtherPlayers(atlas, achievementAtlas, this, userInfo, friends, UIOtherPlayers.TYPE_FRIEND);
			addChild(envFriends);
			// Adding fight dialog
			envFightStart = new UIFightStart(atlas, arenaAtlas, this, userInfo);
			addChild(envFightStart);
			
			// Checking level up
			if (GlobalVariables.playerCurrentLevel == 0 && userInfo.UserID == Main.userid) {
				GlobalVariables.playerCurrentLevel = userInfo.Level;
			}
			if (GlobalVariables.playerCurrentLevel != userInfo.Level && userInfo.UserID == Main.userid) {
				GlobalVariables.playerCurrentLevel = userInfo.Level;
				try {
					ExternalInterface.call("shareLevelUp", Main.userid, Main.token);
				} catch (ex:Error) {
					trace(ex);
				}
			}
			
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
				addingCharacters();
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
		
		public function reloadCharacters():void {
			for (var i:int = 0; i < characters.length; ++i) {
				characters[i].removeEventListeners(TouchEvent.TOUCH);
				charactersContainer.removeChild(characters[i], true);
			}
			characters.splice(0, characters.length);
			characters.length = 6;
			addEventListener(EnterFrameEvent.ENTER_FRAME, loading);
		}
		
		private function addingCharacters():void {
			characters.length = 6;
			for (var i:int = 0; i < characters.length; ++i) {
				characters[i] = new CharacterLobby(this, userInfo, userInfo.AvailableCharacters[i]);
				characters[i].touchable = true;
				characters[i].useHandCursor = true;
				charactersContainer.addChild(characters[i]);
			}
			// Set characters position
			characters[CharacterTextureHelper.CHAR_ARCHER].x = 700;
			characters[CharacterTextureHelper.CHAR_ARCHER].y = 430;
			characters[CharacterTextureHelper.CHAR_ASSASIN].x = 990;
			characters[CharacterTextureHelper.CHAR_ASSASIN].y = 620;
			characters[CharacterTextureHelper.CHAR_FIGHTER].x = 675;
			characters[CharacterTextureHelper.CHAR_FIGHTER].y = 630;
			characters[CharacterTextureHelper.CHAR_KNIGHT].x = 150;
			characters[CharacterTextureHelper.CHAR_KNIGHT].y = 650;
			characters[CharacterTextureHelper.CHAR_HERMIT].x = 975;
			characters[CharacterTextureHelper.CHAR_HERMIT].y = 430;
			characters[CharacterTextureHelper.CHAR_MAGE].x = 300;
			characters[CharacterTextureHelper.CHAR_MAGE].y = 430;
		}
		
		private function goToArena(e:Event):void {
			arenaBtn.touchable = false;
			Manager.SFXSoundManager.play("click_button");
			var arenaService:ArenaService = new ArenaService(Manager);
			arenaService.initArenaLoader(userInfo);
			arenaService.start();
		}
		
		private function goToHome(e:Event):void {
			arenaBtn.touchable = false;
			Manager.SFXSoundManager.play("click_button");
			var lobbyService:LobbyService = new LobbyService(Manager);
			lobbyService.initLobbyLoader();
			lobbyService.start();
		}
		
		public override function doBlackFade(delay:Number = 0.75):void {
			if (fadeImg == null) {
				super.doBlackFade();
				addChild(fadeImg);
				Starling.juggler.add(fadeTween);
			}
		}
		
		public override function doFadeOutTween(delay:Number = 0.75):void {
			if (fadeImg != null) {
				super.doFadeOutTween();
				Starling.juggler.add(fadeTween);
			}
		}
		
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			trace("Lobby disposing...");
			arenaBtn.removeEventListeners(Event.TRIGGERED);
			background.texture.dispose();
			removeAndDisposeChildren();
			var t:Texture;
			for each (t in atlas.getTextures()) 
				t.dispose();
			atlas.dispose();
			for each (t in shopAtlas.getTextures())
				t.dispose();
			shopAtlas.dispose();
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
			var that:Lobby = this;
			if (!isTutorial)
				return;
			switch (tutorialState) {
				case 0:
					// Dialog 1
					tutorialDialog.setMessages("สวัสดีท่าน " + userInfo.Name + " !  ข้าชื่อโจว เป็นผู้ฝึกสอนของท่าน  ข้าจะสอน\nท่านเกี่ยวกับวิธีเล่นเกม Rune War \n\nตอนนี้ท่านอยู่ในหน้า Lobby ท่านสามารถปรับแต่งทหาร\nและซื้อของต่าง ๆ ได้ในหน้านี้ หากท่านต้องการไปสู้รบ\nกับศัตรู ท่านต้องไปหน้า Arena โดยการคลิกปุ่ม Play! \n\nลองกดดูสิ");
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
					// Dialog 1
					tutorialDialog.close();
					tutorialNPC.close();
					tutorialDialog.removeAllOKButtonTriggerEvents();
					tutorialArrow.setPosRot(1035, 500, 0);
					tutorialArrow.visible = true;
				break;
			}
		}
		
		public function set CharInfoState(value:Boolean):void {
			charInfoState = value;
		}
		public function get CharInfoState():Boolean {
			return charInfoState;
		}
		public function get EnvPlayerControl():UIPlayerControl {
			return envPlayerControl;
		}
		public function get EnvFriends():UIOtherPlayers {
			return envFriends;
		}
		public function get EnvFightStart():UIFightStart {
			return envFightStart;
		}
		public function get Atlas():TextureAtlas {
			return atlas;
		}
		public function get ArenaAtlas():TextureAtlas {
			return arenaAtlas;
		}
		public function get ShopAtlas():TextureAtlas {
			return shopAtlas;
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
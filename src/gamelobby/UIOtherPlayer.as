package gamelobby 
{
	import assets.LobbyTexturesHelper;
	import assets.TutorialTexturesHelper;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.utils.getTimer;
	import network.PacketHeader;
	import player.PlayerInformation;
	import scene.Scene;
	import service.LobbyService;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UIOtherPlayer extends UIScene
	{
		public static const ONLINE_UPDATE_DELAY:int = 5000;
		private var user:PlayerInformation;
		private var type:int;
		private var index:int;
		private var OtherPlayerImage:Sprite;
		private var OtherPlayerMOUI:Sprite;
		private var AddFriendBtn:Image;
		private var OtherPlayerBackUI:Image;
		private var OtherPlayerUI:Image;
		private var StatusOnlineGreen:Image;
		private var StatusOnlineYellow:Image;
		private var OtherPlayerMOFightBtn:Button;
		private var OtherPlayerMOVisitBtn:Button;
		private var fromPanel:UIOtherPlayers;
		private var onlineStatusUpdateTime:int;
		private var achievementIcon:Image;
		private var achievementAtlas:TextureAtlas;
		public function UIOtherPlayer(atlas:TextureAtlas, achievementAtlas:TextureAtlas, from:Scene, fromPanel:UIOtherPlayers, userInfo:PlayerInformation, user:PlayerInformation, type:int, index:int)
		{
			super(atlas, from, userInfo);
			this.achievementAtlas = achievementAtlas;
			this.fromPanel = fromPanel;
			this.user = user;
			this.type = type;
			this.index = index;
			this.onlineStatusUpdateTime = getTimer();
			if (from.Manager.IsOnline && user != null) {
				var data:Object = new Object();
				data.key = PacketHeader.online_status;
				data.values = [ user.UserID ];
				from.Manager.clientPacket.writeLine(data);
			}
		}
		protected override function InitEvironment():void {
			super.InitEvironment();
			
			OtherPlayerImage = new Sprite();
			OtherPlayerImage.x = 15;
			OtherPlayerImage.y = 30;
			StatusOnlineGreen = new Image(atlas.getTexture("StatusGUI_Green"));
			StatusOnlineGreen.touchable = false;
			StatusOnlineGreen.y = 22;
			StatusOnlineYellow = new Image(atlas.getTexture("StatusGUI_Yellow"));
			StatusOnlineYellow.touchable = false;
			StatusOnlineYellow.y = 22;
			AddFriendBtn = new Image(atlas.getTexture("Add_Button"));
			AddFriendBtn.y = 22;
			AddFriendBtn.useHandCursor = true;
			OtherPlayerBackUI = new Image(atlas.getTexture("FriendGUI_Back"));
			OtherPlayerBackUI.y = 22;
			OtherPlayerBackUI.touchable = false;
			OtherPlayerUI = new Image(atlas.getTexture("FriendGUI"));
			OtherPlayerUI.y = 22;
			OtherPlayerUI.useHandCursor = true;
			// An friend menus
			OtherPlayerMOUI = new Sprite();
			OtherPlayerMOUI.y = 22;
			OtherPlayerMOFightBtn = new Button(atlas.getTexture("FriendGUI_MouseOver_Fight"));
			OtherPlayerMOFightBtn.x = 13;
			OtherPlayerMOFightBtn.y = 59;
			OtherPlayerMOVisitBtn = new Button(atlas.getTexture("FriendGUI_MouseOver_Visit"));
			OtherPlayerMOVisitBtn.x = 13;
			OtherPlayerMOVisitBtn.y = 20;
			OtherPlayerMOUI.addChild(new Image(atlas.getTexture("FriendGUI_MouseOver_BG")));
			//OtherPlayerMOUI.touchable = false;
			OtherPlayerMOUI.addChild(OtherPlayerMOFightBtn);
			OtherPlayerMOUI.addChild(OtherPlayerMOVisitBtn);
			// An textfields
			var LvTextField:TextField = new TextField(40, 40, "", "RWFont", 25);
			var NameTextField:TextField = new TextField(100, 30, "", "Verdana", 14);
			var glowFilter:GlowFilter;
			
			// Lv textfield setting
			//LvTextField.border = true;
			LvTextField.autoScale = true;
			LvTextField.pivotX = 0;
			LvTextField.pivotY = 0;
			LvTextField.x = 77;
			LvTextField.y = 12;
			LvTextField.vAlign = VAlign.CENTER;
			LvTextField.hAlign = HAlign.CENTER;
			LvTextField.color = 0xFFFFFF;
			
			// Name textfield setting
			//NameTextField.border = true;
			NameTextField.autoScale = true;
			NameTextField.pivotX = 0;
			NameTextField.pivotY = 0;
			NameTextField.x = 6;
			NameTextField.y = 86;
			NameTextField.vAlign = VAlign.CENTER;
			NameTextField.hAlign = HAlign.CENTER;
			NameTextField.color = 0xFFFFFF;
			
			glowFilter = new GlowFilter();
			glowFilter.inner = false;
			glowFilter.color = 0x444444; 
			glowFilter.blurX = 4; 
			glowFilter.blurY = 4; 
			LvTextField.nativeFilters = [glowFilter];
			
			glowFilter = new GlowFilter();
			glowFilter.inner = false;
			glowFilter.color = 0x000000; 
			glowFilter.blurX = 3; 
			glowFilter.blurY = 3; 
			NameTextField.nativeFilters = [glowFilter];
			
			if (user == null || user.UserID < 0) {
				if (type == UIOtherPlayers.TYPE_FRIEND) {
					addChild(AddFriendBtn);
					addEventListener(TouchEvent.TOUCH, onAddFriend);
				}
				if (type == UIOtherPlayers.TYPE_TARGET) {
					var playerInfo:Object = new Object();
					var isTutorial:Boolean = (from is Arena && (from as Arena).IsTutorial);
					playerInfo.userid = -index;
					if (isTutorial) {
						playerInfo.userid = -8;
					}
					playerInfo.level = userInfo.Level;
					switch(playerInfo.userid) {
						case -1:
							playerInfo.level -= 3;
							break;
						case -2:
							playerInfo.level -= 2;
							break;
						case -3:
							playerInfo.level -= 1;
							break;
						case -4:
							playerInfo.level -= 0;
							break;
						case -5:
							playerInfo.level += 1;
							break;
						case -6:
							playerInfo.level += 2;
							break;
						case -7:
							playerInfo.level += 3;
							break;
						case -8:
							// Tutorial
							playerInfo.level = 1;
							break;
					}
					if (playerInfo.level <= 0) {
						playerInfo.level = userInfo.Level;
					}
					
					user = new PlayerInformation(PlayerInformation.MODE_LOBBY, playerInfo);
					// Achievement
					achievementIcon = new Image(achievementAtlas.getTexture("Achievement_" + GlobalVariables.AchievementsIndex[user.UsedAchievement] + "_Friends"));
					achievementIcon.x = 70;
					LvTextField.text = "" + user.Level;
					NameTextField.text = "" + user.Name;
					user.ProfileImageTexture = LobbyTexturesHelper.getTexture("Icon");
					if (isTutorial) {
						if (from is Lobby) {
							user.ProfileImageTexture = (from as Lobby).TutorialAtlas.getTexture("npc_icon");
						}
						if (from is Arena) {
							user.ProfileImageTexture = (from as Arena).TutorialAtlas.getTexture("npc_icon");
						}
					}
					// Append profile image to container
					user.appendImageTo(OtherPlayerImage);
					
					addChild(OtherPlayerBackUI);
					addChild(OtherPlayerImage);
					addChild(OtherPlayerUI);
					addChild(achievementIcon);
					addChild(LvTextField);
					addChild(NameTextField);
					addEventListener(TouchEvent.TOUCH, onTouchTarget);
				}
			} else {
				// Achievement
				achievementIcon = new Image(achievementAtlas.getTexture("Achievement_" + GlobalVariables.AchievementsIndex[user.UsedAchievement] + "_Friends"));
				achievementIcon.x = 70;
				LvTextField.text = "" + user.Level;
				NameTextField.text = "" + user.Name;
				user.appendImageTo(OtherPlayerImage);
				
				addChild(OtherPlayerBackUI);
				addChild(OtherPlayerImage);
				addChild(OtherPlayerUI);
				addChild(NameTextField);
				if (type == UIOtherPlayers.TYPE_FRIEND) {
					addEventListener(TouchEvent.TOUCH, onTouchFriend);
					OtherPlayerMOFightBtn.addEventListener(Event.TRIGGERED, OtherPlayerMOFightBtnTriggered);
					OtherPlayerMOVisitBtn.addEventListener(Event.TRIGGERED, OtherPlayerMOVisitBtnTriggered);
					OtherPlayerMOUI.visible = false;
					addChild(OtherPlayerMOUI);
				}
				if (type == UIOtherPlayers.TYPE_TARGET) {
					addEventListener(TouchEvent.TOUCH, onTouchTarget);
				}
				addChild(achievementIcon);
				addChild(LvTextField);
			}
			addChild(StatusOnlineGreen);
			StatusOnlineGreen.visible = false;
			addChild(StatusOnlineYellow);
			StatusOnlineYellow.visible = false;
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		private function update(e:EnterFrameEvent):void {
			var data:Object = new Object();
			var that:Scene = (from as Scene);
			if (OtherPlayerImage != null && OtherPlayerImage.width != 85 && OtherPlayerImage.height != 85) {
				OtherPlayerImage.width = 85;
				OtherPlayerImage.height = 85;
			}
			if (user != null) {
				switch (user.OnlineStatus) {
					case PlayerInformation.ONLINE_ONLINE:
						StatusOnlineGreen.visible = true;
						StatusOnlineYellow.visible = false;
						break;
					case PlayerInformation.ONLINE_BUSY:
						StatusOnlineGreen.visible = false;
						StatusOnlineYellow.visible = true;
						break;
					default:
						StatusOnlineGreen.visible = false;
						StatusOnlineYellow.visible = false;
						break;
				}
				// Updating online status
				if (that.Manager.IsOnline && getTimer() - onlineStatusUpdateTime >= UIOtherPlayer.ONLINE_UPDATE_DELAY)
				{
					data.key = PacketHeader.online_status;
					data.values = [ user.UserID ];
					from.Manager.clientPacket.writeLine(data);
					onlineStatusUpdateTime = getTimer();
				}
			}
		}
		private function onAddFriend(e:TouchEvent):void {
			var touch:Touch = e.getTouch(this, TouchPhase.ENDED);
			var that:Lobby = (from as Lobby);
			if (touch && that != null && !that.IsTutorial)
			{
				that.Manager.SFXSoundManager.play("click_button");
				try {
					ExternalInterface.call("callAddFriends", Main.userid, Main.token);
				} catch (ex:Error) {
					trace(ex);
				}
			}
		}
		private function onTouchFriend(e:TouchEvent):void {
			var hover:Touch = e.getTouch(this, TouchPhase.HOVER);
			if (hover)
			{
				OtherPlayerMOUI.visible = true;
				OtherPlayerUI.visible = false;
			} else {
				OtherPlayerMOUI.visible = false;
				OtherPlayerUI.visible = true;
			}
		}
		private function onTouchTarget(e:TouchEvent):void {
			var touch:Touch = e.getTouch(this, TouchPhase.ENDED);
			if (touch && from != null)
			{
				from.Manager.SFXSoundManager.play("click_button");
				startingFight();
			}
		}
		private function visit():void {
			var lobbyService:LobbyService = new LobbyService(from.Manager);
			lobbyService.initLobbyLoader(user.UserID);
			lobbyService.start();
		}
		private function startingFight():void {
			if (from is Lobby) {
				(from as Lobby).EnvFightStart.selectTarget(user);
			}
			if (from is Arena) {
				(from as Arena).EnvFightStart.selectTarget(user);
			}
		}
		private function OtherPlayerMOFightBtnTriggered(e:Event):void {
			from.Manager.SFXSoundManager.play("click_button");
			startingFight();
		}
		private function OtherPlayerMOVisitBtnTriggered(e:Event):void {
			from.Manager.SFXSoundManager.play("click_button");
			visit();
		}
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			removeEventListeners(TouchEvent.TOUCH);
			removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
			removeAndDisposeChildren();
		}
	}

}
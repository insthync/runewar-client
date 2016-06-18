package gameplay 
{
	import assets.GameTexturesHelper;
	import assets.LobbyTexturesHelper;
	import assets.TutorialTexturesHelper;
	import character.HPBar;
	import player.PlayerEntity;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.VAlign;
	import starling.utils.HAlign;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UIPlayerInfo extends UIScene
	{
		private var Player:PlayerEntity;
		private var TFPlayerHP:TextField;
		private var TFPlayerLV:TextField;
		private var hpBar:HPBar;
		private var OtherPlayerImage:Sprite;
		private var achievementIcon:Image;
		public function UIPlayerInfo(game:Game, Player:PlayerEntity) 
		{
			super(game);
			this.Player = Player;
			this.hpBar = new HPBar(Player, 118, 38, 0xda3c00, 1, 118, 38, 0xff0000, 1);
			// Start Event
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		protected override function InitEvironment():void {
			super.InitEvironment();
			
			var atlas:TextureAtlas = game.Atlas;
			var profileBG1:Image = new Image(atlas.getTexture("Profile01"));
			var profileBG2:Image = new Image(atlas.getTexture("Profile02"));
			var profileBG3:Image = new Image(atlas.getTexture("Profile03"));
			addChild(profileBG1);
			addChild(profileBG2);
			addChild(hpBar);
			addChild(profileBG3);
			hpBar.x = 70;
			hpBar.y = 32;
			
			OtherPlayerImage = new Sprite();
			OtherPlayerImage.width = 90;
			OtherPlayerImage.height = 90;
			OtherPlayerImage.x = 38;
			OtherPlayerImage.y = 67;
			if (Player.Information.UserID > 0) {
				OtherPlayerImage.addChild(new Image(Player.Information.ProfileImageTexture));
			} else {
				if (game.IsTutorial) {
					OtherPlayerImage.addChild(new Image(game.TutorialAtlas.getTexture("npc_icon")));
				} else {
					OtherPlayerImage.addChild(new Image(LobbyTexturesHelper.getTexture("Icon")));
				}
			}
			addChild(OtherPlayerImage);
			
			// Achievement
			achievementIcon = new Image(game.AchievementAtlas.getTexture("Achievement_" + GlobalVariables.AchievementsIndex[Player.Information.UsedAchievement] + "_Friends"));
			achievementIcon.x = 125;
			addChild(achievementIcon);
			
			TFPlayerHP = new TextField(140, 40, "", "RWFont", 20, 0xffffff);
			TFPlayerHP.autoScale = true;
			TFPlayerHP.x = 0;
			TFPlayerHP.y = 15;
			TFPlayerHP.vAlign = VAlign.CENTER;
			TFPlayerHP.hAlign = HAlign.CENTER;
			addChild(TFPlayerHP);
			TFPlayerLV = new TextField(50, 40, "", "RWFont", 25, 0xffffff);
			TFPlayerLV.autoScale = true;
			TFPlayerLV.x = 128;
			TFPlayerLV.y = 8;
			TFPlayerLV.vAlign = VAlign.CENTER;
			TFPlayerLV.hAlign = HAlign.CENTER;
			addChild(TFPlayerLV);
		}
		
		private function update(e:EnterFrameEvent):void {
			if (OtherPlayerImage != null && OtherPlayerImage.width != 90 && OtherPlayerImage.height != 90) {
				OtherPlayerImage.width = 90;
				OtherPlayerImage.height = 90;
			}
			TFPlayerHP.text = Player.CurrentHP + "/" + Player.MaxHP;
			TFPlayerLV.text = "" + Player.Information.Level;
		}
		
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
			removeAndDisposeChildren();
		}
		
	}

}
package gamelobby 
{
	import assets.LobbyTexturesHelper;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import player.PlayerInformation;
	import player.ExpBar;
	import scene.Scene;
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
	public class UIPlayerControl extends UIScene
	{
		private var ExpTextField:TextField;
		private var LvTextField:TextField;
		private var GoldTextField:TextField;
		private var GemTextField:TextField;
		private var HeartTextField:TextField;
		private var glowFilter:GlowFilter;
		
		private var BuyHeartButton:Button;
		private var BuyGemButton:Button;
		
		private var GoToArenaButton:Button;
		private var GoToLobbyButton:Button;
		private var PlayerImage:Sprite;
		private var achievementIcon:Image;
		private var achievementAtlas:TextureAtlas;
		
		public function UIPlayerControl(atlas:TextureAtlas, achievementAtlas:TextureAtlas, from:Scene, userInfo:PlayerInformation) 
		{
			super(atlas, from, userInfo);
			this.achievementAtlas = achievementAtlas;
		}
		
		protected override function InitEvironment():void {
			super.InitEvironment();
			// Achievement
			achievementIcon = new Image(achievementAtlas.getTexture("Achievement_" + GlobalVariables.AchievementsIndex[userInfo.UsedAchievement] + "_Profile"));
			achievementIcon.x = 145;
			achievementIcon.y = -5;
			var BetaTexture:Texture = atlas.getTexture("BetaGUI");
			var gui_beta:Image = new Image(BetaTexture);
			gui_beta.x = 1200 - gui_beta.width;
			
			var UserBackgroundTexture:Texture = atlas.getTexture("UserGUI_Back");
			var gui_user_bottom:Image = new Image(UserBackgroundTexture);
			
			var gui_exp_bar:ExpBar = new ExpBar(userInfo, 134, 39, 0x5fa407, 1, 134, 39, 0xff0000, 1);
			gui_exp_bar.x = 85;
			gui_exp_bar.y = 35;
			
			PlayerImage = new Sprite();
			userInfo.appendImageTo(PlayerImage);
			PlayerImage.x = 38;
			PlayerImage.y = 70;
			PlayerImage.width = 120;
			PlayerImage.height = 120;
			
			var UserFrameTexture:Texture = atlas.getTexture("UserGUI_Top");
			var gui_user_top:Image = new Image(UserFrameTexture);
			
			addChild(gui_beta);
			addChild(gui_user_bottom);
			addChild(gui_exp_bar);
			addChild(PlayerImage);
			addChild(gui_user_top);
			addChild(achievementIcon);
			
			// Labels
			ExpTextField = new TextField(150, 40, "", "RWFont", 25);
			//ExpTextField.border = true;
			ExpTextField.autoScale = true;
			ExpTextField.pivotX = 0;
			ExpTextField.pivotY = 0;
			ExpTextField.x = 10;
			ExpTextField.y = 16;
			ExpTextField.vAlign = VAlign.CENTER;
			ExpTextField.hAlign = HAlign.CENTER;
			ExpTextField.color = 0xFFFFFF;
			addChild(ExpTextField);
			
			glowFilter = new GlowFilter();
			glowFilter.inner = false;
			glowFilter.color = 0x444444; 
			glowFilter.blurX = 4; 
			glowFilter.blurY = 4; 
			ExpTextField.nativeFilters = [glowFilter];
			
			LvTextField = new TextField(40, 40, "", "RWFont", 30);
			//LvTextField.border = true;
			LvTextField.autoScale = true;
			LvTextField.pivotX = 0;
			LvTextField.pivotY = 0;
			LvTextField.x = 160;
			LvTextField.y = 16;
			LvTextField.vAlign = VAlign.CENTER;
			LvTextField.hAlign = HAlign.CENTER;
			LvTextField.color = 0xFFFFFF;
			addChild(LvTextField);
			
			glowFilter = new GlowFilter();
			glowFilter.inner = false;
			glowFilter.color = 0x444444; 
			glowFilter.blurX = 6; 
			glowFilter.blurY = 6; 
			LvTextField.nativeFilters = [glowFilter];
			
			// Heart, Gem, Gold
			if (userInfo.UserID == Main.userid) {
				var HeartBarTexture:Texture = atlas.getTexture("HeartBar");
				var gui_heartbar:Image = new Image(HeartBarTexture);
				gui_heartbar.x = 264;
				gui_heartbar.y = 12;
				
				var GemBarTexture:Texture = atlas.getTexture("GemBar");
				var gui_gembar:Image = new Image(GemBarTexture);
				gui_gembar.x = 520;
				gui_gembar.y = 1;
				
				var GoldBarTexture:Texture = atlas.getTexture("MoneyBar");
				var gui_goldbar:Image = new Image(GoldBarTexture);
				gui_goldbar.x = 750;
				gui_goldbar.y = 1;
				
				addChild(gui_heartbar);
				addChild(gui_gembar);
				addChild(gui_goldbar);
				
				GoldTextField = new TextField(150, 40, "", "RWFont", 30);
				//GoldTextField.border = true;
				GoldTextField.autoScale = true;
				GoldTextField.pivotX = 0;
				GoldTextField.pivotY = 0;
				GoldTextField.x = 815;
				GoldTextField.y = 25;
				GoldTextField.vAlign = VAlign.CENTER;
				GoldTextField.hAlign = HAlign.CENTER;
				GoldTextField.color = 0xFFFFFF;
				addChild(GoldTextField);
				
				GemTextField = new TextField(150, 40, "", "RWFont", 30);
				//GemTextField.border = true;
				GemTextField.autoScale = true;
				GemTextField.pivotX = 0;
				GemTextField.pivotY = 0;
				GemTextField.x = 570;
				GemTextField.y = 25;
				GemTextField.vAlign = VAlign.CENTER;
				GemTextField.hAlign = HAlign.CENTER;
				GemTextField.color = 0xFFFFFF;
				addChild(GemTextField);
				
				HeartTextField = new TextField(150, 40, "", "RWFont", 30);
				//HeartTextField.border = true;
				HeartTextField.autoScale = true;
				HeartTextField.pivotX = 0;
				HeartTextField.pivotY = 0;
				HeartTextField.x = 335;
				HeartTextField.y = 25;
				HeartTextField.vAlign = VAlign.CENTER;
				HeartTextField.hAlign = HAlign.CENTER;
				HeartTextField.color = 0xFFFFFF;
				addChild(HeartTextField);
				
				GoldTextField.nativeFilters = [glowFilter];
				GemTextField.nativeFilters = [glowFilter];
				HeartTextField.nativeFilters = [glowFilter];
				
				// Buttons
				var ShopBtnTexture:Texture = atlas.getTexture("Shop_btn");
				// Heart buy 
				BuyHeartButton = new Button(ShopBtnTexture);
				BuyHeartButton.addEventListener(Event.TRIGGERED, buyHeart);
				BuyHeartButton.x = 460; 
				BuyHeartButton.y = 25;
				addChild(BuyHeartButton);
				// Gem buy
				BuyGemButton = new Button(ShopBtnTexture);
				BuyGemButton.addEventListener(Event.TRIGGERED, buyGem);
				BuyGemButton.x = 695; 
				BuyGemButton.y = 25;
				addChild(BuyGemButton);
			}
			// Options
			var OptBtnTex:Texture = atlas.getTexture("OptionGUI");
			var option_btn:Button = new Button(OptBtnTex, "");
			option_btn.x = 1010;
			option_btn.y = 12;
			//addChild(option_btn);
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		private function buyHeart(e:Event):void {
			from.Manager.SFXSoundManager.play("click_button");
			ExternalInterface.call("callBuyHeart", Main.userid, Main.token);
		}
		
		private function buyGem(e:Event):void {
			from.Manager.SFXSoundManager.play("click_button");
			ExternalInterface.call("callBuyGem", Main.userid, Main.token);
		}
		
		private function update(e:EnterFrameEvent):void {
			var delExp:int = GlobalVariables.player_exp[userInfo.Level - 1];
			ExpTextField.text = "" + (userInfo.Exp - delExp) + "/" + (GlobalVariables.player_exp[userInfo.Level] - delExp);
			if (userInfo.Level >= GlobalVariables.player_exp.length)
				ExpTextField.text = "MAX";
			LvTextField.text = "" + userInfo.Level;
			if (userInfo.UserID == Main.userid) {
				HeartTextField.text = "" + userInfo.Heart;
				GoldTextField.text = "" + userInfo.Gold;
				GemTextField.text = "" + userInfo.Crystal;
			}
			if (PlayerImage != null && PlayerImage.width != 120 && PlayerImage.height != 120) {
				PlayerImage.width = 120;
				PlayerImage.height = 120;
			}
		}
		
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
			removeAndDisposeChildren();
		}
	}

}

package gamelobby 
{
	import assets.CharacterTextureHelper;
	import assets.LobbyTexturesHelper;
	import character.BaseCharacterInformation;
	import character.BaseCharacterSkill;
	import player.PlayerInformation;
	import scene.Scene;
	import starling.animation.Tween;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Button;
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
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UICharacterInfo extends UIScene
	{
		private var char_index:int;
		private var char_mc:MovieClip;
		private var charInfo:BaseCharacterInformation;
		private var skillInfo:BaseCharacterSkill;
		private var statusContainer:Sprite;
		private var avatarIconContainer:Sprite;
		private var skillIconContainer:Sprite;
		private var shopAtlas:TextureAtlas;
		private var closing:Boolean;
		public function UICharacterInfo(atlas:TextureAtlas, shopAtlas:TextureAtlas, from:Scene, userInfo:PlayerInformation, char_index:int) 
		{
			super(atlas, from, userInfo);
			this.shopAtlas = shopAtlas;
			this.char_index = char_index;
			from.doBlackFade(0.5);
			(from as Lobby).CharInfoState = true;
			closing = false;
		}
		
		private function loading(e:EnterFrameEvent):void {
			if (userInfo.Loaded) {
				removeEventListener(EnterFrameEvent.ENTER_FRAME, loading);
				charInfo = userInfo.AvailableCharacters[char_index];
				skillInfo = userInfo.AvailableSkills[char_index];
				InitCharacterEnvironment();
			}
		}
		
		private function InitCharacterEnvironment():void {
			// Character
			statusContainer = new Sprite();
			charInfo.appendStatusTo(statusContainer);
			statusContainer.x = 340;
			statusContainer.y = 30;
			addChild(statusContainer);
			
			var lobbyTextureAtlas:TextureAtlas = charInfo.Animation[CharacterTextureHelper.ANIM_LOBBY][0];
			var lobbyFPS:Number = charInfo.Animation[CharacterTextureHelper.ANIM_LOBBY][1];
			char_mc = new MovieClip(lobbyTextureAtlas.getTextures("Idle_Front_"));
			char_mc.loop = true;
			char_mc.x = 0;
			char_mc.y = 0;
			char_mc.fps = lobbyFPS;
			addChild(char_mc);
			Starling.juggler.add(char_mc);
			
			//add Button
			avatarIconContainer = new Sprite();
			avatarIconContainer.x = 115;
			avatarIconContainer.y = 420;
			avatarIconContainer.width = 80;
			avatarIconContainer.height = 80;
			charInfo.appendIconTo(avatarIconContainer);
			addChild(avatarIconContainer);
			if (userInfo.UserID == Main.userid) {
				avatarIconContainer.useHandCursor = true;
				avatarIconContainer.addEventListener(TouchEvent.TOUCH, onAvatarIconTouch);
			}
			
			skillIconContainer = new Sprite();
			skillIconContainer.x = 205;
			skillIconContainer.y = 420;
			skillIconContainer.width = 80;
			skillIconContainer.height = 80;
			skillInfo.appendIconTo(skillIconContainer);
			addChild(skillIconContainer);
			if (userInfo.UserID == Main.userid) {
				skillIconContainer.useHandCursor = true;
				skillIconContainer.addEventListener(TouchEvent.TOUCH, onSkillIconTouch);
			}
		}
		
		protected override function InitEvironment():void {
			super.InitEvironment();
			
			//add Paper
			var PaperTex:Texture = shopAtlas.getTexture("paper");
			var gui_paper:Image = new Image(PaperTex);
			addChild(gui_paper);
			
			//add BG Info
			var BGInfo_Image:Image = new Image(shopAtlas.getTexture("Paper_CharacterInfo_Shadow"));
			addChild(BGInfo_Image);
			
			var CrossBtnTex:Texture = shopAtlas.getTexture("Cross");
			var CrossButton:Button = new Button(CrossBtnTex);
			
			CrossButton.x = width - CrossButton.width - 10;
			CrossButton.addEventListener(Event.TRIGGERED, onCrossButtonTriggered);
			
			addChild(CrossButton);
			
			// Opening
			pivotX = width / 2;
			pivotY = height / 2;
			x = GlobalVariables.screenWidth / 2;
			y = GlobalVariables.screenHeight / 2;
			scaleX = 0.1;
			scaleY = 0.1;
			var openTween:Tween = new Tween(this, 0.5, Transitions.EASE_OUT_BACK);
			openTween.animate("scaleX", 1);
			openTween.animate("scaleY", 1);
			Starling.juggler.add(openTween);
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, loading);
		}
		
		protected function onCrossButtonTriggered(event:Event):void {
			if (!closing) {
				closing = true;
				scaleX = 1;
				scaleY = 1;
				(from as Lobby).Manager.SFXSoundManager.play("click_button_close");
				//(from as Lobby).Manager.SFXSoundManager.play("ui_sfx_open");
				(from as Lobby).reloadCharacters();
				from.doFadeOutTween(0.5);
				var closeTween:Tween = new Tween(this, 0.5, Transitions.EASE_IN_BACK);
				closeTween.animate("scaleX", 0.1);
				closeTween.animate("scaleY", 0.1);
				closeTween.onComplete = function():void {
					closing = false;
					(from as Lobby).CharInfoState = false;
					removeFromParent(true);
				};
				Starling.juggler.add(closeTween);
			}
		}
		
		protected function onAvatarIconTouch(event:TouchEvent):void {
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			if (touch) {
				if (!closing) {
					closing = true;
					(from as Lobby).Manager.SFXSoundManager.play("click_button");
					scaleX = 1;
					scaleY = 1;
					var closeTween:Tween = new Tween(this, 0.5, Transitions.EASE_IN_BACK);
					closeTween.animate("scaleX", 0.1);
					closeTween.animate("scaleY", 0.1);
					closeTween.onComplete = function():void {
						closing = false;
						removeFromParent(true);
						from.addChild(new UIStore(atlas, shopAtlas, from, userInfo, char_index, UIStore.TYPE_AVATAR));
					};
					Starling.juggler.add(closeTween);
				}
			}
		}
		
		protected function onSkillIconTouch(event:TouchEvent):void {
			var touch:Touch = event.getTouch(this, TouchPhase.ENDED);
			if (touch) {
				if (!closing) {
					closing = true;
					(from as Lobby).Manager.SFXSoundManager.play("click_button");
					scaleX = 1;
					scaleY = 1;
					var closeTween:Tween = new Tween(this, 0.5, Transitions.EASE_IN_BACK);
					closeTween.animate("scaleX", 0.1);
					closeTween.animate("scaleY", 0.1);
					closeTween.onComplete = function():void {
						closing = false;
						removeFromParent(true);
						from.addChild(new UIStore(atlas, shopAtlas, from, userInfo, char_index, UIStore.TYPE_SKILL));
					};
					Starling.juggler.add(closeTween);
				}
			}
		}
		
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			removeAndDisposeChildren();
		}
	}

}
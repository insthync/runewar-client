package gamelobby 
{
	import assets.CharacterTextureHelper;
	import assets.LobbyTexturesHelper;
	import character.BaseCharacterInformation;
	import character.BaseCharacterSkill;
	import player.PlayerInformation;
	import scene.Scene;
	import service.LobbyService;
	import starling.animation.Tween;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
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
	public class UIStore extends UIScene
	{
		public static const TYPE_AVATAR:int = 0;
		public static const TYPE_SKILL:int = 1;
		private var char_index:int;
		private var type:int;
		private var PrevButton:Button;
		private var NextButton:Button;
		private var lobbyService:LobbyService;
		private var list:Vector.<Sprite>;
		private var currentPage:int;
		private var listContainer:Sprite;
		private var shopAtlas:TextureAtlas;
		private var closing:Boolean;
		public function UIStore(atlas:TextureAtlas, shopAtlas:TextureAtlas, from:Scene, userInfo:PlayerInformation, char_index:int, type:int) 
		{
			super(atlas, from, userInfo);
			this.shopAtlas = shopAtlas;
			this.char_index = char_index;
			this.type = type;
			this.list = new Vector.<Sprite>();
			this.lobbyService = new LobbyService(from.Manager);
			closing = false;
		}
		
		protected override function InitEvironment():void {
			super.InitEvironment();
			
			//add Paper
			var PaperTex:Texture = shopAtlas.getTexture("paper");
			var gui_paper:Image = new Image(PaperTex);
			addChild(gui_paper);
			
			// Title
			var titleTextField:TextField = new TextField(300, 50, "Store", "RWFont", 36, 0x4b2a0f, true);
			titleTextField.autoScale = true;
			titleTextField.x = 30;
			titleTextField.y = 10;
			titleTextField.touchable = false;
			titleTextField.vAlign = VAlign.TOP;
			titleTextField.hAlign = HAlign.LEFT;
			addChild(titleTextField);
			if (type == UIStore.TYPE_AVATAR) {
				titleTextField.text = "Avatar Shop";
			}
			if (type == UIStore.TYPE_SKILL) {
				titleTextField.text = "Skill Shop";
			}
			
			// Pagination
			var pageTextField:TextField = new TextField(200, 50, "1 of 1", "RWFont", 32, 0x4b2a0f, true);
			pageTextField.autoScale = true;
			pageTextField.pivotX = pageTextField.width / 2;
			pageTextField.x = width / 2;
			pageTextField.y = 458;
			pageTextField.touchable = false;
			pageTextField.vAlign = VAlign.TOP;
			pageTextField.hAlign = HAlign.CENTER;
			addChild(pageTextField);
			
			//add Button
			var CrossBtnTex:Texture = shopAtlas.getTexture("Cross");
			var CrossButton:Button = new Button(CrossBtnTex);
			CrossButton.x = width - CrossButton.width - 10;
			CrossButton.addEventListener(Event.TRIGGERED, onCrossButtonTriggered);
			addChild(CrossButton);
			
			var PrevBtnTex:Texture = atlas.getTexture("Prev_btn");
			PrevButton = new Button(PrevBtnTex);
			PrevButton.pivotX = PrevButton.width / 2;
			PrevButton.pivotY = PrevButton.height / 2;
			PrevButton.x = 200;
			PrevButton.y = 478;
			PrevButton.addEventListener(Event.TRIGGERED, onPreviousPage);
			addChild(PrevButton);
			
			var NextBtnTex:Texture = atlas.getTexture("Next_btn");
			NextButton = new Button(NextBtnTex);
			NextButton.pivotX = NextButton.width / 2;
			NextButton.pivotY = NextButton.height / 2;
			NextButton.x = width - 200;
			NextButton.y = 478;
			NextButton.addEventListener(Event.TRIGGERED, onNextPage);
			addChild(NextButton);
			
			// List container
			listContainer = new Sprite();
			listContainer.x = 50;
			listContainer.y = 50;
			addChild(listContainer);
			
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
			
			// Start loading
			switch (type) {
				case UIStore.TYPE_AVATAR:
					lobbyService.initAvatarShopLoader(char_index, this);
					break;
				case UIStore.TYPE_SKILL:
					lobbyService.initSkillShopLoader(char_index, this);
					break;
			}
			lobbyService.start();
		}
		
		public function setItems(obj:Array):void {
			var i:int = 0;
			for (i = 0; i < list.length; ++i) {
				list[i].removeChildren(0, -1, true);
			}
			listContainer.removeChildren(0, -1, true);
			list.splice(0, list.length);
			list.length = 0;
			var j:int = 0;
			var listOnePage:Sprite = new Sprite();
			for (i = 0; i < obj.length; ++i ) {
				var item:UIStoreItem = new UIStoreItem(atlas, shopAtlas, from, userInfo, char_index, this, obj[i]);
				item.y = i * 130;
				listOnePage.addChild(item);
				++j;
				if ((j + 1) % 4 == 0) {
					list.push(listOnePage);
					listOnePage = new Sprite();
					j = 0;
				}
			}
			if ((j + 1) % 4 != 0) {
				list.push(listOnePage);
			}
			for (i = 0; i < list.length; ++i) {
				list[i].visible = false;
				listContainer.addChild(list[i]);
			}
			CurrentPage = 0;
		}
		
		protected function onCrossButtonTriggered(event:Event):void {
			if (!closing) {
				closing = true;
				scaleX = 1;
				scaleY = 1;
				from.Manager.SFXSoundManager.play("click_button_close");
				//from.Manager.SFXSoundManager.play("ui_sfx_open");
				var closeTween:Tween = new Tween(this, 0.5, Transitions.EASE_IN_BACK);
				closeTween.animate("scaleX", 0.1);
				closeTween.animate("scaleY", 0.1);
				closeTween.onComplete = function():void {
					closing = false;
					removeFromParent(true);
					from.addChild(new UICharacterInfo(atlas, shopAtlas, from, userInfo, char_index));
				};
				Starling.juggler.add(closeTween);
			}
		}
		
		public function get CurrentPage():int {
			return currentPage;
		}
		
		public function set CurrentPage(value:int):void {
			if (value >= 0 && value < list.length) {
				list[currentPage].visible = false;
				currentPage = value;
				list[currentPage].visible = true;
			}
		}
		
		public function get Type():int {
			return type;
		}
		
		private function onPreviousPage(e:Event):void {
			from.Manager.SFXSoundManager.play("click_button");
			if (CurrentPage > 0) {
				CurrentPage--;
			}
		}
		
		private function onNextPage(e:Event):void {
			from.Manager.SFXSoundManager.play("click_button");
			if (CurrentPage < list.length) {
				CurrentPage++;
			}
		}
		
		protected override function removedFromStage(e:Event):void 
		{
			super.removedFromStage(e);
			removeAndDisposeChildren();
		}
	}

}
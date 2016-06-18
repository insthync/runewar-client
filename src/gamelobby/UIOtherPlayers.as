package gamelobby 
{
	import assets.LobbyTexturesHelper;
	import flash.utils.Dictionary;
	import player.PlayerInformation;
	import scene.Scene;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UIOtherPlayers extends UIScene
	{
		public static const TYPE_FRIEND:int = 0;
		public static const TYPE_TARGET:int = 1;
		private var prev_btn:Button;
		private var next_btn:Button;
		private var users:Vector.<PlayerInformation>;
		private var type:int;
		private var list:Vector.<Sprite>;
		private var currentPage:int;
		private var listContainer:Sprite;
		private var achievementAtlas:TextureAtlas
		public function UIOtherPlayers(atlas:TextureAtlas, achievementAtlas:TextureAtlas, from:Scene, userInfo:PlayerInformation, users:Vector.<PlayerInformation>, type:int) 
		{
			super(atlas, from, userInfo);
			this.achievementAtlas = achievementAtlas;
			this.users = users;
			this.type = type;
			this.list = new Vector.<Sprite>();
		}
		
		protected override function InitEvironment():void {
			super.InitEvironment();
			
			var isTutorial:Boolean = ((from is Lobby && (from as Lobby).IsTutorial) || (from is Arena && (from as Arena).IsTutorial));
			
			var NextBtnTex:Texture = atlas.getTexture("Next_btn");
			next_btn = new Button(NextBtnTex, "");
			next_btn.x = 940;
			next_btn.y = 700;
			next_btn.addEventListener(Event.TRIGGERED, onNextPage);
			addChild(next_btn);
			
			var PrevBtnTex:Texture = atlas.getTexture("Prev_btn");
			prev_btn = new Button(PrevBtnTex, "");
			prev_btn.x = 105;
			prev_btn.y = 700;
			prev_btn.addEventListener(Event.TRIGGERED, onPreviousPage);
			addChild(prev_btn);
			
			var j:int = 0;
			var listOnePage:Sprite = new Sprite();
			var otherPlayer:UIOtherPlayer;
			if (!isTutorial) {
				for (var i:int = 0; i < users.length; ++i) {
					otherPlayer = new UIOtherPlayer(atlas, achievementAtlas, from, this, userInfo, users[i], type, j + 1);
					otherPlayer.x = 110 * j;
					listOnePage.addChild(otherPlayer);
					++j;
					if ((j + 1) % 8 == 0) {
						listOnePage.x = 162;
						listOnePage.y = 665;
						list.push(listOnePage);
						listOnePage = new Sprite();
						j = 0;
					}
				}
			}
			while ((j + 1) % 8 != 0) {
				otherPlayer = new UIOtherPlayer(atlas, achievementAtlas, from, this, userInfo, null, type, j + 1);
				otherPlayer.x = 110 * j;
				listOnePage.addChild(otherPlayer);
				++j;
			}
			listOnePage.x = 162;
			listOnePage.y = 665;
			list.push(listOnePage);
			
			listContainer = new Sprite();
			addChild(listContainer);
			
			for (i = 0; i < list.length; ++i) {
				list[i].visible = false;
				listContainer.addChild(list[i]);
			}
			
			CurrentPage = 0;
		}
		
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			prev_btn.removeEventListeners(Event.TRIGGERED);
			next_btn.removeEventListeners(Event.TRIGGERED);
			removeAndDisposeChildren();
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
	}

}
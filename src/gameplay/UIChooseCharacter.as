package gameplay 
{
	import assets.GameTexturesHelper;
	import starling.animation.Tween;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UIChooseCharacter extends UIScene
	{
		public static const TYPE_TOP:int = 0;
		public static const TYPE_BOTTOM:int = 1;
		private var board:Board;
		private var ImageBG:Image;
		private var ButtonOK:Button;
		private var runes:Vector.<UIButtonChooseCharacter>;
		private var type:int;
		private var setIndex1:int;
		private var setIndex2:int;
		
		public function UIChooseCharacter(game:Game, board:Board, type:int) 
		{
			this.board = board;
			this.type = type;
			switch(type) {
				case TYPE_TOP:
					this.setIndex1 = 0;
					this.setIndex2 = 1;
					board.Player.addHomeTopChooseCharacterEvent(this);
					break;
				case TYPE_BOTTOM:
					this.setIndex1 = 2;
					this.setIndex2 = 3;
					board.Player.addHomeBottomChooseCharacterEvent(this);
					break;
			}
			super(game);
		}
		
		protected override function InitEvironment():void {
			super.InitEvironment();
			var atlas:TextureAtlas = game.Atlas;
			ImageBG = new Image(atlas.getTexture("SelectMonster_BG"));
			addChild(ImageBG);
			
			runes = new Vector.<UIButtonChooseCharacter>();
			runes.length = 2;
			runes[0] = new UIButtonChooseCharacter(game, board, setIndex1);
			runes[0].useHandCursor = true;
			runes[0].x = 12;
			runes[0].y = 19;
			addChild(runes[0]);
			runes[1] = new UIButtonChooseCharacter(game, board, setIndex2);
			runes[1].useHandCursor = true;
			runes[1].x = 77;
			runes[1].y = 19;
			addChild(runes[1]);
			
			ButtonOK = new Button(atlas.getTexture("SelectMonster_OK"));
			ButtonOK.x = 37;
			ButtonOK.y = 70;
			ButtonOK.addEventListener(Event.TRIGGERED, onOK);
			addChild(ButtonOK);
			
			pivotX = width / 2;
			pivotY = height / 2;
			open();
		}
		private function onOK(event:Event):void {
			game.Manager.SFXSoundManager.play("click_button");
			
			if (game.IsTutorial && game.TutorialState == 1) {
				game.TutorialState = 2;
			}
			close();
		}
		public function open():void {
			game.Manager.SFXSoundManager.play("ui_sfx_open");
			visible = true;
			scaleX = 0.1;
			scaleY = 0.1;
			var tw:Tween = new Tween(this, 0.25, Transitions.EASE_IN_OUT_BACK);
			tw.scaleTo(1);
			Starling.juggler.add(tw);
			
		}
		public function close(dispose:Boolean = false):void {
			var that:UIChooseCharacter = this;
			scaleX = 1;
			scaleY = 1;
			var tw:Tween = new Tween(this, 0.25, Transitions.EASE_IN_OUT_BACK);
			tw.scaleTo(0.1);
			tw.onComplete = function():void {
				visible = false;
				if (dispose) {
					that.parent.removeChild(that, true);
				}
			};
			Starling.juggler.add(tw);
		}
		
		public function sendToServer():void {
			runes[0].sendToServer();
			runes[1].sendToServer();
		}
		
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			ButtonOK.removeEventListeners(Event.TRIGGERED);
			removeAndDisposeChildren();
		}
	}

}
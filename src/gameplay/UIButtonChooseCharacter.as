package gameplay 
{
	import assets.GameTexturesHelper;
	import character.*;
	import network.PacketHeader;
	import starling.display.Sprite;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class UIButtonChooseCharacter extends UIScene
	{
		private var board:Board;
		private var runesImage:Vector.<Image>;
		private var imageContainer:Sprite;
		private var index:int;
		private var setIndex:int;
		public function UIButtonChooseCharacter(game:Game, board:Board, setIndex:int) 
		{
			this.board = board;
			this.setIndex = setIndex;
			super(game);
		}
		
		protected override function InitEvironment():void {
			super.InitEvironment();
			
			var atlas:TextureAtlas = game.RuneAtlas;
			runesImage = new Vector.<Image>();
			runesImage.length = CharacterIndex.INDEX_TOTAL;
			runesImage[CharacterIndex.INDEX_ARCHER] = new Image(atlas.getTexture("RuneBase_Archer"));
			runesImage[CharacterIndex.INDEX_ASSASIN] = new Image(atlas.getTexture("RuneBase_Assasin"));
			runesImage[CharacterIndex.INDEX_FIGHTER] = new Image(atlas.getTexture("RuneBase_Fighter"));
			runesImage[CharacterIndex.INDEX_KNIGHT] = new Image(atlas.getTexture("RuneBase_Knight"));
			runesImage[CharacterIndex.INDEX_HERMIT] = new Image(atlas.getTexture("RuneBase_Hermit"));
			runesImage[CharacterIndex.INDEX_MAGE] = new Image(atlas.getTexture("RuneBase_Mage"));
			
			imageContainer = new Sprite();
			addChild(imageContainer);
			index = -1;
			random();
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onTouch(event:TouchEvent):void {
			var touch:Touch = event.getTouch(stage, TouchPhase.ENDED);
			if (touch) {
				next();
			}
		}
		
		protected override function removedFromStage(e:Event):void {
			super.removedFromStage(e);
			removeEventListeners(TouchEvent.TOUCH);
			removeAndDisposeChildren();
		}
		
		public function next():void {
			game.Manager.SFXSoundManager.play("click_button");
			if (Index + 1 >= CharacterIndex.INDEX_TOTAL) {
				Index = 0;
			} else {
				++Index;
			}
		}
		
		public function random():void {
			Index = CharacterIndex.random();
		}
		
		public function sendToServer():void {
			if (game.GameMode != GameModes.SINGLEPLAYER) {
				var data:Object = new Object();
				data.key = PacketHeader.game_set_rune;
				data.values = [ setIndex, index ];
				game.Manager.clientPacket.writeLine(data);
			}
		}
		
		public function get Index():int {
			return index;
		}
		
		public function set Index(idx:int):void {
			if (index != idx) {
				imageContainer.removeChildren(0, -1, true);
				imageContainer.addChild(runesImage[idx]);
				index = idx;
				board.chooseCharacterByIndex(setIndex, index);
				sendToServer();
			}
		}
	}

}